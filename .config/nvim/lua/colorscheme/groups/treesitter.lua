local M = {}

---@param c Colors
M.from_colors = function(c, opts)
    local diag = c.diagnostic
    local syn = c.syntax
    local ts = c.treesitter


    -- see `:h treesitter-highlight-groups`
    -- colors that are explicitly handled by me, i.e. no linking
    local highlights = {
        ["@variable"]                  = { fg = ts["@variable"],                  bg = nil },
        ["@constant.builtin"]          = { fg = ts["@constant.builtin"],          bg = nil },
        ["@punctuation.bracket"]       = { fg = ts["@punctuation.bracket"],       bg = nil },
        ["@constructor.lua"]           = { fg = ts["@constructor.lua"],           bg = nil },   -- constructor for lua, i.e. {}
        ["@string.special.url.vimdoc"] = { fg = ts["@string.special.url.vimdoc"], bg = nil },
    }

    ---@return vim.api.keyset.highlight
    local hl_fg = function(key, fallback)
        return ts[key] and { fg = ts[key] } or { link = fallback }
    end

    -- colors that require fallback link if not set
    for key, fallback in pairs {
        -- ["@variable"]            = "",  -- Any variable name that does not have another highlight.
        ["@variable.builtin"]    = "@variable.parameter",  -- Variable names that are defined by the languages, like `this` or `self`.
        ["@variable.member"]     = "Identifier",  -- For fields.
        ["@variable.parameter"]  = "@variable",   -- For parameters of a function.

        ["@constant"]              = "Constant",
        ["@constant.macro"]        = "Define",

        ["@module"]                = "Type",         --  modules or namespaces
        ["@module.builtin"]        = "@module",         -- built-in modules or namespaces
        ["@label"]                 = "Label",         -- `GOTO` and other labels (e.g. `label:` in C), including heredoc labels

        ["@string"]                = "String",                 -- string literals
        ["@string.documentation"]  = "String",               -- string documenting code (e.g. Python docstrings)
        ["@string.regexp"]         = "String",                 -- regular expressions
        ["@string.escape"]         = "String",                 -- escape sequences
        ["@string.special"]        = "SpecialChar",                 -- other special strings (e.g. dates)
        ["@string.special.symbol"] = "SpecialChar",                 -- symbols or atoms
        ["@string.special.path"]   = "SpecialChar",                 -- filenames
        ["@string.special.url"]    = "SpecialChar",                 -- URIs (e.g. hyperlinks)

        ["@character"]             = "Character",        -- character literals
        ["@character.special"]     = "SpecialChar",        -- special characters (e.g. wildcards)

        ["@boolean"]               = "Boolean",        -- boolean literals
        ["@number"]                = "Number",        -- numeric literals
        ["@number.float"]          = "@number",        -- floating-point number literals

        ["@type"]                  = "Type",        -- type or class definitions and annotations
        ["@type.builtin"]          = "Type",        -- built-in types
        ["@type.definition"]       = "Type",        -- identifiers in type definitions (e.g. `typedef <type> <identifier>` in C)

        ["@attribute"]             = "PreProc",        -- attribute annotations (e.g. Python decorators, Rust lifetimes)
        ["@attribute.builtin"]     = "Special",        -- builtin annotations (e.g. `@property` in Python)
        ["@property"]              = "Identifier",        -- the key in key/value pairs

        ["@function"]              = "Function",        -- function definitions
        ["@function.builtin"]      = "Special",        -- built-in functions
        ["@function.call"]         = "Function",        -- function calls
        ["@function.macro"]        = "Macro",        -- preprocessor macros

        ["@function.method"]       = "Function",        -- method definitions
        ["@function.method.call"]  = "Function",        -- method calls

        ["@constructor"]           = "Operator",        -- constructor calls and definitions
        -- ["@constructor.lua"]       = "Normal",          -- constructor calls and definitions
        ["@operator"]              = "Operator",        -- symbolic operators (e.g. `+`, `*`)

        ["@keyword"]               = "Keyword",        -- keywords not fitting into specific categories
        ["@keyword.coroutine"]     = "@keyword",       -- keywords related to coroutines (e.g. `go` in Go, `async/await` in Python)
        ["@keyword.function"]      = "Statement",        -- keywords that define a function (e.g. `func` in Go, `def` in Python)
        ["@keyword.operator"]      = "@operator",        -- operators that are English words (e.g. `and`, `or`)
        ["@keyword.import"]        = "PreProc",        -- keywords for including or exporting modules (e.g. `import`, `from` in Python)
        ["@keyword.type"]          = "@keyword",        -- keywords describing namespaces and composite types (e.g. `struct`, `enum`)
        ["@keyword.modifier"]      = "@keyword",        -- keywords modifying other constructs (e.g. `const`, `static`, `public`)
        ["@keyword.repeat"]        = "@keyword",        -- keywords related to loops (e.g. `for`, `while`)
        ["@keyword.return"]        = "@keyword",        -- keywords like `return` and `yield`
        ["@keyword.debug"]         = "@keyword",        -- keywords related to debugging
        ["@keyword.exception"]     = "@keyword",        -- keywords related to exceptions (e.g. `throw`, `catch`)
        -- ["@keyword.conditional.lua"] = "@keyword",
        -- ["@keyword.lua"] = "@keyword",

        ["@keyword.conditional"]         = "@keyword",        -- keywords related to conditionals (e.g. `if`, `else`)
        ["@keyword.conditional.ternary"] = "@keyword.conditional",        -- ternary operator (e.g. `?`, `:`)
        ["@keyword.directive"]           = "@keyword",       -- various preprocessor directives and shebangs
        ["@keyword.directive.define"]    = "@keyword.directive",        -- preprocessor definition directives

        ["@punctuation.bracket"]    = "Normal", --brackets (e.g. `()`, `{}`, `[]`)
        ["@punctuation.delimiter"]  = "@punctuation.delimiter", --delimiters (e.g. `;`, `.`, `,`)
        ["@punctuation.special"]    = "@punctuation.delimiter", --special symbols (e.g. `{}` in string interpolation)

        ["@comment"]                = "Comment", --line and block comments
        ["@comment.documentation.lua"]  = "String", --comments documenting code

        ["@comment.error"]          = "DiagnosticError", --error-type comments (e.g. `ERROR`, `FIXME`, `DEPRECATED`)
        ["@comment.warning"]        = "DiagnosticWarn", --warning-type comments (e.g. `WARNING`, `FIX`, `HACK`)
        ["@comment.todo"]           = "DiagnosticHint", --todo-type comments (e.g. `TODO`, `WIP`)
        ["@comment.note"]           = "DiagnosticInfo", --note-type comments (e.g. `NOTE`, `INFO`, `XXX`)

        -- ["@markup.strong"]          = "", --bold text
        -- ["@markup.italic"]          = "", --italic text
        -- ["@markup.strikethrough"]   = "", --struck-through text
        -- ["@markup.underline"]       = "", --underlined text (only for literal underline markup!)

        ["@markup.heading"]         = "Title",             -- headings, titles (including markers)
        ["@markup.heading.1"]       = "@markup.heading",   -- top-level heading
        ["@markup.heading.2"]       = "@markup.heading",   -- section heading
        ["@markup.heading.3"]       = "@markup.heading",   -- subsection heading
        ["@markup.heading.4"]       = "@markup.heading",   -- and so on
        ["@markup.heading.5"]       = "@markup.heading",   -- and so forth
        ["@markup.heading.6"]       = "@markup.heading",   -- six levels ought to be enough for anybody

        -- ["@markup.quote"]           = "@markup.quote",    -- block quotes
        -- ["@markup.math"]            = "@markup.math",      -- math environments (e.g. `$ ... $` in LaTeX)

        ["@markup.link"]            = "Identifier",    -- text references, footnotes, citations, etc.
        ["@markup.link.label"]      = "@markup.link",    -- link, reference descriptions
        ["@markup.link.url"]        = "@markup.link",    -- URL-style links

        ["@markup.raw"]             = "Type", --literal or verbatim text (e.g. inline code)
        -- ["@markup.raw.block"]       = "", --literal or verbatim text as a stand-alone block
        --
        -- ["@markup.list"]            = "", --list markers
        -- ["@markup.list.checked"]    = "", --checked todo-style list markers
        -- ["@markup.list.unchecked"]  = "", --unchecked todo-style list markers
        --
        -- ["@diff.plus"]              = "", --added text (for diff files)
        -- ["@diff.minus"]             = "", --deleted text (for diff files)
        -- ["@diff.delta"]             = "", --changed text (for diff files)
        --
        -- ["@tag"]                    = "", --XML-style tag names (e.g. in XML, HTML, etc.)
        -- ["@tag.builtin"]            = "", --builtin tag names (e.g. HTML5 tags)
        -- ["@tag.attribute"]          = "", --XML-style tag attributes
        -- ["@tag.delimiter"]          = "", --XML-style tag delimiters
    } do
        highlights[key] = hl_fg(key, fallback)
    end

    for name, color in pairs(ts) do
        if highlights[name] == nil then
            highlights[name] = { fg = color, bg = nil }
        end
    end

    return highlights
end

return M
