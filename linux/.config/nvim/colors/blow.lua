---@type config.Colors
local c = {
  bg0 = "#0b3335",
  bg1 = "#062329",
  bg2 = "#07262c",
  bg3 = "#051e23",
  bg4 = "#04191e",
  fg0 = "#e7d4be",
  fg1 = "#d1b897",
  fg2 = "#b9a285",
  fg3 = "#9c886f",
  fg4 = "#7f705b",
  accent = "#ffffff",

  bool = "#7ad0c6",
  builtin = "#ffffff",
  const = "#7ad0c6",
  func = "#ffffff",
  keyword = "#ffffff",
  number = "#7ad0c6",
  operator = "#8cde94",
  ret = "#ffffff",
  special = "#8cde94",
  str = "#2ec09c",
  type = "#8cde94",
  comment = "#44b340",
  docs = "#44b340",

  ok = "#44b340",
  error = "#ff0000",
  warn = "#ffaa00",
  info = "#2ec09c",
  hint = "#7ad0c6",

  search = "#ffaa00",
  match = "#126367",
  selection = "#133678",
  folder = "#d1b897",
  directory = "#7ad0c6",

  msgarea = "#062329",
  stl = "#d1b897",
  stlnc = "#062329",

  added = "#44b340",
  changed = "#7ad0c6",
  removed = "#ff0000",
}

c.visual = c.selection

c.red = c.error
c.green = c.ok
c.yellow = c.folder
c.blue = "#c1d1e3"
c.magenta = c.str
c.cyan = c.hint

if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
if vim.g.colors_name then vim.cmd("highlight clear") end
vim.g.colors_name = "blow"
vim.o.termguicolors = true
require("colorscheme.hls").set_hls(colors)
