
---@class QuickFixSource
---@field error_format string
---@field items_to_qftf fun()
---@field line_to_item fun()

local M = setmetatable({}, {
    __index = function(_, k)
        local mod = "quickfix.sources." .. k
        return require(mod)
    end,
})

return M
