local M = {}

M.from_colors = function(c, _)
    local semantic = c.semantic

    ---@return vim.api.keyset.highlight
    local hl_fg = function(key, fallback)
        return semantic[key] and { fg = semantic[key] } or { link = fallback }
    end

    -- see `:h lsp-semantic-highlight`
    -- colors that are explicitly handled by me, i.e. no linking
    local highlights = {}

    for key, fallback in pairs {
        ["@lsp.typemod.function.defaultLibrary"] = "@function.builtin",
        ["@lsp.type.modifier.java"] = "",
        ["@lsp.type.namespace.java"] = "",

        -- ["@lsp.type"] = "",
        -- ["@lsp.type.function"] = "",
        -- ["@lsp.mod.documentation"] = "@comment.documention",
        -- ["@lsp.type.type"] = "",
        -- ["@lsp.type.property.lua"] = "",
        -- ["@lsp.mod.documentation.lua"] = "@comment.documentation",
        -- ["@lsp.type.macro.lua"] = "",
        -- ["@lsp.type.class.lua"] = "",
        -- ["@lsp.type.comment.lua"] = "",
        -- ["@lsp.type.string.lua"] = "",

        -- ["@lsp.type.class"]         = "@structure",          -- Identifiers that declare or reference a class type
        -- ["@lsp.type.comment"]       = "Comment",             -- Tokens that represent a comment
        -- ["@lsp.type.decorator"]     = "@function",           -- Identifiers that declare or reference decorators and annotations
        -- ["@lsp.type.enum"]          = "@type",               -- Identifiers that declare or reference an enumeration type
        -- ["@lsp.type.enumMember"]    = "@constant",           -- Identifiers that declare or reference an enumeration property, constant, or member
        -- ["@lsp.type.event"]         = "",                 -- Identifiers that declare an event property
        -- ["@lsp.type.function"]      = "@function",           -- Identifiers that declare a function
        -- ["@lsp.type.interface"]     = "@type",               -- Identifiers that declare or reference an interface type
        -- ["@lsp.type.keyword"]       = "@keyword",            -- Tokens that represent a language keyword
        -- ["@lsp.type.macro"]         = "@macro",              -- Identifiers that declare a macro
        -- ["@lsp.type.method"]        = "@function.method",    -- Identifiers that declare a member function or method
        -- ["@lsp.type.modifier"]      = "",                 -- Tokens that represent a modifier
        -- ["@lsp.type.namespace"]     = "@namespace",          -- Identifiers that declare or reference a namespace, module, or package
        -- ["@lsp.type.number"]        = "@constant",           -- Tokens that represent a number literal
        -- ["@lsp.type.operator"]      = "@operator",           -- Tokens that represent an operator
        -- ["@lsp.type.parameter"]     = "@variable.parameter", -- Identifiers that declare or reference a function or method parameters
        -- ["@lsp.type.property"]      = "@property",           -- Identifiers that declare or reference a member property, member field, or member variable
        -- ["@lsp.type.regexp"]        = "@string.regexp",      -- Tokens that represent a regular expression literal
        -- ["@lsp.type.string"]        = "@string",             -- Tokens that represent a string literal
        -- ["@lsp.type.struct"]        = "@structure",          -- Identifiers that declare or reference a struct type
        -- ["@lsp.type.type"]          = "@type",               -- Identifiers that declare or reference a type that is not covered above
        -- ["@lsp.type.typeParameter"] = "@type.definition",    -- Identifiers that declare or reference a type parameter
        -- ["@lsp.type.variable"]      = "@variable",          -- Identifiers that declare or reference a local or global variable
        ["@lsp.type.variable"]      = "",                    -- Identifiers that declare or reference a local or global variable

        -- ["@lsp.mod.abstract"]      = "",    -- Types and member functions that are abstract
        -- ["@lsp.mod.async"]         = "@keyword.coroutine",    -- Functions that are marked async
        -- ["@lsp.mod.declaration"]   = "",    -- Declarations of symbols
        -- ["@lsp.mod.defaultLibrary"]= "",    -- Symbols that are part of the standard library
        -- ["@lsp.mod.definition"]    = "",    -- Definitions of symbols, for example, in header files
        -- ["@lsp.mod.deprecated"]    = "",    -- Symbols that should no longer be used
        -- ["@lsp.mod.documentation"] = "",    -- Occurrences of symbols in documentation
        -- ["@lsp.mod.modification"]  = "",    -- Variable references where the variable is assigned to
        -- ["@lsp.mod.readonly"]      = "@constant",    -- Readonly variables and member fields (constants)
        -- ["@lsp.mod.static"]        = "@constant",    -- Class members (static members)
        --
        -- ["@lsp.typemod.keyword.documentation"] = "@comment.documentaion"
    } do
        highlights[key] = hl_fg(key, fallback)
    end

	return highlights
end

return M
