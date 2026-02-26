local fn = vim.fn
local api = vim.api

local function with_hl(text, hl)
    return "%#" .. hl .. "#" .. text
end

local M = {}

M.render = function()
    local components = {
        with_hl(M.fname(), "WinBarFilename"),
    }
    return table.concat(components, " ")
end

M.fname = function()
    local fname = fn.expand("%")
    local ft = vim.bo.filetype
    if fname == "" then return ft end
    local icon, hl = require("mini.icons").get("filetype", ft)
    fname = fn.fnamemodify(fname, ":t")
    local out = with_hl(icon .. " " .. fname .. " ", "WinBarFilename") ..  with_hl(" ", "WinBar")
    out = not vim.bo.modifiable and out .. " " or out
    -- out = vim.bo.modified and out .. " [•]" or out
    out = vim.bo.modified and out .. " [+]" or out
    return " " .. out .. " "
end

-- M.restart = function()
--     package["ui.winbar"] = nil
--     vim.wo.winbar = "%{%v:lua.require('ui.winbar').render()%}"
-- end
-- M.restart()

vim.api.nvim_create_autocmd("BufWinEnter", {
    group = vim.api.nvim_create_augroup("winbar", { clear = true }),
    desc = "Attach winbar",
    callback = function(args)
        if
            not vim.api.nvim_win_get_config(0).zindex -- Not a floating window
            and vim.bo[args.buf].buftype == '' -- Normal buffer
            and vim.api.nvim_buf_get_name(args.buf) ~= '' -- Has a file name
            and not vim.wo[0].diff -- Not in diff mode
        then
            vim.wo.winbar = "%{%v:lua.require'ui.winbar'.render()%}"
        end
    end,
})

return M
