local c = require("matugen")
local utils = require("colorscheme.utils")

if vim.g.colors_name then
    vim.cmd.highlight "clear"
end
if vim.fn.exists "syntax_on" then
    vim.cmd.syntax "reset"
end

vim.o.termguicolors = true
vim.g.colors_name = "matugen"

vim.keymap.set("n", "<C-Enter>", "<CMD>colorscheme matugen<CR>")
local bg = c.background
local float_bg = utils.darken(bg, 0.10)
-- local fg = c.on_background

local fg = utils.lighten(bg, 0.75)
local accent = utils.brighten(bg, 0.70, 0.5)
local comment = utils.blend(bg, 0.50, fg)
local identifier = utils.blend(fg, 0.25, accent)
local keyword = utils.blend(bg, 0.55, identifier)
local func = utils.blend(fg, 0.65, accent)
local whitespace = utils.blend(bg, 0.15, comment)

local cursorline = utils.brighten(bg, 0.10, 0.05)
-- local statusline = utils.brighten(bg, 0.40, 0.10)
local statusline = c.on_primary
local statusline = c.primary_container
local on_statusline = utils.lighten(statusline, 0.35)
local qfline = utils.brighten(bg, 0.20, 0.10)
-- local visual = utils.brighten(bg, 0.35, 0.10)
-- local visual = utils.brighten(c.yellow,0, 0.10)
local visual = utils.darken(c.yellow)
local search = utils.blend(bg, 0.20, accent)

vim.g.terminal_color_0  = c.transparent_black
vim.g.terminal_color_1  = c.red
vim.g.terminal_color_2  = c.green
vim.g.terminal_color_3  = c.yellow
vim.g.terminal_color_4  = c.purple
vim.g.terminal_color_5  = c.pink
vim.g.terminal_color_6  = c.cyan
vim.g.terminal_color_7  = c.white
vim.g.terminal_color_8  = c.selection
vim.g.terminal_color_9  = c.bright_red
vim.g.terminal_color_10 = c.bright_green
vim.g.terminal_color_11 = c.bright_yellow
vim.g.terminal_color_12 = c.bright_blue
vim.g.terminal_color_13 = c.bright_magenta
vim.g.terminal_color_14 = c.bright_cyan
vim.g.terminal_color_15 = c.bright_white
vim.g.terminal_color_background = bg
vim.g.terminal_color_foreground = fg

