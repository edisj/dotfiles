local M = {}

---@param c Colors
---@return table<string, vim.api.keyset.highlight>
M.from_colors = function(c, _)
    local syn = c.syntax
    local diag = c.diagnostic

    -- see `:h group-name`
    -- colors that are explicitly handled by me, i.e. no linking
    local highlights = {
        Comment    = { fg = syn.Comment,    bg = nil },    -- any comment
        Constant   = { fg = syn.Constant,   bg = nil },    -- any constant
        String     = { fg = syn.String,     bg = nil },    -- a string constant: "this is a string"
        Boolean    = { fg = syn.Boolean,    bg = nil },    -- a number constant: 234, 0xff
        Identifier = { fg = syn.Identifier, bg = nil },    -- any variable name
        Function   = { fg = syn.Function,   bg = nil },    -- function name (also: methods for classes)
        Keyword	   = { fg = syn.Keyword,    bg = nil },    -- any other keyword
        Operator   = { fg = syn.Operator,   bg = nil },    -- "sizeof", "+", "*", etc.
        PreProc    = { fg = syn.PreProc,    bg = nil },    -- generic Preprocessor
        Type	   = { fg = syn.Type,       bg = nil },    -- int, long, char, etc.
        Special	   = { fg = syn.Special,    bg = nil },    -- any special symbol
        Error      = { fg = diag.error,     bg = nil },    -- any erroneous construct

        Todo       = { fg = c.bg,           bg = syn.Todo },    -- anything that needs extra attention; mostly the keywords TODO FIXME and XXX

        Bold       = { bold = true },
        Italic     = { italic = true },
        Underlined = { underline = true },
    }

    local hl_fg = function(name, fallback)
        return syn[name] and { fg = syn[name] } or { link = fallback }
    end
    for key, fallback in pairs {
        Character      = "String",      -- a character constant: 'c', '\n'
        Number         = "Constant",    -- a boolean constant: TRUE, false
        Float          = "Number",      -- a floating point constant: 2.3e10

        Statement	   = "Keyword",     -- any statement
        Conditional	   = "Statement",   -- if, then, else, endif, switch, etc.
        Repeat		   = "Statement",   -- for, do, while, etc.
        Label		   = "Statement",   -- case, default, etc.
        Exception	   = "Statement",   -- try, catch, throw

        Include	       = "PreProc",     -- preprocessor #include
        Define	       = "Preproc",     -- preprocessor #define
        Macro	       = "PreProc",     -- same as Define
        PreCondit      = "PreProc",     -- preprocessor #if, #else, #endif, etc.

        StorageClass   = "Type",	    -- static, register, volatile, etc.
        Structure	   = "Type",        -- struct, union, enum, etc.
        Typedef		   = "Type",        -- a typedef

        SpecialChar	   = "Special",     -- special character in a constant
        Tag		       = "Special",     -- you can use CTRL-] on this
        Delimiter	   = "Special",     -- character that needs attention
        SpecialComment = "Special",     -- special things inside a comment
        Debug		   = "Special",     -- debugging statements

        Ignore         = "Normal",      -- left blank, hidden  |hl-Ignore|
    } do
        highlights[key] = hl_fg(key, fallback)
    end

    return highlights
end

return M
