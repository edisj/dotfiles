local picker = {
  ui_select = false,
  layouts = {
    sidebar = {
      preview = "main",
      layout = {
        backdrop = false,
        width = 26,
        min_width = 20,
        height = function()
          return 20
        end,
        position = "left",
        -- border = "none",
        zindex=20,
        box = "vertical",
        {
          win = "input",
          height = 1,
          border = "rounded",
          title = "{title} {live} {flags}",
          title_pos = "center",
        },
        { win = "list", border = "none" },
        -- { win = "preview", title = "{preview}", height = 0.4, border = "top" },
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
      layout = {
        auto_hide = { "input" },
        layout = {
          width = 40,
          height = function() return 20 end,
        },
      },
    },
  },
}

local indent = {
  indent = { enabled = false, char = "▏" },
  scope = { enabled = false, only_current = false, char = "│" },
  animate = { enabled = false },
  chunk = {
    enabled = true,
    only_current = true,
    chunkwidth = 1,
    char = {
      corner_top = "┌",
      corner_bottom = "└",
      -- corner_top = "╭",
      -- corner_bottom = "╰",
      horizontal = "─",
      vertical = "│",
      arrow = "─",
    },
  },
}

pack.add({{
  src = "https://github.com/folke/snacks.nvim",
  data = {
    enable = true,
    defer = true,
    loader = function()
      require("snacks").setup({
        picker = picker,
        indent = indent,
        statuscolumn = {
          enabled = false,
          left = { "sign", "git"}, -- priority of signs on the left (high to low)
          right = { "fold" }, -- priority of signs on the right (high to low)
          folds = {
            open = false, -- show open fold icons
            git_hl = false, -- use Git Signs hl for fold icons
          },
          git = {
            -- patterns to match Git signs
            patterns = { "GitSign", "MiniDiffSign" },
          },
          refresh = 50, -- refresh at most every 50ms
        },
        bigfile = { enabled = false },
        image = { enabled = true },
      })
      map("<C-Tab>", function() Snacks.explorer() end, { desc = "Explorer" })
      map("<Leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
      map("<Leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
    end,
  },
}})
