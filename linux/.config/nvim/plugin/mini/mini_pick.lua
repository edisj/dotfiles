-- local _win_config = function()
--   local state = require("mini.pick").get_picker_state()
--   local is_preview = state ~= nil and state.buffers.preview == vim.api.nvim_win_get_buf(state.windows.main)
--   local is_info = state ~= nil and state.buffers.info == vim.api.nvim_win_get_buf(state.windows.main)
--   local preview_height = math.floor(0.80 * vim.o.lines)
--   local preview_width = math.floor(0.50 * vim.o.columns)
--   local main_height = math.floor(0.45 * vim.o.lines)
--   local main_width = math.floor(0.40 * vim.o.columns)
--   main_height = 20
--   main_width = 50
--   local width = is_preview and preview_width or main_width
--   local height = (is_preview or is_info) and preview_height or main_height
--   return {
--     relative = "laststatus",
--     anchor = "SW",
--     row = 0,
--     col = 2,
--     width = width,
--     height = height,
--     -- border = "bold",
--   }
-- end
-- local refresh_picker = vim.schedule_wrap(function()
--   if not require("mini.pick").is_picker_active() then return end
--   require("mini.pick").refresh()
-- end)
-- vim.api.nvim_create_autocmd("BufWinEnter", { callback = refresh_picker })

