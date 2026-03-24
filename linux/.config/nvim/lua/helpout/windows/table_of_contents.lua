local config = require("helpout.config")
local actions = require("helpout.actions")
local main_win = require("helpout.windows.main")
local parser = require("helpout.parser")

local api = vim.api

---@type Window
local _toc
local _toc_group = api.nvim_create_augroup("helpout-toc", { clear = true })
local _toc_ns = api.nvim_create_namespace("helpout.windows.toc")
local _toc_buf = api.nvim_create_buf(false, true)
-- local _toc_last_cur_pos = 1
local _buf_name = string.format("helpout://%s/table-of-contents", _toc_buf)
api.nvim_buf_set_name(_toc_buf, _buf_name)


local function _create_toc_win()

    local merge = {
        bufnr = _toc_buf,
        parent = main_win.get(),
        relative = "win",
        stickybuf = true,
        keymaps = {},
        bo = {
            modifiable = false,
        },
        wo = {
            conceallevel = 3,
            concealcursor = "n",
            winhl = table.concat({
                "NormalFloat:HelpoutNormalFloat",
                "FloatBorder:HelpoutFloatBorder",
                "FloatTitle:HelpoutFloatTitle",
                "FloatFooter:HelpoutFloatFooter",
                "CursorLine:HelpoutCursorLine",
            }, ",")
        }
    }

    for _, action in ipairs {
        "search",
        "toc_close",
        "toc_jump",
        "toc_expand",
        "toc_expand_all",
        "toc_collapse",
        "toc_collapse_all",
    } do
        local keys = type(config.keymaps[action]) == "string" and { config.keymaps[action] } or config.keymaps[action]
        if keys then
            for _, key in ipairs(keys) do
                merge.keymaps[#merge.keymaps + 1] = { "n", key, actions[action].cb, { desc = actions[action].desc } }
            end
        end
    end

    local win_config = config.toc_window
    local win_opts = vim.tbl_deep_extend("force", win_config, merge)
    local float_or_split = config.window_style
    _toc = require("window." .. float_or_split).new(win_opts)

    _toc:create_autocmd("BufLeave", function(_, _) api.nvim_buf_clear_namespace(main_win.get().bufnr, main_win.ns(), 0, -1) end, {
        desc = "clear extmarks from main window when leaving toc buffer",
        group = _toc_group,
        buf = true,
    })

    _toc:create_autocmd("WinClosed", function(_, _) pcall(main_win.focus) end, {
        desc = "attempt to focus main helpout win when closing toc",
        group = _toc_group,
        win = true,
    })

    if config.preview_toc == false then return _toc end

    _toc:create_autocmd("CursorMoved", function(_, _)
        local lnum = _toc:get_cursor()[1]

        if lnum == main_win.loclist.last_cursor_position then return end
        main_win.loclist.last_cursor_position = lnum

        local line = _toc:get_line(lnum)
        local item = parser.get_item_from_line(line, main_win.loclist)
        if item == nil then return end

        local target_lnum = item.lnum
        local target_col = item.col
        local target_end_lnum = item.end_lnum
        local target_end_col = item.end_col

        main_win.get():set_cursor(target_lnum, target_col)

        local zt = vim.api.nvim_replace_termcodes("zt", true, true, true)
        main_win.get()
            :win_call(function() vim.cmd(("normal! %s"):format(zt)) end)

        if config.hl_toc_preview ~= "none" then
            local ns = main_win.ns()
            local bufnr = main_win.get().bufnr
            vim.api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
            vim.api.nvim_buf_set_extmark(bufnr, ns, target_lnum - 1, target_col, {
                end_row = target_end_lnum - 1,
                end_col = target_end_col,
                hl_group = "IncSearch",
            })
        end
    end, { buf = true })

    return _toc
end

local _update_extmarks = function(lines, list)
    for i, line in ipairs(lines) do
        local item = parser.get_item_from_line(line, list)
        if item == nil then return end

        local pad = string.rep(" ", item.depth)
        local char =
            (item.expanded == nil and "  ")
            -- or item.depth == 0 and (item.expanded and "▽ " or "▶ ") or (item.expanded and "▿ " or "▸ ")
            or item.depth == 0 and (item.expanded and "○ " or "● ") or (item.expanded and "▿ " or "▸ ")
        local virt_text = pad .. char
        local row = i - 1
        local text_hl = item.expanded == nil and "Comment" or item.depth == 0 and "Special" or "Identifier"
        local icon_hl = item.expanded == nil and "Comment" or item.depth == 0 and "Special" or "Comment"
        api.nvim_buf_set_extmark(_toc_buf, _toc_ns, row, 0, {
            id = item.idx,
            virt_text = {
                { virt_text, icon_hl }
            },
            virt_text_pos = "inline",
            line_hl_group = text_hl,
        })
    end
end


local M = {}

M.get = function()
    return _toc or _create_toc_win()
end

M.open = function()
    if _toc and _toc:is_open() then return end

    local lines = parser.get_lines_from_loclist(main_win.loclist)
    local last_cur_pos = main_win.loclist.last_cursor_position or 1
    _toc = M.get()
        :set_lines(lines)
        :open()
        :set_cursor(last_cur_pos, 0)
        :win_call(function()
            vim.fn.matchadd("Conceal", [[/\d\+/\d\+/]])
            vim.fn.matchadd("Function", [[/\d\+/0/\zs.*]])
            vim.fn.matchadd("Identifier", [[/\d\+/1/\zs.*]])
        end)
    _update_extmarks(lines, main_win.loclist)
end

M.refresh = function()
    local lines = parser.get_lines_from_loclist(main_win.loclist)
    _toc:set_lines(lines)
    _update_extmarks(lines, main_win.loclist)
end

M.close = function()
    if _toc then _toc:close() end
end

M.jump = function()
    if _toc == nil or not _toc:is_open() then return end

    local lnum = _toc:get_cursor()[1]
    local line = _toc:get_line(lnum)
    local item = parser.get_item_from_line(line, main_win.loclist)
    if item == nil then return end

    local target_lnum = item.lnum
    local target_col = item.col

    main_win.get()
        :focus()
        :set_cursor(target_lnum, target_col)

    api.nvim_buf_clear_namespace(main_win.get().bufnr, main_win.ns(), 0, -1)

    if config.auto_close_toc then
        M.close()
    end
end

---@param direction "up" | "down"
M.move_cursor = function(direction)
    if _toc == nil or not _toc:is_open() then return end

    _toc:move_cursor(direction)
    main_win.loclist.last_cursor_position = _toc:get_cursor()[1]
    M.jump()
    local zt = vim.api.nvim_replace_termcodes("zt", true, true, true)
    main_win.get()
        :win_call(function() vim.cmd(("normal! %s"):format(zt)) end)
end

---@param all? boolean
M.expand = function(all)
    if _toc == nil or not _toc:is_open() then return end

    local lnum = _toc:get_cursor()[1]
    local line = _toc:get_line(lnum)
    local list = main_win.loclist
    local curr_item = parser.get_item_from_line(line, list)
    if curr_item == nil then return end

    local next_item = list[curr_item.idx + 1]
    if
        curr_item.expanded == nil
        or (curr_item.expanded == true and not all)
        or next_item == nil
        or next_item.depth <= curr_item.depth
    then
        return
    end

    curr_item.expanded = true
    local max_depth = all and math.huge or curr_item.depth + 1
    while next_item.depth ~= curr_item.depth do
        if next_item.depth <= max_depth then
            next_item.show = true
        end
        next_item.expanded = (all and next_item.expanded ~= nil) and true or next_item.expanded
        next_item = list[next_item.idx + 1]
        if next_item == nil then break end
    end

    M.refresh()
end

M.expand_all = function()
    M.expand(true)
end

---@param all? boolean
M.collapse = function(all)
    if _toc == nil or not _toc:is_open() then return end

    local lnum = _toc:get_cursor()[1]
    local line = _toc:get_line(lnum)
    local list = main_win.loclist
    local curr_item = parser.get_item_from_line(line, list)
    if curr_item == nil then return end

    if
        not curr_item.expanded
        and curr_item.depth == 0
        and not all
    then
        return
    end

    if not curr_item.expanded then
        local target_depth = all and 0 or curr_item.depth - 1
        while curr_item.depth ~= target_depth do
            lnum = lnum - 1
            line = _toc:get_line(lnum)
            curr_item = parser.get_item_from_line(line, list)
        end
    end
    -- local col = 2 * curr_item.depth

    curr_item.expanded = false
    local next_item = list[curr_item.idx + 1]
    while next_item.depth > curr_item.depth do
        if next_item.expanded ~= nil then
            next_item.expanded = false
        end
        next_item.show = false
        next_item = list[next_item.idx + 1]
        if next_item == nil then break end
    end

    M.refresh()
    _toc:set_cursor(lnum, 0)
end


M.collapse_all = function()
    M.collapse(true)
end

return M
