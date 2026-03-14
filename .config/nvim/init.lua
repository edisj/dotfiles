if vim.loader then vim.loader.enable() end

vim.g.mapleader = " "

vim.cmd.colorscheme "materialyou"

require "ui.winbar"
require "ui.statusline"
require "ui.wildermenu"
require("helpout").setup()
require("inspector").setup()

_G.P = vim.print
do
    local function lazy_require(modname)
        return setmetatable({}, {
            __index = function(t, k)
                local mod = require(modname)
                setmetatable(t, { __index = mod })
                return mod[k]
            end,
        })
    end
    _G.Win = lazy_require("win")
    _G.Edis = lazy_require("edis")
    _G.Arglist = lazy_require("arglist")
    _G.Terminal = lazy_require("floaterminal")
    _G.Session = lazy_require("session")
    _G.Quickfix = lazy_require("quickfix")
end


pcall(function()
    require("vim._core.ui2").enable {}
end)
