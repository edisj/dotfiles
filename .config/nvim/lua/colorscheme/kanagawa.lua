local utils = require "colorscheme.utils"

local M = {}

M.colors = {
  bg = "#1a1d25",
  bg2 = "#283355",
  bg3 = "#2d4f67",

  accent = "#4dcfff",
  primary = "#53769c",
  secondary = "#686342",
  tertiary =	"#1c2462",

  str = "#e6c384",
  func = "#7aa89f",
  class = "#7aa89f",
  identifier = "#92b8c0",
  constant = "#ffa066",
  number = "#e6c384",
  special = "#98bb62",
  preproc = "#938aa9",
  builtin = "#d27e99",

  success = "#98bb62",
  error = "#ff5d62",
  warning = "#ffd43b",
  info = "#a9dfff",
  hint = "#bbbbbb",

  folder = "#caaa67"
}

M.load = function()

  if vim.g.colors_name then vim.cmd("highlight clear") end
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.g.colors_name = "kanagawa"

  local c = M.colors
  c.fg = utils.lighten(c.bg, 0.65)

  local cursorline = utils.brighten(c.bg, 0.1, 0.03)
  local statusline = utils.brighten(c.bg, 0.05, -0.05)
  local on_statusline = utils.brighten(statusline, 0.0, 0.30)
  local statusline2 = utils.blend(statusline, 0.20, c.primary)
  local dark_border = utils.darken(statusline, 0.50)

  local bg_float = utils.darken(c.bg, 0.30)
  local bg_pmenu = utils.brighten(c.bg, 0.05, 0.05)
  local selection = utils.lighten(bg_pmenu, 0.15)
  local bg_linenr = utils.darken(c.bg, 0.20)
  local linenr = utils.brighten(bg_linenr, 0.10, 0.25)

  local visual = utils.brighten(c.bg, 0.35, 0.10)
  local comment = utils.blend(c.bg, 0.50, c.fg)
  local keyword = utils.brighten(c.primary, 0.1, 0.05)
  local operator = utils.brighten(c.fg, 0.30, -0.20)

  vim.g.terminal_color_0  = dark_border
  vim.g.terminal_color_1  = c.error
  vim.g.terminal_color_2  = c.success
  vim.g.terminal_color_3  = c.str
  vim.g.terminal_color_4  = keyword
  vim.g.terminal_color_5  = c.builtin
  vim.g.terminal_color_6  = c.identifier
  vim.g.terminal_color_7  = c.fg
  vim.g.terminal_color_8  = "#a8a8a8"
  vim.g.terminal_color_9  = utils.brighten(vim.g.terminal_color_1, 0.20, 0.10)
  vim.g.terminal_color_10 = utils.brighten(vim.g.terminal_color_2, 0.20, 0.10)
  vim.g.terminal_color_11 = utils.brighten(vim.g.terminal_color_3, 0.20, 0.10)
  vim.g.terminal_color_12 = utils.brighten(vim.g.terminal_color_4, 0.30, 0.10)
  vim.g.terminal_color_13 = utils.brighten(vim.g.terminal_color_5, 0.20, 0.10)
  vim.g.terminal_color_14 = utils.brighten(vim.g.terminal_color_6, 0.20, 0.10)
  vim.g.terminal_color_15 = "#a9dfff"
  -- vim.g.terminal_color_background = bg
  -- vim.g.terminal_color_foreground = fg


  -- `:h group-name`
  local syntax = {
    Comment        = { fg = comment,      bg = nil                },  -- any comment
    Constant       = { fg = c.constant,   bg = nil                },  -- any constant
    Boolean        = { fg = c.constant,   bg = nil                },  -- a boolean constant: TRUE, false
    Number         = { fg = c.number,     bg = nil                },  -- a number constant: 234, 0xff
    Float          = { link = "Number"                            },  -- a floating point constant: 2.3e10
    String         = { fg = c.str,        bg = nil                },  -- a string constant: "this is a string"
    Character      = { link = "String"                            },  -- a character constant: 'c', '\n'
    Identifier     = { fg = c.identifier, bg = nil                },  -- any variable name
    Function       = { fg = c.func,       bg = "none"                },  -- function name (also: methods for classes)
    Operator       = { fg = operator,     bg = nil                },  -- "sizeof", "+", "*", etc.

    Keyword	       = { fg = keyword,      bg = nil, italic = true },  -- any other keyword
    Statement	     = { link = "Keyword"                           },  -- any statement
    Conditional	   = { link = "Keyword"                           },  -- if, then, else, endif, switch, etc.
    Repeat		     = { link = "Keyword"                           },  -- for, do, while, etc.
    Label		       = { link = "Keyword"                           },  -- case, default, etc.
    Exception	     = { link = "Keyword"                           },  -- try, catch, throw

    PreProc        = { fg = c.preproc,    bg = nil                },  -- generic Preprocessor
    Include	       = { link = "PreProc"                           },  -- preprocessor #include
    Define	       = { link = "Preproc"                           },  -- preprocessor #define
    Macro	         = { link = "PreProc"                           },  -- same as Define
    PreCondit      = { link = "PreProc"                           },  -- preprocessor #if, #else, #endif, etc.

    Type	         = { fg = c.class,      bg = nil                },  -- int, long, char, etc.
    StorageClass   = { link = "Type"                              },	-- static, register, volatile, etc.
    Structure	     = { link = "Type"                              },  -- struct, union, enum, etc.
    Typedef		     = { link = "Type"                              },  -- a typedef

    Special	       = { fg = c.special,    bg = nil                },  -- any special symbol
    SpecialChar	   = { link = "Special"                           },  -- special character in a constant Tag		         = { link = "Special"                           },  -- you can use CTRL-] on this
    Delimiter	     = { link = "Special"                           },  -- character that needs attention
    SpecialComment = { link = "Special"                           },  -- special things inside a comment
    Debug		       = { link = "Special"                           },  -- debugging statements

    Ignore         = { link = "Comment"                           },  -- left blank, hidden  |hl-Ignore|
    Error          = { fg = c.error,      bg = nil                },  -- any erroneous construct
    Todo           = { link = "Error"                             },  -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    Added = { fg = c.success, bg = utils.blend(c.bg, 0.05, c.success) },
    Removed = { fg = c.error, bg = utils.blend(c.bg, 0.05, c.error) },
  }

  -- `:h highlight-groups`
  local editor = {
    Normal           = { fg = c.fg,         bg = c.bg                          },  -- Normal text.
    NormalNC         = { link = "Normal"                                       },  -- Normal text in non-current windows.
    NormalFloat      = { fg = c.fg,         bg = bg_float                      },  -- Normal text in floating windows.
    NormalSplit      = { fg = c.fg,         bg = bg_linenr                        },
    EndOfBuffer      = { fg = linenr,    bg = c.bg                          },  -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    EndOfBuffer2     = { fg = linenr,    bg = bg_linenr                        },  -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    FloatBorder      = { fg = dark_border,    bg = bg_float                      },  -- Border of floating windows.
    FloatBorderTransparent      = { fg = dark_border,    bg = "NONE"                      },  -- Border of floating windows.
    FloatBorder2     = { fg = c.primary,  bg = bg_float                      },  -- Border of floating windows.
    FloatTitle       = { fg = c.on_primary, bg = cursorline                    },  -- Title of floating windows.
    FloatFooter      = { fg = c.on_primary, bg = c.primary,       bold = true  },  -- Footer of floating windows.
    Cursor           = { fg = c.bg,         bg = c.accent                      },  -- Character under the cursor.
    CursorLine       = { fg = nil,          bg = cursorline                    },  -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    LineNr           = { fg = linenr,    bg = bg_linenr                        },  -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    CursorLineNr     = { fg = c.number,     bg = cursorline,      bold = true  },  -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "oth", for the cursor line.
    -- Folded           = { fg = c.primary,   bg = nil                         },     -- Line used for closed folds.
    -- FoldColumn       = { fg = comment,     bg = c.bg                        },     -- 'foldcolumn'
    Visual           = { fg = nil,          bg = visual                        },  -- Visual mode selection.
    VisualNOS        = { link = "Visual"                                       },  -- Visual mode selection when vim is "Not Owning the Selection".

    Title            = { fg = c.identifier, bg = nil                           },  -- Titles for output from ":set all", ":autocmd" etc.
    Directory        = { fg = c.primary,    bg = nil,             bold = true  },  -- Directory names (and other special names in listings).
    Search           = { fg = nil,          bg = visual                        },  -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
    IncSearch        = { fg = c.bg,          bg = c.identifier,       bold = true  },  -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
    Substitute       = { fg = c.on_red,     bg = c.red                         },  -- |:substitute| replacement text highlighting.
    MatchParen       = { fg = c.accent,     bg = nil,             bold = true  },  -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|

    MsgArea          = { fg = nil,          bg = c.bg                    },  -- Area for messages and command-line, see also 'cmdheight'.
    MoreMsg          = { fg = c.identifier, bg = statusline                    },  -- |more-prompt|
    Question         = { fg = c.identifier,    bg = bg_float,      bold = true  },  -- |hit-enter| prompt and yes/no questions.
    ModeMsg          = { fg = c.primary,    bg = nil                           },  -- 'showmode' message (e.g., "-- INSERT --").
    NonText          = { fg = comment,      bg = nil                           },  -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text
    WhiteSpace       = { fg = comment,      bg = nil                           },

    Pmenu            = { fg = nil,          bg = bg_pmenu                      },  -- Popup menu: Normal item.
    PmenuSel         = { fg = nil,          bg = selection,           },  -- Popup menu: Selected item.
    PmenuMatch       = { fg = c.primary,    bg = nil                           },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
    PmenuThumb       = { fg = c.primary,    bg = c.primary                     },  -- Popup menu: Thumb of the scrollbar.
    PmenuSbar        = { fg = c.primary,    bg = bg_pmenu                          },  -- Popup menu: Scrollbar.
    WildMenu         = { fg = c.fg,         bg = c.bg                          },  -- Current match in 'wildmenu' completion.

    WinSeparator     = { fg = dark_border,   bg = bg_float                  },  -- Separators between window splits.
    WinSeparatorNC   = { link = "WinSeparator"                          },

    StatusLine       = { fg = on_statusline, bg = statusline              },  -- Status line of current window.
    StatusLineNC     = { link = "Statusline"                              },  -- Status lines of not-current windows.

    StatusLine2      = { fg = c.primary,     bg = statusline2             },  -- "y" or "b" second of status line
    StatuslineCmd    = { fg = statusline,    bg = c.identifier,      bold = true  },
    StatuslineInsert = { fg = statusline,    bg = c.str,     bold = true  },
    StatuslineNormal = { fg = statusline,    bg = c.primary, bold = true  },
    StatuslineVisual = { fg = statusline,    bg = c.special,    bold = true  },

    SignColumn       = { fg = linenr,  bg = bg_linenr                     },  -- Column where |signs| are displayed.
    StatusColBorder  = { fg = dark_border,  bg = nil },
    StatusColBorder2 = { fg = dark_border,  bg = nil },

    WinBar           = { fg = nil,           bg = nil                     },  -- Window bar of current window.
    WinBarNC         = { link = "WinBar"                                  },  -- Window bar of not  -current windows.
    WinBarNormal     = { fg = dark_border,    bg = c.primary, bold = true },
    WinBarModified   = { fg = dark_border,    bg = c.str,     bold = true },
    WinBarModifiable = { fg = dark_border,    bg = c.error,   bold = true },
    TabLine        = { fg = comment, bg = bg_float,                       },  -- Tab pages line, not active tab page label.
    TabLineFill    = { link = "NormalSplit"                               },  -- Tab pages line, where there are no labels.
    TabLineSel     = { fg = nil, bg = cursorline, bold = true             },  -- Tab pages line, active tab page label.

    -- QuickFixLine     = { fg = nil,      bg = qfline, bold = true            },  -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    qfFileName       = { fg = c.blue,   bg = nil                              },
    qfLineNr         = { fg = c.yellow, bg = nil                              },
    qfSeparator1     = "@punctuation.bracket",
    qfSeparator2     = "qfSeparator1",

    SpellBad     = { sp = c.error,   undercurl = true                      },  -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap     = { sp = c.warning, undercurl = true                      },  -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal   = { sp = c.info,    undercurl = true                      },  -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare    = { sp = c.info,    undercurl = true                      },  -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
  }

  -- `:h diagnostic-highlights`
  -- `:h lsp-highlight`
  local lsp = {
    DiagnosticError            = { fg = c.error,    bg = nil },
    DiagnosticWarn             = { fg = c.warning,  bg = nil },
    DiagnosticInfo             = { fg = c.info,     bg = nil },
    DiagnosticHint             = { fg = c.hint,     bg = nil },
    DiagnosticOk               = { fg = c.success,  bg = nil },

    DiagnosticVirtualTextError = { link = "DiagnosticError" },
    DiagnosticVirtualTextWarn  = { link = "DiagnosticWarn"  },
    DiagnosticVirtualTextInfo  = { link = "DiagnosticInfo"  },
    DiagnosticVirtualTextHint  = { link = "DiagnosticHint"  },
    DiagnosticVirtualTextOk    = { link = "DiagnosticOk"    },
    DiagnosticSignError        = { fg = c.fg, bg = utils.blend(bg_linenr, 0.15, c.error) },   -- Used for "Error" signs in sign column.
    DiagnosticSignWarn         = { fg = c.fg, bg = utils.blend(bg_linenr, 0.15, c.warning) },   -- Used for "Warn" signs in sign column.
    DiagnosticSignInfo         = { fg = nil, bg = c.info},   -- Used for "Info" signs in sign column.
    DiagnosticSignHint         = { link = "DiagnosticHint"  },   -- Used for "Hint" signs in sign column.
    DiagnosticSignOk           = { link = "DiagnosticOk"    },   -- Used for "Ok" signs in sign column.

    DiagnosticUnnecessary      = { },
    DiagnosticUnderlineError   = { sp = c.error,   undercurl = true },
    DiagnosticUnderlineWarn    = { sp = c.warning, undercurl = true },
    DiagnosticUnderlineInfo    = { sp = c.info,    undercurl = true },
    DiagnosticUnderlineHint    = { sp = c.hint,    undercurl = true },
    DiagnosticUnderlineOk      = { sp = c.success, undercurl = true },

  }

  -- `:h treesitter-highlight`
  local treesitter = {

    ["@variable"]                  = { fg = c.fg, bg = nil },
    -- ["@variable"]                  = {},
    -- ["@type.builtin"]          = { fg = nil, bg = nil, italic = true },
    ["@type.builtin"]          = { link = "Keyword" },
    ["@punctuation.bracket"]       = { fg = utils.darken(c.fg, 0.30), bg = nil },
    ["@punctuation.delimiter"]     = { link = "@punctuation.bracket" },
    -- ["@punctuation.bracket.css"]     = { link = "DiagnosticError" },
    -- ["@punctuation.bracket.json"]     = { link = "DiagnosticError" },
    -- ["@comment.documentation"]     = { fg = utils.darken(c, 0.20), bg = nil },

    ["@variable.builtin"]          = { fg = c.builtin, bg = nil },
    ["@constant.builtin"]          = { fg = c.builtin, bg = nil },
    ["@function.builtin"]          = { fg = c.builtin, bg = nil },
    ["@module.builtin"]            = { fg = c.builtin, bg = nil },

    ["@string.special.url.vimdoc"] = { fg = c.builtin, bg = nil },
    ["@string.special.path"]   = { fg = c.builtin, bg = nil },
    ["@markup.link"] =  { link = "String" },
    ["@markup.raw.vimdoc"] =  { link = "Function" },

    ["@keyword.return"]           = { fg = c.special, bg = nil, bold = true },
    ["@keyword.exception"]        = { fg = c.error, bg = nil, bold = true },
    ["@keyword.operator"]         = {},

    ["@variable.parameter.vimdoc"] = { link = "Special" },
    ["@constructor.lua"] = { link = "@punctuation.bracket" },

    ["@lsp.type.variable"]      = { },                    -- Identifiers that declare or reference a local or global variable
    ["@lsp.type.function"]      = { },
    ["@lsp.type.modifier"]      = { link = "Keyword" },                    -- Identifiers that declare or reference a local or global variable
    -- ["@lsp.mod.global"] = { fg = nil, bg = nil, italic = true },
  }

  local plugins = {

    FugitiveUntrackedHeading = { link = "Function" },
    FugitiveUntrackedModifier = { fg = c.error, bg = nil },
    FugitiveUnstagedModifier = { fg = c.warning, bg = nil },
    FugitiveUnstagedHeading = { link = "Function" },

    GitSignsChange = { fg = utils.blend(c.primary, 0.70, linenr), bg = nil },
    GitSignsDelete = { fg = utils.blend(c.error, 0.20, linenr),   bg = nil, bold = true },
    GitSignsAdd = { fg = utils.blend(c.success, 0.45, linenr), bg = nil },

    FzfLuaNormal        = { fg = nil, bg = bg_float      },
    FzfLuaBorder        = { fg = dark_border, bg = bg_float     },
    FzfLuaTitle         = { link = "Normal"           },
    FzfluaPreviewNormal = { link = "Normal"           },
    FzfLuaPreviewBorder = { fg = c.primary, bg = c.bg },

    BlinkCmpDocBorder                    = { link = "FloatBorder" },
    BlinkCmpDocSeparator                 = { link = "Comment" },
    BlinkCmpLabel                        = { link = "Normal" },
    BlinkCmpLabelMatch                   = { fg = c.error, bg = nil },
    BlinkCmpSignatureHelpBorder          = { link = "FloatBorder" },
    BlinkCmpSignatureHelpActiveParameter = { fg = c.error, bg = nil, bold = true },

    MiniHipatternsTodo       = { fg = c.error, bg = nil, bold = true },
    MiniHipatternsHack       = { link = "MiniHipatternsTodo"         },
    MiniHipatternsNote       = { link = "MiniHipatternsTodo"         },
    MiniHipatternsFixme      = { link = "MiniHipatternsTodo"         },

    Folder = { fg = c.folder, bg = nil },
    MiniFilesBorder         = { link = "FloatBorder" },
    MiniFilesTitle          = { fg = nil, bg = dark_border, bold = true},
    MiniFilesTitleFocused   = { fg = nil, bg = dark_border, bold = true },
    MiniFilesBorderModified = { fg = c.warning, bg = bg_float, bold = true },
    -- MiniFilesCursorLine     = { link = "Visual" },

    SnacksPicker = { fg = nil, bg = bg_linenr },
    SnacksPickerInputBorder = { fg = c.primary, bg = bg_linenr },
    SnacksDashboardSpecial = { link = "Function" },
    SnacksDashboardDesc = { link = "Function" },
    SnacksDashboardTitle = { link = "Keyword" },
    SnacksDashboardFile = { link = "Identifier" },
    SnacksDashboardIcon = { link = "String" },
  }

  -- NOTE: maybe figure out a way to highlight bg of mini icons in winbar
  -- local mini_icon_hls = {
  --   "MiniIconsAzure", "MiniIconsBlue", "MiniIconsCyan",
  --   "MiniIconsGreen", "MiniIconsGrey", "MiniIconsOrange",
  --   "MiniIconsPurple", "MiniIconsRed", "MiniIconsYellow"
  -- }
  -- for _, hl in ipairs(mini_icon_hls) do
  --   local fg = vim.api.nvim_get_hl(0, { name = hl }).fg
  --   local bg_normal = vim.api.nvim_get_hl(0, { name = "WinBarNormal" }).bg
  --   local bg_modified = vim.api.nvim_get_hl(0, { name = "WinBarModified" }).bg
  --   local bg_modifiable = vim.api.nvim_get_hl(0, { name = "WinBarModifiable" }).bg
  --   plugins[hl .. "WinBarNormal"] = { fg = fg, bg = bg_normal }
  --   plugins[hl .. "WinBarNormalModified"] = { fg = fg, bg = bg_modified }
  --   plugins[hl .. "WinBarNormalModifiable"] = { fg = fg, bg = bg_modifiable }
  -- end

  local set_hl = vim.api.nvim_set_hl
  for _, highlights in ipairs {
    syntax,
    editor,
    lsp,
    treesitter,
    plugins,
  } do
    for group, hl in pairs(highlights) do
      hl = type(hl) == "string" and { link = hl } or hl ---@type vim.api.keyset.highlight
      set_hl(0, group, hl)
    end
  end
end

return M
