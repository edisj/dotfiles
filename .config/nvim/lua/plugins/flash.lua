return {
    -- enabled = false,
	"folke/flash.nvim",
    event = "VeryLazy",
    ---@type Flash.Config
	opts = {
        labels = "asdfghjklqwertyuiopzxcvbnm",
        modes = {
            char = {
                enabled = true,
                keys = { "f", "F", "t", "T", ";", "," },
                char_actions = function(motion)
                    return {
                        [";"] = "right", -- set to `right` to always go right
                        [","] = "left", -- set to `left` to always go left
                        -- clever-f style
                        [motion:lower()] = "next",
                        [motion:upper()] = "prev",
                        -- jump2d style: same case goes next, opposite case goes prev
                        -- [motion] = "next",
                        -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
                    }
                end,
            },
        },
    },
    -- stylua: ignore
    keys = {
        -- { "<c-s>",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        { "b",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        { "<leader>s",     mode = { "n", "x", "o" }, function() require("flash").jump() end,              desc = "Flash" },
        -- { "S",     mode = { "n", "x", "o" }, function() require("flash").treesitter() end,        desc = "Flash Treesitter" },
        -- { "r",     mode = { "o" },           function() require("flash").remote() end,            desc = "Remote Flash" },
        { "B",     mode = { "o" },           function() require("flash").remote() end,            desc = "Remote Flash" },
        -- { "R",     mode = { "o", "x" },      function() require("flash").treesitter_search() end, desc = "Treesitter Search" },
        { "<c-s>", mode = { "c" },           function() require("flash").toggle() end,            desc = "Toggle Flash Search" },
        { "<c-y>", mode = { "n" },           "y<cmd>lua require('flash').remote()<cr>",           desc = "Flash yank remote" },
    },
}
