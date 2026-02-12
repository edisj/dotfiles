local Base = require("window.base")

local _direction_map = {
    top = "above",
    bot = "below",
    left = "left",
    right = "right",
}

local function _find_parent_in_layout(winlayout, parent_id, left_or_right, top_or_bot)

    local function resolve(layout, in_row)
        in_row = in_row == nil and true or in_row
        local curr_node = layout[1]
        local children = layout[2]

        if curr_node ~= "leaf" then
            for _, child in ipairs(children) do
                in_row = curr_node == "col" and true or false
                local winid, split = resolve(child, in_row)
                if parent_id == winid then return winid, split end
            end

            error(string.format("could not resolve position of parent window %s in layout", parent_id))
        end

        assert(curr_node == "leaf", "curr_node must be 'leaf' at this point")
        assert(type(children) == "number", "children must be the winid at this point")

        local split_direction = in_row and _direction_map[left_or_right] or _direction_map[top_or_bot]

        return children, split_direction
    end

    return resolve(winlayout, winlayout[1] ~= "col")
end

local function _find_win_in_layout(winlayout, left_or_right, top_or_bot)

    local function resolve(layout, in_row)
        in_row = in_row == nil and true or in_row
        local curr_node = layout[1]
        local children = layout[2]

        if curr_node == "row" then
            local idx = left_or_right == "right" and #children or 1
            return resolve(children[idx], false)
        end
        if curr_node == "col" then
            local idx = top_or_bot == "bot" and #children or 1
            return resolve(children[idx], true)
        end

        assert(curr_node == "leaf", "curr_node must be 'leaf' at this point")
        assert(type(children) == "number", "children must be the winid at this point")

        local winid = children
        local split = in_row and _direction_map[left_or_right] or _direction_map[top_or_bot]

        return winid, split
    end

    return resolve(winlayout, winlayout[1] ~= "col")
end

local function _resolve_split_position(win)

    local parent_id = win.parent and win.parent.winid or nil
    local split = win.opts.split

    -- immediately return if the split is fully specified in opts
    if parent_id and split then return parent_id, split end

    local pos = win.opts.auto_position

    -- handle left,right,top,bot positions first
    -- no magic going on here, just need to detect whether to
    -- split with respect to whole editor or a single window
    if _direction_map[pos] ~= nil then
        parent_id = parent_id or (win.opts.relative == "editor" and -1 ) or win.opts.win or -1
        split = _direction_map[pos]
        return parent_id, split
    end

    local left_or_right = pos:match("left") or pos:match("right")
    local top_or_bot = pos:match("top") or pos:match("bot")
    local winlayout = vim.fn.winlayout()
    if parent_id ~= nil then
        parent_id, split = _find_parent_in_layout(winlayout, parent_id, left_or_right, top_or_bot)
    else
        parent_id, split = _find_win_in_layout(winlayout, left_or_right, top_or_bot)
    end

    return parent_id, split
end

local function _resolve_win_dim(dim, parent_dim)
    if not dim then return end

    if dim <= 0 then
        dim = parent_dim
    elseif dim < 1 then
        dim = math.floor(dim * parent_dim)
    else
        dim = math.floor(dim)
    end

    return math.min(dim, parent_dim)
end

---@class window.Split: window.Base
local M = setmetatable({}, Base)
M.__index = M

---@type WinOpts
local _defaults = {
    auto_position = "botright",
    auto_resize = true,
    enter = true,
    keymaps = {},
    bo = {},
    wo = {},
}

---@param opts WinOpts
M.new = function(opts)
    opts = vim.tbl_deep_extend("force", _defaults, opts or {})
    -- normally to create an instance you'd do `local self = setmetatable({}, M)`
    -- however, here, we first initialize self with the Base constructor
    -- and then point the metatable to M afterwards
    local self = Base.new(opts)
    setmetatable(self, M)

    self.win_config = self:resolve_win_opts()

    return self
end

---@override
---@private
function M:resolve_win_opts()

    ---@type vim.api.keyset.win_config
    local win_opts = {}
    -- filtering self.opts for win_config opts
    for _, opt in ipairs {
        "anchor",
        "bufpos",
        "external",
        "fixed",
        "focusable",
        "relative",
        "height",
        "hide",
        "noautocmd",
        "split",
        "style",
        "width",
        "win",
    } do
        win_opts[opt] = self.opts[opt]
    end

    self.win_config = vim.tbl_deep_extend("force", self.win_config or {}, win_opts)
    local wc = self.win_config

    local todos = {}

    local parent_dims = self:get_parent_dimensions()
    for _, dim in ipairs {
        "width",
        "height",
    } do
        local dim_opt = win_opts[dim]
        if type(dim_opt) == "function" then
            todos[dim] = function() return _resolve_win_dim(dim_opt(self), parent_dims[dim]) end
        else
            -- vim.print("RESOLVING " .. dim)
            wc[dim] = _resolve_win_dim(dim_opt, parent_dims[dim])
            -- vim.print(wc[dim])
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

    wc.win, wc.split = _resolve_split_position(self)

    for _, opt in ipairs {
        "border",
        "col",
        "footer",
        "footer_pos",
        "relative",
        "row",
        "title",
        "title_pos",
        "zindex",
    } do
        wc[opt] = nil
    end

    return wc
end

---@return window.Float
function M:to_float()
    local Float = require("window.float")
    setmetatable(self, Float)
    self:close():refresh():open()
    return self --[[@as window.Float]]
end

return M
