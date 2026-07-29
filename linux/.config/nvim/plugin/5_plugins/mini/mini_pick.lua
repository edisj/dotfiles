local nmap_leader = Config.nmap_leader
local nmap = Config.nmap

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

local function setup_mini_pick()

  local function arglist_add(k)
    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end
    MiniPick.default_choose(current)
    Arglist.set_key(k, current)
    MiniPick.stop()
  end

  require("mini.pick").setup({
    -- See `:h MiniPick-actions`.
    mappings = {
      move_down  = "<C-n>",
      move_start = "<C-g>",
      move_up    = "<C-p>",

      refine        = "<C-Space>",
      refine_marked = "<C-M-Space>",

      mark              = "<C-e>",
      mark_all          = "<C-a>",
      choose_marked     = "<C-q>",
      choose_in_split   = "<M-S-j>",
      choose_in_tabpage = "<C-t>",
      choose_in_vsplit  = "<M-S-l>",

      delete_left       = "<C-u>",

      toggle_info    = "<C-h>",
      toggle_preview = "<C-Tab>",

      scroll_down  = "<C-j>",
      scroll_left  = "<M-h>",
      scroll_right = "<M-l>",
      scroll_up    = "<C-k>",

      close_ = { char = "<C-f>", func = function() return true end },
      arglist_add_q = { char = "<M-S-q>", func = function() arglist_add("q") end },
      arglist_add_w = { char = "<M-S-w>", func = function() arglist_add("w") end },
      arglist_add_e = { char = "<M-S-e>", func = function() arglist_add("e") end },
      arglist_add_r = { char = "<M-S-r>", func = function() arglist_add("r") end },
      arglist_add_s = { char = "<M-S-s>", func = function() arglist_add("s") end },
      arglist_add_d = { char = "<M-S-d>", func = function() arglist_add("d") end },
      arglist_add_f = { char = "<M-S-f>", func = function() arglist_add("f") end },
    },
    options = {
      content_from_bottom = false,
      use_cache = true,
      hidden = true,
    },
    window = {
      config = {
        relative = package.loaded["msgarea"] and "msgarea" or nil,
        -- border = { "▔", "▔", "▔", " ", " ", " ", " ", " " },
        border = { " ", " ", " ", " ", " ", " ", " ", " " },
        height = 12,
      },
      prompt_prefix = ">>> ",
      -- prompt_caret = "▎",
      prompt_caret = "🯏",
      -- prompt_caret = "▌",
    },
  })

  MiniPick.registry["registry"] = require("pickers.registry")
  MiniPick.registry["find_file"] = require("pickers.find-file")

  nmap("<C-f><C-f>", function() MiniPick.registry.find_file() end)
  nmap("<C-f><C-.>", function() MiniPick.registry.find_file({ dir = vim.fn.expand("%:p:h") }) end)
  nmap("<C-f>~", function() MiniPick.registry.find_file({ dir = vim.fn.expand("~") }) end)

  nmap("<C-f><C-o>", function()
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(cwd, ":~")
    MiniPick.builtin.files({}, {
      source = {
        show = function(buf_id, items_arr, query)
          require("mini.pick").default_show(buf_id, items_arr, query, { show_icons = true } )
          -- local lines = vim.tbl_map(function(x) return 'Item: ' .. x end, items_arr)
          -- vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
        end
      },
      window = { prompt_prefix = " Find: " .. path .. "/" }
    }) end, { desc = "Pick files" })
  nmap_leader("ff", function() MiniPick.registry.registry() end,   { desc = "registry" })
  nmap_leader("fh", function() MiniPick.builtin.help() end,        { desc = "helptags" })
  nmap_leader("fb", function() MiniPick.builtin.buffers() end,     { desc = "buffers" })
  nmap_leader("fr", function() MiniPick.builtin.resume() end,      { desc = "resume" })
  nmap_leader("/",  function() MiniPick.builtin.grep_live() end,   { desc = "grep live" })
  nmap_leader("fd", function() MiniExtra.pickers.diagnostic({scope="current"}) end, { desc = "diagnostics %" })
  nmap_leader("fD", function() MiniExtra.pickers.diagnostic() end, { desc = "diagnostics" })
  nmap_leader("fk", function() MiniExtra.pickers.keymaps() end,    { desc = "keymaps" })
  nmap_leader("fH", function() MiniExtra.pickers.hl_groups() end,  { desc = "highlights" })

  nmap("<leader><leader>", function() MiniPick.builtin.resume() end)

  nmap_leader("fc", function()
    local cwd = vim.fn.stdpath("config")
    local prefix = " " .. vim.fn.fnamemodify(cwd, ":~") .. "/"
    local opts = {
      source = { cwd = cwd },
      window = { prompt_prefix = prefix },
    }
    MiniPick.builtin.files(nil, opts)
  end, { desc = "config" })

  nmap_leader("fv", function()
    local opts = { source = { cwd = vim.fn.expand("$VIMRUNTIME").."/lua" } }
    MiniPick.builtin.files(nil, opts)
  end, { desc = "runtime" })

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
      window = { prompt_prefix = prefix },
    }
    MiniPick.builtin[picker](nil, opts)
  end
  nmap_leader("fp", function() pp("files") end, { desc = "find pack" })
  nmap_leader("fP", function() pp("grep_live") end, { desc = "grep packs" })

  ---@class MiniPick.Source
  ---@field items? any[]|fun(...):any  Array of items, or callable that sets them async
  ---@field name? string  Shown in the border
  ---@field cwd? string  Directory paths resolve against
  ---@field match? fun(stritems: string[], inds: integer[], query: string[]): integer[]?
  ---@field show? fun(buf_id: integer, items_arr: any[], query: string[])
  ---@field preview? fun(buf_id: integer, item: any)
  ---@field choose? fun(item: any): any?  Truthy return keeps picker open
  ---@field choose_marked? fun(items_arr: any[]): any?

end

Pack.load_on_loop(setup_mini_pick)("mini.pick")
