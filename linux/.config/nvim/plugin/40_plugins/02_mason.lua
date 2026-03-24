Config.add({
  {
    src = "https://github.com/j-hui/fidget.nvim",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("fidget").setup()
      end
    },
  },
  {
    src = "https://github.com/mason-org/mason.nvim",
    data = {
      enabled = true,
      loader = Config.on_event("UIEnter", function(name)
        vim.cmd.packadd(name)
        require("mason").setup({
          ui = {
            width = 0.60,
            height = 0.60,
            border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
          },
        })

        -- https://www.reddit.com/r/neovim/comments/1p1y73n/automatically_downloading_and_installing_lsps/
        local ensure_installed = {
          "lua-language-server",
          "stylua",
          "basedpyright",
          "black",
          "debugpy",
          "java-debug-adapter",
          "jdtls",
          "bash-language-server",
          "hyprls",
          "codelldb",
          "clangd",
        }

        local already_installed = require("mason-registry").get_installed_package_names()

        for _, pack in ipairs(ensure_installed) do
          if not vim.tbl_contains(already_installed, pack) then
            vim.cmd("MasonInstall " .. pack)
          end
        end

        local auto_enable = {
          "lua_ls",
          "bashls",
          "basedpyright",
          "hyprls",
          "clangd",
        }
        vim.lsp.enable(auto_enable)

        vim.keymap.set("n", "<leader>M", "<Cmd>Mason<CR>", { desc = "Open Mason" })

      end)
    }
  }
})
