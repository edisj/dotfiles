-- https://github.com/boningmaple/mac-clear
local c = {
  bg = "#212734",
  fg = "#aeb0b3",

  -- syntax
  -- builtin = "#f2a57e",
  constant ="#f2a57e",
  boolean = "#f2a57e",
  func = "#67b5ed",
  builtin = "#53769c",

  keyword = "#B782C2",
  ret = "#ffee99",
  -- conditional = "#ad64be",
  -- ret = "#ad64be",

  number = "#f2a57e",
  operator = "#81a1c1",
  special = "#81a1c1",
  str = "#6caa71",
  type = "#c4ac62",

  ok = "#79be7e",
  error = "#ff5d62",
  warn = "#e5c872",
  info = "#6d96b4",
  hint = "#7ccbcd",

  statusline = "#171d29",
  cursearch = "#ffe082",
  search = "#f2a57e",
  selection = "#5384b4",
  folder = "#caaa67",
  directory = "#5685a8",
}

-- terminal colors
c.red = c.error
c.green = c.ok
c.yellow = c.type
c.blue = c.func
c.magenta = c.keyword
c.cyan = c.hint

return c
