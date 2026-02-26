local _floaterminal
local function floaterminal()
    if _floaterminal then return _floaterminal end

    local win_opts = {
        bufnr = function()
            local bufnr = vim.api.nvim_create_buf(false, true)
            vim.api.nvim_buf_call(bufnr, function() vim.cmd.terminal() end)
            return bufnr
        end,
        position = "center",
        split = "right",
        style = "minimal",
        win = function(self) return not self.is_float and -1 or nil end,
        width = function(self, config) return self.is_float and 0.75 or 0.5 end,
        height = function(self, config) return self.is_float and 0.60 or 10 end,
        border = { "🭽", "▔", "🭾", "🮇", "🭿", "▁", "🭼", "▏" },
    }

    _floaterminal = require("win").split(win_opts)

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
M.to_split = function() floaterminal():to_split() end
M.to_float = function() floaterminal():to_float() end

M.setup = function()
    vim.keymap.set({"n", "t", "i", "x"}, "<c-t>", function()
        if _floaterminal and not _floaterminal:is_focused() then
            M.focus()
        else
            M.toggle()
        end
    end)

    vim.keymap.set({"n", "t"}, "<M-S-t>", function()
        return floaterminal().is_float and floaterminal():to_split():focus() or floaterminal():to_float():focus()
    end)
end

return M
