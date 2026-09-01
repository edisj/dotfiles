local utils = require("colorscheme.utils")
local M = {}


local function set_terminal_colors(c)
    -- vim.g.terminal_color_0  = dark_border
    vim.g.terminal_color_1  = c.red
    vim.g.terminal_color_2  = c.green
    vim.g.terminal_color_3  = c.yellow
    vim.g.terminal_color_4  = c.blue
    vim.g.terminal_color_5  = c.magenta
    vim.g.terminal_color_6  = c.cyan
    vim.g.terminal_color_7  = c.fg
    -- vim.g.terminal_color_8  = linenr
    vim.g.terminal_color_9  = utils.brighten(vim.g.terminal_color_1, 0.20, 0.10)
    vim.g.terminal_color_10 = utils.brighten(vim.g.terminal_color_2, 0.20, 0.10)
    vim.g.terminal_color_11 = utils.brighten(vim.g.terminal_color_3, 0.20, 0.10)
    vim.g.terminal_color_12 = utils.brighten(vim.g.terminal_color_4, 0.30, 0.10)
    vim.g.terminal_color_13 = utils.brighten(vim.g.terminal_color_5, 0.20, 0.10)
    vim.g.terminal_color_14 = utils.brighten(vim.g.terminal_color_6, 0.20, 0.10)
    vim.g.terminal_color_15 = c.bright_white or "#dddddd"
end

