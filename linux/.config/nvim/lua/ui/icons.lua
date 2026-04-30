local M = {}

M.arrow = {
    right = "",
    left = "",
    up = "",
    down = "",
}

M.dap = {
  rejected = "○ ",
  -- breakpoint = " ",
  breakpoint = " ",
  -- conditional = "",
  -- conditional = "󱄶",
  conditional = " ",
  logpoint = "󰐪 ",
  -- logpoint = "󱞆",
  pc = " ",
}

M.diagnostics2 = {
  error = "",
  warning = "",
  info = "",
  hint = "󰌶",
  note = "󰌶",
}
M.diagnostics = {
  error = "",
  warning = "",
  -- warning = "",
  info = "",
  hint = "󰌵",
  note = "󰌵"
}

M.border = {
  bold = { "┏", "━", "┓", "┃", "┛", "━", "┗", "┃" },
  thinblock = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
  needle = {
    { "▁", "FloatBorderTransparent" },
    { "▁", "FloatBorderTransparent"},
    { "▁", "FloatBorderTransparent"  },
    { "🮇", "FloatBorder"  },
    { "▔", "FloatBorderTransparent"  },
    { "▔", "FloatBorderTransparent"  },
    { "▔", "FloatBorderTransparent"  },
    { "▎", "FloatBorder"  },
  }
}

M.lsp_kinds = {
  Array         = "󰅪",
  Boolean       = "󰺟",
  Class         = "󱡠",
  Color         = "󰏘",
  Constant      = "󰏿",
  Constructor   = "",
  Enum          = "",
  EnumMember    = "",
  Event         = "",
  Field         = "·",
  File          = "󰈙",
  Folder        = "󰉋",
  Function      = "󰊕",
  Interface     = "",
  Keyword       = "",
  Method        = "󰊕",
  Module        = "",
  Operator      = "󰆕",
  Property      = "·",
  Reference     = "󰈇",
  Snippet       = "",
  Struct        = "󱡠",
  Text          = "󰉿",
  TypeParameter = "",
  Unit          = "",
  Value         = "󰎠",
  Variable      = "󰀫",
}

M.misc = {
    bug = "",
    dashed_bar = "┊",
    ellipsis = "…",
    git = "",
    palette = "󰏘",
    robot = "󰚩",
    search = "",
    terminal = "",
    toolbox = "󰦬",
    vertical_bar = "│",
}

return M
