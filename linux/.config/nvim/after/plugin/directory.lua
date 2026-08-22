local api, fs, fn = vim.api, vim.fs, vim.fn

local icons = require("icons")
local myfs = require("fs")

local NS = vim.api.nvim_create_namespace("after.plugin.directory")

local _return_buf
local bring_me_back = function()
  if not _return_buf then return end
  vim.cmd.edit(_return_buf)
  _return_buf = nil
end

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
  _G.MiniPick.registry.find_file({}, {
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
on("FileType", group, { pattern = "directory" }, function(args)
  map("<C-e>", bring_me_back, { buf = args.buf, nowait = true })

  map("~",          "<Cmd>edit $HOME<CR>",   { buf = args.buf })
  map("<C-h>",      "<Plug>(nvim-dir-up)",   { buf = args.buf })
  map("<C-l>",      "<Plug>(nvim-dir-open)", { buf = args.buf })
  map("<CR>",       "<Plug>(nvim-dir-open)", { buf = args.buf })

  map("/", explorer_live, { buf = args.buf })

  local winid = api.nvim_get_current_win()
  -- NOTE: have to strip the trailing / so that i can get the tail i want
  local dir = api.nvim_buf_get_name(0):gsub("/$", "")
  local head, tail = fn.fnamemodify(fs.dirname(dir), ":~"), fs.basename(dir)
  local winbar = "%#Comment#" .. head .. (head == "/" and "" or "/") .. "%#Directory#" .. tail .. (tail == "" and "" or "/")
  vim.wo[winid].winbar = winbar
end)

local decorate_dir_buf = function(buf)
end

on("User", group, { pattern = "DirReadPost" }, function(args)
  local dir = vim.api.nvim_buf_get_name(args.buf)
  local extmark = function(lnum, text, hl, extmark_opts)
    api.nvim_buf_set_extmark(args.buf, NS, lnum-1, 0, {
      virt_text = {{ text, hl }},
      virt_text_pos = extmark_opts.virt_text_pos,
      virt_text_win_col = extmark_opts.virt_text_win_col,
      hl_mode = extmark_opts.hl_mode,
    })
  end
  api.nvim_buf_clear_namespace(args.buf, NS, 0, -1)

  local names = vim.api.nvim_buf_get_lines(args.buf, 0, -1, true)
  local name_col_width = vim.iter(names):fold({}, function(acc, name)
    acc.max = math.max(#name, acc.max or #name)
    return acc
  end).max
  local permissions_offset = math.max(8 + name_col_width + 4, 40)
  for lnum, name in ipairs(names) do
    local path = fs.joinpath(dir, name)
    local item = myfs.get_fs_info(path)
    local icon, icon_hl
    -- if item.type == "directory" then
    --   icon, icon_hl = icons.lsp_kinds.Folder .. " ", "Folder"
    -- else
      icon, icon_hl = icons.get(item.type, item.path)
    -- end
    extmark(lnum, ("%6s  "):format(item.size), "String", { virt_text_pos = "inline" })
    extmark(lnum, icon, icon_hl, { virt_text_pos = "inline" })
    extmark(lnum, item.permissions, "Number", { virt_text_win_col = permissions_offset, hl_mode="combine" })
    extmark(lnum, item.modified, "Comment", { virt_text_win_col = permissions_offset + 20, hl_mode="combine" })
  end
end)

