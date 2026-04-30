local picker = {
  ui_select = false,
  layouts = {
    sidebar = {
      preview = "main",
      layout = {
        backdrop = false,
        width = 26,
        min_width = 20,
        height = vim.o.lines - 3,
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

local indent = {
  indent = { enabled = false, char = "▏" },
  scope = { enabled = false, only_current = true, char = "▏" },
  animate = { enabled = false },
  chunk = {
    enabled = true,
    only_current = true,
    char = {
      -- corner_top = "┌",
      -- corner_bottom = "└",
      corner_top = "╭",
      corner_bottom = "╰",
      horizontal = "─",
      vertical = "│",
      arrow = "─",
    },
  },
}

local nmap = function(...) Config.map("n", ...) end
local nmap_leader = function(lhs, ...) Config.map("n", "<leader>" .. lhs, ...) end
Pack.add({{
  src = "https://github.com/folke/snacks.nvim",
  data = {
    enabled = true,
    loader = Pack.load_on_loop(function(name)
      vim.cmd.packadd(name)
      require("snacks").setup({
        picker = picker,
        indent = indent,
        bigfile = { enabled = false },
        image = { enabled = true },
      })
      nmap("<C-Tab>", function() Snacks.explorer() end, { desc = "Explorer" })
      nmap_leader(".", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
      nmap_leader("S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
    end),
  },
}})
