local Base = require("window.base")

---@class window.Split: window.Base
local M = setmetatable({}, Base)
M.__index = M

---@type WinOpts
local _defaults = {
    split = "right",
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
    wc.split = win_opts.split or "right"

    local todos = {}

    local function resolve_win_dim(dim, parent_dim)
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
