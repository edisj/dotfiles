
local c = {
  -- bg = "#0f1419",
  bg = "#14191f",
  fg = "#e6e1cf",
  primary = "#53769c",

  str = "#b8cc52",
  number = "#ffee99",
  constant = "#ffee99",
  boolean = "#ffee99",
  special = "#0096cf",
  operator = "#0096cf",
  cond = "#ff7733",
  keyword = "#ff7733",
  -- operator = "#e6e1cf",
  func = "#ffb454",

  preproc = "#8a7daa",
  builtin = "#d27e99",
  member = "#81a1c1",

  ok = "#98bb62",
  error = "#ff5d62",
  warn = "#ffd43b",
  info = "#76946A",
  hint = "#717C7C",

  search = "#ff5d62",
  folder = "#caaa67",
}

c.red = c.error
c.green = c.ok
c.yellow = c.type
c.blue = c.func
c.magenta = c.keyword
c.cyan = c.builtin

return c
