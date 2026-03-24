---@class helpout.action
---@field desc string
---@field cb fun(...): any
---@overload fun(...): any

---@type table<string, helpout.action>
local M = setmetatable({}, {
    __newindex = function(t, k, v)
        assert(type(v) == "table", "actions value must be a table")
        rawset(t, k, v)
        setmetatable(t[k], {
            __call = function(self, ...)
                return self.cb(...)
            end
        })
    end
})

M.close = {
    desc = "close",
    cb = function()
        require("helpout.windows.main").close()
    end,
}

M.search = {
    desc = "search",
    cb = function()
        require("helpout.windows.search_bar").open()
    end
}

M.search_cancel = {
    desc = "cancel search",
    cb = function()
        require("helpout.windows.search_bar").cancel()
    end,
}

M.search_accept = {
    desc = "accept search",
    cb = function()
        require("helpout.windows.search_bar").accept()
    end
}

M.open_toc = {
    desc = "table of contents",
    cb = function()
        local toc = require("helpout.windows.table_of_contents").get()
        if toc:is_open() then
            toc:focus()
        else
            require("helpout.windows.table_of_contents").open()
        end
    end,
}

M.toc_close = {
    desc = "close",
    cb = function()
        require("helpout.windows.table_of_contents").close()
    end,
}

M.toc_jump = {
    desc = "jump to current toc selection",
    cb = function()
        require("helpout.windows.table_of_contents").jump()
    end,
}

M.toc_expand = {
    desc = "expand heading under cursor",
    cb = function()
        require("helpout.windows.table_of_contents").expand()
    end
}

M.toc_expand_all = {
    desc = "expand all headings under cursor",
    cb = function()
        require("helpout.windows.table_of_contents").expand_all()
    end
}

M.toc_collapse = {
    desc = "collapse heading under cursor",
    cb = function()
        require("helpout.windows.table_of_contents").collapse()
    end,
}

M.toc_collapse_all = {
    desc = "collapse all headings under cursor",
    cb = function()
        require("helpout.windows.table_of_contents").collapse_all()
    end,
}

M.scroll_toc_down = {
    desc = "next",
    cb = function()
        require("helpout.windows.table_of_contents").move_cursor("down")
    end,
}

M.scroll_toc_up = {
    desc = "prev",
    cb = function()
        require("helpout.windows.table_of_contents").move_cursor("up")
    end,
}

return M
