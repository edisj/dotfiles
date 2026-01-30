return {
    -- Useful plugin to show you pending keybinds.
    "folke/which-key.nvim",
    event = "VeryLazy",
    opts = {
        preset = "modern",
        delay = function(ctx)
            return ctx.plugin and 0 or 1000
        end,
        win = {
            border = "bold",
            padding = { 1, 0 },
            wo = {
                winblend = 10,
            },
        },
        plugins = {
            marks = false,
            registers = false,
        },
    },
    keys = {
        {
            "<leader>?",
            function()
                require("which-key").show({ global = false })
            end,
            desc = "WhichKey"
        },
    },
}
