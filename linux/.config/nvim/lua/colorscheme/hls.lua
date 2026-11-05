local utils = require("colorscheme.utils")

---@param name string Highlight group name, e.g. "ErrorMsg"
---@param val vim.api.keyset.highlight Highlight definition map, accepts the following keys:
local function hi(name, val)
  vim.api.nvim_set_hl(0, name, val)
end

local function syntax(c)
  hi("Comment",    { fg = c.comment })                 -- any comment
  hi("Constant",   { fg = c.const })                   -- any constant
  hi("Boolean",    { fg = c.bool,  bold = true })      -- a boolean constant: TRUE, false
  hi("Number",     { fg = c.number })                  -- a number constant: 234, 0xff
  hi("Float",      { link = "Number" })                -- a floating point constant: 2.3e10
  hi("String",     { fg = c.str })                     -- a string constant: "this is a string"
  hi("Character",  { link = "String" })                -- a character constant: 'c', '\n'
  hi("Identifier", { fg = c.fg1 })                      -- any variable name
  hi("Function",   { fg = c.func })                    -- function name (also: methods for classes)
  hi("Operator",   { fg = c.operator, bold=true })                -- "sizeof", "+", "*", etc.

  hi("Keyword",     { fg = c.keyword })                -- any other keyword
  hi("Statement",   { link = "Keyword" })              -- any statement
  hi("Exception",   { link = "Keyword" })              -- try, catch, throw
  hi("Conditional", { link = "Keyword" })              -- if, then, else, endif, switch, etc.
  hi("Repeat",      { link = "Conditional" })          -- for, do, while, etc.
  hi("Label",       { link = "Conditional" })          -- case, default, etc.

  hi("PreProc",   { link = "Special" })                -- generic Preprocessor
  hi("Include",   { link = "PreProc" })                -- preprocessor #include
  hi("Define", 	  { link = "Preproc" })                -- preprocessor #define
  hi("Macro",     { link = "PreProc" })                -- same as Define
  hi("PreCondit", { link = "PreProc" })                -- preprocessor #if, #else, #endif, etc.

  hi("Type",         { fg = c.type })                -- int, long, char, etc.
  hi("StorageClass", { link = "Type" })              -- static, register, volatile, etc.
  hi("Structure",    { link = "Type" })              -- struct, union, enum, etc.
  hi("Typedef",      { link = "Type" })              -- a typedef

  hi("Special",        { fg = c.special,})             -- any special symbol
  hi("SpecialChar",    { link = "Special" })           -- special character in a constant
  hi("Tag",            { link = "Special" })           -- you can use CTRL       -] on this
  hi("Delimiter",      { link = "Special" })           -- character that needs attention
  hi("SpecialComment", { link = "Special" })           -- special things inside a comment
  hi("Debug",          { link = "Special" })           -- debugging statements

  hi("Ignore", { link = "Comment" })                   -- left blank, hidden  |hl-Ignore|
  hi("Error",  { fg = c.error })                       -- any erroneous construct
  hi("Todo",   { link = "Error" })                     -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

  hi("Added", { fg = c.ok, bg = utils.blend(c.bg1, 0.05, c.ok) })
  hi("Removed", { fg = c.error, bg = utils.blend(c.bg1, 0.05, c.error) })
end

