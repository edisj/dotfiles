local cache = require("helpout.cache")
local config = require("helpout.config")

local api = vim.api
local fn = vim.fn
local ts = vim.treesitter

---private namespace for helper functions
---@class _parser
---@field generate_loclist fun(bufnr: integer): Loclist
---@field parse fun(tokens: LoclistItem[]): Loclist
---@field tokenize fun(tree_data: TreeData[]): LoclistItem[]
---@field get_tree_data fun(bufnr: integer): TreeData[]
---@field get_node_data fun(node: TSNode, bufnr: integer): NodeData
local _parser = {}


local M = {}
M.parser = _parser

---@param bufnr integer
---@return Loclist
M.get_loclist = function(bufnr)
    if bufnr == nil or not api.nvim_buf_is_valid(bufnr) then
        vim.notify(string.format("bufnr: `%s` is invalid", bufnr), vim.log.levels.ERROR, { title = "helpout.loclist" })
        return {}
    end

    if not config.use_cache then
        return _parser.generate_loclist(bufnr)
    end

    local fname = api.nvim_buf_get_name(bufnr)
    local fname_tail = fn.fnamemodify(fname, ":t")

    if cache.loclists[fname_tail] then
        return cache.loclists[fname_tail]
    end

    local loclist = _parser.generate_loclist(bufnr)
    cache.loclists[fname_tail] = loclist

    return loclist
end

---@param list Loclist
---@return string[]
M.get_lines_from_loclist = function(list)
    local should_show = function(_, data)
        return data.show
    end
    local data_to_text = function(_, data)
        local text = data.text
        if text:match(":$") then
            text = string.gsub(text, ":", "")
        end
        if text:match(".+( %~)$") then
            text = string.gsub(text, " ~", "")
        end
        if text:match("^%*.+%*$") then
            text = string.gsub(text, "*", "")
        end
        text = string.gsub(text, "Lua module: ", "")
        -- return string.format("/%s/%s/%s", data.idx, data.depth, text)
        return string.format("/%s/%s/%s", data.idx, data.depth, data.type)
    end

    local lines = vim.iter(ipairs(list))
        :filter(should_show)
        :map(data_to_text)
        :totable()

    return lines
end

---@param line string
---@param list Loclist
---@return LoclistItem|nil
M.get_item_from_line = function(line, list)
    if #list == 0 then return end
    local pattern = "^/(%d+)/%d+/.+"
    local i = tonumber(line:match(pattern))
    return list[i]
end


_parser.generate_loclist = function(bufnr)

    local tree_data = _parser.get_tree_data(bufnr)
    if #tree_data == 0 then return tree_data end

    local tokens = _parser.tokenize(tree_data)

    local parsed = _parser.parse(tokens)

    local loclist = vim.iter(parsed)
        :map(function(item)
            if parsed[item.idx + 1] ~= nil and parsed[item.idx + 1].depth == parsed[item.idx].depth + 1
            then
                item.expanded = false
            end

            return item
        end)
        :totable()

    loclist.last_cursor_position = 1
    return loclist
end

-- Not exactly "tokens" in the regular sense, but rather a linear
-- sequence of location list items with a distinct "type" field
-- (e.g. h2 heading, inline_tag, h4 heading, etc...) that is
-- to be parsed into the final state of the location list
_parser.tokenize = function(tree_data)
    local tokens = {}

    for _, parent in ipairs(tree_data) do
        local curr_idx = #tokens + 1

        if
            parent.data.type == "h1"
            or parent.data.type == "h2"
            or parent.data.type == "h3"
        then
            tokens[curr_idx] = _parser.consume_heading(parent, curr_idx)
        end

        if parent.data.type == "column_heading" then
            tokens[curr_idx] = _parser.consume_column_heading(parent, curr_idx)
        end

        if parent.data.type == "tag" then
            tokens[curr_idx] = _parser.consume_tag(parent, curr_idx)
        end

    end

    return tokens
end

_parser.consume_heading = function(parent, curr_idx)

    local heading
    for _, child in ipairs(parent.children) do
        if child.data.type == "heading" then
            heading = child.data
            break
        end
    end
    assert(type(heading) == "table", "uh-oh, should have found a heading...")

    local text = heading.text
    if text:match("^vim:") or text == "" then return end

    return {
        idx = curr_idx,
        bufnr = parent.data.bufnr,
        lnum = heading.start_row + 1,
        end_lnum = heading.end_row + 1,
        col = heading.start_col,
        end_col = heading.end_col,
        text = heading.text,
        type = parent.data.type,
        show = true,
        depth = 0,
    }
end

_parser.consume_column_heading = function(parent, curr_idx)

    local heading
    for _, child in ipairs(parent.children) do
        if child.data.type == "heading" then
            heading = child.data
            break
        end
    end
    assert(type(heading) == "table", "uh-oh, should have found a heading...")

    local type_ = _parser.is_api_heading(heading.text) and "api_heading" or "column_heading"

    return {
        idx = curr_idx,
        bufnr = parent.data.bufnr,
        lnum = heading.start_row + 1,
        end_lnum = heading.end_row + 1,
        col = heading.start_col,
        end_col = heading.end_col,
        text = heading.text,
        type = type_,
        show = true,
        depth = 0,
    }
