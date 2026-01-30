return {
    "lewis6991/gitsigns.nvim",
    enabled = true,
    cmd = "Gitsigns",
    event = { "BufReadPost", "BufNewFile", "BufWritePre" },
    -- event = "VeryLazy",
    opts = {
        signs = {
            add = { text = "▎" },
            change = { text = "▎" },
            delete = { text = "" },
            topdelete = { text = "" },
            changedelete = { text = "▎" },
            untracked = { text = "▎" },
        },
    },
}