local function editor(c)
  hi("Bold",         { bold = true })
  hi("ColorColumn",  { bg = c.bg2 })
  hi("Cursor",       { fg = nil, bg = c.accent })                  -- Character under the cursor.
  hi("CursorLine",   { bg = c.cursorline })                        -- Screen-line at the cursor, when 'cursorline' is set. Low-priority if foreground (ctermfg OR guifg) is not set.
  hi("CursorLineNr", { fg = c.fg1, bg = c.cursorline })            -- Like LineNr when 'cursorline' is set and 'cursorlineopt' contains "number" or is "oth", for the cursor line.
  hi("EndOfBuffer",  { fg = c.linenr })                            -- Filler lines (~) after the end of the buffer. By default, this is highlighted like |hl-NonText|.
  hi("FloatBorder",  { fg = c.border, bg = c.bg4, bold = true })   -- Border of floating windows.
  hi("FloatFooter",  { fg = c.fg1, bg = c.border, bold = true })   -- Footer of floating windows.
  hi("FloatTitle",   { fg = c.fg1, bg = c.border })                -- Title of floating windows.
  hi("FoldColumn",   { fg = c.func, bg = c.bg2 })               -- 'foldcolumn'
  hi("Folded",       {})                                          -- Line used for closed folds.
  hi("FoldedText",   { bg = c.bg4 })
  -- hi("Folded",       { bg = c.bg4 })                               -- Line used for closed folds.
  hi("LineNr",       { fg = c.linenr, })                           -- Line number for ":number" and ":#" commands, and when 'number' or 'relativenumber' option is set.
  hi("NonText",      { fg = c.linenr, })                           -- '@' at the end of the window, characters from 'showbreak' and other characters that do not really exist in the text
  hi("Normal",       { fg = c.fg1, bg = c.bg1 })                   -- Normal text.
  hi("NormalFloat",  { fg = c.fg1, bg = c.bg4 })                   -- Normal text in floating windows.
  hi("NormalNC",     { link = "Normal" })                          -- Normal text in non-current windows.
  hi("NormalSplit",  { fg = c.fg1, bg = c.bg2 })                   -- Normal text in special splits.
  hi("Selection",    { bg = c.selection })
  hi("SignColumn",   { fg = c.linenr })                            -- Column where |signs| are displayed.
  hi("Visual",       { bg = c.visual })                            -- Visual mode selection.
  hi("VisualNOS",    { link = "Visual" })                          -- Visual mode selection when vim is "Not Owning the Selection".
  hi("WhiteSpace",   { fg = c.comment, })
  hi("Title",        { fg = c.special, bold = true })              -- Titles for output from ":set all", ":autocmd" etc.
  hi("Directory",    { fg = c.directory })                         -- Directory names (and other special names in listings).
  hi("Folder",       { fg = c.folder })
end

local function spell(c)
  hi("SpellBad",   { sp = c.error, undercurl = true }) -- Word that is not recognized by the spellchecker. |spell| Combined with the highlighting used otherwise.
  hi("SpellCap",   { sp = c.warn,  undercurl = true }) -- Word that should start with a capital. |spell| Combined with the highlighting used otherwise.
  hi("SpellLocal", { sp = c.info,  undercurl = true }) -- Word that is recognized by the spellchecker as one that is used in another region. |spell| Combined with the highlighting used otherwise.
  hi("SpellRare",  { sp = c.info,  undercurl = true }) -- Word that is recognized by the spellchecker as one that is hardly ever used. |spell| Combined with the highlighting used otherwise.
end

local function ui(c)
  local stl_border = utils.darken(c.stl, 0.15)
  hi("StatusLine",   { fg = c.fg1, bg = c.stl, underline = true, sp = stl_border })  -- Status line of current window.
  hi("StatusLineNC", { fg = c.linenr,  bg = c.stlnc, underline = true, sp = stl_border })  -- Status lines of not-current windows.
  hi("TabLine",      { fg = c.linenr, bg = c.bg2 })  -- Tab pages line, not active tab page label.
  hi("TabLineFill",  { bg = c.bg2, underline = true, sp = stl_border })  -- Tab pages line, where there are no labels.
  hi("TabLineKey",   { link = "TabLine" })
  hi("TabLineSel",   { fg = c.fg1, bg = c.bg2, underline = true, sp = stl_border })  -- Tab pages line, active tab page label.
  hi("WinBar",       { link = "TabLineSel" })  -- Window bar of current window.
  hi("WinBarNC",     { link = "WinBar" })  -- Window bar of not  -current windows.
  hi("WinSeparator", { fg = stl_border, bold = true })  -- Separators between window splits.
  hi("WinSeparatorNC", { link = "WinSeparator" })
  hi("MsgSeparator",               { fg = c.bg3, bg = c.msgarea      })    -- Separator for scrolled messages |msgsep|.
end