local ui_select = vim.ui.select
local function setup_mini_pick()

  local mappings = {
    move_down  = "<C-n>",
    move_up    = "<C-p>",
    move_start = "<C-g>",

    refine        = "<M-CR>",
    refine_marked = "<C-CR>",

    mark              = "<C-x>",
    mark_all          = "<C-a>",
    choose_marked     = "<C-q>",
    choose_in_split   = "<M-S-j>",
    choose_in_vsplit  = "<M-S-l>",
    choose_in_tabpage = "<C-t>",

    delete_left       = "<C-u>",

    toggle_info    = "<C-h>",
    toggle_preview = "<C-Tab>",

    scroll_left  = "<M-h>",
    scroll_down  = "<C-j>",
    scroll_up    = "<C-k>",
    scroll_right = "<M-l>",

    -- test3 = { char = "<C-\\>", func = function()
    --   require("vim._core.ui2.messages").show_msg("msgarea", "", {{0, "a\nb\nc", 0 }})
    -- end},
    -- test2 = { char = "<C-o>", func = function() vim.print(require("vim._core.ui2").wins) end },
    expand = { char = "<C-space>", func = function()
      if not package.loaded["msgarea"] then return end
      local view = require("msgarea.view")
      local eph = view.state.windows.ephemeral
      local bigger = math.floor(2/3 * vim.o.lines)
      eph._height, eph.height = eph.height, eph._height or bigger
      view.show{silent = true}
      -- MiniPick.refresh()
    end},
  }

  local function arglist_add(k)
    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end
    MiniPick.default_choose(current)
    arglist.add(k, current)
    MiniPick.stop()
  end
  for _, k in ipairs(arglist.keys()) do
    local lhs = "<M-S-" .. k .. ">"
    mappings["arglist_add_" .. k] = { char = lhs, func = function() arglist_add(k) end }
  end


  local centered = function()
    local h = math.floor(0.8*vim.o.lines)
    local w = math.floor(0.8*vim.o.columns)
    return {
      relative = "editor", anchor = "NW",
      border = "bold",
      height = h, width = w,
      row = 0.5 * ( vim.o.lines - h -2 ),
      col = 0.5 * ( vim.o.columns - w-2 ),
    }
  end

  require("mini.pick").setup({
    -- See `:h MiniPick-actions`.
    mappings = mappings,
    options = {
      content_from_bottom = false,
      use_cache = true,
      hidden = true,
    },
    window = {
      config = centered,
      prompt_prefix = ">>> ",
      -- prompt_caret = "▎",
      prompt_caret = "🯏",
      -- prompt_caret = "▌",
    },
  })
  vim.ui.select = ui_select

  MiniPick.registry["registry"] = require("pickers.registry")
  MiniPick.registry["find_file"] = require("pickers.find-file")
  MiniPick.registry["grep_live"] = require("pickers.grep-live")
  MiniPick.registry["buf_lines_current"] = require("pickers.buf-lines-current")
  MiniPick.registry["buf_lines"] = require("pickers.buf-lines")

  local fmap = function(key, desc, rhs)
    map("<C-f>" .. key, rhs, { desc = desc })
  end


  local win_cfg = function()
    return {
      relative = package.loaded["msgarea"] and "msgarea" or nil,
      height = math.floor(1/3 * vim.o.lines),
      -- border = { " ", " ", " ", "", "", "", "", "" },
      border = { "", " ", "", "", "", " ", "", "" },
    }
  end
  local msgarea_opts = { window = { config = win_cfg } }

  map("<C-e><C-/>", function() MiniPick.registry.find_file({ dir = vim.fn.expand("%:p:h") }, msgarea_opts) end)
  fmap("<C-o>", "files (cwd)", function() MiniPick.registry.find_file() end)
  fmap("<C-f>", "registry", function() MiniPick.registry.registry() end)
  fmap("<C-h>", "helptags", function() MiniPick.builtin.help(nil, msgarea_opts) end)
  fmap("<C-b>", "buffers", function() MiniPick.builtin.buffers(nil, msgarea_opts) end)
  map("<Leader>fd", function() MiniExtra.pickers.diagnostic({scope="current"}) end, { desc = "diagnostics %" })
  map("<Leader>fD", function() MiniExtra.pickers.diagnostic() end, { desc = "diagnostics" })
  map("<Leader>fk", function() MiniExtra.pickers.keymaps() end,    { desc = "keymaps" })
  map("<Leader>fH", function() MiniExtra.pickers.hl_groups() end,  { desc = "highlights" })

  map("<C-/>", function() MiniPick.registry.grep_live({ show_header = true, group_by = "fname" }, msgarea_opts) end)
  -- map("<C-_>", function() MiniPick.registry.grep_live({ show_header = true, group_by = "fname" }, msgarea_opts) end)
  map("<M-/>", function() MiniPick.registry.buf_lines({ scope = "current", show_header = false }, msgarea_opts) end)
  map("<C-M-/>", function() MiniPick.registry.buf_lines({ show_header = true }, msgarea_opts) end)

  fmap("<C-.>", "files", function()
    local cwd = vim.fn.getcwd(-1, -1, -1)
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(cwd, ":~")
    local prompt_prefix = " Find (file): " .. path .. "/"
    MiniPick.builtin.files({}, {
      source = { cwd = cwd },
      window = { prompt_prefix = prompt_prefix, config = win_cfg },
    })
  end)

  -- map("<C-space>", "<Cmd>Pick files<CR>")
  map("<M-space>", function()
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(cwd, ":~")
    MiniPick.builtin.files({}, {

      mappings = {
        close_ = { char = "<M-space>", func = function() return true end },
      },
      source = {
        show = function(buf_id, items_arr, query)
          require("mini.pick").default_show(buf_id, items_arr, query, { show_icons = true } )
          -- local lines = vim.tbl_map(function(x) return 'Item: ' .. x end, items_arr)
          -- vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
        end
      },
      window = { prompt_prefix = " Find: " .. path .. "/", config = win_cfg }
    }) end, { desc = "Pick files" })
  map("<leader><leader>", function() MiniPick.builtin.resume() end)

  fmap("<C-n>", "config", function()
    local cwd = vim.fn.stdpath("config")
    local prefix = " " .. vim.fn.fnamemodify(cwd, ":~") .. "/"
    local opts = {
      source = { cwd = cwd },
      window = { prompt_prefix = prefix, config = win_cfg },
    }
    MiniPick.builtin.files(nil, opts)
  end)

  fmap("<C-r>", "runtime", function()
    local opts = { source = { cwd = vim.fn.expand("$VIMRUNTIME").."/lua" }, window = { config = win_cfg } }
    MiniPick.builtin.files(nil, opts)
  end)

  local function pp(picker)
    local packroot = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    local prefix = " opt/**/lua/"
    local opts = {
      source = {
        cwd = packroot,
        name = "Pack",
        command = "fd",
        args = { "-e", "lua", "-p", ".*/lua/" }
      },
      window = { prompt_prefix = prefix, config = win_cfg },
    }
    MiniPick.builtin[picker](nil, opts)
  end
  fmap("<C-p>", "packages", function() pp("files") end)
  map("<Leader>fP", function() pp("grep_live") end, { desc = "grep packs" })
end

pack.gen_loop_loader(setup_mini_pick)("mini.pick")
