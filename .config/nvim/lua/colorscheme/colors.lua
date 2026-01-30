local M = {}

---@alias HexColor string a hex color in the format "#RRGGBB"

---@alias TreesitterColors table<string, HexColor>
---@alias SemanticColors table<string, HexColor>

---@class DiagnosticColors
---@field error HexColor
---@field hint HexColor
---@field info HexColor
---@field warn HexColor
---@field ok HexColor

---@class SyntaxColors
---@field Boolean? HexColor
---@field Character? HexColor
---@field Comment? HexColor
---@field Conditional? HexColor
---@field Constant HexColor
---@field Debug? HexColor
---@field Define? HexColor
---@field Delimiter? HexColor
---@field Exception? HexColor
---@field Float? HexColor
---@field Function HexColor
---@field Identifier? HexColor
---@field Ignore? HexColor
---@field Include? HexColor
---@field Keyword? HexColor
---@field Label? HexColor
---@field Macro? HexColor
---@field Number? HexColor
---@field Operator? HexColor
---@field PreCondit? HexColor
---@field PreProc? HexColor
---@field Repeat? HexColor
---@field Special HexColor
---@field SpecialChar? HexColor
---@field Statement? HexColor
---@field StorageClass? HexColor
---@field String HexColor
---@field Structure? HexColor
---@field Tag? HexColor
---@field Todo? HexColor
---@field Type HexColor
---@field Typedef? HexColor

---@class EditorColors
---@field ColorColumn HexColor
---@field Conceal HexColor
---@field CursorColumn HexColor
---@field CursorLine HexColor
---@field CursorLineNr HexColor
---@field Directory HexColor
---@field FloatBorder HexColor
---@field FloatFooter HexColor
---@field FloatTitle HexColor
---@field Folded HexColor
---@field IncSearch HexColor
---@field LineNr HexColor
---@field LineNrAbove HexColor
---@field LineNrBelow HexColor
---@field MatchParen HexColor
---@field ModeMsg HexColor
---@field MoreMsg HexColor
---@field MsgArea HexColor
---@field NonText HexColor
---@field Normal HexColor
---@field NormalNC HexColor
---@field NormalFloat HexColor
---@field Pmenu HexColor
---@field PmenuMatch HexColor
---@field PmenuMatchSel HexColor
---@field PmenuSbar HexColor
---@field PmenuSel HexColor
---@field PmenuThumb HexColor
---@field Question HexColor
---@field QuickFixLine HexColor
---@field Search HexColor
---@field SignColumn HexColor
---@field StatusColumn HexColor
---@field StatusLine HexColor
---@field Substitute HexColor
---@field TabLine HexColor
---@field Title HexColor
---@field VertSplit HexColor
---@field Visual HexColor
---@field WhiteSpace HexColor
---@field WildMenu HexColor
---@field WinSeparator HexColor

---@class TerminalColors
---@field black HexColor
---@field blue HexColor
---@field cyan HexColor
---@field green HexColor
---@field magenta HexColor
---@field red HexColor
---@field white HexColor
---@field yellow HexColor
---@field bright_black HexColor
---@field bright_blue HexColor
---@field bright_cyan HexColor
---@field bright_green HexColor
---@field bright_magenta HexColor
---@field bright_red HexColor
---@field bright_white HexColor
---@field bright_yellow HexColor

---@class Colors
---@field bg HexColor
---@field fg HexColor
---@field accent HexColor
---@field diagnostic DiagnosticColors
---@field editor EditorColors
---@field treesitter TreesitterColors
---@field semantic SemanticColors
---@field none "NONE"
---@field syntax SyntaxColors
---@field terminal TerminalColors



---@param s string
---@return boolean
local is_hex_color = function(s)
    if type(s) ~= "string" then return false end

    local pattern = "^#%x%x%x%x%x%x$"
    return s:match(pattern) and true or false
end

local function resolve_colors(t, palette)
    for k, v in pairs(t) do
        if type(v) == "table" then
            resolve_colors(v, palette)
        else
            if not is_hex_color(v) then
                t[k] = palette[v]
            end
        end
    end

    return t
end

