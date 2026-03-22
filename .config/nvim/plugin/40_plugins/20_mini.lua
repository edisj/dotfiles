local autocmd = vim.api.nvim_create_autocmd

local function setup_mini_hipatterns()
  local hipatterns = require("mini.hipatterns")
  hipatterns.setup({
    highlighters = {
      -- Highlight standalone 'FIXME', 'HACK', 'TODO', 'NOTE'
      fixme = { pattern = '%f[%w]()FIXME()%f[%W]', group = 'MiniHipatternsFixme' },
      hack  = { pattern = '%f[%w]()HACK()%f[%W]',  group = 'MiniHipatternsHack'  },
      todo  = { pattern = '%f[%w]()TODO()%f[%W]',  group = 'MiniHipatternsTodo'  },
      note  = { pattern = '%f[%w]()NOTE()%f[%W]',  group = 'MiniHipatternsNote'  },

      -- Highlight hex color strings (`#rrggbb`) using that color
      hex_color = hipatterns.gen_highlighter.hex_color(),
    },
  })
  -- autocmd("ColorScheme", {
  --   callback = function(ev)
  --     _G.package.loaded["mini.hipatterns"] = nil
  --     setup_hipatterns()
  --   end
  -- })
end

local function setup_mini_clue()
  local clue = require("mini.clue")
  clue.setup({
    window = {
      config = function()
        return {
          anchor = "SW",
          col = 0.75 * vim.o.columns,
          width = "auto",
          -- width = 0.3 * vim.o.columns,
          border = { "🭽", "▔", "🭾", "▕", " ", " ", " ", "▏" },
        }
      end,
    },

    clues = {
      { mode = 'n', keys = '<Leader>e', desc = '+Edit' },
      { mode = 'n', keys = '<Leader>d', desc = '+Dap' },
      { mode = 'n', keys = '<Leader>f', desc = '+Fzf' },
      { mode = 'n', keys = '<Leader>g', desc = '+Git' },
      { mode = 'n', keys = '<Leader>l', desc = '+Lsp' },
      { mode = 'n', keys = '<Leader>s', desc = '+Session' },
      { mode = 'x', keys = '<Leader>g', desc = '+Git' },
      { mode = 'x', keys = '<Leader>l', desc = '+Lsp' },
      clue.gen_clues.g(),
      clue.gen_clues.z(),
      clue.gen_clues.marks(),
      clue.gen_clues.square_brackets(),
      clue.gen_clues.builtin_completion(),
      -- This creates a submode for window resize mappings. Try the following:
      -- - Press `<C-w>s` to make a window split.
      -- - Press `<C-w>+` to increase height. Clue window still shows clues as if
      --   `<C-w>` is pressed again. Keep pressing just `+` to increase height.
      --   Try pressing `-` to decrease height.
      -- - Stop submode either by `<Esc>` or by any key that is not in submode.
      clue.gen_clues.windows({ submode_resize = true }),
    },
    triggers = {
      { mode = { "n", "x" }, keys =  "<leader>" },
      { mode = { "n", "x" }, keys =  "[" },
      { mode = { "n", "x" }, keys =  "]" },
      { mode =   'i',        keys = '<C-x>' },
      { mode = { "n", "x" }, keys =  "g" },
      { mode = { "n", "x" }, keys =  "'" },
      { mode = { "n", "x" }, keys =  "`" },
      { mode = { "n", "x" }, keys =  '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },
      { mode = { 'n', 'x' }, keys = 's' },
      { mode = { 'n', 'x' }, keys = 'd' },
      { mode = { 'n', 'x' }, keys = 'z' },
    }
  })

end

local function setup_mini_pick()

  local function arglist_add(i)
    local ok, arglist = pcall(require, "arglist")
    if not ok then return end

    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end

    arglist.arglist[i] = vim.fn.fnamemodify(current, ":p")

    MiniPick.default_choose(current)
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

      scroll_down  = "<C-M-j>",
      scroll_left  = "<C-M-h>",
      scroll_right = "<C-M-l>",
      scroll_up    = "<C-M-k>",

      arglist_add_1 = { char = "<M-S-q>", func = function() arglist_add(1) end },
      arglist_add_2 = { char = "<M-S-w>", func = function() arglist_add(2) end },
      arglist_add_3 = { char = "<M-S-e>", func = function() arglist_add(3) end },
      arglist_add_4 = { char = "<M-S-u>", func = function() arglist_add(4) end },
      arglist_add_5 = { char = "<M-S-i>", func = function() arglist_add(5) end },
      arglist_add_6 = { char = "<M-S-o>", func = function() arglist_add(6) end },
    },
    options = {
      content_from_bottom = false,
      use_cache = true,
      hidden = true,
    },
    window = {
      config = {
        width = 50,
        height = 20,
        border = "solid",
      },
      -- prompt_caret = "▏",
      prompt_caret = "▎",
      prompt_prefix = "▶ ",
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
  -- NOTE: don't use mini.pick right now but keeping this around just in case
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
end

local function setup_mini_files()
  local mini_files = require("mini.files")

  mini_files.setup({
    mappings = { mark_goto = "<leader>" },
    windows = {
      width_nofocus = 10,
      width_focus = 40,
    },
  })

  autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(ev)
      vim.keymap.set({"n", "i", "x"}, "<C-s>", function()
        vim.cmd.stopinsert()
        mini_files.synchronize()
      end, { desc = "MiniFiles synchronize", buffer = ev.data.buf_id })
    end,
  })

  local set_mark = function(id, path, desc) MiniFiles.set_bookmark(id, path, { desc = desc }) end
  autocmd("User", {
    pattern = "MiniFilesExplorerOpen",
    callback = function()
      set_mark("c", vim.fn.stdpath("config") .. "/lua", "Config") -- path
      set_mark("w", vim.fn.getcwd, "Working directory") -- callable
      set_mark("~", "~", "Home directory")
    end,
  })

  autocmd('User', {
    pattern = 'MiniFilesWindowOpen',
    callback = function(ev)
      local win_id = ev.data.win_id
      local config = vim.api.nvim_win_get_config(win_id)
      config.border = {
        { "▁", "FloatBorderTransparent" },
        { "▁", "FloatBorderTransparent"},
        { "▁", "FloatBorderTransparent"  },
        { "🮇", "FloatBorder"  },
        { "▔", "FloatBorderTransparent"  },
        { "▔", "FloatBorderTransparent"  },
        { "▔", "FloatBorderTransparent"  },
        { "▎", "FloatBorder"  },
      }
      -- config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
      vim.api.nvim_win_set_config(win_id, config)
      vim.wo[win_id].scrolloff = 2
      vim.wo[win_id].sidescrolloff = 0
    end,
  })

  local ensure_center_layout = function(ev)
    local state = MiniFiles.get_explorer_state()
    if state == nil then return end

    -- Compute "depth offset" - how many windows are between this and focused
    local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match('^minifiles://%d+/(.*)$')
    local depth_this
    for i, path in ipairs(state.branch) do
      if path == path_this then depth_this = i end
    end
    if depth_this == nil then return end
    local depth_offset = depth_this - state.depth_focus

    local widths = { 40, 20, 10 }
    -- Adjust config of this event's window
    local i = math.abs(depth_offset) + 1
    local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
    win_config.width = i <= #widths and widths[i] or widths[#widths]

    win_config.zindex = 99
    win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
    local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
    for j = 1, math.abs(depth_offset) do
      -- widths[j+1] for the negative case because we don't want to add the center window's width
      local prev_win_width = (sign == -1 and widths[j+1]) or widths[j] or widths[#widths]
      -- Add an extra +2 each step to account for the border width
      local new_col = win_config.col + sign * (prev_win_width + 2)
      if (new_col < 0) or (new_col + win_config.width > vim.o.columns) then
        win_config.zindex = win_config.zindex - 1
        break
      end
      win_config.col = new_col
    end

    win_config.height = depth_offset == 0 and 22 or 18
    win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
    -- win_config.footer = { { tostring(depth_offset), "Normal" } }
    vim.api.nvim_win_set_config(ev.data.win_id, win_config)
  end

  autocmd("User", { pattern = "MiniFilesWindowUpdate", callback = ensure_center_layout })

  local function go_in_and_arglist(i)
    local path = (mini_files.get_fs_entry() or {}).path
    if path == nil then return vim.notify('Cursor is not on valid entry') end
    if vim.uv.fs_stat(path).type ~= "file" then return end
    Arglist.arglist[i] = vim.fn.fnamemodify(path, ":p")
    mini_files.go_in({ close_on_file = true })
  end
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(ev)
      local buf_id = ev.data.buf_id
      for i, key in ipairs({ "q", "w", "e", "u", "i", "o" }) do
        vim.keymap.set("n", "<M-S-" .. key .. ">", function() go_in_and_arglist(i) end, { buffer = buf_id })
      end
    end,
  })

  Config.map("n", "<C-e>", function()
    if not mini_files.close() then
      mini_files.open(vim.api.nvim_buf_get_name(0), false)
    end
  end, { desc = "MiniFiles toggle" })

