local api, fs, fn = vim.api, vim.fs, vim.fn
local dl = require("dirlist")

local _return_buf
local bring_me_back = function()
  if not _return_buf then return end
  if _return_buf == "" then _return_buf = nil; return end
  vim.cmd.edit(_return_buf)
  _return_buf = nil
end

map("<C-e>.", "<C-e><C-.>", { remap = true })
map("<C-e><C-.>", function()
  _return_buf = api.nvim_buf_get_name(0)
  return "<Plug>(nvim-dir-up)"
end, { expr = true, remap = true })

map("<C-e><C-h>", "<Cmd>topleft vsplit<CR><Plug>(nvim-dir-up)",  { remap = true })
map("<C-e><C-j>", "<Cmd>botright split<CR><Plug>(nvim-dir-up)",  { remap = true })
map("<C-e><C-k>", "<Cmd>topleft split<CR><Plug>(nvim-dir-up)",   { remap = true })
map("<C-e><C-l>", "<Cmd>botright vsplit<CR><Plug>(nvim-dir-up)", { remap = true })

local explorer_live = function()
  if not _G.MiniPick then return end
  local win = api.nvim_get_current_win()
  local lnum = api.nvim_win_get_cursor(win)[1]
  _G.MiniPick.registry.find_file({ sort = dl.default_sort, selected = lnum }, {
    mappings = {
      go_back = {
        char = "<C-e>",
        func = function() vim.schedule(bring_me_back); return true end
      },
    },
    window = {
      config = {
        anchor = "NW",
        border = { "", " ", "", "", "", "", "", "" },
        relative = "win",
        win = win,
        height = api.nvim_win_get_height(win) - 1,
        width = api.nvim_win_get_width(win),
        row = -1, col = 0,
      },
    }
  })
end

local group = api.nvim_create_augroup("plugin.directory", { clear = true })
on("FileType", group, { pattern = {"directory", "zip"} }, function(args)
  local bufnr = args.buf
  map("~",     "<Cmd>edit $HOME<CR>",   { buf = args.buf })
  map("<C-h>", "<Plug>(nvim-dir-up)",   { buf = args.buf })
  map("<C-l>", "<Plug>(nvim-dir-open)", { buf = args.buf })
  map("<CR>",  "<Plug>(nvim-dir-open)", { buf = args.buf })
  map("<C-e>", bring_me_back,           { buf = args.buf, nowait = true })
  map("/",     explorer_live,           { buf = args.buf })

  local winid = api.nvim_get_current_win()
  -- NOTE: have to strip the trailing / so that i can get the tail i want
  local dir = api.nvim_buf_get_name(0):gsub("/$", "")
  local head, tail = fn.fnamemodify(fs.dirname(dir), ":~"), fs.basename(dir)
  local winbar = string.format(
    " %%#Comment#%s%s%%#Directory#%s%s %%#Normal#",
    head,
    head == "/" and "" or "/",
    tail,
    tail == "" and "" or "/"
  )
  vim.wo[winid].winbar = winbar
  vim.wo[winid].winhl = "WinBar:NormalFloat"
  vim.wo[winid].number = false
  vim.wo[winid].relativenumber = false
  vim.wo[winid].statuscolumn = ""
end)

on("User", group, { pattern = "DirReadPost" }, function(args)
  if vim.bo[args.buf].filetype ~= "directory" then return end
  local dirname = vim.api.nvim_buf_get_name(args.buf)
  local items = dl.get_dirlist_items(dirname)
  dl.buf_set_dirlist(args.buf, { items = items })
end)
