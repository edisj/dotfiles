local opts = {
    -- custom_textobjects = {
    --     F = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
    --     C = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
    --     B = require('mini.extra').gen_ai_spec.buffer(),
    --     D = require('mini.extra').gen_ai_spec.diagnostic(),
    --     I = require('mini.extra').gen_ai_spec.indent(),
    --     L = require('mini.extra').gen_ai_spec.line(),
    --     N = require('mini.extra').gen_ai_spec.number(),
    -- },
    mappings = {
        inside      = "i",
        inside_next = "in",
        inside_last = "il",
        around      = "o",
        around_next = "on",
        around_last = "ol",

        -- Move cursor to corresponding edge of `o` textobject
        goto_left  = "g[",
        goto_right = "g]",
    },
    n_lines = 50,
}

require("mini.ai").setup(opts)
