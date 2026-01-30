local M = {}

M.groups = nil --[[@as string[] ]]

M.from_colors = function(c, _)
    local diag = c.diagnostic

    -- see `:h diagnostic-highlights`
    -- colors that are explicitly handled by me, i.e. no linking
    local highlights = {
        DiagnosticError             = { fg = diag.error },
        DiagnosticWarn              = { fg = diag.warn },
        DiagnosticInfo              = { fg = diag.info },
        DiagnosticHint              = { fg = diag.hint },
        DiagnosticOk                = { fg = diag.ok },

        DiagnosticUnderlineError    = { sp = diag.error, undercurl = true },
        DiagnosticUnderlineWarn     = { sp = diag.warn,  undercurl = true },
        DiagnosticUnderlineInfo     = { sp = diag.info,  undercurl = true },
        DiagnosticUnderlineHint     = { sp = diag.hint,  undercurl = true },
        DiagnosticUnderlineOk       = { sp = diag.ok,    undercurl = true },
    }

    -- colors that need a fallback group to link to if not set
    local hl_fg = function(key, fallback)
        return diag[key] and { fg = diag[key] } or { link = fallback }
    end
    for key, fallback in pairs {
        DiagnosticUnnecessary      = "",
        DiagnosticVirtualTextError = "DiagnosticError",
        DiagnosticVirtualTextWarn  = "DiagnosticWarn",
        DiagnosticVirtualTextInfo  = "DiagnosticInfo",
        DiagnosticVirtualTextHint  = "DiagnosticHint",
        DiagnosticVirtualTextOk    = "DiagnosticOk",
        DiagnosticSignError        = "DiagnosticError",     -- Used for "Error" signs in sign column.
        DiagnosticSignWarn         = "DiagnosticWarn",      -- Used for "Warn" signs in sign column.
        DiagnosticSignInfo         = "DiagnosticInfo",      -- Used for "Info" signs in sign column.
        DiagnosticSignHint         = "DiagnosticHint",      -- Used for "Hint" signs in sign column.
        DiagnosticSignOk           = "DiagnosticOk",        -- Used for "Ok" signs in sign column.
    } do
        highlights[key] = hl_fg(key, fallback)
    end

    M.groups = vim.tbl_keys(highlights)

    return highlights
end

return M