local function pmenu(c)
  hi("Pmenu",         { bg = c.bg4 })                                  -- Popup menu: Normal item.
  hi("PmenuBorder",   { fg = c.accent, bg = c.bg4 })                   -- Popup menu: border of popup menu.
  hi("PmenuExtra",    { fg = c.comment })                              -- Popup menu: Normal item "extra text".
  hi("PmenuExtraSel", { fg = c.error  })                               -- Popup menu: Normal item "extra text".
  hi("PmenuKind",     {})
  hi("PmenuMatch",    { fg = c.match_fg, bg = c.match_bg })                -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
  hi("PmenuMatchSel", { fg = c.match_fg, bg = c.match_bg, bold = true })   -- Popup menu: Matched text in normal item. Combined with |hl-Pmenu|.
  hi("PmenuSbar",     { fg = c.fg1, bg = c.bg2 })                      -- Popup menu: Scrollbar.
  hi("PmenuSel",      { fg = c.fg0, bg = c.selection, bold = true })   -- Popup menu: Selected item.
  hi("PmenuThumb",    { fg = c.bg4, bg = c.accent })                   -- Popup menu: Thumb of the scrollbar.
  hi("WildMenu",      { fg = c.fg1, bg = c.bg1 })                      -- Current match in 'wildmenu' completion.
end

local function terminal(c)
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

local function search(c)
  hi("CurSearch",  { fg = c.bg1, bg = c.cursearch })    -- Current match for the last search pattern (see 'hlsearch').
  hi("IncSearch",  { fg = c.bg1, bg = c.cursearch })    -- 'incsearch' highlighting; also used for the text replaced with ":s///c".
  hi("MatchParen", { fg = c.error, bg = c.bg4, bold = true })  -- Character under the cursor or just before it, if it is a paired bracket, and its match. |pi_paren.txt|
  hi("Search",     { fg = c.fg0, bg = c.search })                -- Last search pattern highlighting (see 'hlsearch'). Also used for similar items that need to stand out.
  hi("Substitute", { link = "Search" })             -- |:substitute| replacement text highlighting.
end

local function msgarea(c)
  hi("ErrorMsg", { fg = c.error })
  hi("ModeMsg",  { fg = c.special })                -- 'showmode' message (e.g., "-- INSERT --").
  hi("MoreMsg",  {})                                -- |more-prompt|
  hi("MsgArea",  { fg = c.fg,  bg = c.msgarea })    -- Area for messages and command-line, see also 'cmdheight'.
  hi("Question", { fg = c.special, bold = true  })  -- |hit-enter| prompt and yes/no questions.

  hi("MsgAreaCmpLabelDescription", { fg = c.fg3 })
  hi("MsgAreaWinBar",              { fg = c.linenr, bg = c.msgarea, underline = true, sp = c.bg2 })
  hi("MsgAreaWinBarFill",          { link = "MsgAreaWinBar" })
  hi("MsgAreaWinBarSel",           { fg = c.special, bg = c.msgarea, bold = true, underline = true, sp = c.bg2 })
  hi("MsgAreaWinBarSep",           { fg = c.linenr })
end

