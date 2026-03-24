local _terminal = nil
local function terminal()
    if _terminal then return _terminal end

    local win_opts = {
        bufnr = function()
            local bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_call(bufnr, function() vim.cmd.terminal() end)
            return bufnr
        end,
        position = "center",
        split = "right",
        style = "minimal",
        -- win = function(self) return not self.is_float and -1 or nil end,
        width = function(self, _) return self:floating() and 0.75 or 0.5 end,
        height = function(self, _) return self:floating() and 0.60 or 10 end,
        border = { "🭽", "▔", "🭾", "🮇", "🭿", "▁", "🭼", "▏" },
        wo = {
            winhl = "Normal:NormalFloat",
            winfixbuf = true,
        },
    }

    _terminal = require("win").split(win_opts)

    _terminal:create_autocmd("BufEnter", function(win, ev)
        if win.bufnr == ev.buf then
            vim.cmd.startinsert()
        end
    end, { desc = "floaterminal start insert on bufenter" })

    return _terminal
end

return {
    open = function() terminal():open() end,
    focus = function() terminal():focus() end,
    close = function() terminal():close() end,
    toggle = function() terminal():toggle() end,
    smart_toggle = function()
        if terminal() and not terminal():is_focused() then
            terminal():focus()
        else
            terminal():toggle()
        end
    end,
    to_split = function() terminal():to_split() end,
    to_float = function() terminal():to_float() end,
}
