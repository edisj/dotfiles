pack.add({
  {
    src = "https://github.com/nvim-tree/nvim-tree.lua",
    data = {
      enable = false,
      loader = function()
        require("nvim-tree").setup({
          hijack_netrw = false,
          update_focused_file = {
            enable = true,
            update_root = { enable = false },
          },
          sync_root_with_cwd = true,
          view = {
            width = {
              min = "10%",
              max = "25%",
              padding = 1
            },
            signcolumn = "no",
            number = false,
          },
          renderer = {
            icons = {
              show = {
                git = false,
                modified = false,
                file = true,
                folder = true,
                folder_arrow = false,
              },
            },
            indent_markers = {
              enable = true,
              inline_arrows = true,
              icons = {
                corner = "└",
                edge = "│",
                item = "├",
                bottom = "─",
                none = " ",
              },
            },

          },
        })
        map("<C-`>", function()
          require("nvim-tree.api").tree.toggle {
            focus = false,
          }
        end, { desc ="tree toggle" })

        on("BufWinEnter", nil, { pattern = "NvimTree*" }, function()
          vim.opt_local.fillchars:append("eob: ")
          vim.wo[0][0].winpinned = true
        end)
      end,
    }
  },
})