end

local function setup_mini_cmdline()
  require("mini.cmdline").setup({
    autocomplete = { enable = false },
    autocorrect = {
      enable = true,
      -- func = function(...)
      --   local result = MiniCmdline.default_autocorrect_func(...)
      --   if result then
      -- HACK: feed a backspace -> space so that blink.cmp completion window
      -- pops up, otherwise it can't recognize the autocorrected result
      -- local bs = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
      -- local space = vim.api.nvim_replace_termcodes(" ", true, false, true)
      -- vim.api.nvim_feedkeys(bs .. space, "n", false)
      -- end
      -- return result
      -- end,
    },
    autopeek = {
      enable = true,
      n_context = 5,
    },
  })
end

Config.add({
  {
    src = "https://github.com/nvim-mini/mini.nvim",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("mini.extra").setup()
        require("mini.splitjoin").setup()
        require("mini.align").setup()
        require("mini.trailspace").setup()
        require("mini.operators").setup()
        require("mini.ai").setup()
        require("mini.icons").setup({
          default = {
            directory = { hl = "Folder" },
          },
          filetype = {
            c = { glyph = "" },
            java = { hl = "DiagnosticError" },
          },
        })
        require("mini.surround").setup({
          mappings = { add = "sp" },
          highlight_duration = 3000,
        })
        setup_mini_hipatterns()
        setup_mini_clue()
        setup_mini_files()
        setup_mini_cmdline()
        -- setup_mini_pick()
      end,
    },
  }
})
