local api = vim.api
local ts = vim.treesitter

local _ns = api.nvim_create_namespace("inspector")
local _scratch_buf = api.nvim_create_buf(false, true)
api.nvim_buf_set_name(_scratch_buf, "inspector")

local _win ---@type Window
local _loclist
local _parent_buf

local M  = {}

M.setup = function()
    _G.TS = M
    vim.keymap.set("n", "<C-A-S-Find>q", function()
        M.inspector()
    end)
end

---@return integer
M.ns = function()
    return _ns
end

local _get_lines_from_loclist = function()
    local filter = function(data) return data.show end
    local map = function(data) return string.format("/%s/%s/%s", data.idx, data.depth, data.type) end

    local lines = vim.tbl_map(
        map, vim.tbl_filter(
            filter, _loclist
        )
    )

    return lines
end

local _get_item_from_line = function(line)
    local pattern = "^/(%d+)/%d+/%w+"
    local i = tonumber(line:match(pattern))
    return _loclist[i]
end

local _update_extmarks = function(win, lines)
    if not win:win_is_valid() then return end

    local ns = api.nvim_get_namespaces()["inspector.win"]
    for i, line in ipairs(lines) do
        local item = _get_item_from_line(line)
        local pad = string.rep(" ", item.depth)
        local char =
            (item.expanded == nil and "  ")
            or item.depth == 0 and (item.expanded and "▽ " or "▶ ") or (item.expanded and "▿ " or "▸ ")
        local virt_text = pad .. char
        local row = i - 1
        local hl = item.expanded == nil and "NormalFloat" or item.depth == 0 and "Title" or "Identifier"
        api.nvim_buf_set_extmark(win.bufnr, ns, row, 0, {
            id = item.idx,
            virt_text = {
                { virt_text, hl }
            },
            virt_text_pos = "inline",
            line_hl_group = hl,
        })
    end
end

local _expand_node = function(win)
    local curr_item = _get_item_from_line(api.nvim_get_current_line())
    local next_item = _loclist[curr_item.idx + 1]
    if
        curr_item.expanded == nil
        or curr_item.expanded == true
        or next_item == nil
        or next_item.depth <= curr_item.depth
    then
        return
    end
    curr_item.expanded = true

    while next_item.depth ~= curr_item.depth do
        if next_item.depth == curr_item.depth + 1 then
            next_item.show = true
        end
        next_item = _loclist[next_item.idx + 1]
        if not next_item then break end
    end

    local lines = _get_lines_from_loclist()
    win:set_lines(lines)
    _update_extmarks(win, lines)
end

local _collapse_node = function(win)
    local curr_item = _get_item_from_line(api.nvim_get_current_line())
    if not curr_item.expanded and curr_item.depth == 0 then return end

    local lnum = TS.win:get_cursor()[1]
    if not curr_item.expanded then
        local prev_depth = curr_item.depth - 1
        while curr_item.depth ~= prev_depth do
            lnum = lnum - 1
            local line = win:get_line(lnum)
            curr_item = _get_item_from_line(line)
        end
    end
    local col = 2 * curr_item.depth

    curr_item.expanded = false
    local next_item = _loclist[curr_item.idx + 1]
    while next_item.depth ~= curr_item.depth do
        if next_item.expanded ~= nil then
            next_item.expanded = false
        end
        next_item.show = false
        next_item = _loclist[next_item.idx + 1]
        if next_item == nil then break end
    end

    local lines = _get_lines_from_loclist()
    win:set_lines(lines):set_cursor(lnum, col)
    _update_extmarks(win, lines)
end

local _create_win = function()
    local win_opts = {
        auto_position = "left",
        bufnr = _scratch_buf,
        -- parent = api.nvim_get_current_win(),
        -- relative = "win",
        -- win = api.nvim_get_current_win(),
        stickybuf = true,
        anchor = "NW",
        -- height = 0.85,
        width = 30,
        xoffset = -10,
        style = "minimal",
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        -- border = "solid",
        keymaps = {
            { "n", "q", function(win) win:close() end },
            { "n", "l", function(win) _expand_node(win) end },
            { "n", "h", function(win) _collapse_node(win) end },
            { "n", "<C-A-S-Find>q", function(win) win:close() end },
        },
        bo = {
            filetype = "inspector",
        },
        wo = {
            cursorline = true,
            conceallevel = 3,
            concealcursor = "n",
            winhl = "Normal:NormalFloat",
        },
    }

    _win = require("window.split").new(win_opts)

    _win:create_autocmd("CursorMoved", function(_, _)

        api.nvim_buf_clear_namespace(_parent_buf, M.ns(), 0, -1)

        local item = _get_item_from_line(api.nvim_get_current_line())
        local start_row = item.lnum - 1
        local start_col = item.col
        local end_row = item.end_lnum - 1
        local end_col = item.end_col
        api.nvim_buf_set_extmark(_parent_buf, M.ns(), start_row, start_col, {
            end_row = end_row,
            end_col = end_col,
            hl_group = "IncSearch",
        })
        local parent_win = vim.fn.bufwinid(_parent_buf)
        api.nvim_win_set_cursor(parent_win, { start_row+1, start_col })
        api.nvim_win_call(parent_win, function()
            vim.cmd("normal! zz")
        end)
    end, { buf = true })

    _win:create_autocmd("WinClosed", function(win, ev)
        if win.bufnr ~= ev.buf then return end
        api.nvim_buf_clear_namespace(_parent_buf, M.ns(), 0, -1)
    end)

    api.nvim_create_namespace("inspector.win")

    return _win
