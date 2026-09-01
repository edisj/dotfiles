vim.g.diffs = {
  integrations = {
    neogit = true, gitsigns = true,
  }
}
pack.add({
  {
    src = "https://github.com/tpope/vim-fugitive",
    data = { enable = false, defer = true }
  },
  {
    src = "https://github.com/barrettruth/diffs.nvim",
    data = { enable = true },
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
          integrations = { mini_pick = true, diffview = true },
          -- diffviewer = "diffview",
          popup = { kind = "split", show_title = true },
          -- commit_view = { kind = "split_above_all" },
          -- commit_editor = { kind = "split_above_all" },
          -- preview_buffer = { kind = "split_above_all", show_title = true },
          kind = "tab",
          status = {
            show_head_commit_hash = true,
            recent_commit_count = 30,
            HEAD_padding = 10,
            HEAD_folded = true,
            mode_padding = 3,
            mode_text = {
              M = "modified",
              N = "new file",
              A = "added",
              D = "deleted",
              C = "copied",
              U = "updated",
              R = "renamed",
              T = "changed",
              DD = "unmerged",
              AU = "unmerged",
              UD = "unmerged",
              UA = "unmerged",
              DU = "unmerged",
              AA = "unmerged",
              UU = "unmerged",
              ["?"] = "",
            },
          },
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
          signcolumn = false,
          signs = {
            change       = { text = "▏" },
            add          = { text = "▏" },
            delete       = { text = "▏" },
            topdelete    = { text = "▏" },
            changedelete = { text = "▏" },
            untracked    = { text = "?" },
          },
          signs_staged = {
            change       = { text = "▏" },
            add          = { text = "▏" },
            delete       = { text = "▏" },
            topdelete    = { text = "▏" },
            changedelete = { text = "▏" },
            untracked    = { text = "?" },
          },
        })
        map("<Leader>tg", "<Cmd>Gitsigns toggle_signs<CR>", { desc = "gitsigns" })
      end,
    },
  },
  {
    src = "https://github.com/dlyongemallo/diffview-plus.nvim",
    data = { enable = false },
  }
})
