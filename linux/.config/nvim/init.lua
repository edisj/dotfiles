vim.loader.enable()

vim.g._start_time_ns = vim.uv.hrtime()
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.g._end_time_ns = vim.uv.hrtime()
    vim.g._load_time_ms = (vim.g._end_time_ns - vim.g._start_time_ns) / 1e6
  end,
})

vim.cmd.colorscheme "doom-two"

vim.g.mapleader = " "
vim.g.cmp = "mini.cmdline"
-- vim.g.cmp = "blink.cmp"
vim.g.icons = "mini"
vim.g.CTRL_M = vim.g.neovide and "<C-m>" or "<F13>"
-- vim.g.CTRL_M = "<C-m>"

require "mux"

_G.map = require("globals").map
_G.on = require("globals").on

on("UIEnter", nil, function()
  vim.g.Nu = vim.g.Nu or 0
  vim.g.Rnu = vim.g.Rnu or 0
  vim.g.Diag = vim.g.Diag or 0
  vim.g.DiagCol = vim.g.DiagCol or 0
  vim.o.nu = vim.g.Nu == 1
  vim.o.rnu = vim.g.Rnu == 1
  vim.diagnostic.enable(vim.g.Diag == 1)
end)

vim.go.statusline = "%{%v:lua.require'ui.statusline'.render()%}"
vim.o.statuscolumn = "%{%v:lua.require'ui.statuscol'.render()%}"