local function treesitter(c)
  hi("@comment",               { fg = c.comment, italic = true })
  hi("@comment.documentation", { fg = c.comment, italic = false })

  hi("@constant.bash",             { link = "@variable" })
  hi("@constant.builtin",          { fg = c.bool, bold = true })
  hi("@constant.builtin.hyprlang", { link = "Constant" })

  hi("@constructor.lua", { link = "@punctuation.bracket" })

  hi("@function.cpp",       { link = "Function" })
  hi("@function.macro.vim", { link = "DiagnosticOk" })

  hi("@keyword.break",            { link = "@keyword.return" })
  hi("@keyword.conditional",      { fg = c.keyword, bold = true })
  hi("@keyword.directive.vimdoc", { fg = c.comment })
  hi("@keyword.do_block",         { fg = c.keyword })
  hi("@keyword.exception",        { fg = c.keyword, bold = true })
  hi("@keyword.function",         { fg = c.keyword, bold = true })
  hi("@keyword.import",           { link = "Keyword"})
  hi("@keyword.local",            { fg = c.type, italic = true })
  hi("@keyword.modifier",         { fg = c.keyword, bold = true })
  hi("@keyword.operator",         { fg = c.keyword, bold = true })
  hi("@keyword.operator.java",    { link = "@keyword.operator" })
  hi("@keyword.repeat",           { fg = c.keyword,  bold = true })
  hi("@keyword.return",           { fg = c.ret, bold = false })
  hi("@keyword.vim",              { link = "Keyword" })

  local link_underline = utils.blend(c.bg1, 0.50, c.func)
  hi("@label.vimdoc",      { fg = c.special })
  hi("@markup.heading.1",  { fg = c.special, bold = true})
  hi("@markup.heading.2",  { link = "@markup.heading.1" })
  hi("@markup.heading.3",  { fg = c.special, bold = true, underline = true, sp = c.linenr })
  hi("@markup.heading.4",  { link = "@markup.heading.3" })
  hi("@markup.heading.5",  { link = "@markup.heading.3" })
  hi("@markup.heading.6",  { link = "@markup.heading.3" })
  hi("@markup.link",       { underline = true, sp = link_underline })
  hi("@markup.raw.vimdoc", { fg = c.type, bg = c.bg4 })

  hi("@module",         { fg = c.operator })
  hi("@module.builtin", { link = "Operator" })

  hi("@property", { fg = c.fg1 })

  hi("@punctuation.bracket",      { fg = c.fg2 })
  hi("@punctuation.delimiter",    { link = "@punctuation.bracket" })
  hi("@punctuation.special.bash", { link = "@variable" })

  hi("@string.escape",             { fg = utils.brighten(c.str, 0.10, 0.15) })
  hi("@string.special.path",       { fg = c.builtin })
  hi("@string.special.path.vim",   { fg = c.folder })
  hi("@string.special.url.vimdoc", { link = "Keyword" })

  hi("@type.builtin", { fg = c.type, bold = false })

  hi("@variable",                       { fg = c.fg1, })
  hi("@variable.builtin",               { link = "@variable" })
  hi("@variable.member",                {})
  hi("@variable.parameter.builtin.lua", { link = "@variable.parameter" })
  hi("@variable.parameter.vimdoc",      { link = "DiagnosticOk" })
end

local function lsp(c)
  hi("DiagnosticError", { fg = c.error, })
  hi("DiagnosticWarn",  { fg = c.warn,})
  hi("DiagnosticInfo",  { fg = c.info, })
  hi("DiagnosticHint",  { fg = c.hint, })
  hi("DiagnosticOk",    { fg = c.ok, })

  hi("DiagnosticSignError", { fg = c.error })
  hi("DiagnosticSignWarn",  { fg = c.warn })
  hi("DiagnosticSignInfo",  { fg = c.info })
  hi("DiagnosticSignHint",  { link = "DiagnosticHint" })
  hi("DiagnosticSignOk",    { link = "DiagnosticOk" })

  hi("DiagnosticSignColError", { fg = c.error, bg = utils.blend(c.bg1, 0.12, c.error) })
  hi("DiagnosticSignColWarn",  { fg = c.warn, bg = utils.blend(c.bg1, 0.08, c.warn) })

  hi("DiagnosticUnnecessary",    {})

  hi("DiagnosticUnderlineError", { sp = c.error, underline = true })
  hi("DiagnosticUnderlineWarn",  { sp = c.warn,  underline = true })
  hi("DiagnosticUnderlineInfo",  { sp = c.info,  underline = true })
  hi("DiagnosticUnderlineOk",    { sp = c.ok,    underline = true })
  hi("DiagnosticUnderlineHint",  {})

  hi("DiagnosticVirtualTextError", { link = "DiagnosticError" })
  hi("DiagnosticVirtualTextWarn", { link = "DiagnosticWarn" })
  hi("DiagnosticVirtualTextInfo", { link = "DiagnosticInfo" })
  hi("DiagnosticVirtualTextHint", { link = "DiagnosticHint" })
  hi("DiagnosticVirtualTextOk", { link = "DiagnosticOk" })

  hi("DiagnosticVirtualLinesError", { fg = c.error, bg = c.bg3 })
  hi("DiagnosticVirtualLinesWarn", { fg = c.warn, bg = c.bg3 })
  hi("DiagnosticVirtualLinesInfo", { fg = c.info, bg = c.bg3 })
  hi("DiagnosticVirtualLinesHint", { fg = c.hint, bg = c.bg3 })

  hi("@lsp.type.modifier", {})
  hi("@lsp.mod.defaultLibrary", { link = "@function.builtin" })
