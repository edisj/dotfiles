local nmap_leader = Config.nmap_leader
local nmap = Config.nmap
local _cmdheight_saved = vim.o.cmdheight

-- local _win_config = function()
--   local state = MiniPick.get_picker_state()
--   local is_preview = state ~= nil and state.buffers.preview == vim.api.nvim_win_get_buf(state.windows.main)
--   local is_info = state ~= nil and state.buffers.info == vim.api.nvim_win_get_buf(state.windows.main)
--   local preview_width = math.floor(0.45 * vim.o.columns)
--   local preview_height = math.floor(0.75 * vim.o.lines)
--
--   local main_height = math.floor(0.40 * vim.o.lines)
--   local main_width = math.floor(0.35 * vim.o.columns)
--
--   local width = is_preview and preview_width or main_width
--   local height = (is_preview or is_info) and preview_height or main_height
--
--   return { anchor = "NW", row = 0, col = 0, width = width, height = height }
-- end
--
-- -- Ensure that window is updated every time a new buffer is shown in it.
-- -- Schedule since state data is not yet updated when the buffer is shown.
-- local refresh_picker = vim.schedule_wrap(function()
--   if not MiniPick.is_picker_active() then return end
--   MiniPick.refresh()
-- end)
-- autocmd("BufWinEnter", { callback = refresh_picker })

local minibuffer_win_config = function()
  local cmd_win = require("vim._core.ui2").wins.cmd
  return {
    width = vim.api.nvim_win_get_width(cmd_win),
    -- height = vim.api.nvim_win_get_height(cmd_win) - 2,
    height = vim.g.minibuffer_height - 2,
    border = { "▔", "▔", "▔", " ", " ", " ", " ", " " },
    zindex = vim.api.nvim_win_get_config(cmd_win).zindex + 1,
    -- relative = "win",
    relative = "minibuffer",
    win = cmd_win,
  }
end

---@diagnostic disable-next-line: unused-function, unused-local
local function setup_mini_pick()

  local function arglist_add(k)
    -- local ok, arglist = pcall(require, "arglist")
    -- if not ok then return end
    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end

    MiniPick.default_choose(current)
    -- local file = vim.fn.fnamemodify(current, ":p")
    Arglist.set_key(k, current)
    MiniPick.stop()
  end

  require("mini.pick").setup({
    -- See `:h MiniPick-actions`.
    mappings = {
      move_down  = "<C-j>",
      move_start = "<C-g>",
      move_up    = "<C-k>",

      refine        = "<C-Space>",
      refine_marked = "<C-M-Space>",

      mark              = "<C-e>",
      mark_all          = "<C-a>",
      choose_marked     = "<C-q>",
      choose_in_split   = "<M-S-j>",
      choose_in_tabpage = "<C-t>",
      choose_in_vsplit  = "<M-S-l>",

      delete_left       = '',

      scroll_down  = "<C-d>",
      scroll_left  = "<C-h>",
      scroll_right = "<C-l>",
      scroll_up    = "<C-u>",

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
      -- config = minibuffer_win_config,
      config = {
        relative = "minibuffer",
        border = { "▔", "▔", "▔", " ", " ", " ", " ", " " },
      },
      -- prompt_prefix = " >>> ",
      -- prompt_prefix = " Pick >>> ",
      prompt_prefix = " Pick: ",
      prompt_caret = "▌",
      -- prompt_caret = "▎",
      -- prompt_caret = "🯏",
      -- prompt_caret ="█ ",
    },
  })
  require("mini.pick").registry.registry = function()
    local picker = require("mini.pick")
    local selected = picker.start({
      source = { items = vim.tbl_keys(picker.registry), name = "Registry" }
    })
    if selected == nil then return end
    return picker.registry[selected]()
  end

  local function setup_minibuffer()
    vim.cmd.mode()
    local cmd_win = require("vim._core.ui2").wins.cmd
    vim.o.cmdheight = vim.g.minibuffer_height
    local win = MiniPick.get_picker_state().windows.main
    Config.on("WinClosed", function()
      vim.schedule(function()
        vim.o.cmdheight = _cmdheight_saved
        -- vim.cmd.redraw()
      end)
    end, { pattern = tostring(win), once = true })
  end

  -- vim.api.nvim_create_autocmd("User", {
  --   pattern = "MiniPickStart",
  --   callback = vim.schedule_wrap(setup_minibuffer)
  -- })

  nmap("<C-f>", function() MiniPick.builtin.files() end, { desc = "Pick files" })
  nmap_leader("ff", function() MiniPick.registry.registry() end,   { desc = "registry" })
  nmap_leader("fh", function() MiniPick.builtin.help() end,        { desc = "helptags" })
  nmap_leader("fb", function() MiniPick.builtin.buffers() end,     { desc = "buffers" })
  nmap_leader("fr", function() MiniPick.builtin.resume() end,      { desc = "resume" })
  nmap_leader("/",  function() MiniPick.builtin.grep_live() end,   { desc = "grep live" })
  nmap_leader("fd", function() MiniExtra.pickers.diagnostic({scope="current"}) end, { desc = "diagnostics %" })
  nmap_leader("fD", function() MiniExtra.pickers.diagnostic() end, { desc = "diagnostics" })
  nmap_leader("fk", function() MiniExtra.pickers.keymaps() end,    { desc = "keymaps" })
  nmap_leader("fH", function() MiniExtra.pickers.hl_groups() end,  { desc = "highlights" })

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
end

Pack.load_on_loop(function() setup_mini_pick() end)("mini.pick")
