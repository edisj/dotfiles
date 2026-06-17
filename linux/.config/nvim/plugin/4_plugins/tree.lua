Pack.add({
  "https://github.com/nvim-lua/plenary.nvim",
  "https://github.com/MunifTanjim/nui.nvim",
  {
    src = "https://github.com/nvim-neo-tree/neo-tree.nvim",
    version = vim.version.range("3"),
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("neo-tree").setup({
          sources = { "filesystem", "buffers", "git_status", "document_symbols" },

          default_component_configs = {
            indent = {
              with_markers = false,        -- drop the │ └ tree lines
              with_expanders = true,       -- show expander icons on directories
              -- expander_highlight = 'NeoTreeExpander',
            },
          },

          renderers = {
            file = {
              { "indent" },
              { "icon" },
              -- OMITTING: { "git_status" }
              { "name", use_git_status_colors = false },
              -- { "diagnostics" },
            },
            directory = {
              { "indent" },
              { "icon", default = "📁", zephyr_icon = "📁" },
              { "current_filter" },
              { "name", use_git_status_colors = false },
              -- { "icon" },
            }
          },

          event_handlers = {
            {
              event = 'neo_tree_buffer_enter',
              handler = function()
                vim.opt_local.statuscolumn = ""
                vim.opt_local.signcolumn = "no"
                vim.opt_local.number = false
                vim.opt_local.relativenumber = false
                vim.opt_local.fillchars:append("eob: ")
              end,
            },
          },
        })
      end,
    },
  },
  {
    src = "https://github.com/nvim-tree/nvim-tree.lua",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("nvim-tree").setup()
      end,
    }
  },
})