end

local function diff(c)
  hi("DiffAdd",     { fg = c.added })
  hi("DiffChange",  { fg = c.changed })
  hi("DiffDelete",  { fg = c.removed })
  hi("DiffText",    {})
  hi("DiffTextAdd", {})
end

local function dap(c)
  hi("DapBreakpoint",      { link = "DiagnosticError" })
  hi("DapStopped",         { fg = c.fg1, bold = true })
  hi("DapStoppedLine",     { bg = c.bg3 })
  hi("DapUIDecoration",    { link = "LineNr" })
  hi("DapUIModifiedValue", { fg = c.error, bg = c.selection })
  hi("DapUINormal",        { bg = c.bg2 })
  hi("DapUIScope",         { fg = c.special, bold = true })
  hi("DapUIThread",        { link = "DiagnosticOk" })
  hi("DapUIType",          { link = "Comment" })
  hi("DapUIValue",         { fg = c.const })
  hi("DapUIVariable",      { fg = c.special })
  hi("DapUIWatchesEmpty",  { link = "Comment" })
  hi("DapUIWatchesValue",  { fg = c.const })
  hi("NvimDapVirtualText", { fg = c.error, bold = true })
end

local function nvimtree(c)
  hi("NvimTreeCursorLine",   { link = "Visual" })
  hi("NvimTreeExecFile",     { link = "DiagnosticOk" })
  hi("NvimTreeFolderIcon",   { link = "Folder" })
  hi("NvimTreeIndentMarker", { link = "LineNr" })
  hi("NvimTreeNormal",       { bg = c.bg2 })
  hi("NvimTreeRootFolder",   { fg = c.directory, bg = c.bg2, bold = true })
  hi("NvimTreeWinSeparator", { fg = utils.darken(c.stl, 0.15), bg = c.bg2 })
end

local function aerial(c)
  hi("AerialNormal", { link = "NormalSplit" })
  hi("AerialNormalFloat", { link = "NormalSplit" })
  hi("AerialNormalNC", { link = "NormalSplit" })
  hi("AerialLine", { link = "Search", })
  hi("AerialWinSeparator", { fg = utils.darken(c.stl, 0.15), bg = c.bg2 })
end

local function neogit(_)
  hi("NeogitDiffAddCursor",         { link =  "NeogitDiffAdd" })
  hi("NeogitDiffDeleteCursor",      { link =  "NeogitDiffDelete" })
  hi("NeogitDiffContextCursor",     { link =  "NeogitDiffContext" })
  hi("NeogitHunkMergeHeaderCursor", { link =  "NeogitHunkMergeHeader" })
  hi("NeogitHunkHeaderCursor",      { link =  "NeogitHunkHeader" })
  hi("NeogitDiffContext",           {})
  hi("NeogitActiveItem",            { link =  "Visual" })
  hi("NeogitChangeModified",        { link =  "String" })
  hi("NeogitChangeNewFile",         { link =  "DiagnosticHint" })
  hi("NeogitHunkHeader",            { link =  "Visual" })
  hi("NeogitNormalFloat",           { link =  "MsgArea" })
  hi("NeogitFloat",                 { link =  "MsgArea" })
  hi("NeogitObjectId",              { link =  "LineNr" })
  hi("NeogitPopupSectionTitle",     { link =  "Number" })
  hi("NeogitSectionHeader",         { link =  "Number" })
  hi("NeogitSignColumn",            { link =  "LineNr" })

  hi("DiffsClear",  {})
end