end

_parser.consume_tag = function(parent, curr_idx)

    local text = parent.data.text
    -- escape all non-alphanumeric characters
    local escaped = text:gsub("[%W]", "%%%1")
    local line = api.nvim_buf_get_lines(parent.data.bufnr, parent.data.start_row, parent.data.end_row+1, false)[1]
    local is_h4 = line:match(escaped .. "$")

    local is_api_tag =
        text:match("%(%)")
        or text:match("^%*nvim_")
        or text:match("^%*vim%.")
        or text:match("^%*treesitter%-")
        or text:match("^%*TS")
        or text:match("^%*gitsigns%-")

    local type_ = is_api_tag and "api_tag" or is_h4 and "h4" or "tag"

    return {
        idx = curr_idx,
        bufnr = parent.data.bufnr,
        lnum = parent.data.start_row + 1,
        end_lnum = parent.data.end_row + 1,
        col = parent.data.start_col,
        end_col = parent.data.end_col,
        text = parent.data.text,
        type = type_,
        show = true,
        depth = 0,
    }
end

_parser.parse = function(tokens)

    local start_idx ---@type integer
    local base_heading ---@type "h1" | "h2"
    for i, token in ipairs(tokens) do
        if token.type == "h1" or token.type == "h2" then
            start_idx = i
            base_heading = token.type
            break
        end
    end
    assert(type(start_idx == "number"), "how did we not find a heading?")

    local parsed = {}

    local i = start_idx
    local curr_depth = 0
    local in_col_heading = false
    local in_api_tag = false

    while i <= #tokens do
        local curr_idx = #parsed + 1
        local curr_item = tokens[i]

        if curr_item.type == "h1" then
            curr_item.depth = 0
            curr_item.show = true
            curr_depth = 1
            in_col_heading = false
            in_api_tag = false

        elseif curr_item.type == "h2" then
            curr_item.depth = base_heading == "h2" and 0 or 1
            curr_item.show = curr_item.depth == 0
            curr_depth = base_heading == "h2" and 1 or 2
            in_col_heading = false
            in_api_tag = false

        elseif curr_item.type == "column_heading" then
            curr_item.depth = curr_depth
            curr_item.show = false
            in_col_heading = true
            in_api_tag = false

        elseif curr_item.type == "api_tag" then
            curr_item.depth = curr_depth
            curr_item.show = false
            in_api_tag = true

        elseif curr_item.type == "api_heading" then
            curr_item.depth = in_api_tag and curr_depth + 1 or curr_depth
            curr_item.show = false

        elseif curr_item.type == "tag" or curr_item.type == "h4" then
            if in_api_tag then
                goto continue
            end
            curr_item.depth = in_col_heading and curr_depth + 1 or curr_depth
            curr_item.show = false

        else
            curr_item.depth = in_col_heading and curr_depth + 1 or curr_depth
            curr_item.show = false

        end

        curr_item.idx = curr_idx
        parsed[curr_idx] = curr_item

        ::continue::
        i = i + 1
    end

    return parsed
end

_parser.is_api_heading = function(text)
    local patterns = {
        "^attributes",
        "^examples",
        "^fields",
        "^note",
        "^parameters",
        "^properties",
        "^see also",
        "^return",
        "^usage",
    }
    for _, pattern in ipairs(patterns) do
        text = string.lower(vim.trim(text))
        if text:match(pattern) then
            return true
        end
    end

    return false
end

_parser.get_tree_data = function(bufnr)

    local root_node = ts.get_node({ bufnr = bufnr, pos = { 0, 0 } }):tree():root()

    local function i_want_this_node(node)
        local t = node:type()
        local text = ts.get_node_text(node, bufnr)
        return
            t:match("^h1$")
            or t:match("^h2$")
            or t:match("^h3$")
            or (t:match("^column_heading$") and (_parser.is_api_heading(text) or select(2, node:range()) == 0))
            or (t:match("^tag$") and not (text:match("E%d+") or text:match("W%d+")))
    end

    ---@type TSNode[]
    local accepted_nodes = {}

    local function append_node(node)
        if i_want_this_node(node) then
            accepted_nodes[#accepted_nodes + 1] = node
            return
        end

        if node:child_count() == 0 then return end

        for child_node in node:iter_children() do
            append_node(child_node)
        end
    end

    append_node(root_node)

    ---@type TreeData[]
    local tree_data = {}

    local function append_data(t, node, depth)
        if not node:named() then return end

        local child_t = {}
        child_t.data = _parser.get_node_data(node, bufnr)
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
        append_data(tree_data, node, 0)
    end

    return tree_data
end

_parser.get_node_data = function(node, bufnr)
    local text = ts.get_node_text(node, bufnr)
    local type_ = node:type()
    local id = node:id()
    local children = node:named_children()
    local start_row, start_col, end_row, end_col = node:range()

    return {
        bufnr = bufnr,
        id = id,
        text = text,
        type = type_,
        start_row = start_row,
        start_col = start_col,
        end_row = end_row,
        end_col = end_col,
        children = children,
    }
end

return M