local function hl_groups(c)
  local cursorline = utils.brighten(c.bg, 0.05, 0.02)
  local comment = utils.brighten(c.bg, 0.02, 0.25)
  local linenr = utils.brighten(c.bg, 0.10, 0.12)

  local bg_visual = utils.brighten(c.bg, 0.10, 0.10)
  -- local fg_visual = utils.lighten(c.fg, 0.25)

  local dark_border = utils.darken(c.bg, 0.75)

  local bg_float = utils.darken(c.bg, 0.30)
  local bg_sidebar = utils.darken(c.bg, 0.15)

  local bg_pmenu = utils.brighten(c.bg, 0.15, 0.05)
  bg_pmenu = bg_sidebar
  local pmenu_border = c.selection

  c.statusline = utils.brighten(c.bg, 0.15, 0.15)
  local on_statusline = utils.brighten(c.statusline, 0.01 ,0.35)
  c.statusline = bg_float
  on_statusline = utils.brighten(c.fg, 0.10)


  c.selection = utils.blend(c.bg, 0.10, c.match)
  c.selection = bg_visual

  local groups = {
    { -- syntax {{{
      Comment        = { fg = comment,      bg = nil, italic = true },  -- any comment
      Constant       = { fg = c.constant,   bg = nil                },  -- any constant
      Boolean        = { fg = c.boolean,    bg = nil, bold = true   },  -- a boolean constant: TRUE, false
      Number         = { fg = c.number,     bg = nil                },  -- a number constant: 234, 0xff
      Float          = { link = "Number"                            },  -- a floating point constant: 2.3e10
      String         = { fg = c.str,        bg = nil                },  -- a string constant: "this is a string"
      Character      = { link = "String"                            },  -- a character constant: 'c', '\n'
      Identifier     = { fg = c.fg,         bg = nil                },  -- any variable name
      Function       = { fg = c.func,       bg = nil                },  -- function name (also: methods for classes)
      Operator       = { fg = c.operator,   bg = nil                },  -- "sizeof", "+", "*", etc.

      Keyword	       = { fg = c.keyword,     bg = nil },  -- any other keyword
      Statement	     = { link = "Keyword"             },  -- any statement
      Exception	     = { link = "Keyword"             },  -- try, catch, throw
      Conditional	   = { link = "Keyword"             },  -- if, then, else, endif, switch, etc.
      Repeat		     = { link = "Conditional"         },  -- for, do, while, etc.
      Label		       = { link = "Conditional"         },  -- case, default, etc.

      PreProc        = { link = "Special"            },  -- generic Preprocessor
      Include	       = { link = "PreProc"            },  -- preprocessor #include
      Define	       = { link = "Preproc"            },  -- preprocessor #define
      Macro	         = { link = "PreProc"            },  -- same as Define
      PreCondit      = { link = "PreProc"            },  -- preprocessor #if, #else, #endif, etc.

      Type	         = { fg = c.type,       bg = nil },  -- int, long, char, etc.
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

      Added   = { fg = c.ok, bg = utils.blend(c.bg, 0.05, c.ok) },
      Removed = { fg = c.error,   bg = utils.blend(c.bg, 0.05, c.error) },
    }, -- }}}

    { -- base {{{
      Normal           = { fg = c.fg,         bg = c.bg,                     },  -- Normal text.
      NormalNC         = { link = "Normal"                                   },  -- Normal text in non-current windows.
      NormalSplit      = { fg = c.fg,         bg = bg_sidebar                },  -- Normal text in special splits.
      Bold = { bold = true },
    }, -- }}}

    { -- float {{{
      NormalFloat      = { fg = c.fg,         bg = bg_float                  },  -- Normal text in floating windows.
      FloatBorder      = { fg = dark_border,  bg = bg_float,    bold = true  },  -- Border of floating windows.
      FloatTitle       = { fg = c.fg,         bg = dark_border               },  -- Title of floating windows.
      FloatFooter      = { fg = c.fg,         bg = dark_border, bold = true  },  -- Footer of floating windows.
    }, -- }}}

    { -- editor {{{
      EndOfBuffer      = { fg = linenr,       bg = nil                       },  -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
      ColorColumn      = { fg = nil,          bg = bg_sidebar,               },
      LineNr           = { fg = linenr,       bg = nil                       },  -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
      CursorLineNr     = { fg = c.fg,         bg = cursorline,  bold = true  },  -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "oth", for the cursor line.
      -- Folded           = { fg = c.primary,   bg = nil                       },  -- Line used for closed folds.
      -- FoldColumn       = { fg = comment,     bg = c.bg                      },  -- 'foldcolumn'
      SignColumn       = { fg = linenr,       bg = nil                       },  -- Column where |signs| are displayed.
      NonText          = { fg = linenr,       bg = nil                       },  -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text
      WhiteSpace       = { fg = comment,      bg = nil                       },
      WinSeparator     = { fg = bg_float,  bg = bg_sidebar                  },  -- Separators between window splits.
      WinSeparatorNC   = { link = "WinSeparator"                             },
    }, -- }}}

    { -- cursor {{{
      Cursor           = { fg = c.bg,         bg = c.accent                  },  -- Character under the cursor.
      CursorLine       = { fg = nil,          bg = cursorline                },  -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    }, -- }}}

    { -- visual {{{
      Visual           = { fg = nil,          bg = bg_visual,          },  -- Visual mode selection.
      VisualNOS        = { link = "Visual"                                   },  -- Visual mode selection when vim is "Not Owning the Selection".
    }, -- }}}

    { -- search {{{
      CurSearch        = { fg = c.bg,      bg = c.search,   },  --Current match for the last search pattern (see 'hlsearch').
      Search           = { link = "Visual" },  -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
      IncSearch        = { fg = c.bg,      bg = c.search,   },  -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
      Substitute       = { link = "Search"                    },  -- |:substitute| replacement text highlighting.
      MatchParen       = { fg = c.search, bg = nil, bold = true },  -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    }, -- }}}

    { -- bars {{{
      StatusLine       = { fg = on_statusline, bg = c.statusline               },  -- Status line of current window.
      StatusLineNC     = { fg = utils.lighten(c.statusline, 0.25), bg = c.statusline                               },  -- Status lines of not-current windows.
      TabLine          = { fg = linenr,      bg = bg_sidebar,                 },  -- Tab pages line, not active tab page label.
      TabLineKey       = { link = "TabLine" },
      TabLineFill      = { link = "Normal"                          },  -- Tab pages line, where there are no labels.
      TabLineSel       = { fg = on_statusline,   bg = cursorline, underline=true, sp=linenr },  -- Tab pages line, active tab page label.
      -- TabLineBorder    = {  },
      -- TabLineBorderSel = { link = "TabLine" },
      WinBar           = { fg = nil,       bg = nil                         },  -- Window bar of current window.
      WinBarNC         = { link = "WinBar"                                  },  -- Window bar of not  -current windows.
    }, -- }}}

    { -- msg {{{
      -- MsgArea          = { fg = nil,          bg = bg_sidebar                       },  -- Area for messages and command-line, see also 'cmdheight'.
      MsgArea          = { link = "Normal" },  -- Area for messages and command-line, see also 'cmdheight'.
      MsgSeparator     = { fg = c.statusline, bg = bg_sidebar                       },  -- Separator for scrolled messages |msgsep|.
      MoreMsg          = { fg = nil,    bg = nil,       bold = nil   },  -- |more-prompt|
      ModeMsg          = { fg = c.special,    bg = nil                },  -- 'showmode' message (e.g., "-- INSERT --").
      ErrorMsg         = { fg = c.error, bg = nil },
      Question         = { fg = c.special,    bg = nil, bold = true   },  -- |hit-enter| prompt and yes/no questions.
    }, -- }}}

    { -- diff {{{
      DiffAdd	    = {},
      DiffChange  = {},
      DiffDelete  = {},
      DiffText    = {},
      DiffTextAdd = {},
    }, -- }}}

    { -- pmenu {{{
      Pmenu            = { fg = nil,         bg = bg_pmenu                  },  -- Popup menu: Normal item.
      PmenuSel         = { fg = utils.lighten(c.fg, 0.40 ),         bg = c.selection,   bold=true,  },  -- Popup menu: Selected item.
      PmenuMatch       = { fg = c.func,     bg = nil,                        },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
      PmenuMatchSel    = { fg = utils.brighten(c.func, 0.50, 0.05),      bg = nil, bold = true                       },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
      PmenuExtra       = { fg = comment,      bg = nil,                      },  -- Popup menu: Normal item "extra text".
      PmenuThumb       = { fg = pmenu_border, bg = pmenu_border                 },  -- Popup menu: Thumb of the scrollbar.
      PmenuSbar        = { fg = pmenu_border, bg = bg_pmenu                  },  -- Popup menu: Scrollbar.
      PmenuBorder      = { fg = pmenu_border, bg = bg_pmenu                       }, -- Popup menu: border of popup menu.
      PmenuKind = { fg = nil, bg = nil },
      -- PmenuKindSel    = { fg = c.error,    bg = nil                       },  -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
      -- PmenuExtra       = { fg = comment,      bg = nil,                      },  -- Popup menu: Normal item "extra text".
      PmenuExtraSel       = { fg = c.error,      bg = nil,                      },  -- Popup menu: Normal item "extra text".
      WildMenu         = { fg = c.fg,         bg = c.bg                      },  -- Current match in 'wildmenu' completion.
    }, -- }}}

    { -- quickfix {{{
      QuickFixLine     = { fg = nil,          bg = cursorline,  bold = true   },  -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
      qfFileName       = { link = "Directory" },
      qfLineNr         = { link = "Number" },
      qfColNr          = { link = "LineNr" },
      qfText           = { link = "@variable" },
      qfSeparator1     = "@punctuation.bracket",
      qfSeparator2     = "qfSeparator1",
    }, -- }}}

    { -- spell {{{
      SpellBad     = { sp = c.error,   undercurl = true },  -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
      SpellCap     = { sp = c.warn,    undercurl = true },  -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
      SpellLocal   = { sp = c.info,    undercurl = true },  -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
      SpellRare    = { sp = c.info,    undercurl = true },  -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
    }, -- }}}

    { -- misc {{{
      Title            = { fg = c.func,          bg = nil,        bold = true  },  -- Titles for output from ":set all", ":autocmd" etc.
      Directory        = { fg = c.directory,   bg = nil },  -- Directory names (and other special names in listings).
    }, -- }}}

    { -- lsp {{{
      DiagnosticError            = { fg = c.error, bg = nil },
      DiagnosticWarn             = { fg = c.warn,  bg = nil },
      DiagnosticInfo             = { fg = c.info,  bg = nil },
      DiagnosticHint             = { fg = c.hint,  bg = nil },
      DiagnosticOk               = { fg = c.ok,    bg = nil },
      DiagnosticSignError        = { fg = c.error, bg = nil    },   -- Used for "Error" signs in sign column.
      DiagnosticSignWarn         = { fg = c.warn,  bg = nil    },   -- Used for "Warn" signs in sign column.
      DiagnosticSignInfo         = { fg = c.info,  bg = nil    },   -- Used for "Info" signs in sign column.
      DiagnosticSignHint         = { link = "DiagnosticHint"     },   -- Used for "Hint" signs in sign column.
      DiagnosticSignOk           = { link = "DiagnosticOk"       },   -- Used for "Ok" signs in sign column.
      DiagnosticSignColError     = { fg = c.error,   bg = utils.blend(c.bg, 0.12, c.error)   },
      DiagnosticSignColWarn      = { fg = c.warn,   bg = utils.blend(c.bg, 0.08, c.warn)  },
      DiagnosticUnnecessary      = {},
      DiagnosticUnderlineError   = { sp = c.error, undercurl = true },
      DiagnosticUnderlineWarn    = { sp = c.warn,  undercurl = true },
      DiagnosticUnderlineInfo    = { sp = c.info,  undercurl = true },
      DiagnosticUnderlineOk      = { sp = c.ok,    undercurl = true },
      DiagnosticUnderlineHint    = {},

      DiagnosticVirtualTextError = { link = "DiagnosticError"    },
      DiagnosticVirtualTextWarn  = { link = "DiagnosticWarn"     },
      DiagnosticVirtualTextInfo  = { link = "DiagnosticInfo"     },
      DiagnosticVirtualTextHint  = { link = "DiagnosticHint"     },
      DiagnosticVirtualTextOk    = { link = "DiagnosticOk"       },
      DiagnosticVirtualLinesError = { fg = c.error, bg = bg_float },
      DiagnosticVirtualLinesWarn = { fg = c.warn, bg = bg_float },
      DiagnosticVirtualLinesInfo = { fg = c.info, bg = bg_float },
      DiagnosticVirtualLinesHint = { fg = c.hint, bg = bg_float },
    }, -- }}}

    { -- treesitter {{{
      -- ["@comment.documentation"]       = { fg   = c.documentation, bg = nil },
      ["@constant.bash"]                  = { link = "@variable" },
      ["@constant.builtin"]            = { fg = c.constant, bg = nil, bold = true },
      ["@constant.builtin.hyprlang"]      = { link = "Constant" },
      ["@constructor.lua"]                = { link = "@punctuation.bracket" },
      -- ["@keyword"]                        = { fg = c.keyword, bg = nil, bold = false, italic = true },
      ["@keyword.break"]                  = { link = "@keyword.return" },
      ["@keyword.do_block"]               = { fg = c.keyword, bg = nil },
      ["@keyword.exception"]              = { fg = c.ret, bg = nil },
      ["@keyword.operator"]               = { fg = c.operator, bg = nil, bold = true },
      ["@keyword.conditional"]            = { fg = c.keyword, bg = nil,  bold = false },
      ["@keyword.repeat"]                 = { fg = c.keyword, bg = nil,  bold = false },
      ["@keyword.function"]               = { fg = c.keyword, bg = nil,  bold = false },
      ["@keyword.operator.java"]          = { link = "Keyword" },
      ["@keyword.modifier"]               = { link = "Operator" },
      ["@keyword.import"]                 = { link = "PreProc"},
      ["@keyword.return"]                 = { fg = c.ret, bg = nil, bold = false },
      ["@keyword.vim"]                    = { link = "Keyword" },
      ["@function.macro.vim"]             = { link = "DiagnosticOk" },
      ["@label.vimdoc"]                   = { link = "Function" },
      ["@module.builtin"]                 = { link = "Operator" },
      ["@property"]                       = { fg = c.fg, bg = nil },
      -- ["@punctuation.bracket"]            = { fg = utils.darken(c.fg, 0.30), bg = nil },
      ["@punctuation.bracket"]            = "@function.builtin",
      ["@punctuation.delimiter"]          = { link = "@punctuation.bracket" },
      ["@punctuation.special.bash"]       = { link = "@variable" },
      ["@string.escape"]                  = { fg = utils.brighten(c.str, 0.10, 0.15), bg = nil },
      ["@string.special.path"]            = { fg = c.builtin, bg = nil },
      ["@string.special.path.vim"]        = { fg = c.folder, bg = nil },
      ["@string.special.url.vimdoc"]      = { link = "Keyword" },
      ["@variable"]                       = { fg = c.fg, bg = nil, },
      ["@variable.builtin"]               = { link = "@variable" },
      ["@variable.member"]               = {},
      ["@variable.parameter.builtin.lua"] = { link = "@variable.parameter" },
      ["@variable.parameter.vimdoc"]      = { link = "DiagnosticOk" },

      ["@type.builtin"] = { fg = c.builtin, bg = nil, bold = true },
      ["@module"] = { fg = c.operator, bg = nil },

      ["@keyword.local"] = { fg = c.builtin, bg = nil, italic = true  },

      -- ["@type.builtin.cpp"]  = { link = "Keyword" },
      ["@function.cpp"] = { link = "Function" },

      ["@markup.link"]       = "Special",
      ["@markup.raw.vimdoc"] = "Type",
      ["@markup.heading.1"]  = { fg = c.func, bg = nil },
      ["@markup.heading.2"]  = "@markup.heading.1",
      ["@markup.heading.3"]  = "@markup.heading.1",
      ["@markup.heading.4"]  = "@markup.heading.1",
      ["@markup.heading.5"]  = "@markup.heading.1",
      ["@markup.heading.6"]  = "@markup.heading.1",
    }, -- }}}

    { -- plugins {{{

      MsgAreaWinBar = "MsgArea",
      -- MsgAreaWinBarFill = { fg = comment, bg = nil },
      -- MsgAreaWinBarSel = { link = "Title" },
      MsgAreaWinBarSep = { fg = linenr, bg = nil },
      MsgAreaCmpLabelDescription = "Comment",

      -- DapUINormal = { link = "NormalSplit" },
      DapBreakpoint  = { link = "DiagnosticError" },
      DapStopped     = { fg = c.fg, bg = nil, bold = true },
      DapStoppedLine = { fg = nil,  bg = dark_border },
      -- DapLogPoint = {},
      -- DapBreakpointCondition = {},
      -- DapBreakpointRejected = {},

      NvimDapViewThread        = { link = "Normal"                           },
      NvimDapViewThreadStopped = { link = "DiagnosticError"                  },
      NvimDapViewWatchUpdated  = { fg = "#000000", bg = c.warn, bold=true },
      NvimDapViewFrameCurrent  = { link = "DiagnosticOk"                     },

      FugitiveUntrackedHeading  = { link = "Function"        },
      FugitiveUntrackedModifier = { fg = c.error,   bg = nil },
      FugitiveUnstagedModifier  = { fg = c.warn, bg = nil },
      FugitiveUnstagedHeading   = { link = "Function"        },
      fugitiveHeader            = { fg = c.fg,      bg = nil },
      fugitiveHelpHeader        = { link = "fugitiveHeader"  },

      GitSignsChange = { fg = utils.blend(c.special, 0.25, c.bg), bg = nil              },
      GitSignsDelete = { fg = utils.blend(c.error, 0.10, c.bg),   bg = nil, bold = true },
      GitSignsAdd    = { fg = utils.blend(c.ok, 0.25, c.bg), bg = nil              },

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

      BlinkCmpSelection                    = { fg = nil, bg = c.selection, bold = true },
      BlinkCmpLabel                        = { link = "Normal"                     },
      BlinkCmpLabelMatch                   = { fg = c.match, bg = nil              },
      BlinkCmpLabelDetail                  = { link = "Comment" },
      BlinkCmpMenuBorder                   = { link = "PmenuBorder" },
      BlinkCmpMenu                         = { link = "Pmenu" },

      BlinkCmpSource                       = { link = "Comment" },
      BlinkCmpDocBorder                    = { link = "FloatBorder"                },
      BlinkCmpDocSeparator                 = { link = "Comment"                    },
      BlinkCmpSignatureHelpBorder          = { link = "FloatBorder"                },
      BlinkCmpSignatureHelpActiveParameter = { fg = c.error, bg = nil, bold = true },

      MiniJump = { link = "Substitute" },

      MiniIconsYellow = { fg = c.folder },
      MiniIconsPurple = { fg = c.magenta },

      MiniHipatternsTodo  = { fg = c.error, bg = nil, bold = true },
      MiniHipatternsHack  = { link = "MiniHipatternsTodo"         },
      MiniHipatternsNote  = { link = "MiniHipatternsTodo"         },
      MiniHipatternsFixme = { link = "MiniHipatternsTodo"         },

      MiniPickBorder       = { fg = linenr, bg = c.bg                      },
      MiniPickBorderBusy   = { link = "MsgArea"                      },
      -- MiniPickCursor       = { fg = c.bg, bg = c.fg },
      MiniPickNormal       = { link = "MsgArea" },
      -- MiniPickMatchCurrent = { fg = c.bg,         bg = c.keyword, bold = false },
      MiniPickBorderText   = { fg = c.fg,     bg = c.bg },
      MiniPickPrompt       = { fg = c.func,   bg = bg_float               },
      MiniPickPromptPrefix = { fg = comment,     bg = bg_float,    italic=true           },
      MiniPickPromptCaret  = { fg = c.fg,     bg = bg_float               },
      MiniPickMatchRanges  = { fg = c.error,  bg = nil                    },
      MiniPickMatchCurrent = { fg = nil,      bg = c.selection, bold = true },
      MiniCmdlinePeekNormal = { link = "MsgArea" },

      Folder                  = { fg = c.folder,     bg = nil                      },
      -- FloatBorder3            = { fg = dark_border,  bg = bg_float                 },  -- Border of floating windows.
      MiniFilesBorder         = { link = "FloatBorder"                             },
      MiniFilesTitle          = { fg = comment,      bg = dark_border, bold = true },
      MiniFilesTitleFocused   = { fg = nil,          bg = dark_border, bold = true },
      MiniFilesBorderModified = { fg = c.warn,    bg = bg_float,    bold = true },
      -- MiniFilesCursorLine     = { link = "Visual"                          },

      RenderMarkdownH1Bg = { fg = nil, bg = nil },
      RenderMarkdownH2Bg = { fg = nil, bg = nil },
      RenderMarkdownH3Bg = {  },
      RenderMarkdownH4Bg = {  },
      RenderMarkdownH5Bg = {  },
      RenderMarkdownH6Bg = {  },

      NeoTreeNormal = { fg = nil, bg = bg_sidebar },
      NeoTreeNormalNC = "NeoTreeNormal",
      NeoTreeDirectoryIcon = { fg = c.folder, bg = nil },

      SnacksPicker            = { fg = nil,                             bg = nil },
      SnacksPickerInputBorder = { fg = c.primary,                       bg = nil },
      SnacksDashboardSpecial  = { link = "Function"                                    },
      SnacksDashboardDesc     = { link = "Function"                                    },
      SnacksDashboardTitle    = { link = "Keyword"                                     },
      SnacksDashboardFile     = { link = "Identifier"                                  },
      SnacksDashboardIcon     = { link = "String"                                      },
      SnacksIndent            = { fg = utils.brighten(c.bg, 0.04, 0.03), bg = nil      },
      SnacksIndentScope       = { fg = c.operator,                        bg = nil      },
    }, -- }}}
  }
  return groups
end

M.set_hls = function(c)
  local set_hl = vim.api.nvim_set_hl
  for _, highlights in ipairs(hl_groups(c)) do
    for group, hl in pairs(highlights) do
      hl = type(hl) == "string" and { link = hl } or hl ---@type vim.api.keyset.highlight
      set_hl(0, group, hl)
    end
  end
  set_terminal_colors(c)
end

return M
