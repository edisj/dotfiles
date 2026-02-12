local config = require("helpout.config")
local actions = require("helpout.actions")
local parser = require("helpout.parser")

local api = vim.api

---@type Window
local _main_win
local _ns = vim.api.nvim_create_namespace("helpout.windows.main")


local M = {}

---@type Loclist
M.loclist = {}

local function _create_main_win()

    local merge = {
        file = api.nvim_get_runtime_file("doc/help.txt", false)[1],
        stickybuf = "help",
        keymaps = {},
        bo = {
            buftype = "help",
            filetype = "help",
            keywordprg = ":Helpout",
            modifiable = false,
        },
        wo = {
            winhl = table.concat({
                "CursorLineNr:HelpoutCursorLine",
                "CursorLine:HelpoutCursorLine",
                "NormalFloat:HelpoutNormalFloat",
                "FloatBorder:HelpoutFloatBorder",
                "FloatTitle:HelpoutFloatTitle",
                "FloatFooter:HelpoutFloatFooter",
            }, ",")

        },
    }

    for _, action in ipairs {
        "close",
        "search",
        "open_toc",
        "scroll_toc_down",
        "scroll_toc_up",
    } do
        local keys = type(config.keymaps[action]) == "string" and { config.keymaps[action] } or config.keymaps[action]
        if keys then
            for _, key in ipairs(keys) do
                merge.keymaps[#merge.keymaps + 1] = { "n", key, actions[action].cb, { desc = actions[action].desc } }
            end
        end
    end

    local win_config = config.main_window
    local win_opts = vim.tbl_deep_extend("force", win_config, merge)
    local float_or_split = config.window_style
    _main_win = require("window." .. float_or_split).new(win_opts)

    M.loclist = parser.get_loclist(_main_win.bufnr)

    _main_win:create_autocmd("Filetype", function(win, _)
        local toc = require("helpout.windows.table_of_contents")

        M.loclist = parser.get_loclist(win.bufnr)
        win:refresh()
        if toc.get():is_open() then
            toc.refresh()
        end

    end, { pattern = "help", win = true })

    return _main_win
end

M.get = function()
    return _main_win or _create_main_win()
end

M.ns = function()
    return _ns
end

M.open = function()
    if _main_win and _main_win:is_open() then return _main_win end

    _main_win = M.get():open()
    -- M.loclist = parser.get_loclist(_main_win.bufnr)

    -- if config.auto_open_toc then
    --     local toc = require("helpout.windows.table_of_contents")
    --     toc.open()
    -- end
    return _main_win
end

M.focus = function()
    return M.open():focus()
end

M.close = function()
    if _main_win then
        return _main_win:close()
    end
end

M.toggle = function()
    if _main_win and _main_win:is_open() then
        return M.close()
    end
    return M.open()
end

return M
