return {
    { "folke/tokyonight.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    config = function()
        require("tokyonight").setup()
        vim.cmd("colorscheme tokyonight")
    end
},
    { "rebelot/kanagawa.nvim",
    enabled = false,
    lazy = false,
    priority = 1000,
    opts = {
        compile = true,             -- enable compiling the colorscheme
        undercurl = true,            -- enable undercurls
        commentStyle = { italic = false },
        functionStyle = {},
        keywordStyle = { italic = false },
        statementStyle = { bold = true },
        typeStyle = {},
        transparent = true,         -- do not set background color
        dimInactive = true,         -- dim inactive window `:h hl-NormalNC`
        terminalColors = true,       -- define vim.g.terminal_color_{0,17}
        colors = {                   -- add/modify theme and palette colors
            palette = {},
            theme = {
                all = {
                    ui = {
                        -- bg_gutter = "none",
                    },
                },
            },
        },
        overrides = function(colors) -- add/modify highlights
            return {}
        end,
        theme = "wave",              -- Load "wave" theme
        background = {               -- map the value of 'background' option to a theme
            dark = "wave",           -- try "dragon" !
            light = "lotus"
        },

    },
    config = function(_, opts)
        -- setup must be called before loading
        require("kanagawa").setup(opts)
        vim.cmd("colorscheme kanagawa")
        -- vim.cmd("colorscheme kanagawa-dragon")
    end, }
}
