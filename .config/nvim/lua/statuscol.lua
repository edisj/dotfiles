local api = vim.api


local function with_hl(text, hl)
    return "%#" .. hl .. "#" .. text
end

local M = {}

M.restart = function()
    package.loaded["statuscol"] = nil
    vim.opt.statuscolumn = "%!v:lua.require('statuscol').render()"
end

M.border = function()
	return with_hl(" ┃", "SignColumn")
end


M.lnum = function()
    local num = vim.wo.relativenumber and "{v:relnum}" or "{v:lnum}"
    local bufnr = api.nvim_win_get_buf(1000)
    local line_count = api.nvim_buf_line_count(bufnr)
    local pad = #tostring(line_count)
    local out = " %" .. pad .. num
    return with_hl(out, "SignColumn")
end

M.render = function()
    return table.concat({
        M.lnum(),
        M.border(),
        with_hl("%s", "Statusline"),
        "%#Normal#",
    })
end

M.restart()

return M
