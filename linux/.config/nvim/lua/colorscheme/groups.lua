local utils = require("colorscheme.utils")
local M = {}

M.set_hls = function(c)

  if vim.g.colors_name then vim.cmd("highlight clear") end
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.g.colors_name = "kanagawa"


  local cursorline = utils.brighten(c.bg, 0.1, 0.07)
  local visual = utils.brighten(c.bg, 0.25, 0.15)
  local fg_visual = utils.lighten(c.fg, 0.50)
  local qfline = utils.brighten(c.bg, 0.05, 0.03)
  -- local statusline = utils.brighten(c.bg, 0.00, -0.04)

  local statusline = utils.brighten(c.bg, 0.08, 0.10)
  local on_statusline = utils.brighten(statusline, 0.0, 0.30)
  on_statusline = c.fg


  local dark_border = utils.darken(c.bg, 0.75)

  local bg_float = utils.darken(c.bg, 0.30)
  local bg_pmenu = utils.brighten(c.bg, 0.05, 0.05)
  local bg_linenr = utils.darken(c.bg, 0.20)
  local bg_selection = utils.blend(c.bg, 0.5, c.selection)
  local bg_msgarea = nil

  local linenr = utils.brighten(bg_linenr, 0.10, 0.15)

  local comment = utils.blend(c.bg, 0.50, c.fg)

  local native = utils.brighten(c.fg, 0.10, -0.15)

  vim.g.terminal_color_0  = dark_border
  vim.g.terminal_color_1  = c.error
  vim.g.terminal_color_2  = c.success
  vim.g.terminal_color_3  = c.str
  vim.g.terminal_color_4  = c.keyword
  vim.g.terminal_color_5  = c.builtin
  vim.g.terminal_color_6  = c.member
  vim.g.terminal_color_7  = c.fg
  vim.g.terminal_color_8  = "#a8a8a8"
  vim.g.terminal_color_9  = utils.brighten(vim.g.terminal_color_1, 0.20, 0.10)
  vim.g.terminal_color_10 = utils.brighten(vim.g.terminal_color_2, 0.20, 0.10)
  vim.g.terminal_color_11 = utils.brighten(vim.g.terminal_color_3, 0.20, 0.10)
  vim.g.terminal_color_12 = utils.brighten(vim.g.terminal_color_4, 0.30, 0.10)
  vim.g.terminal_color_13 = utils.brighten(vim.g.terminal_color_5, 0.20, 0.10)
  vim.g.terminal_color_14 = utils.brighten(vim.g.terminal_color_6, 0.20, 0.10)
  vim.g.terminal_color_15 = "#a9dfff"

  -- `:h group-name`
  local syntax = {
    Comment        = { fg = comment,      bg = nil },  -- any comment
    Constant       = { fg = c.constant,   bg = nil },  -- any constant
    Boolean        = { fg = c.boolean,    bg = nil },  -- a boolean constant: TRUE, false
    Number         = { fg = c.number,     bg = nil },  -- a number constant: 234, 0xff
    Float          = { link = "Number"             },  -- a floating point constant: 2.3e10
    String         = { fg = c.str,        bg = nil },  -- a string constant: "this is a string"
    Character      = { link = "String"             },  -- a character constant: 'c', '\n'
    Identifier     = { fg = c.fg,         bg = nil },  -- any variable name
    Function       = { fg = c.func,       bg = nil },  -- function name (also: methods for classes)
    Operator       = { fg = c.operator,   bg = nil },  -- "sizeof", "+", "*", etc.

    Keyword	       = { fg = c.keyword,    bg = nil },  -- any other keyword
    Statement	     = { link = "Keyword"            },  -- any statement
    Conditional	   = { link = "Keyword"            },  -- if, then, else, endif, switch, etc.
    Repeat		     = { link = "Keyword"            },  -- for, do, while, etc.
    Label		       = { link = "Keyword"            },  -- case, default, etc.
    Exception	     = { link = "Keyword"            },  -- try, catch, throw

    PreProc        = { fg = c.preproc,    bg = nil },  -- generic Preprocessor
    Include	       = { link = "PreProc"            },  -- preprocessor #include
    Define	       = { link = "Preproc"            },  -- preprocessor #define
    Macro	         = { link = "PreProc"            },  -- same as Define
    PreCondit      = { link = "PreProc"            },  -- preprocessor #if, #else, #endif, etc.

    Type	         = { fg = c.fg,         bg = nil },  -- int, long, char, etc.
    StorageClass   = { link = "Type"               },  -- static, register, volatile, etc.
    Structure	     = { link = "Type"               },  -- struct, union, enum, etc.
    Typedef		     = { link = "Type"               },  -- a typedef

    Special	       = { fg = c.special,    bg = nil },  -- any special symbol
    SpecialChar	   = { link = "Special"            },  -- special character in a constant
    Tag            = { link = "Special"            },  -- you can use CTRL-] on this
    Delimiter	     = { link = "Special"            },  -- character that needs attention
    SpecialComment = { link = "Special"            },  -- special things inside a comment
    Debug		       = { link = "Special"            },  -- debugging statements

    Ignore         = { link = "Comment"            },  -- left blank, hidden  |hl-Ignore|
    Error          = { fg = c.error,      bg = nil },  -- any erroneous construct
    Todo           = { link = "Error"              },  -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

    Added   = { fg = c.success, bg = utils.blend(c.bg, 0.05, c.success) },
    Removed = { fg = c.error,   bg = utils.blend(c.bg, 0.05, c.error) },

    Bold = { bold = true },
  }

  -- `:h highlight-groups`
  local editor = {
    Normal           = { fg = c.fg,         bg = c.bg                      },  -- Normal text.
    -- NormalNC         = { fg = nil,          bg = nil                       },  -- Normal text in non-current windows.
    NormalFloat      = { fg = c.fg,         bg = bg_float                  },  -- Normal text in floating windows.
    NormalSplit      = { fg = c.fg,         bg = bg_linenr                 },  -- Normal text in special splits.
    EndOfBuffer      = { fg = linenr,       bg = nil                       },  -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    FloatBorder      = { fg = dark_border,  bg = bg_float,    bold=true    },  -- Border of floating windows.
    FloatBorderTransparent      = { fg = dark_border,    bg = nil          },  -- Border of floating windows.
    FloatBorder2     = { fg = c.primary,    bg = bg_float                  },  -- Border of floating windows.
    FloatTitle       = { fg = c.fg,         bg = dark_border               },  -- Title of floating windows.
    FloatFooter      = { fg = c.fg,         bg = dark_border, bold = true  },  -- Footer of floating windows.
    Cursor           = { fg = c.bg,         bg = c.accent                  },  -- Character under the cursor.
    CursorLine       = { fg = nil,          bg = cursorline                },  -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    LineNr           = { fg = linenr,       bg = bg_linenr                 },  -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    CursorLineNr     = { fg = c.fg,         bg = cursorline,  bold = true  },  -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "oth", for the cursor line.
    -- Folded           = { fg = c.primary,   bg = nil                       },  -- Line used for closed folds.
    -- FoldColumn       = { fg = comment,     bg = c.bg                      },  -- 'foldcolumn'
    Visual           = { fg = fg_visual,          bg = visual,                     },  -- Visual mode selection.
    VisualNOS        = { link = "Visual"                                   },  -- Visual mode selection when vim is "Not Owning the Selection".

    Title            = { fg = c.keyword,    bg = nil,          },  -- Titles for output from ":set all", ":autocmd" etc.
    Directory        = { fg = c.primary,    bg = nil,     bold = true   },  -- Directory names (and other special names in listings).

    CurSearch        = { fg = c.bg,      bg = c.search,   },  --Current match for the last search pattern (see 'hlsearch').
    CurSearchInv     = { fg = c.search,  bg = nil,   },
    Search           = { fg = c.bg,      bg = utils.darken(c.search,0.2)  },  -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
    IncSearch        = { fg = c.bg,      bg = c.search,   },  -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
    -- Substitute       = { fg = nil,     bg = nil                    },  -- |:substitute| replacement text highlighting.
    MatchParen       = { link = "Visual"                                  },  -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|

    -- MsgArea          = { fg = nil,          bg = bg_linenr                       },  -- Area for messages and command-line, see also 'cmdheight'.
    -- MsgArea          = { fg = nil,          bg = bg_msgarea                       },  -- Area for messages and command-line, see also 'cmdheight'.
    MsgArea          = { fg = nil, bg = "NONE"},  -- Area for messages and command-line, see also 'cmdheight'.
    MiniBufferBorder = { fg = statusline,   bg = bg_msgarea },
    MiniBufferTitle = { fg = c.fg,   bg = dark_border, bold = true },
    MsgSeparator     = { fg = dark_border,  bg = nil                       },  -- Separator for scrolled messages |msgsep|.

    MoreMsg          = { fg = c.member, bg = nil,        bold = true   },  -- |more-prompt|
    Question         = { fg = c.member, bg = nil,        bold = true   },  -- |hit-enter| prompt and yes/no questions.
    ModeMsg          = { fg = c.primary,    bg = nil                       },  -- 'showmode' message (e.g., "-- INSERT --").
    NonText          = { fg = comment,      bg = nil                       },  -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text
    WhiteSpace       = { fg = comment,      bg = nil                       },

    Pmenu            = { fg = nil,          bg = cursorline                  },  -- Popup menu: Normal item.
    PmenuSel         = { fg = nil,          bg = bg_selection, bold=true               },  -- Popup menu: Selected item.

    PmenuMatch       = { fg = c.primary,    bg = nil                       },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
    PmenuExtra       = { fg = comment,      bg = nil,                      },  -- Popup menu: Normal item "extra text".
    PmenuThumb       = { fg = c.primary,    bg = c.primary                 },  -- Popup menu: Thumb of the scrollbar.
    PmenuSbar        = { fg = c.primary,    bg = bg_pmenu                  },  -- Popup menu: Scrollbar.
    -- Pmenu            = { fg = nil,          bg = bg_float                  },  -- Popup menu: Normal item.
    -- PmenuSel         = { fg = nil,     bg = utils.blend(c.primary,0.5,c.bg), bold=true               },  -- Popup menu: Selected item.
    -- PmenuMatch       = { fg = c.error,    bg = nil                       },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
    PmenuMatchSel    = { fg = c.error,    bg = nil                       },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
    PmenuKind = { fg = nil, bg = nil },
    -- PmenuKindSel    = { fg = c.error,    bg = nil                       },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
    -- PmenuExtra       = { fg = comment,      bg = nil,                      },  -- Popup menu: Normal item "extra text".
    PmenuExtraSel       = { fg = c.error,      bg = nil,                      },  -- Popup menu: Normal item "extra text".
    -- PmenuThumb       = { fg = c.primary,    bg = c.primary                 },  -- Popup menu: Thumb of the scrollbar.
    -- PmenuSbar        = { fg = c.primary,    bg = bg_pmenu                  },  -- Popup menu: Scrollbar.

    WildMenu         = { fg = c.fg,         bg = c.bg                      },  -- Current match in 'wildmenu' completion.

    WinSeparator     = { fg = dark_border,  bg = bg_float                  },  -- Separators between window splits.
    WinSeparatorNC   = { link = "WinSeparator"                             },

    StatusLine       = { fg = on_statusline, bg = statusline               },  -- Status line of current window.
    StatusLineNC     = { link = "Statusline"                               },  -- Status lines of not-current windows.
    StatuslineCmd    = { fg = c.number,    bg = nil, bold = true                },
    StatuslineInsert = { fg = c.str,       bg = nil, bold = true                },
    StatuslineNormal = { fg = c.selection,   bg = nil, bold = true                },
    StatuslineVisual = { fg = c.special,   bg = nil, bold = true                },

    SignColumn       = { fg = linenr,       bg = bg_linenr                 },  -- Column where |signs| are displayed.
    StatusColBorder  = { fg = dark_border,  bg = nil                       },
    StatusColBorder2 = { fg = dark_border,  bg = nil                       },

    WinBar           = { fg = nil,          bg = nil                       },  -- Window bar of current window.
    WinBarNC         = { link = "WinBar"                                   },  -- Window bar of not  -current windows.
    WinBarNormal     = { fg = c.fg,      bg = bg_linenr                    },
    WinBarModified   = { fg = c.number,  bg = bg_linenr                    },
    WinBarModifiable = { fg = c.error,   bg = bg_linenr                    },
    WinBarWarn       = { fg = c.warning, bg = bg_linenr                    },
    WinBarError      = { fg = c.error,   bg = bg_linenr                    },

    TabLine          = { fg = comment,      bg = bg_float,                 },  -- Tab pages line, not active tab page label.
    TabLineFill      = { link = "NormalSplit"                              },  -- Tab pages line, where there are no labels.
    TabLineSel       = { fg = nil,          bg = cursorline, bold = true   },  -- Tab pages line, active tab page label.

    QuickFixLine     = { fg = nil,          bg = cursorline,  bold = true   },  -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    qfFileName       = { link = "Function" },
    qfLineNr         = { link = "Number" },
    qfColNr          = { link = "LineNr" },
    qfText           = { link = "@variable" },
    qfSeparator1     = "@punctuation.bracket",
    qfSeparator2     = "qfSeparator1",

    SpellBad     = { sp = c.error,   undercurl = true },  -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap     = { sp = c.warning, undercurl = true },  -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal   = { sp = c.info,    undercurl = true },  -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare    = { sp = c.info,    undercurl = true },  -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
  }

  -- `:h diagnostic-highlights`
  -- `:h lsp-highlight`
  local lsp = {
    DiagnosticError            = { fg = c.error,    bg = nil },
    DiagnosticWarn             = { fg = c.warning,  bg = nil },
    DiagnosticInfo             = { fg = c.info,     bg = nil },
    DiagnosticHint             = { fg = c.hint,     bg = nil },
    DiagnosticOk               = { fg = c.success,  bg = nil },

    DiagnosticVirtualTextError = { link = "DiagnosticError"    },
    DiagnosticVirtualTextWarn  = { link = "DiagnosticWarn"     },
    DiagnosticVirtualTextInfo  = { link = "DiagnosticInfo"     },
    DiagnosticVirtualTextHint  = { link = "DiagnosticHint"     },
    DiagnosticVirtualTextOk    = { link = "DiagnosticOk"       },
    DiagnosticSignError        = { fg = c.error,   bg = nil    },   -- Used for "Error" signs in sign column.
    DiagnosticSignWarn         = { fg = c.warning, bg = nil    },   -- Used for "Warn" signs in sign column.
    DiagnosticSignInfo         = { fg = c.info,    bg = nil    },   -- Used for "Info" signs in sign column.
    DiagnosticSignHint         = { link = "DiagnosticHint"     },   -- Used for "Hint" signs in sign column.
    DiagnosticSignOk           = { link = "DiagnosticOk"       },   -- Used for "Ok" signs in sign column.

    DiagnosticSignColError     = { fg = comment,   bg = utils.blend(c.bg, 0.12, c.error)   },
    DiagnosticSignColWarn      = { fg = comment, bg = utils.blend(c.bg, 0.08, c.warning)  },

    DiagnosticUnnecessary      = {},
    DiagnosticUnderlineError   = { sp = c.error,   undercurl = true },
    DiagnosticUnderlineWarn    = { sp = c.warning, undercurl = true },
    DiagnosticUnderlineInfo    = { sp = c.info,    undercurl = true },
    DiagnosticUnderlineHint    = { sp = c.hint,    undercurl = true },
    DiagnosticUnderlineOk      = { sp = c.success, undercurl = true },

  }

  -- `:h treesitter-highlight`
  local treesitter = {
    -- ["@comment.documentation"]       = { fg   = c.documentation, bg = nil },
    ["@constant.bash"]                  = { link = "@variable" },
    ["@constant.builtin"]               = { fg = c.builtin, bg = nil },
    ["@constant.builtin.hyprlang"]    = { link = "Constant" },
    ["@constructor.lua"]                = { link = "@punctuation.bracket" },
    -- ["@function.builtin"]               = { link = "Special" },
    -- ["@function.builtin"]               = { fg = c.builtin, bg = nil },
    -- ["@keyword"]                        = { link = "@constant.builtin" },
    ["@keyword.break"]                  = { link = "@keyword.return" },
    ["@keyword.exception"]              = { fg = c.ret, bg = nil },
    ["@keyword.operator"]               = { link = "Keyword" },
    -- ["@keyword.operator.java"]          = { fg = c.special, bg = nil },
    ["@keyword.operator.java"]          = { link = "Keyword" },
    ["@keyword.import"]                 = { link = "PreProc"},
    ["@keyword.return"]                 = { fg = c.ret, bg = nil },
    ["@keyword.vim"]                    = { link = "Special" },
    -- ["@label.vimdoc"]                    = { link = "Keyword" },
    ["@label.vimdoc"]                    = { fg = c.keyword, bg = utils.blend(c.bg, 0.15, c.keyword)},
    -- ["@label.vimdoc"]                    = { fg = c.fg, bg = "#000000"},
    ["@markup.link"]                    = { link = "String" },
    ["@markup.raw.block"]               = { link = "Normal" },
    ["@markup.raw.vimdoc"]              = { link = "Function" },
    ["@module.builtin"]                 = { link = "@variable" },
    ["@property"]                       = { fg = c.fg, bg = nil },
    ["@punctuation.bracket"]            = { fg = utils.darken(c.fg, 0.30), bg = nil },
    ["@punctuation.delimiter"]          = { link = "@punctuation.bracket" },
    ["@punctuation.special.bash"]       = { link = "@variable" },
    ["@string.escape"]                  = { link = "@keyword.return" },
    ["@string.special.path"]            = { fg = c.builtin, bg = nil },
    ["@string.special.path.vim"]        = { link = "OkMsg" },
    ["@string.special.url.vimdoc"]      = { link = "OkMsg" },
    ["@type.builtin"]                   = { fg = native, bg = nil },
    ["@variable"]                       = { fg = c.fg, bg = nil },
    ["@variable.builtin"]               = { link = "@variable" },
    -- ["@variable.member"]               = { fg = member, bg = nil},
    ["@variable.member"]               = {},
    ["@variable.parameter.builtin.lua"] = { link = "@variable.parameter" },
    ["@variable.parameter.vimdoc"]      = { link = "DiagnosticOk" },
  }

  local plugins = {

    DapBreakpoint  = { link = "DiagnosticError" },
    DapStopped     = { fg = c.fg, bg = nil, bold = true },
    DapStoppedLine = { fg = nil,  bg = dark_border },
    -- DapLogPoint = {},
    -- DapBreakpointCondition = {},
    -- DapBreakpointRejected = {},

    NvimDapViewThread        = { link = "Normal"                           },
    NvimDapViewThreadStopped = { link = "DiagnosticError"                  },
    NvimDapViewWatchUpdated  = { fg = "#000000", bg = c.warning, bold=true },
    NvimDapViewFrameCurrent  = { link = "DiagnosticOk"                     },

    FugitiveUntrackedHeading  = { link = "Function"        },
    FugitiveUntrackedModifier = { fg = c.error,   bg = nil },
    FugitiveUnstagedModifier  = { fg = c.warning, bg = nil },
    FugitiveUnstagedHeading   = { link = "Function"        },
    fugitiveHeader            = { fg = c.fg,      bg = nil },
    fugitiveHelpHeader        = { link = "fugitiveHeader"  },

    GitSignsChange = { fg = utils.blend(c.primary, 0.70, linenr), bg = nil              },
    GitSignsDelete = { fg = utils.blend(c.error, 0.20, linenr),   bg = nil, bold = true },
    GitSignsAdd    = { fg = utils.blend(c.success, 0.45, linenr), bg = nil              },

    -- FzfLuaNormal        = { fg = nil,         bg = bg_float },
    FzfLuaNormal        = { link = "MsgArea" },
    FzfLuaBorder        = { link = "FloatBorderTransparent" },
    FzfLuaTitle         = { link = "FloatTitle"                 },
    -- FzfLuaTitleFlags         = { link = "FloatTitle"                 },
    FzfluaPreviewNormal = { link = "Normal"                 },
    FzfLuaPreviewBorder = { fg = dark_border, bg = c.bg     },

    FlashMatch      = { link = "Visual" },
    FlashCurrent    = { link = "IncSearch" },
    FlashLabel      = { link = "DiagnosticError" },
    FlashPrompt     = { link = "DiagnosticError" },
    FlashPromptIcon = { link = "DiagnosticWarn" },

    BlinkCmpSelection                    = { fg = nil, bg = cursorline, bold = true },
    BlinkCmpLabel                        = { link = "Normal"                     },
    BlinkCmpLabelMatch                   = { fg = c.selection, bg = nil              },
    BlinkCmpLabelDetail                  = { link = "Comment" },
    -- BlinkCmpLabelDescription             = { fg = c.special, bg = nil              },
    BlinkCmpSource                       = { link = "Comment" },
    BlinkCmpDocBorder                    = { link = "FloatBorder"                },
    BlinkCmpDocSeparator                 = { link = "Comment"                    },
    BlinkCmpSignatureHelpBorder          = { link = "FloatBorder"                },
    BlinkCmpSignatureHelpActiveParameter = { fg = c.error, bg = nil, bold = true },

    MiniHipatternsTodo  = { fg = c.error, bg = nil, bold = true },
    MiniHipatternsHack  = { link = "MiniHipatternsTodo"         },
    MiniHipatternsNote  = { link = "MiniHipatternsTodo"         },
    MiniHipatternsFixme = { link = "MiniHipatternsTodo"         },

    MiniPickBorder       = { link = "MiniBufferBorder"                      },
    MiniPickNormal       = { link = "MsgArea"                               },
    MiniPickMatchCurrent = { fg = nil,         bg = cursorline, bold = true },
    MiniPickBorderText   = { fg = nil,         bg = dark_border               },
    MiniPickPrompt       = { fg = nil,         bg = dark_border               },
    MiniPickPromptPrefix = { fg = nil,         bg = dark_border               },
    MiniPickPromptCaret  = { fg = c.ret,       bg = dark_border               },
    MiniPickMatchRanges  = { fg = c.selection, bg = nil                     },

    Folder                  = { fg = c.folder,     bg = nil                      },
    -- FloatBorder3            = { fg = dark_border,  bg = bg_float                 },  -- Border of floating windows.
    MiniFilesBorder         = { link = "FloatBorder"                             },
    MiniFilesTitle          = { fg = comment,      bg = dark_border, bold = true },
    MiniFilesTitleFocused   = { fg = nil,          bg = dark_border, bold = true },
    MiniFilesBorderModified = { fg = c.warning,    bg = bg_float,    bold = true },
    -- MiniFilesCursorLine     = { link = "Visual"                          },

    SnacksPicker            = { fg = nil,                             bg = bg_linenr },
    SnacksPickerInputBorder = { fg = c.primary,                       bg = bg_linenr },
    SnacksDashboardSpecial  = { link = "Function"                                    },
    SnacksDashboardDesc     = { link = "Function"                                    },
    SnacksDashboardTitle    = { link = "Keyword"                                     },
    SnacksDashboardFile     = { link = "Identifier"                                  },
    SnacksDashboardIcon     = { link = "String"                                      },
    SnacksIndent            = { fg = utils.brighten(c.bg, 0.04, 0.03), bg = nil      },
    SnacksIndentScope       = { fg = c.primary,                        bg = nil      },
  }

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
