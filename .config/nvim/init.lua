-- vim.print("init.lua")

if vim.loader then
    vim.loader.enable()
end

vim.g.mapleader = " "

_G.P = vim.print
_G.R = function(pack)
    if package.loaded[pack] ~= nil then
        package.loaded[pack] = nil
        require(pack)
        vim.print("reloaded pack: " .. pack)
        return
    end
    vim.print("could not find pack: " .. pack)
end

-- _G.dd = function(...)
--     Snacks.debug.inspect(...)
-- end
-- _G.bt = function()
--     Snacks.debug.backtrace()
-- end
-- if vim.fn.has("nvim-0.11") == 1 then
--     vim._print = function(_, ...)
--         dd(...)
--     end
-- else
--     vim.print = dd
-- end

-- vim.highlight.priorities.semantic_tokens = 95
require("colorscheme").setup()
vim.cmd("colorscheme custom")

require "config"
