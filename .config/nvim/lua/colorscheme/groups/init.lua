local M = {}

local function get_hls(module, colors, opts)
    return require("colorscheme.groups." .. module).from_colors(colors, opts)
end

local function resolve_links(name, hls)
    local hl = hls[name]

    if hl.link == nil then return vim.deepcopy(hls[name]) end

    return resolve_links(hl.link, hls)
end

local function add_styling2(hl, styling)

    for _, style in ipairs {
        "bold",
        "italic",
        "underline",
        "undercurl",
        "strikethrough",
        "reverse",
    } do
        hl[style] = styling[style]
    end

    -- hl.link = nil

    return hl
end

---@param colors Colors
---@return table<string, vim.api.keyset.highlight>
M.setup = function(colors, opts)
    local highlights = {}

    for _, module in ipairs {
        "syntax",
        "editor",
        "diagnostic",
        "treesitter",
        "semantic_tokens",
        "helpout",
        "statusline",
    } do
        local hls = get_hls(module, colors, opts)
        for group, hl in pairs(hls) do
            -- hl = add_styling(hl, group, opts)
            highlights[group] = hl
        end
    end



    for group, styling in pairs(opts.styles) do
        local hl = resolve_links(group, highlights)
        hl = add_styling2(hl, styling)
        highlights[group] = hl
    end

    if opts.terminal_colors then
        local hls = get_hls("terminal", colors, opts)
        for var, color in pairs(hls) do
            vim.g[var] = color
        end
    end



    return highlights
end

return M
