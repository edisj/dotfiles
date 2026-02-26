local api = vim.api
local fn = vim.fn

local SEVERITY_TO_CHAR = {
    error = "E",
    warning = "W",
    info = "I",
    note = "N",
}
local CHAR_TO_SEVERITY = {
    E = "error",
    W = "warning",
    I = "info",
    N = "note",
}

return {
    error_format = "^([^:]+):(%d+):(%d+):([^:]+):(.+)$",

    items_to_qftf = function(items)
        local formatted_lines = {}

        local name_pad = 0
        local lnum_pad = 0
        local col_pad = 0

        -- need to find longest fields for right/left justification
        for _, item in ipairs(items) do
            local full_name = api.nvim_buf_get_name(item.bufnr)
            local rel_name = fn.fnamemodify(full_name, ":.")
            name_pad = math.max(name_pad, #rel_name)
            lnum_pad = math.max(lnum_pad, #tostring(item.lnum))
            col_pad = math.max(col_pad, #tostring(item.col))
        end

        local name_sub = string.format("%%%ds", name_pad)
        local lnum_sub = string.format("%%%ds", lnum_pad)
        local col_sub = string.format("%%-%ds", col_pad)

        for _, item in ipairs(items) do
            local full_name = api.nvim_buf_get_name(item.bufnr)
            local rel_name = fn.fnamemodify(full_name, ":.")
            local formatted_line = string.format(
                name_sub .. " " .. lnum_sub .. ":" .. col_sub .. " %s: %s",
                rel_name,
                item.lnum,
                item.col,
                CHAR_TO_SEVERITY[item.type],
                item.text
            )
            formatted_lines[#formatted_lines + 1] = formatted_line
        end
        return formatted_lines
    end,

    line_to_item = function(line)
        local qf_item = {}
        local line_split = vim.split(line, ":")
        qf_item.filename = vim.trim(line_split[1])
        qf_item.lnum = vim.trim(line_split[2])
        qf_item.col = vim.trim(line_split[3])
        qf_item.type = SEVERITY_TO_CHAR[vim.trim(line_split[4])]
        qf_item.text = vim.trim(line_split[5])
        return qf_item
    end,

    highlight_func = function()
        fn.clearmatches()
        fn.matchadd("Special", [[\v^[^:]+\ze\s]])
        fn.matchadd("Type", [[\v^[^:]+\s+\zs\d+:\d+\ze]])
        fn.matchadd("DiagnosticError", [[error\ze:]])
        fn.matchadd("DiagnosticWarn", [[warning\ze:]])
        fn.matchadd("DiagnisticInfo", [[(info|note)\ze:]])
        fn.matchadd("Normal", [[\v^[^:]+\s\d+:\d+\s+(error|warning|info|note):\s\zs.+$]])
        fn.matchadd("@punctuation.bracket", [[\v:]])
    end,
}
