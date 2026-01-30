local M = {}

M.from_colors = function(c, _)
    local syn = c.syntax
    local ed = c.editor
    local p = c.palette

    local highlights = {
        StatuslineCommand = { fg = syn.Type,      bg = ed.StatusLine, bold = true, },
        StatuslineInsert =  { fg = syn.String,    bg = ed.StatusLine, bold = true, },
        StatuslineNormal =  { fg = syn.Function,  bg = ed.StatusLine, bold = true, },
        StatuslineVisual =  { fg = p.magenta,     bg = ed.StatusLine, bold = true, },

        StatuslineCommandInverted = { fg = syn.Type,      bg = ed.StatusLine, bold = true, reverse = true },
        StatuslineInsertInverted =  { fg = syn.String,       bg = ed.StatusLine, bold = true, reverse = true },
        StatuslineNormalInverted =  { fg = syn.Function,  bg = ed.StatusLine, bold = true, reverse = true },
        StatuslineVisualInverted =  { fg = p.magenta,     bg = ed.StatusLine, bold = true, reverse = true },
    }

    return highlights
end

return M
