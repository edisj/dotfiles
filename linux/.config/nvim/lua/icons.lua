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

M.diagnostic2 = {
  error = "",
  warn = "",
  info = "",
  hint = "󰌶",
  note = "󰌶",
}
M.diagnostic = {
  error = "",
  warn = "",
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
    -- terminal = "",
    terminal = "",
    toolbox = "󰦬",
    vertical_bar = "│",
}

M.get = function(category, name)
  local get
  if vim.g.icons == "real" and pcall(require, "real-icons") then
    get = require("real-icons").get
  elseif vim.g.icons == "mini" and pcall(require, "mini.icons") then
    get = require("mini.icons").get
  elseif vim.g.icons == "dev" and pcall(require, "nvim-web-devicons") then
    category = name
    name = nil
    get = function(filename)
      local icon, icon_hl = require("nvim-web-devicons").get_icon(filename)
      return icon, icon_hl, icon_hl == "DevIconDefault"
    end
  else
    get = function() return "", nil end
  end

  local icon, icon_hl, default = get(category, name)
  icon = icon and icon .. " " or "  "
  -- icon_hl = not default and icon_hl or nil
  return icon, icon_hl
end

return M
