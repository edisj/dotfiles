local get_fg = require("colorscheme.utils").get_fg
local get_bg = require("colorscheme.utils").get_bg

local out = ([[
background %s
foreground %s
cursor %s
cursor_text_color %s

color0 %s
color1 %s
color2 %s
color3 %s
color4 %s
color5 %s
color6 %s
color7 %s

color8 %s
color9 %s
color10 %s
color11 %s
color12 %s
color13 %s
color13 %s
color15 %s
]]):format(
  get_bg("Normal"),
  get_fg("Normal"),
  vim.g.terminal_color_15,
  vim.g.terminal_color_8,
  vim.g.terminal_color_0,
  vim.g.terminal_color_1,
  vim.g.terminal_color_2,
  vim.g.terminal_color_3,
  vim.g.terminal_color_4,
  vim.g.terminal_color_5,
  vim.g.terminal_color_6,
  vim.g.terminal_color_7,
  vim.g.terminal_color_8,
  vim.g.terminal_color_9,
  vim.g.terminal_color_10,
  vim.g.terminal_color_11,
  vim.g.terminal_color_12,
  vim.g.terminal_color_13,
  vim.g.terminal_color_14,
  vim.g.terminal_color_15)

vim.print(out)
