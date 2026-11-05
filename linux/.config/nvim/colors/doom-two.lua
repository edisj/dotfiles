---@type config.Colors
local colors = {
  accent  = "#51afef",
  -- accent = "#ff6c6b",

  bg0 = "#33373e",
  bg1 = "#282c34",
  bg2 = "#23272e",
  bg3 = "#21242b",
  bg4 = "#1e2128",
  fg0 = "#dfdfdf",
  fg1 = "#bbc2cf",
  fg2 = "#9ca0a4",
  fg3 = "#73797e",
  fg4 = "#5b6268",

  bool     = "#ecbe7b",
  builtin  = "#a9a1e1",
  comment  = "#5b6268",
  const    = "#bbc2cf",
  docs     = "#84898d",
  func     = "#67b5ed",
  keyword  = "#a9a1e1",
  number   = "#ecbe7b",
  -- number = "#95a99f",
  operator = "#96a6c8",
  ret      = "#ff6c6b",
  special  = "#96a6c8",
  str      = "#b7cf94",
  type     = "#82b3a4",

  ok    = "#98be65",
  error = "#ff6c6b",
  warn  = "#ecbe7b",
  info  = "#98be65",
  hint  = "#4db5bd",

  -- directory = "#6d96b4",
  folder    = "#caaa67",
  search     = "#2257a0",
  -- search = "#387aa7",
  -- cursearch    = "#f9d791",
  selection = "#282c34",
  visual = "#42444a",

  msgarea = "#21242b",
  stl     = "#1d2026",
  stlnc     = "#1d2026",
  -- stlnc   = "#21242b",
  -- stlnc = "#23272e",

  added   = "#98be65",
  changed = "#a9a1e1",
  removed = "#ff6c6b",
}
colors.cursorline = colors.bg3

colors.red     = colors.error
colors.green   = colors.ok
colors.yellow  = colors.number
colors.blue    = colors.func
colors.magenta = colors.builtin
colors.cyan    = colors.hint

if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
if vim.g.colors_name then vim.cmd("highlight clear") end
vim.g.colors_name = "doom-two"
vim.o.termguicolors = true
require("colorscheme.hls").set_hls(colors)
-- require("colorscheme").load("doom-two")
