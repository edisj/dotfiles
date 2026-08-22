local c = {
  bg = "#272b31",
  -- fg = "#c9cdd3",
  fg = "#aeb0b3",


  boolean = "#e6c384",
  constant = "#e6c384",
  number = "#e6c384",
  str = "#b7cf94",
  -- str = "#c5e19c",
  -- -- str = "#c6e894",
  -- str = "#98bb62",
  ret = "#f2a57e",
  keyword = "#bca6d6",
  builtin = "#82b3a4",
  -- conditional = "#B782C2",

  type = "#e6c384",

  -- keyword = "#53769c",
  -- func = "#74b5db",
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
  -- selection = "#81a1c1",
  match = "#84b5db",

  folder = "#caaa67",
  -- directory = "#74b5db",
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

return c
