local Base = require("window.base")

local _borders = {
    single  = { "┌", "─", "┐", "│", "┘", "─", "└", "│" },
    double  = { "╔", "═", "╗", "║", "╝", "═", "╚", "║" },
    rounded = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    curved  = { "╭", "─", "╮", "│", "╯", "─", "╰", "│" },
    edged   = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▎" },
}

---@param win Window
---@return integer row
---@return integer col
local function _calculate_auto_position(win)
    local position = win.opts.auto_position or "center"
    local anchor = win.opts.anchor or win.win_config.anchor or "NW"

    local has_border = win.win_config.border ~= "" and win.win_config.border ~= "none"
    local w = win.win_config.width + (has_border and 2 or 0)
    local h = win.win_config.height + (has_border and 2 or 0)
    local parent_dims = win:get_parent_dimensions()
    local W, H = parent_dims.width, parent_dims.height

    local xoffset = (type(win.opts.xoffset) == "function" and win.opts.xoffset(win)) or win.opts.xoffset or 0
    if math.abs(xoffset --[[@as number]]) < 1 then
        xoffset = math.floor(xoffset * W)
    end
    local yoffset = (type(win.opts.yoffset) == "function" and win.opts.yoffset(win)) or win.opts.yoffset or 0
    if math.abs(yoffset --[[@as number]]) < 1 then
        yoffset = math.floor(yoffset * H)
    end

    local anchor_map = {
        NW = { 0, 0 },
        NE = { 0, 1 },
        SW = { 1, 0 },
        SE = { 1, 1 },
    }
    local auto_pos_map = {
        topleft  = { 0, 0 },
        top      = { 0, 0.5*(W-w) },
        topright = { 0, W-w },
        left     = { 0.5*(H-h), 0 },
        center   = { 0.5*(H-h), 0.5*(W-w) },
        right    = { 0.5*(H-h), W-w },
        botleft  = { H-h, 0 },
        bot      = { H-h, 0.5*(W-w) },
        botright = { H-h, W-w },
    }

    local Ay, Ax = unpack(anchor_map[anchor])
    local y, x = unpack(auto_pos_map[position])

    local row = math.floor(Ay*h + y - yoffset)
    local col = math.floor(Ax*w + x + xoffset)

    return row, col
end

---@class window.Float: window.Base
local M = setmetatable({}, Base)
M.__index = M

---@type WinOpts
local _defaults = {
    auto_position = "center",
    auto_resize = true,
    relative = "editor",
    enter = true,
    keymaps = {},
    bo = {},
    wo = {},
}

---@return window.Float
M.new = function(opts)
    opts = vim.tbl_deep_extend("force", _defaults, opts or {})
    -- normally to create an instance you'd do `local self = setmetatable({}, M)`
    -- however, here, we first initialize self with the Base constructor
    -- and then point the metatable to M afterwards
    local self = Base.new(opts)
    setmetatable(self, M)

    self.win_config = self:resolve_win_opts()

    return self --[[@as window.Float]]
end

---@private
---@override
function M:resolve_win_opts()

    ---@type vim.api.keyset.win_config
    local win_opts = {}
    -- filtering self.opts for win_config opts
    for _, opt in ipairs {
        "anchor",
        "border",
        "bufpos",
        "col",
        "external",
        "fixed",
        "focusable",
        "footer",
        "footer_pos",
        "height",
        "hide",
        "noautocmd",
        "relative",
        "row",
        "style",
        "title",
        "title_pos",
        "width",
        "win",
        "zindex",
    } do
        win_opts[opt] = self.opts[opt]
    end

    self.win_config = vim.tbl_deep_extend("force", self.win_config or {}, win_opts)
    local wc = self.win_config
    wc.relative = win_opts.relative or "editor"
    wc.split = nil
    wc.border = win_opts.border or vim.o.winborder

    local function resolve_win_dim(dim, parent_dim)
        if not dim then
            dim = math.floor(0.5 * parent_dim)
        elseif dim <= 0 then
            dim = parent_dim
        elseif dim < 1 then
            dim = math.floor(dim * parent_dim)
        else
            dim = math.floor(dim)
        end
        if win_opts.relative == "editor" then
            -- cannot exceed editor dimension
            dim = math.min(dim, parent_dim)
        end
        return dim
    end

    local todos = {}

    local parent_dims = self:get_parent_dimensions()
    for _, dim in ipairs {
        "width",
        "height",
    } do
        local dim_opt = win_opts[dim]
        if type(dim_opt) == "function" then
            todos[dim] = function() return resolve_win_dim(dim_opt(self), parent_dims[dim]) end
        else
            wc[dim] = resolve_win_dim(dim_opt, parent_dims[dim])
        end
    end

    wc.title_pos = win_opts.title and (win_opts.title_pos or "center") or nil
    wc.footer_pos = win_opts.footer and (win_opts.footer_pos or "center") or nil
    for _, border_text in ipairs {
        "title",
        "footer",
    } do
        local text = win_opts[border_text]
        if type(text) == "function" then
            todos[border_text] = function() return text(self) end
        else
            wc[border_text] = win_opts[border_text]
        end
    end

    local has_todos = next(todos) or false
    if has_todos then
        local function len(t)
            local count = 0
            for _, _ in pairs(t) do
                count = count + 1
            end
            return count
        end

        local last_check = len(todos)
        while (len(todos) > 0) do
            for key, f in pairs(todos) do
                local ok, res = pcall(f, self)
                if ok then
                    wc[key] = res
                    todos[key] = nil
                end
            end
            if len(todos) == last_check then
                error("could not resolve win opts")
            end
        end
    end

    wc.row, wc.col = _calculate_auto_position(self)

    return wc
end

---@return window.Split
function M:to_split()
    local Split = require("window.split")
    setmetatable(self, Split)
    self:close():refresh():open()
    return self --[[@as window.Split]]
end

return M
