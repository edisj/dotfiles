local config = require("helpout.config")
local actions = require("helpout.actions")
local main_win = require("helpout.windows.main")

local api = vim.api

---@type window.Float
local _search_bar
local _search_bar_ns = api.nvim_create_namespace("helpout.windows.search_bar")
local _search_pending = false
local _search_bar_group = api.nvim_create_augroup("helpout-searchbar", { clear = true })
local _search_bar_buf = api.nvim_create_buf(false, true)
local _buf_name = string.format("helpout://%s/search-bar", _search_bar_buf)
api.nvim_buf_set_name(_search_bar_buf, _buf_name)


local M = {}

---@return window.Float
local function _create_search_bar()

    local merge = {
        bufnr = _search_bar_buf,
        parent = main_win.get(),
        relative = "win",
        stickybuf = true,
        keymaps = {
            { "n", "q", function(win) win:close() end },
        },
        bo = {
            filetype = "helpout_search",
        },
        wo = {
            winhl = table.concat({
                "Normal:HelpoutNormal",
                "NormalFloat:HelpoutSearchBar",
                "FloatBorder:HelpoutSearchBarBorder",
                "FloatTitle:HelpoutFloatTitle",
                "FloatFooter:HelpoutFloatFooter",
            }, ","),
        },
    }

    for _, action in ipairs {
        "search_accept",
        "search_cancel",
    } do
        local keys = type(config.keymaps[action]) == "string" and { config.keymaps[action] } or config.keymaps[action]
        if keys then
            for _, key in ipairs(keys) do
                merge.keymaps[#merge.keymaps + 1] = { { "n", "i" }, key, actions[action].cb, { desc = actions[action].desc } }
            end
        end
    end

    local win_config = config.search_window
    local win_opts = vim.tbl_deep_extend("force", win_config, merge)
    _search_bar = require("window.float").new(win_opts)
    _search_bar:set_lines({""})

    if config.close_search_on_bs then
        vim.keymap.set({"n", "i"}, "<BS>", function()
            local empty_query = _search_bar:get_line(1) == ""
            local BACKSPACE = api.nvim_replace_termcodes("<BS>", true, true, true)
            if empty_query then
                M.cancel()
                return
            end
            vim.api.nvim_feedkeys(BACKSPACE, "n", false)
        end, { buffer = _search_bar.bufnr, nowait = true })
    end

    _search_bar:create_autocmd("BufEnter", function(_, _)
        vim.cmd.startinsert()
        -- vim.bo[_search_bar_buf].completefunc = "v:lua.HelpoutCompletion"
        -- vim.bo[_search_bar_buf].omnifunc = "v:lua.HelpoutCompletion"
        vim.b.minicompletion_config = {
            fallback_action = '<C-x><C-o>' -- use line completion for markdown
        }
    end, {
        desc = "start insert when entering search bar",
        group = _search_bar_group,
        buf = true,
    })

    _search_bar:create_autocmd("BufLeave", function(_, _) M.cancel() end, {
        desc = "cancel search when leaving search bar buffer",
        group = _search_bar_group,
        buf = true,
    })

    _search_bar:create_autocmd("WinClosed", function(_, _) pcall(main_win.focus) end, {
        desc = "attempt to focus main helpout win when closing search bar",
        group = _search_bar_group,
        win = true,
    })

    return _search_bar
end


M.get = function()
    return _search_bar or _create_search_bar()
end

M.ns = function()
    return _search_bar_ns
end

M.open = function()
    _search_bar = _search_bar or _create_search_bar()
    _search_bar:focus()
    _search_pending = true

    if config.search_preview == false then return end
end

M.cancel = function()
    if _search_bar == nil then return end

    vim.cmd.stopinsert()
    _search_pending = false
    _search_bar:close():set_lines({""})
end

M.accept = function()
    if _search_bar == nil then return end

    local query = _search_bar:get_line(1) or ""
    local ok = require("helpout").help(query)
    -- local ok, _ = pcall(help, query)
    if ok then
        M.cancel()
        return
    end
end

return M
