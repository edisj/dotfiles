---@type config.Colors
local c = {
  bg = "#272b31",
  -- fg = "#c9cdd3",
  fg = "#aeb0b3",

  bool = "#e6c384",
  const = "#e6c384",
  num = "#e6c384",
  str = "#b7cf94",
  ret = "#f2a57e",
  keyword = "#bca6d6",
  builtin = "#82b3a4",

  type = "#e6c384",

  func = "#67b5ed",

  operator = "#81a1c1",
  special = "#81a1c1",

  ok = "#98BB6C",
  error = "#ff5d62",
  warn = "#ffd43b",
  info = "#96ccbd",
  -- info = "#6d96b4",
  hint = "#7ccbcd",

  search = "#f9d791",
  match = "#84b5db",
  selection = "#202867",

  folder = "#caaa67",
  directory = "#6d96b4",
}

-- terminal colors
c.red = c.error
c.green = c.ok
c.yellow = c.type
c.blue = c.func
c.magenta = c.keyword
c.cyan = c.hint
c.bright_white = "#a9dfff"

if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
if vim.g.colors_name then vim.cmd("highlight clear") end
vim.g.colors_name = "kanordwa"
vim.o.termguicolors = true
require("colorscheme.hls").set_hls(colors)
