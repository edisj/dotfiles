local utils = require("colorscheme.utils")

local M = {}

local _did_setup = false

---@class ColorsConfig
---@field transparent boolean
---@field terminal_colors boolean
---@field palette table<string, HexColor|nil>
local defaults = {
    palette = {
        bg = "#1c1e22",
        fg = nil,
        accent = nil,

        black = "#414868",
        blue = "#5B95DE",
        cyan = "#7dcfff",
        green = "#55ca88",
        magenta = "#bb9af7",
        red = "#b92a28",
        white = "#c0caf5",
        yellow = "#F4D35E",

        orange = "#db9c6a",
        pink = "#d88ec9",
        gold = "#c6bd81",
    },
    colors = {
        -- `:h highlight-groups`
        editor = {
            -- Directory = "cyan",
            DiffAdd = "green",
            DiffChange = "yellow",
            DiffDelete = "red",
            DiffText = "blue",
        },
        -- `:h group-name`
        syntax = {
            Constant = "orange",
            Operator = "gold",
            Special = "magenta",
            String = "#72b88a",
            Type = "yellow",
        },
        -- `:h treesitter-highlight-groups`
        treesitter = {
            ["@constant.builtin"] = "pink",
            ["@keyword.return"] = "red",
            ["@comment.documentation"] = "#59786b",
            ["@variable.parameter.vimdoc"] = "green",
        },
        -- `:h lsp-semantic-highlight`
        semantic = {},
        -- `:h diagnostic-highlights`
        diagnostic = {
            error = "red",
            warn = "yellow",
            info = "blue",
            hint = "cyan",
            ok = "green"
        },
        terminal = {
            black = "black",
            blue = "blue",
            cyan = "cyan",
            green = "green",
            magenta = "magenta",
            red = "red",
            white = "white",
            yellow = "yellow",
        },
    },
    styles = {
        WinSeparator = { bold = true },
        Boolean = { bold = true },
        CursorLineNr = { bold = true },
        FloatTitle = { reverse = true },
        FloatFooter = { reverse = true },
        PmenuSel = { bold = true },
        MatchParen = { bold = true },
        Title = { bold = true },
        ["Keyword"] = { bold = true, italic = true },
        ["@keyword.return"] = { bold = true },
        ["@keyword"] = { bold = true, italic = true },
        ["@keyword.conditional"] = { bold = true, italic = true },
        ["@constant.builtin"] = { bold = true },

    },
    transparent = false,
    terminal_colors = true,
    dim_inactive = false,
}

M.get_defaults = function()
    return vim.deepcopy(defaults)
end

M.config = nil
M.setup = function(opts)
    M.config = vim.tbl_deep_extend("force", defaults, opts or {})

    -- export module to global namespace for convenience
    _G.Colors = {
        config = M.config,
        get = M.api.get,
        set = M.api.set,
        brighten = M.api.brighten,
        darken = M.api.darken,
        lighten = M.api.lighten,
        saturate = M.api.saturate,
        desaturate = M.api.desaturate,
    }

    _did_setup = true
end

M.load = function(opts)
    if not _did_setup then
        M.setup(opts)
    end

    if vim.g.colors_name then
        vim.cmd("hi clear")
    end
    vim.g.colors_name = "custom"
    vim.o.termguicolors = true

    opts = vim.tbl_deep_extend("force", M.config or defaults, opts or {})
    local colors = require("colorscheme.colors").setup(opts)
    local highlights = require("colorscheme.groups").setup(colors, opts)

    for group, hl in pairs(highlights) do
        vim.api.nvim_set_hl(0, group, hl)
    end

    _G.Colors.colors = colors

    return colors, highlights
end

local _get = function(name, follow_links)
    if not _did_setup then return end

    local colors = _G.Colors.colors
    if colors == nil then return end

    follow_links = follow_links == nil and true or false

    for k, v in pairs(colors) do
        if k == name then return v end

        if type(v) == "table" then
            for group, color in pairs(v) do
                if group == name then
                    return color
                end
            end
        end
    end

    local hl = vim.api.nvim_get_hl(0, { name = name, link = not follow_links })
    local c = hl.bg or hl.fg or hl.sp
    return hl.link or utils.rgb_to_hex(c)
end

local _set = function(name, color)
    local opts
    if name:match("^@lsp") then
        opts = { colors = { semantic = { [name] = color } } }
    elseif name:match("^@") then
        opts = { colors = { treesitter = { [name] = color } } }
    elseif vim.tbl_contains(vim.tbl_keys(M.config.colors.diagnostic), name) then
        opts = { colors = { diagnostic = { [name] = color } } }
    elseif vim.tbl_contains(vim.tbl_keys(M.config.palette), name) then
        opts = { palette = { [name] = color } }
    else
        opts = { colors = { syntax = { [name] = color } } }
    end

    M.load(opts)
end

local _brighten = function(name, alpha_s, alpha_l)
    local color = _get(name, true) --[[@as HexColor]]
    if color == nil then return end
    local new_color = utils.brighten(color, alpha_s, alpha_l)
    _set(name, new_color)
end

local _saturate = function(name, alpha)
    local color = _get(name, true)
    if color == nil then return end
    local new_color = utils.brighten(color, alpha, 0.0)
    _set(name, new_color)
end

local _desaturate = function(name, alpha)

end

local _lighten = function(name, alpha)
    local color = _get(name, true)
    if color == nil then return end
    local new_color = utils.lighten(color, alpha)
    _set(name, new_color)
end

local _darken = function(name, alpha)
    local color = _get(name, true)
    if color == nil then return end
    local new_color = utils.darken(color, alpha)
    _set(name, new_color)
end

M.api = {
    get = _get,
    set = _set,
    brighten = _brighten,
    saturate = _saturate,
    desaturate = _desaturate,
    lighten = _lighten,
    darken = _darken,
}

return M
