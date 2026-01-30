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

---@return CmdlineState
M.get_state = function()
    return _state
end

---@param state CmdlineState
M.set_state = function(state)
    _state = vim.tbl_extend("force", _state, state)
end

local _namespace = vim.api.nvim_create_namespace("ui-cmdline")

local function _update_cursor()
    local state = M.get_state()
    local pos = state.pos or 0
    vim.api.nvim_win_set_cursor(
        M.win.win_id,
        { vim.api.nvim_buf_line_count(M.win.buf), pos+1 }
    )
    if state.firstc == "/" or state.firstc == "?" then
        vim.api.nvim__redraw({ flush = false, win = M.win.win_id, cursor = true })
    else
        vim.api.nvim__redraw({ flush = true, win = M.win.win_id, cursor = true })
    end
end

M.attach = function()
    vim.api.nvim_set_hl(0, "FloatBorder", {fg="#7799EE", bg="NONE"})
    vim.opt.cmdheight = 0
    vim.ui_attach(_namespace, { ext_cmdline = true }, require("edis.ui.cmdline.handler"))
    if M.win then
        vim.g.ui_cmdline_pos = {M.win:get_win_config().row+2, M.win:get_win_config().col}
    end
end

M.detach = function()
    vim.ui_detach(_namespace)
    vim.opt.cmdheight = 1
    vim.g.ui_cmdline_pos = nil
end


local function _create_cmdline_win()

    local win_opts = {
        auto_position = "bottomcenter",
        yoffset = 0.25,
        bo = {
            filetype = "vim",
        },
        wo = {
            sidescrolloff = 2,
            virtualedit = "all",
        },
        win_config = {
            height = 1,
            width = 0.5,
            border = { "▁", "▁", "▁", "▕", "▔", "▔", "▔", "▎" },
            -- border = "rounded",
            focusable = false,
            style = "minimal",
            hide = true,
        }
    }
    local win = require("edis.win").new(win_opts)
    win:open()

    vim.g.ui_cmdline_pos = {win:get_win_config().row+2, win:get_win_config().col}

    return win
end


M.win = _create_cmdline_win()


local function content_to_line(content)
    local line = _state.firstc or ""
    local attrs, text
    for _, chunk in ipairs(content) do
        attrs, text = unpack(chunk)
        line = line .. text
    end

    return { line }
end

---@private
M._render = function()
    vim.api.nvim_buf_clear_namespace(M.win.buf, _namespace, 0, -1);

    local line = content_to_line(_state.content)

    if M.is_exiting() then
        vim.notify("is exiting", vim.log.levels.INFO, {})
    end

    M.show()
    M.win:set_lines(line)
    _update_cursor()
end

function M.show()
    M.win:update(
        { win_config = { hide = false } }
    )
end
function M.hide()
    M.win:update(
        { win_config = { hide = true } }
    )
end


M.attach()


return M