local highlights = {

    Comment        = { fg = comment,     bg = nil },    -- any comment
    Constant       = { fg = c.orange,    bg = nil },    -- any constant
    Number         = { link = "Constant" },             -- a boolean constant: TRUE, false
    Float          = { link = "Number" },               -- a floating point constant: 2.3e10
    String         = { fg = c.green,     bg = nil },    -- a string constant: "this is a string"
    Character      = { link = "String" },               -- a character constant: 'c', '\n'
    Boolean        = { fg = c.orange,    bg = nil },    -- a number constant: 234, 0xff
    Identifier     = { fg = identifier,  bg = nil },    -- any variable name
    Function       = { fg = func,        bg = nil },    -- function name (also: methods for classes)
    Keyword	       = { fg = c.blue,      bg = nil },    -- any other keyword
    Statement	   = { link = "Keyword" },              -- any statement
    Conditional	   = { link = "Statement" },            -- if, then, else, endif, switch, etc.
    Repeat		   = { link = "Statement" },            -- for, do, while, etc.
    Label		   = { link = "Statement" },            -- case, default, etc.
    Exception	   = { link = "Statement" },            -- try, catch, throw
    Operator       = { link = "Keyword" },              -- "sizeof", "+", "*", etc.
    PreProc        = { fg = c.cyan,      bg = nil },    -- generic Preprocessor
    Include	       = { link = "PreProc" },              -- preprocessor #include
    Define	       = { link = "Preproc" },              -- preprocessor #define
    Macro	       = { link = "PreProc" },              -- same as Define
    PreCondit      = { link = "PreProc" },              -- preprocessor #if, #else, #endif, etc.
    Type	       = { fg = c.yellow,    bg = nil },    -- int, long, char, etc.
    StorageClass   = { link = "Type" },	                -- static, register, volatile, etc.
    Structure	   = { link = "Type" },                 -- struct, union, enum, etc.
    Typedef		   = { link = "Type" },                 -- a typedef
    Special	       = { fg = c.cyan,      bg = nil },    -- any special symbol
    SpecialChar	   = { link = "Special" },              -- special character in a constant
    Tag		       = { link = "Special" },              -- you can use CTRL-] on this
    Delimiter	   = { link = "Special" },              -- character that needs attention
    SpecialComment = { link = "Special" },              -- special things inside a comment
    Debug		   = { link = "Special" },              -- debugging statements
    Error          = { fg = c.error,     bg = nil },    -- any erroneous construct
    Ignore         = { link = "Normal" },               -- left blank, hidden  |hl-Ignore|
    -- Todo       = { fg = c.bg,           bg = syn.Todo },    -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX
    -- Bold       = { bold = true },
    -- Italic     = { italic = true },
    -- Underlined = { underline = true },

    Normal            = { fg = fg,  bg = bg },       -- Normal text.
    NormalTransparent = { fg = fg,  bg = "none" },       -- Normal text.
    NormalNC     = { link = "Normal" },                               -- Normal text in non-current windows.

    NormalFloat  = { fg = fg,             bg = float_bg },        -- Normal text in floating windows.
    FloatBorder  = { fg = c.primary_container,      bg = float_bg },        -- Border of floating windows.
    FloatTitle   = { fg = c.on_primary_container,   bg = c.primary_container },           -- Title of floating windows.
    FloatFooter  = { fg = c.on_primary,   bg = c.primary, bold = true },           -- Footer of floating windows.
    Cursor       = { fg = bg,             bg = fg },               -- Character under the cursor.
    CursorLine   = { fg = nil,            bg = cursorline },      -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
    LineNr       = { fg = comment,        bg = nil },                -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
    CursorLineNr = { fg = c.orange,       bg = cursorline, bold = true },      -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "oth", for the cursor line.

    Visual      = { fg = c.on_yellow,             bg = visual, bold = true },          -- Visual mode selection.
    VisualNOS   = { link = "Visual" },        -- Visual mode selection when vim is "Not Owning the Selection".

    Title      = { fg = utils.blend(bg, 0.90, accent), bg = nil },         -- Titles for output from ":set all", ":autocmd" etc.
    Directory    = { fg = c.primary,    bg = nil },                -- Directory names (and other special names in listings).
    EndOfBuffer  = { link = "LineNr" },                -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
    -- Folded       = { fg = c.primary,       bg = nil },                -- Line used for closed folds.
    -- FoldColumn   = { fg = comment,     bg = c.bg },               -- 'foldcolumn'
    Search       = { fg = nil,             bg = search },          -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
    IncSearch    = { fg = c.on_primary,    bg = c.primary,  bold = true },       -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
    Substitute   = { fg = c.on_red,        bg = c.red },                          -- |:substitute| replacement text highlighting.
    MatchParen   = { fg = c.orange,        bg = nil,        bold = true },          -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
    MsgArea      = { fg = nil,             bg = float_bg },         -- Area for messages and command-line, see also 'cmdheight'.
    ModeMsg      = { fg = accent,          bg = nil },                -- 'showmode' message (e.g., "-- INSERT --").
    MoreMsg      = { fg = accent,          bg = float_bg },         -- |more-prompt|
    NonText      = { fg = comment,         bg = nil },                -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text
    Question     = { fg = c.primary,       bg = nil, bold = true },          -- |hit-enter| prompt and yes/no questions.
    WhiteSpace   = { fg = whitespace,      bg = nil},

    Pmenu        = { fg = nil,    bg = utils.darken(bg, 0.40) },                      -- Popup menu: Normal item.
    PmenuSel     = { fg = nil,    bg = utils.brighten(bg, 0.35, 0.10), bold = true }, -- Popup menu: Selected item.
    PmenuMatch   = { fg = accent, bg = nil },                                      -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
    PmenuThumb   = { fg = accent, bg = nil },                                      -- Popup menu: Thumb of the scrollbar.
    PmenuSbar    = { link = "Pmenu" },                                             -- Popup menu: Scrollbar.
    WildMenu     = { fg = bg,     bg = float_bg },        -- Current match in 'wildmenu' completion.

    WinSeparator        = { fg = c.primary_container,      bg = bg },          -- Separators between window splits.
    WinSeparator2       = { fg = c.primary_container,      bg = float_bg },          -- Separators between window splits.
    WinSeparatorNC      = { link = "WinSeparator" },
    WinSeparatorFocused = { link = "WinSeparator" },

    StatusLine                = { fg = nil,             bg = statusline },                     -- Status line of current window.
    OnStatusLine              = { fg = on_statusline,   bg = statusline },                     -- Status line of current window.
    StatusLineNC              = { link = "Statusline" },                                       -- Status lines of not-current windows.
    StatusLineTerm            = { link = "Statusline" },                                       -- Status line of |terminal| window.
    StatuslineCommand         = { fg = c.white,         bg = statusline, bold = true },
    StatuslineInsert          = { fg = c.green,         bg = statusline, bold = true },
    StatuslineNormal          = { fg = c.primary,       bg = statusline, bold = true },
    StatuslineVisual          = { fg = visual,          bg = statusline, bold = true },
    StatuslineCommandInverted = { fg = statusline,      bg = c.white,    bold = true },
    StatuslineInsertInverted  = { fg = statusline,      bg = c.green,    bold = true },
    StatuslineNormalInverted  = { fg = statusline,      bg = c.primary,  bold = true },
    StatuslineVisualInverted  = { fg = statusline,      bg = visual,     bold = true },

    QuickFixLine  = { fg = nil,      bg = qfline, bold = true },    -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
    qfFileName    = { fg = c.blue,   bg = nil },
    qfLineNr      = { fg = c.yellow, bg = nil },
    qfSeparator1  = { link = "@punctuation.bracket" },
    qfSeparator2  = { link = "qfSeparator1" },

    -- SignColumn   = { fg = ed.SignColumn,   bg = ed.NormalFloat },     -- Column where |signs| are displayed.
    -- TabLine        = {  },         -- Tab pages line, not active tab page label.
    TabLineFill    = { link = "TabLine" },    -- Tab pages line, where there are no labels.
    TabLineSel     = { link = "TabLine" },     -- Tab pages line, active tab page label.

    WinBar         = { bg = nil },          -- Window bar of current window.
    WinBarNC       = { link = "WinBar" },   -- Window bar of not-current windows.
    WinBarFileName = { fg = c.on_primary_container, bg = c.primary_container, bold = true },

    SpellBad     = { sp = c.error,  undercurl = true },             -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
    SpellCap     = { sp = c.yellow, undercurl = true },             -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
    SpellLocal   = { sp = c.blue,   undercurl = true },             -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
    SpellRare    = { sp = c.blue,   undercurl = true },             -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.

    DiagnosticError            = { fg = c.error,  bg = nil },
    DiagnosticWarn             = { fg = c.yellow, bg = nil },
    DiagnosticInfo             = { fg = c.blue,   bg = nil },
    DiagnosticHint             = { fg = c.blue,   bg = nil },
    DiagnosticOk               = { fg = c.green,  bg = nil },
    DiagnosticVirtualTextError = { link = "DiagnosticError" },
    DiagnosticVirtualTextWarn  = { link = "DiagnosticWarn" },
    DiagnosticVirtualTextInfo  = { link = "DiagnosticInfo" },
    DiagnosticVirtualTextHint  = { link = "DiagnosticHint" },
    DiagnosticVirtualTextOk    = { link = "DiagnosticOk" },
    DiagnosticSignError        = { link = "DiagnosticError" },     -- Used for "Error" signs in sign column.
    DiagnosticSignWarn         = { link = "DiagnosticWarn" },      -- Used for "Warn" signs in sign column.
    DiagnosticSignInfo         = { link = "DiagnosticInfo" },      -- Used for "Info" signs in sign column.
    DiagnosticSignHint         = { link = "DiagnosticHint" },      -- Used for "Hint" signs in sign column.
    DiagnosticSignOk           = { link = "DiagnosticOk" },        -- Used for "Ok" signs in sign column.
    DiagnosticUnnecessary      = { },
    DiagnosticUnderlineError   = { sp = c.error,  underline = true },
    DiagnosticUnderlineWarn    = { sp = c.yellow, underline = true },
    DiagnosticUnderlineInfo    = { sp = c.blue,   underline = true },
    DiagnosticUnderlineHint    = { sp = c.blue,   underline = true },
    DiagnosticUnderlineOk      = { sp = c.green,  underline = true },

    ["@variable"]                  = { fg = fg, bg = nil },
    ["@punctuation.bracket"]       = { fg = utils.darken(fg, 0.30), bg = nil },
    ["@punctuation.delimiter"]     = { link = "@punctuation.bracket" },
    ["@comment.documentation"]     = { fg = utils.darken(c.green, 0.20), bg = nil },
    ["@string.special.url.vimdoc"] = { fg = c.magenta, bg = nil },
    ["@constant.builtin"]          = { fg = c.magenta, bg = nil },
    ["@keyword.return"]            = { fg = c.red, bg = nil, bold = true },
    ["@variable.parameter.vimdoc"] = { fg = c.green, bg = nil },
    ["@constructor.lua"] = { link = "@punctuation.bracket" },

    ["@lsp.type.variable"]      = { },                    -- Identifiers that declare or reference a local or global variable
    ["@lsp.type.modifier"]      = { link = "Keyword" },                    -- Identifiers that declare or reference a local or global variable
    -- ["@lsp.mod.global"] = { fg = c.cyan, bg = nil },

    MiniPickBorder        = { link = "MiniPickNormal" },
    MiniPickBorderBusy    = { link = "FloatBorder" },
    MiniPickBorderText    = { fg = c.primary,                      bg = statusline,                      bold = true },
    MiniPickMatchCurrent  = { fg = nil,                            bg = utils.lighten(statusline, 0.15), bold = true },
    MiniPickMatchRanges   = { fg = c.red,                       bg = nil,                             bold = true, underline = true, },
    MiniPickNormal        = { fg = c.on_primary_container, bg = statusline },
    MiniPickPrompt        = { link = "MiniPickNormal" },
    MiniPickPreviewRegion = { link = "Normal" },
    -- MiniPickPromptCaret = {},
    -- MiniPickPromptPrefix = {},

    -- MiniFilesBorder         = { link = "FloatBorder" },
    -- MiniFilesBorderModified = {},
    -- MiniFilesCursorLine     = { },
    -- MiniFilesDirectory      = {},
    -- MiniFilesFile           = {},
    -- MiniFilesNormal         = { bg = bg },
    -- MiniFilesTitle          = {},
    -- MiniFilesTitleFocused   = {},
}

local set_hl = vim.api.nvim_set_hl
for group, hl in pairs(highlights) do
    set_hl(0, group, hl)
end
