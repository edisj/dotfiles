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
        "mfussenegger/nvim-jdtls",
        enabled = true,
        dependencies = { "mfussenegger/nvim-dap" },
    },
}
