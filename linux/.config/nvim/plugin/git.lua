pack.add({
  {
    src = "https://github.com/tpope/vim-fugitive",
    data = { enable = false, defer = true }
  },
  {
    src = "https://github.com/NeogitOrg/neogit",
    data = {
      enable = true,
      defer = true,
      loader = function()
        require("neogit").setup({
          disable_hint = true,
          graph_style = "kitty",
          integrations = { mini_pick = true },
          popup = { kind = "split", show_title = true },
          -- commit_view = { kind = "split_above_all" },
          -- commit_editor = { kind = "split_above_all" },
          -- preview_buffer = { kind = "split_above_all", show_title = true },
          kind = "split_below_all",
          floating = {
            relative = "editor",
            width = 0.8,
            height = 0.7,
            style = "minimal",
            border = "rounded",
          },
        })
      end
    }
  },
  {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    data = {
      enable = true,
      event = { "BufReadPre", "BufReadPost" },
      loader = function()
        require("gitsigns").setup({
          signcolumn = true,
          signs = {
            add = { text = "+" },
            change = { text = "·" },
            -- change = { text = "~" },
            delete = { text = "-" },
            topdelete = { text = "-" },
            changedelete = { text = "·" },
            untracked = { text = "?" },
          },
        })
        map("<Leader>tg", "<Cmd>Gitsigns toggle_signs<CR>", { desc = "gitsigns" })
      end,
    },
  },
})
