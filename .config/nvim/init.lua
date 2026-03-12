vim.print "init"
if vim.loader then vim.loader.enable() end
require("vim._core.ui2").enable({})

vim.g.mapleader = " "

_G.P = vim.print

vim.cmd("colorscheme materialyou")

-- vim.lsp.config("jdtls", {
--     root_markers = { ".edis", ".git", },
-- })

require "arglist"
require "ui.winbar"
require "ui.statusline"
require "ui.wildermenu"
require("floaterminal").setup()
require("helpout").setup()
require("inspector").setup()
require("session").setup()

require "edis"
require "quickfix"

local lazypath = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
if not (vim.uv or vim.loop).fs_stat(lazypath) then
    local lazyrepo = "https://github.com/folke/lazy.nvim.git"
    local out = vim.fn.system({
        "git",
        "clone",
        "--filter=blob:none",
        "--branch=stable",
        lazyrepo,
        lazypath
    })
    if vim.v.shell_error ~= 0 then
        vim.api.nvim_echo({
            { "Failed to clone lazy.nvim:\n", "ErrorMsg" },
            { out, "WarningMsg" },
            { "\nPress any key to exit..." },
        }, true, {})
        vim.fn.getchar()
        os.exit(1)
    end
end

---@diagnostic disable-next-line: undefined-field
vim.opt.rtp:prepend(lazypath)

require("lazy").setup("plugins", {
    change_detection = { notify = false },
    performance = {
        rtp = {
            disabled_plugins = {
                "gzip",
                "netrwPlugin",
                "rplugin",
                "tarPlugin",
                "tohtml",
                "tutor",
                "zipPlugin",
            },
        },
    },
    rocks = { enabled = false },
    -- spec = {
    --     { import = "plugins" },
    -- },
    ui = {
        size = { width = 0.8, height = 0.7 },
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
    },
})

-- vim.pack.add({
--     { src = "https://github.com/tpope/vim-fugitive" },
-- })