end

M.win = _win or _create_win()

M.inspect_cursor = function()
    local tree_data = M.get_tree_data()
    _loclist = M.get_loclist(tree_data)
    M.inspector(_loclist)
end

M.inspector = function(loclist, opts)
    opts = opts or {}
    opts.filter = function(node) return node:type() ~= "chunk" end
    local root = M.get_root_data(opts)
    _loclist = loclist or M.get_loclist(root)

    local lines = _get_lines_from_loclist()

    M.win
        :set_lines(lines)
        :open()
        :set_cursor(1, 0)
        :win_call(function()
            vim.fn.matchadd("Conceal", [[/\d\+/\d\+/]])
            vim.fn.matchadd("Title", [[/\d\+/0/\zs.*]])
            vim.fn.matchadd("Identifier", [[/\d\+/1/\zs.*]])
        end)

    _update_extmarks(M.win, lines)

end

M.get_loclist = function(tree_data, filter, map)

    for _, subtree in ipairs(tree_data) do
        if subtree.data then
            _parent_buf = subtree.data.bufnr
            break
        end
    end

    map = map or function(data)
        local expanded
        if data.child_count ~= 0 then expanded = false end
        return {
            bufnr = data.bufnr,
            idx = data.idx,
            lnum = data.start_row + 1,
            end_lnum = data.end_row + 1,
            col = data.start_col,
            end_col = data.end_col,
            text = data.text,
            type = data.type,
            depth = data.depth,
            show = data.depth == 0,
            expanded = expanded,
        }
    end

    local loclist = M.flatten_tree_data(tree_data, filter, map)

    return loclist
end

M.flatten_tree_data = function(tree_data, filter, map)
    filter = type(filter) == "function" and filter or function(_) return true end
    map = type(map) == "function" and map or function(data) return data end

    local flattened_data = {}
    local function append_list_item(item)
        if filter(item) then
            local idx = #flattened_data + 1
            flattened_data[idx] = map(item.data)
            flattened_data[idx].idx = idx
        end
        for _, child_item in ipairs(item.children) do
            append_list_item(child_item)
        end
    end

    for _, subtree in ipairs(tree_data) do
        append_list_item(subtree)
    end

    return flattened_data
end

M.get_root_data = function(opts)
    opts = opts or {}
    local root = ts.get_node({ bufnr = opts.bufnr, pos = {0, 0} }):tree():root()
    return M.get_tree_data(root, opts)
end

---@class get_tree_data.Opts: vim.treesitter.get_node.Opts
---@field filter fun(TSNode): boolean
---@field map fun(any): any

---@param root_node? TSNode
---@param opts? get_tree_data.Opts
M.get_tree_data = function(root_node, opts)
    opts = opts or {}
    local filter = opts.filter or function(_) return true end

    root_node = root_node or ts.get_node(opts)

    local accepted_nodes = {}
    local function append_node(node)
        if filter(node) then
            accepted_nodes[#accepted_nodes + 1] = node
            return
        end

        if node:child_count() == 0 then return end

        for child_node in node:iter_children() do
            append_node(child_node)
        end
    end

    append_node(root_node)

    local tree = {}
    local function append_data(t, node, depth)
        if not node:named() then return end

        local child_t = {}
        child_t.data = M.get_node_data(node, opts)
        child_t.children = {}
        child_t.data.depth = depth
        child_t.data.child_count = #child_t.data.children
        child_t.data.children = nil

        t[#t + 1] = child_t

        if node:child_count() == 0 then return end

        for child_node in node:iter_children() do
            append_data(child_t.children, child_node, depth + 1)
        end
    end

    for _, node in ipairs(accepted_nodes) do
        append_data(tree, node, 0)
    end

    return tree
end

---@param node TSNode
---@param opts vim.treesitter.get_node.Opts
M.get_node_data = function(node, opts)
    opts = opts or {}
    opts.bufnr = opts.bufnr or api.nvim_get_current_buf()
    node = node or ts.get_node(opts)

    local text = ts.get_node_text(node, 0)
    local type_ = node:type()
    local id = node:id()
    local children = node:named_children()
    local start_row, start_col, end_row, end_col = node:range()

    return {
        text = text,
        type = type_,
        id = id,
        start_row = start_row,
        start_col = start_col,
        end_row = end_row,
        end_col = end_col,
        children = children,
        bufnr = opts.bufnr,
    }
end

return M
