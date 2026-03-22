local styles = { dashboard = { wo = { fillchars = "eob: " } } }

local dashboard = {}
dashboard.preset = {
  pick = "fzf-lua",
  keys = {
    { icon = " ", key = "f", desc = "fzf files",    action = ":FzfLua files" },
    { icon = " ", key = "n", desc = "new file",     action = ":ene | startinsert" },
    { icon = " ", key = "g", desc = "live grep",    action = ":lua Snacks.dashboard.pick('live_grep')" },
    { icon = " ", key = "r", desc = "recent files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
    { icon = " ", key = "c", desc = "config",       action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
    { icon = " ", key = "s", desc = "last session", action = ":lua Session.last()" },
    { icon = " ", key = "q", desc = "quit",         action = ":qa" },
  }
}
dashboard.sections = {
  { section = "header" },
  { icon = "󰌓", title = "Keymaps", section = "keys", indent = 2, padding = 1 },
  { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
  { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
  -- { section = "terminal", cmd = "colorscript -e square", height = 5, padding = 1 },
  {
    pane = 1,
    icon = " ",
    title = "Git Status",
    section = "terminal",
    enabled = function() return Snacks.git.get_root() ~= nil end,
    padding = 1,
    ttl = 5 * 60,
    indent = 3,
    cmd = "git --no-pager diff --stat -B -M -C",
    -- cmd = "git status --short --branch --renames",
    height = 5,
  },
}

local scroll = {
  enabled = false,
  animate = {
    easing = "outQuart",
    -- easing = "inOutQuart",
  },
}

local picker = {
  layouts = {
    sidebar = {
      preview = "main",
      layout = {
        backdrop = false,
        width = 26,
        min_width = 20,
        height = 0,
        position = "left",
        border = "none",
        box = "vertical",
        {
          win = "input",
          height = 1,
          border = "rounded",
          title = "{title} {live} {flags}",
          title_pos = "center",
        },
        { win = "list", border = "none" },
        { win = "preview", title = "{preview}", height = 0.4, border = "top" },
      },
    }
  },
  sources = {
    ---@type snacks.picker.explorer.Config
    explorer = {
      hidden = true,
      diagnostics = false,
      diagnostics_open = false,
      git_status = false,
      git_untracked = false,
      git_status_open = false,
    },
  },
}

Config.add({{
  src = "https://github.com/folke/snacks.nvim",
  data = {
    enabled = true,
    loader = function(name)
      vim.cmd.packadd(name)
      require("snacks").setup({
        styles = styles,
        dashboard = dashboard,
        scroll = scroll,
        picker = picker,
        bigfile = { enabled = true },
        indent = { enabled = false },
        debug = { enabled = false },
        image = { enabled = true },
        lazygit = { enabled = false },
        notifier = { enabled = true },
        quickfile = { enabled = false },
      })

      Config.map("n", "<C-`>", function() Snacks.explorer() end, { desc = "Explorer" })
      Config.map("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
      Config.map("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
    end,
  },
}})
