vim.loader.enable()

vim.g._start_time_ns = vim.uv.hrtime()
vim.api.nvim_create_autocmd("VimEnter", {
  once = true,
  callback = function()
    vim.g._end_time_ns = vim.uv.hrtime()
    vim.g._load_time_ms = (vim.g._end_time_ns - vim.g._start_time_ns) / 1e6
  end,
})

vim.g.mapleader = " "
vim.g.cmp = "mini.cmdline"
vim.g.icons = "mini"
vim.g.CTRL_M = vim.g.neovide and "<C-m>" or "<F13>"

vim.cmd.colorscheme "kanordwa"
-- vim.cmd.colorscheme "mac_clear"

require("vim._core.ui2").enable({
  enable = true,
  msg = {
    targets = { default = "msg" },
    msg = { height = 0.999 },
    pager = { height = 0.75 },
  }
})
require "ui.messages"
