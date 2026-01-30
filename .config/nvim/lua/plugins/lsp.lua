return {
    -- `lazydev` configures Lua LSP for your Neovim config, runtime and plugins
    -- used for completion, annotations and signatures of Neovim apis
    {
        "folke/lazydev.nvim",
        ft = "lua",
        dependencies = {
            { "Bilal2453/luvit-meta", lazy = true },
            { "DrKJeff16/wezterm-types", lazy = true, version = false },
        },
        opts = {
            library = {
                -- "nvim-dap-ui",
                -- See the configuration section for more details
                -- Load luvit types when the `vim.uv` word is found
                { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                { path = 'wezterm-types', mods = { 'wezterm' } },
            },
        },
    },
    {
        "neovim/nvim-lspconfig",
        event = { "BufReadPost", "BufNewFile", "BufWritePre" },
        dependencies = {
            { "j-hui/fidget.nvim", opts = {} },
        },
        config = function()
            vim.diagnostic.config({
                signs = true,
                virtual_text = true,
            })
            vim.api.nvim_create_autocmd("LspAttach", {
                group = vim.api.nvim_create_augroup("lsp_attach", { clear = true }),
                callback = function(event)

                    local map = function(mode, lhs, rhs, desc)
                        vim.keymap.set(mode, lhs, rhs, {
                            buffer = event.buf, silent = true, desc = desc,
                        })
                    end

                    local client = vim.lsp.get_client_by_id(event.data.client_id)
                    assert(client, "LSP client not found")

                    ---@diagnostic disable-next-line: inject-field
                    client.server_capabilities.document_formatting = true

                    -- stylua: ignore
                    map("n", "K",          vim.lsp.buf.hover, "LSP: Hover")
                    -- map("i", "<C-h>",      vim.lsp.buf.signature_help, "LSP: Signature Help")
                    map("n", "<leader>rn", vim.lsp.buf.rename, "LSP: Rename")
                    map("n", "<leader>ca", vim.lsp.buf.code_action, "LSP: Code Action")
                    map("n", "gD",         vim.lsp.buf.declaration, "LSP: goto Declaration" )
                end,
            })
        end,
    },

    {
        "mfussenegger/nvim-jdtls",
        enabled = false,
        dependencies = { "mfussenegger/nvim-dap" },
    },
}
