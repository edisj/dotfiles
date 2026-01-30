---@type window.Float
local _floaterminal

local function floaterminal()
    if _floaterminal then return _floaterminal end

    local win_opts = {
        auto_position = "center",
        bufnr = function()
            local bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_call(bufnr, function() vim.cmd.terminal() end)
            return bufnr
        end,
        stickybuf = true,
        width = 0.75,
        height = 0.60,
        border = { "🭽", "▔", "🭾", "🮇", "🭿", "▁", "🭼", "▏" },
        style = "minimal",
    }

    _floaterminal = require("window.float").new(win_opts)

    _floaterminal:create_autocmd("BufEnter", function(win, ev)
        if win.bufnr == ev.buf then
            vim.cmd.startinsert()
        end
    end, { desc = "floaterminal start insert on bufenter" })

    return _floaterminal
end

local M = {}
M.open = function() floaterminal():open() end
M.focus = function() floaterminal():focus() end
M.close = function() floaterminal():close() end
M.toggle = function() floaterminal():toggle() end
M.setup = function()
    vim.keymap.set({"n", "t", "i", "x"}, "<c-t>", function()
        if _floaterminal and not _floaterminal:is_focused() then
            M.focus()
        else
            M.toggle()
        end
    end)
end

return M
