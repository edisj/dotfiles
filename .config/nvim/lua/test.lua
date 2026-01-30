local main = require("helpout.windows.main")
local loclist = require('helpout.loclist')


local flat_data = main.loclist


local function _parse_flat_data(data)
    local parsed = {}

    local first_real_heading_idx
    for i, item in ipairs(data) do
        if (item.type == "heading" and item.col == 0)
            or (i >= 2 and item.type == "tag" and data[i-1].type == "heading")
        then
            first_real_heading_idx = i
            break
        end
    end

    local i = first_real_heading_idx

    local try_consume_heading = function(item)
        local curr_idx = #parsed + 1
        item.idx = curr_idx

        parsed[curr_idx] = item
    end

    local try_consume_tag = function(item)
        local prev_item = data[i - 1]
        -- We want to exclude this tag if it shares a line with another tag.
        -- This can occur if the tag has multiple aliases, or if it shares a line with a heading.
        -- In either case, I don't want it listed
        if item.lnum == prev_item.lnum then return end

        local next_item = data[i + 1]

        local curr_idx = #parsed + 1
        item.text = next_item.text
        item.idx = curr_idx
        item.depth = 0
        -- item.expanded = nil

        parsed[curr_idx] = item
    end

    local consume_column_heading = function(item)

        local next_item = data[i + 1]
        assert(next_item.type == "heading", "type, `column_heading`, must be followed by `heading`")

        local curr_idx = #parsed + 1

        next_item.idx = curr_idx
        next_item.expanded = nil
        parsed[curr_idx] = next_item

        -- IMPORTANT: we skip over the subsequent heading after column_heading
        i = i + 1
    end

    while i <= #flat_data do
        local curr_item = data[i]

        if curr_item.type == "heading" then
            try_consume_heading(curr_item)
        elseif curr_item.type == "tag" then
            try_consume_tag(curr_item)
        elseif curr_item.type == "column_heading" then
            consume_column_heading(curr_item)
        end

        i = i + 1
    end

    return parsed
end

local parsed = _parse_flat_data(flat_data)
vim.print(parsed)

