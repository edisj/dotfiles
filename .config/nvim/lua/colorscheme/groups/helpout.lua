local M = {}

M.from_colors = function(c, _)
    local syn = c.syntax
    local ed = c.editor

    local highlights = {
        HelpoutCursorLine = { fg = nil, bg = ed.Visual },
        HelpoutFloatTitle = { fg = ed.NormalFloat, bg = ed.FloatBorder, bold = true },
        HelpoutFloatFooter = { fg = syn.Identifier, bg = ed.FloatBorder, bold = true },
        HelpoutSearchBarBorder = { fg = syn.Function, bg = ed.NormalFloat},
    }

    return highlights
end

return M
