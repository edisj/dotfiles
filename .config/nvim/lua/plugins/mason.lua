local function get_lsp_configs()
    local path = vim.fn.stdpath("config") .. "/lsp"
    local lsp_configs = vim.fn.readdir(path)
    return vim.tbl_map(function(filename)
        return filename:match("(.+)%.%a+$")
    end, lsp_configs)
end

return {
    -- Mason is essentially a package manager for LSP servers and tools
    {
        "mason-org/mason.nvim",
        cmd = "Mason",
        build = ":MasonUpdate",
        event = "VeryLazy",
        keys = { { "<leader>M", "<Cmd>Mason<CR>", desc = "Open Mason" } },
        opts = {
            ui = {
                width = 0.85,
                height = 0.80,
                border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
            },
        },
        config = function(_, opts)
            require("mason").setup(opts)

            -- see https://www.reddit.com/r/neovim/comments/1p1y73n/automatically_downloading_and_installing_lsps/
            local ensure_installed = {
                "lua-language-server",
                "stylua",
                "basedpyright",
                "black",
                "debugpy",
                "jdtls",
                "bash-language-server",
            }

            local already_installed = require("mason-registry").get_installed_package_names()

            for _, pack in ipairs(ensure_installed) do
                if not vim.tbl_contains(already_installed, pack) then
                    vim.cmd("MasonInstall " .. pack)
                end
            end

            local installed_packages = require("mason-registry").get_installed_packages()
            local installed_lsps = vim.iter(installed_packages):fold({}, function(acc, pack)
                table.insert(acc, pack.spec.neovim and pack.spec.neovim.lspconfig)
                return acc
            end)

            vim.lsp.enable(installed_lsps)
        end,
    },

    -- -- mason-lspconfig can only install lsps,
    -- -- mason-nvim-dap can only install daps,
    -- -- so this plugin handles installing lsp servers, daps, and formatters
    -- {
    --     "WhoIsSethDaniel/mason-tool-installer.nvim",
    --     -- for some reason this plugin doesn't install
    --     -- anything when it's lazy loaded
    --     -- event = "VeryLazy",
    --     dependencies = {
    --         "neovim/nvim-lspconfig",
    --         "mason-org/mason.nvim",
    --         { "mason-org/mason-lspconfig.nvim", opts = {} },
    --     },
    --     opts = {
    --         ensure_installed = {
    --             -- "bashls",
    --             "debugpy",
    --             "java-debug-adapter",
    --             -- "local-lua-debugger-vscode",
    --             "stylua",
    --             "black",
    --         },
    --         auto_update = true,
    --     },
    --     config = function(_, opts)
    --
    --         local lsp_configs = get_lsp_configs() or {}
    --         for _, key in ipairs(lsp_configs) do
    --             if not vim.list_contains(opts.ensure_installed, key) then
    --                 table.insert(opts.ensure_installed, key)
    --             end
    --         end
    --
    --         -- vim.print(opts.ensure_installed)
    --         require("mason-tool-installer").setup({
    --             ensure_installed = opts.ensure_installed
    --         })
    --
    --     end
    -- },
}