local function gitsigns(c)
  hi("GitSignsAdd",    { fg = utils.blend(c.ok, 0.25, c.bg1) })
  hi("GitSignsChange", { fg = utils.blend(c.special, 0.25, c.bg1) })
  hi("GitSignsDelete", { fg = utils.blend(c.error, 0.10, c.bg1), bold = true })
end

local function mini(c)
  hi("MiniCmdlinePeekNormal",   { link = "MsgArea" })

  hi("MiniFilesBorder",         { link = "FloatBorder" })
  hi("MiniFilesBorderModified", { fg = c.warn, bg = c.bg3, bold = true })
  hi("MiniFilesTitle",          { fg = c.comment, bg = c.border, bold = true })
  hi("MiniFilesTitleFocused",   { bg = c.border, bold = true })

  hi("MiniHipatternsNote",      { fg = c.ok, bold = true })
  hi("MiniHipatternsTodo",      { fg = c.error, bold = true })
  hi("MiniHipatternsFixme",     { link = "MiniHipatternsTodo" })
  hi("MiniHipatternsHack",      { link = "MiniHipatternsTodo" })

  hi("MiniIconsPurple",         { fg = c.magenta })
  hi("MiniIconsYellow",         { fg = c.folder })

  hi("MiniJump",                { link = "Search" })

  hi("MiniPickBorder",          { fg = c.linenr })
  hi("MiniPickBorderBusy",      { link = "MsgArea" })
  hi("MiniPickBorderText",      { fg = c.fg1, bg = c.bg1 })
  hi("MiniPickMatchCurrent",    { fg = c.fg0, bg = c.selection, bold = true })
  hi("MiniPickMatchMarked",     { fg = c.match_fg, bg = c.match_bg })
  hi("MiniPickMatchRanges",     { fg = c.match_fg, bg = c.match_bg, bold=true })
  hi("MiniPickNormal",          { link = "MsgArea" })
  hi("MiniPickPrompt",          { fg = c.func, bg = c.bg3 })
  hi("MiniPickPromptCaret",     { fg = c.fg1, bg = c.bg3 })
  hi("MiniPickPromptPrefix",    { fg = c.comment, bg = c.bg3, italic=true })

  hi("MiniTrailspace",          { bg = utils.blend(c.bg1, 0.2, c.error) })
end

local function snacks(c)
  -- hi("NormalSplit",  { fg = c.fg1, bg = c.bg2 })                   -- Normal text in special splits.
  local separator = { fg = utils.darken(c.stl, 0.15), bg = c.bg2 }
  local sep_fg = utils.darken(c.stl, 0.15)
  -- hi("SnacksPickerInputTitle", { underline = false })
  hi("SnacksPickerBox",         { link = "NormalSplit" })
  hi("SnacksPickerBoxBorder",   separator)
  hi("SnacksPickerInput",       { bg = c.bg2})
  hi("SnacksPickerInputBorder", { fg = sep_fg, bg = c.bg2 })
  hi("SnacksPickerInputSideBorder", { fg = sep_fg, bg = c.bg2 })
  hi("SnacksPickerInputTitle",  { fg = c.type, bg = c.bg4 })
  hi("SnacksPickerPrompt", { fg = c.type, bg = c.bg4, bold = true })
  hi("SnacksPickerList",        { link = "NormalSplit" })
  hi("SnacksPickerListBorder",  separator)
  hi("SnacksPickerListCursorLine", { bg = c.match_bg, bold = true })
  hi("SnacksPickerCursorLine", { link = "SnacksPickerListCursorLine" })
  hi("SnacksPickerMatch",       { link = "PmenuMatch" })
  hi("SnacksPickerTitle", { fg = c.type, bg = c.bg2 })
  hi("SnacksWinSeparator",      separator)
end

