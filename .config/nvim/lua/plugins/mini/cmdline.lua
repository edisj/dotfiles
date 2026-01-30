local opts = {
    -- Autocompletion: show `:h 'wildmenu'` as you type
    autocomplete = {
        enable = true,

        -- Delay (in ms) after which to trigger completion
        -- Neovim>=0.12 is recommended for positive values
        delay = 0,

        -- Custom rule of when to trigger completion
        predicate = nil,

        -- Whether to map arrow keys for more consistent wildmenu behavior
        map_arrows = true,
    },

    -- Autocorrection: adjust non-existing words (commands, options, etc.)
    autocorrect = {
        enable = true,

        -- Custom autocorrection rule
        func = nil,
    },

    -- Autopeek: show command's target range in a floating window
    autopeek = {
        enable = true,

        -- Number of lines to show above and below range lines
        n_context = 2,

        predicate = nil,

        window = {
            config = {},

            -- Function to render statuscolumn
            statuscolumn = nil,
        },
    },
}

require("mini.cmdline").setup(opts)
