return {
    {
        "OXY2DEV/markview.nvim",
        enabled = false,
        lazy = false,
        priority = 49,
        ft = { "markdown", "help", "quarto", "ipynb" },
        opts = {
            -- modes = { "n", "i", "c" },
            modes = { "n" },
            code_blocks = {
                enable = true,
                style = "simple",

                hl = "Layer2",

                min_width = 80,
                pad_amount = 2,
                language_names = {
                    { "py", "python" },
                },
                language_direction = "right",
                sign = true,
                sign_hl = nil,
            },
        },
    },
    {
        "MeanderingProgrammer/markdown.nvim",
        enabled = false,
        name = "render-markdown",
        ft = { "markdown", "help", "quarto", "ipynb", },
        dependencies = {
            "nvim-treesitter/nvim-treesitter",
            "nvim-mini/mini.icons",
        },
        opts = {
            render_modes = { "n", "c", "i", },
            code = {
                -- Turn on / off code block & inline code rendering
                enabled = true,

                -- Turn on / off any sign column related rendering
                sign = true,
                -- Determines how code blocks & inline code are rendered:
                --  none: disables all rendering
                --  normal: adds highlight group to code blocks & inline code, adds padding to code blocks
                --  language: adds language icon to sign column if enabled and icon + name above code blocks
                --  full: normal + language
                style = "full",
                -- Amount of padding to add to the left of code blocks
                left_pad = 2,
                -- Determins how the top / bottom of code block are rendered:
                --  thick: use the same highlight as the code body
                --  thin: when lines are empty overlay the above & below icons
                border = "thick",
                -- Used above code blocks for thin border
                above = "▄",
                -- Used below code blocks for thin border
                below = "▀",
                -- Highlight for code blocks & inline code
                highlight = "RenderMarkdownCode",
            },
        },
    }
}
