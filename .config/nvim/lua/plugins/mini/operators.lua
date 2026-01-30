local opts = {
    evaluate = { prefix = "g=" },
    exchange = {
        -- NOTE: Default `gx` is remapped to `gX`
        prefix = "gx",
    },
    multiply = { prefix = "gm" },
    replace = {
        -- NOTE: Default `gr*` LSP mappings are removed
        prefix = "gr",
    },
    sort = { prefix = "gs" }
}

require("mini.operators").setup(opts)

vim.keymap.set("n", "_ol", "<Cmd>normal gxiagxina<CR>")
vim.keymap.set("n", "_oh", "<Cmd>normal gxiagxiNa<CR>")
vim.keymap.set("n", "<C-a><C-l>", "<Cmd>normal gxiagxina<CR>")
vim.keymap.set("n", "<C-a><C-h>", "<Cmd>normal gxiagxiNa<CR>")

