return {
    "windwp/nvim-autopairs",
    enabled = true,
    event = "InsertEnter",
    opts = {
        disable_filetype = { "helpout_search" },
        map_cr = true,
        map_bs = true,
        -- map_c_w = true,
        check_ts = true,
        -- ts_config = { lua = { 'string' } },
        fast_wrap = {
            map = '<C-e>',
            chars = { '{', '[', '(', '"', "'" },
            pattern = [=[[%'%"%>%]%)%}%,]]=],
            end_key = '$',
            before_key = 'h',
            after_key = 'l',
            cursor_pos_before = true,
            keys = 'qwertyuiopzxcvbnmasdfghjkl',
            manual_position = true,
            highlight = 'Search',
            highlight_grey='Comment'
        }
    },
    config = function(_, opts)
        local autopairs = require("nvim-autopairs")
        autopairs.setup(opts)
        autopairs.remove_rule("`")
        autopairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
    end,

}