---@param opts table
---@return Colors
M.setup = function(opts)
    local utils = require("colorscheme.utils")

    local c = vim.deepcopy(opts.colors)
    c.palette = vim.deepcopy(opts.palette)
    local p = c.palette
    c = resolve_colors(c, p)

    c.none = "NONE"

    for _, color in ipairs {
        "black",
        "blue",
        "cyan",
        "green",
        "magenta",
        "red",
        "white",
        "yellow",
    } do
        local bright_color = "bright_" .. color
        c.terminal[bright_color] = c.terminal[bright_color] or utils.brighten(c.terminal[color])
    end

    -- background color is required, used to generate other editor colors
    c.bg = p.bg
    c.bg = utils.brighten(c.bg, 0.10, 0)

    -- all other colors below can be generated from base colors
    c.fg               = opts.colors.fg     or utils.lighten(c.bg, 0.75)
    c.accent           = opts.colors.accent or utils.brighten(c.bg, 0.70, 0.5)

    local syn = c.syntax
    syn.Comment     = syn.Comment     or utils.blend(c.bg, 0.50, c.fg)
    syn.Boolean     = syn.Boolean     or syn.Constant
    syn.Identifier  = syn.Identifier  or utils.blend(c.fg, 0.25, c.accent)
    -- syn.Keyword     = syn.Keyword     or utils.blend(c.bg, 0.65, syn.Identifier)
    syn.Keyword     = syn.Keyword     or utils.blend(c.bg, 0.55, syn.Identifier)
    syn.Function    = syn.Function    or utils.blend(c.fg, 0.65, c.accent)
    syn.Special     = syn.Special     or utils.lighten(syn.Function, 0.30)
    syn.PreProc     = syn.PreProc     or syn.Special

    local ed = c.editor
    ed.Normal       = ed.Normal       or (opts.transparent and c.none) or c.bg
    ed.NormalNC     = ed.NormalNC     or (opts.transparent and c.none) or (opts.dim_inactive and utils.darken(c.bg, 0.40)) or ed.Normal

    ed.IncSearch    = ed.IncSearch    or c.accent
    ed.Search       = ed.Search       or utils.blend(c.bg, 0.20, c.accent)
    ed.CursorLine   = ed.CursorLine   or utils.darken(c.bg, 0.40)
    ed.Directory    = ed.Directory    or syn.Function
    ed.LineNr       = ed.LineNr       or utils.lighten(c.bg, 0.20)
    ed.CursorLineNr = ed.CursorLineNr or c.accent
    ed.Visual       = ed.Visual       or utils.brighten(c.bg, 0.35, 0.10)
    ed.NormalFloat  = ed.NormalFloat  or utils.darken(c.bg, 0.20)
    -- ed.NormalFloat  = ed.NormalFloat  or ed.Normal
    ed.FloatBorder  = ed.FloatBorder  or utils.blend(c.bg, 0.30, c.accent)
    ed.FloatTitle   = ed.FloatTitle   or ed.FloatBorder
    ed.FloatFooter  = ed.FloatFooter  or ed.FloatBorder
    ed.Pmenu        = ed.Pmenu        or utils.darken(c.bg, 0.40)
    ed.PmenuSel     = ed.PmenuSel     or utils.brighten(c.bg, 0.35, 0.10)
    ed.PmenuMatch   = ed.PmenuMatch   or c.accent
    ed.PmenuThumb   = ed.PmenuThumb   or c.accent
    -- ed.Title        = ed.Title        or utils.blend(c.fg, 0.6, c.accent)
    ed.Title        = ed.Title        or utils.blend(c.bg, 0.90, c.accent)
    ed.MsgArea      = ed.MsgArea      or ed.NormalFloat
    ed.ModeMsg      = ed.ModeMsg      or c.accent
    ed.MoreMsg      = ed.MoreMsg      or c.accent
    ed.NonText      = ed.NonText      or syn.Comment
    ed.Question     = ed.Question     or c.accent
    ed.StatusLine   = ed.StatusLine   or utils.brighten(c.bg, 0.25, 0.05)
    -- ed.StatusLine   = ed.StatusLine   or utils.lighten(c.bg, 0.05)
    ed.MatchParen   = ed.MatchParen   or c.accent
    ed.WinSeparator = ed.WinSeparator or utils.brighten(ed.FloatBorder, 0.05, 0.10)
    ed.VertSplit    = ed.VertSplit    or ed.WinSeparator
    ed.WhiteSpace   = ed.WhiteSpace    or utils.blend(c.bg, 0.15, syn.Comment)

    local ts = c.treesitter
    ts["@variable"]                  = ts["@variable"]                  or c.fg
    ts["@punctuation.bracket"]       = ts["@punctuation.bracket"]       or utils.darken(c.fg, 0.30)
    ts["@comment.documentation"]     = ts["@comment.documentation"]     or utils.darken(syn.String, 0.20)
    ts["@string.special.url.vimdoc"] = ts["@string.special.url.vimdoc"] or opts.palette.magenta

    local sem = c.semantic
    -- sem["@lsp.mod.defaultLibrary"]

    return c
end

return M
