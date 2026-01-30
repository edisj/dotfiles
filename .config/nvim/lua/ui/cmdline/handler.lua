
---comment
---@param content any
---@param pos any
---@param firstc any
---@param prompt any
---@param indent any
---@param level any
---@param hl_id any
local function _handle_show(content, pos, firstc, prompt, indent, level, hl_id)

    local cmdline = require("edis.ui.cmdline")
    cmdline.set_state({
        content = content,
        pos = pos,
        firstc = firstc,
        prompt = prompt,
        indent = indent,
        level = level,
        hl_id = hl_id,
    })

    -- if firstc == "/" or firstc == "?" then
        -- M._render()
    -- else
    vim.schedule(cmdline._render)
    -- end
end

local function _handle_hide(abort)
    vim.api.nvim__redraw({ flush = true, win = M.win.win_id, cursor = true })
    require("edis.ui.cmdline").hide()
end

---@param pos integer
---@param level integer
local function _handle_pos(pos, level)
    local cmdline = require("edis.ui.cmdline")

    cmdline.set_state({
        pos = pos,
        level = level,
    })

    vim.schedule(cmdline._update_cursor)
end

---comment
---@param c any
---@param shift any
---@param level any
local function _handle_special_char(c, shift, level)
    vim.notify("cmdline_special_char not implemented yet", vim.log.levels.WARN, { title = "edis.cmdline" })
    -- not implemented yet
end

---comment
---@param lines any
local function _handle_block_show(lines)
    vim.notify("cmdline_block_show not implemented yet", vim.log.levels.WARN, { title = "edis.cmdline" })
    -- not implemented yet
end

---comment
---@param line any
local function _handle_block_append(line)
    vim.notify("cmdline_block_append not implemented yet", vim.log.levels.WARN, { title = "edis.cmdline" })
    -- not implemented yet
end

local function _handle_block_hide()
    vim.notify("cmdline_block_hide not implemented yet", vim.log.levels.WARN, { title = "edis.cmdline" })
    -- not implemented yet
end

local function _cmdline_handler(event, ...)
    if event == "cmdline_show"         then return _handle_show(...) end
    if event == "cmdline_hide"         then return _handle_hide(...) end
    if event == "cmdline_pos"          then return _handle_pos(...) end
    if event == "cmdline_special_char" then return _handle_special_char(...) end
    if event == "cmdline_block_show"   then return _handle_block_show(...) end
    if event == "cmdline_block_append" then return _handle_block_append(...) end
    if event == "cmdline_block_hide"   then return _handle_block_hide() end
end

local M = setmetatable({}, {
    __call = function(t, ...)
        _cmdline_handler(...)
    end
})

return M
