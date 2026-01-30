---@class Logger
---@field entries string[]
---@field indent integer
---@field win Win
---@field logs string[]
local M = {}
M.__index = M

--@type Logger
-- local logger = nil

local function _format_entries(entries)
    local logs = {}
    local pad
    for _, entry in ipairs(entries) do
        pad = string.rep(" ", 4*entry.indent)
        table.insert(
            logs,
            string.format("%s%s: %s", pad, entry.from, entry.msg)
        )
        -- string.rep
    end

    return logs
end

---@return Logger
function M.new()

    -- -- singleton pattern ?
    -- if logger then
    --     return logger
    -- end

    local self = setmetatable({}, M)
    self.entries = {}
    self.indent = 0
    self.win = require("edis.win").new({
        auto_position = "centerright",
        xoffset = -0.05,
        yoffset = 1,
        autocmds = {
            {
                event = "User",
                cb = function(win, ev) end,
                event_opts = { pattern = "LoggerLogged" },
            },
        },
        bo = {
            readonly = true,
        },
        win_config = {
            style = "minimal",
            height = 0.9,
            width = 0.45,
        },
    })

    return self
end

function M:plus_indent()
    self.indent = self.indent + 1
end

function M:minus_indent()
    self.indent = self.indent ~= 0 and self.indent - 1 or 0
end

function M:log(msg, from)
    local entry = {
        msg = msg or "Message",
        from = from or "from",
        indent = self.indent,
    }
    table.insert(self.entries, entry)

    vim.api.nvim_exec_autocmds("User", {
        pattern = "LoggerLogged",
        data = entry,
    })

end

vim.api.nvim_create_autocmd("User", {
    pattern = "LoggerLogged",
    group = vim.api.nvim_create_augroup("logger-group", {}),
    callback = function(ev)
    end
})


function M:assert(from, value, msg)

end


function M:show()
    local logs = _format_entries(self.entries)
    self.win:set_lines(logs)
            :open()
end


logger = M.new()
logger:log("msg1", "from me")
logger:plus_indent()
logger:log("msg2", "from me again")
logger:show()


return M
