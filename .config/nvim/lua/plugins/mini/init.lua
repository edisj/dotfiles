return {
    "nvim-mini/mini.nvim",
    version = false,
    event = "VeryLazy",
    keys = {
        { "<C-e>", function()
            if not require("mini.files").close() then
                require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
            end
        end, "MiniFiles toggle"},
        { "<C-f>", "<Cmd>Pick files<CR>"}
    },
    config = function()
        require("mini.icons").setup({
            default = {
                directory = {
                    hl = "DiagnosticWarn",
                },
            },
            filetype = {
                inspector = { glyph = "🔎" },
            }
        })
        require("mini.extra").setup()
        require("mini.splitjoin").setup()
        require("mini.trailspace").setup()

        -- require("mini.sessions").setup()


        require("plugins.mini.ai")
        require("plugins.mini.surround")
        require("plugins.mini.cmdline")
        require("plugins.mini.completion")
        require("plugins.mini.operators")
        require("plugins.mini.files")
        require("plugins.mini.pick")
        require("plugins.mini.snippets")
        require("plugins.mini.hipatterns")
    end,
}
