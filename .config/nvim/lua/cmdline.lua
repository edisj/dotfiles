local M = {}

---@class CmdlineState
---@field content? {attrs: table, str: string}[]
---@field pos? integer
---@field firstc? ":" | "?" | "/" | "="
---@field prompt? string
---@field indent? integer
---@field level? integer
---@field hl_id? integer
local _state = {
    pos = 0,
    firstc = ":",
    indent = 0,
    level = 1,
}

M.is_open = false

---@return CmdlineState
function M.get_state()
    return _state
end

---@param state CmdlineState
function M.set_state(state)
    _state = vim.tbl_extend("force", _state, state)
end

local _namespace = vim.api.nvim_create_namespace("ui-cmdline")

local function content_to_line(content)
    local line = _state.firstc or ""
    local attrs, text
    for _, chunk in ipairs(content) do
        attrs, text = unpack(chunk)
        line = line .. text
    end

    return { line }
end

local function _update_cursor()
    local state = M.get_state()
    local pos = state.pos or 0
    vim.api.nvim_win_set_cursor(
        M.win.win_id,
        { vim.api.nvim_buf_line_count(M.win.buf), pos+1 }
    )
    local is_search = state.firstc == "/" or state.firstc == "?"
    if is_search and pos > 0 then
        vim.api.nvim__redraw({ flush = false, win = M.win.win_id, cursor = true })
    else
        vim.api.nvim__redraw({ flush = true, win = M.win.win_id, cursor = true })
    end

end

---@private
function M._render()
    vim.api.nvim_buf_clear_namespace(M.win.buf, _namespace, 0, -1);

    local line = content_to_line(_state.content)

    M.win:set_lines(line)
    _update_cursor()
end

---comment
---@param content any
---@param pos any
---@param firstc any
---@param prompt any
---@param indent any
---@param level any
---@param hl_id any
local function _handle_show(content, pos, firstc, prompt, indent, level, hl_id)
    M.set_state({
        content = content,
        pos = pos,
        firstc = firstc,
        prompt = prompt,
        indent = indent,
        level = level,
        hl_id = hl_id,
    })

    if not M.is_open then
        M.show()
    end
    vim.schedule(M._render)
end

local function _handle_hide(abort)
    -- vim.api.nvim__redraw({ flush = true, win = M.win.win_id, cursor = true })
    --
    if M.is_open then
        M.hide()
    end
end

---@param pos integer
---@param level integer
local function _handle_pos(pos, level)
    M.set_state({
        pos = pos,
        level = level,
    })

    vim.schedule(_update_cursor)
end

---comment
---@param c any
---@param shift any
---@param level any
local function _handle_special_char(c, shift, level)
    vim.notify("cmdline_special_char not implemented yet", vim.log.levels.WARN, { title = "cmdline" })
    -- not implemented yet
end

---comment
---@param lines any
local function _handle_block_show(lines)
    vim.notify("cmdline_block_show not implemented yet", vim.log.levels.WARN, { title = "cmdline" })
    -- not implemented yet
end

---comment
---@param line any
local function _handle_block_append(line)
    vim.notify("cmdline_block_append not implemented yet", vim.log.levels.WARN, { title = "cmdline" })
    -- not implemented yet
end

local function _handle_block_hide()
    vim.notify("cmdline_block_hide not implemented yet", vim.log.levels.WARN, { title = "cmdline" })
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

function M.attach()
    -- vim.api.nvim_set_hl(0, "FloatBorder", {fg="#7799EE", bg="NONE"})
    vim.opt.cmdheight = 0
    vim.ui_attach(_namespace, { ext_cmdline = true }, _cmdline_handler)
    if M.win then
        vim.g.ui_cmdline_pos = {M.win:get_win_config().row+2, M.win:get_win_config().col}
    end
end

function M.detach()
    vim.ui_detach(_namespace)
    vim.opt.cmdheight = 1
    vim.g.ui_cmdline_pos = nil
end


vim.api.nvim_set_hl(0, "TightBorderTop", {fg=vim.api.nvim_get_hl(0, {name="FloatBorder"}).fg, bg="NONE" })
-- vim.api.nvim_set_hl(0, "TightBorderTop", {fg=nil, bg=nil })
vim.api.nvim_set_hl(0, "TightBorderSide", {link = "FloatBorder"})
local tight_border = {
    { "▁", "TightBorderTop" },
    { "▁", "TightBorderTop" },
    { "▁", "TightBorderTop" },
    { "🮇", "TightBorderSide" },
    { "▔", "TightBorderTop" },
    { "▔", "TightBorderTop" },
    { "▔", "TightBorderTop" },
    { "▎", "TightBorderSide" },
}

local default_config = {
    win_opts = {
        auto_position = "bottomcenter",
        yoffset = 0.25,
        bo = {
            filetype = "vim",
        },
        wo = {
            sidescrolloff = 2,
            virtualedit = "all",
            -- winblend=100,
        },
        win_config = {
            height = 1,
            width = 0.5,
            -- border = { "▁", "▁", "▁", "▕", "▔", "▔", "▔", "▎" },
            -- border = { "▁", "▁", "▁", "🮇", "▔", "▔", "▔", "▎" },
            -- border = { " ", "▁", "", "▕", "", "▔", " ", "▎" },
            -- border = "rounded",
            border = tight_border,
            focusable = false,
            style = "minimal",
            hide = true,
        }
    }
}

local function _create_cmdline_win()

    local win = require("custom.win").new(default_config.win_opts)
    win:open()
    vim.g.ui_cmdline_pos = {win:get_win_config().row+2, win:get_win_config().col}

    return win
end


M.win = _create_cmdline_win()



function M.show()
    M.win:update({ win_config = { hide = false } })
    M.is_open = true
end

function M.hide()
    M.win:update({ win_config = { hide = true } })
    M.is_open = false
end


M.attach()


return M