local function blink(c)
  hi("BlinkCmpDocBorder",                    { link = "FloatBorder" })
  hi("BlinkCmpDocSeparator",                 { link = "Comment" })
  hi("BlinkCmpLabel",                        { link = "Normal" })
  hi("BlinkCmpLabelDetail",                  { link = "Comment" })
  hi("BlinkCmpLabelMatch",                   { link = "PmenuMatch" })
  hi("BlinkCmpMenu",                         { link = "Pmenu" })
  hi("BlinkCmpMenuBorder",                   { link = "PmenuBorder" })
  hi("BlinkCmpSignatureHelpActiveParameter", { fg = c.error, bold = true })
  hi("BlinkCmpSignatureHelpBorder",          { link = "FloatBorder" })
  hi("BlinkCmpSource",                       { link = "Comment" })
  hi("BlinkPairsUnmatched",                  { bg = c.error, bold = true })
end

local function markdown(c)
  hi("ScryCodeBorder", {})
  hi("ScryHeading1", { fg = c.fg1, bg = c.bg1, bold = nil })
  hi("ScryHr", { fg = c.fg1, bold = nil })
  hi("ScryCode", {})
end

local function quickfix(c)
  hi("QuickFixLine", { bg = c.selection, bold = true })  -- Current |quickfix| item in the quickfix window. Combined with |hl-CursorLine| when the cursor is there.
  hi("qfColNr",      { link = "LineNr" })
  hi("qfFileName",   { link = "Directory" })
  hi("qfLineNr",     { link = "Number" })
  hi("qfSeparator1", { link = "@punctuation.bracket" })
  hi("qfSeparator2", { link =  "qfSeparator1" })
  hi("qfText",       { link = "@variable" })
end

local M = {}

---@param c config.Colors
function M.set_hls(c)
  c.fg0        = c.fg0        or utils.lighten(c.fg1, 0.40)
  c.bg2        = c.bg2        or utils.darken(c.bg1, 0.15)
  c.bg3        = c.bg3        or utils.darken(c.bg1, 0.30)
  c.border     = c.border     or utils.blend(c.bg4, 0.30, c.bg1)
  c.comment    = c.comment    or utils.brighten(c.bg1, 0.02, 0.25)
  c.linenr     = c.linenr     or utils.brighten(c.bg1, 0.10, 0.12)
  c.cursorline = c.cursorline or utils.brighten(c.bg1, 0.05, 0.02)
  c.cursearch  = c.cursearch  or c.accent
  c.match_fg   = c.match_fg   or utils.blend(c.accent, 0.4, c.fg1)
  c.match_bg   = c.match_bg   or utils.blend(c.accent, 0.9, c.bg1)
  c.directory  = c.directory  or c.special

  blink(c)
  dap(c)
  diff(c)
  editor(c)
  gitsigns(c)
  lsp(c)
  markdown(c)
  mini(c)
  msgarea(c)
  neogit(c)
  nvimtree(c)
  pmenu(c)
  quickfix(c)
  search(c)
  spell(c)
  syntax(c)
  terminal(c)
  treesitter(c)
  ui(c)
  aerial(c)
  snacks(c)
end

---@alias HexColor string a hex color in the format "#RRGGBB"

---@class config.Colors
---@field accent HexColor
---
---base
---@field bg0? HexColor
---@field bg1 HexColor
---@field bg2? HexColor
---@field bg3? HexColor
---@field fg0? HexColor
---@field fg1 HexColor
---@field fg2? HexColor
---
---syntax
---@field bool HexColor
---@field builtin HexColor
---@field comment? HexColor
---@field const HexColor
---@field func HexColor
---@field keyword HexColor
---@field number HexColor
---@field operator HexColor
---@field ret HexColor
---@field special HexColor
---@field str HexColor
---@field type HexColor
---
---diagnostics
---@field ok HexColor
---@field error HexColor
---@field warn HexColor
---@field info HexColor
---@field hint HexColor
---
---@field search HexColor
---@field match? HexColor
---@field selection HexColor
---@field folder HexColor
---@field directory? HexColor
---
---ui
---@field msgarea HexColor
---@field stl HexColor
---@field stlnc HexColor
---
---terminal
---@field red? HexColor
---@field green? HexColor
---@field yellow? HexColor
---@field blue? HexColor
---@field cyan? HexColor
---@field magenta? HexColor
---
---anything else
---@field [string] HexColor

return M
