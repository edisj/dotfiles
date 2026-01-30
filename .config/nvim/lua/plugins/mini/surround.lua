local opts = {
    mappings = {
        add       = "sp",
        delete    = "sd",
        replace   = "sr",
        find      = "sf",
        find_left = "sF",
        highlight = "sh",

        suffix_next = "n",
        suffix_last = "l",
    },
    highlight_duration = 1500,
}

require("mini.surround").setup(opts)
