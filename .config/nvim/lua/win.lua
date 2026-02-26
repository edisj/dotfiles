local api = vim.api
local fn = vim.fn

local internal = {}

-- Window api functions ========================================================

local WinAPI = {}
WinAPI.__index = WinAPI

---wraps `vim.api.nvim_open_win`
---@return self
function WinAPI:open(override_opts)
    if self:is_open() then return self end

    self.bufnr = internal.ensure_valid_buf(self)
    self:set_bo()

    local config_proxy = self:resolve_win_opts(override_opts)
    local enter = self.opts.enter
    if config_proxy.focusable == false then
        enter = false
    end

    self.winid = api.nvim_open_win(self.bufnr, enter, self._config)
    self:set_wo()

    return self
end

---wraps vim.api.nvim_win_close`
---@return self
function WinAPI:close()
    if not self:is_open() then return self end

    api.nvim_win_close(self.winid, true)
    self.winid = nil
    return self
end

---@return self
function WinAPI:focus()
    if not self:is_open() then
        self:open()
    end
    api.nvim_set_current_win(self.winid)
    return self
end

---@return self
function WinAPI:toggle()
    return self:is_open() and self:close() or self:open()
end

---@param bufnr integer
---@return self
function WinAPI:set_buf(bufnr)
    if bufnr == self.bufnr then return self end

    assert(api.nvim_buf_is_valid(bufnr), "not a valid bufnr")
    self.bufnr = bufnr
    self:set_bo(self.opts.bo)

    if self:is_open() then
        api.nvim_win_set_buf(self.winid, self.bufnr)
    end

    return self
end

function WinAPI:ensure_buf()
    if self:buf_is_valid() then return self end

    if self.opts.file then
        self.bufnr = fn.bufadd(self.opts.file)
        if not api.nvim_buf_is_loaded(self.bufnr) then
            vim.fn.bufload(self.bufnr)
        end
    elseif self.opts.bufnr then
        self.bufnr = (type(self.opts.bufnr) == "function" and self.opts.bufnr(self)) or self.opts.bufnr --[[@as integer]]
    else
        self.bufnr = api.nvim_create_buf(false, true)
    end

    internal.win_set_keymaps(self, self.opts.keymaps or {})
    return self
end

function WinAPI:set_bo(bo)
    bo = vim.tbl_deep_extend("keep", bo or {}, self.opts.bo)
    for k, v in pairs(bo) do
        api.nvim_set_option_value(k, v, { buf = self.bufnr })
    end
end

function WinAPI:set_wo(wo)
    wo = vim.tbl_deep_extend("keep", wo or {}, self.opts.wo)
    for k, v in pairs(wo) do
        api.nvim_set_option_value(k, v, { scope = "local", win = self.winid })
    end
end

---wraps `vim.api.nvim_win_call`
---@return self
function WinAPI:win_call(func)
    assert(self:win_is_valid(), "not a valid win")
    api.nvim_win_call(self.winid, func)
    return self
end

---wraps `vim.api.nvim_buf_call`
---@return self
function WinAPI:buf_call(func)
    assert(self:buf_is_valid(), "not a valid buffer")
    api.nvim_buf_call(self.bufnr, func)
    return self
end

---wraps `vim.api.nvim_buf_set_lines`
---@param lines string[]
---@param opts? { from: integer, to: integer, force?: boolean }
---@return self
function WinAPI:set_lines(lines, opts)
    if not self:buf_is_valid() then
        vim.notify(string.format("bufnr `%s` is invalid", self.bufnr), vim.log.levels.ERROR, {})
        return self
    end
    opts = opts or {}
    local from = opts.from and opts.from - 1 or 0
    local to = opts.to and opts.to or -1

    local is_modifiable = api.nvim_get_option_value("modifiable", { buf = self.bufnr })
    if not is_modifiable and opts.force then
        api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
        api.nvim_buf_set_lines(self.bufnr, from, to, false, lines)
        api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
        return self
    end

    api.nvim_buf_set_lines(self.bufnr, from, to, false, lines)
    return self
end

---append lines to end of buffer
---@return self
function WinAPI:append_lines(lines, force)
    local is_empty = #self:get_lines() == 1 and self:get_lines()[1] == ""
    return self:set_lines(lines, {
        from = is_empty and 1 or 0, -- set_lines internally converts from to 0-indexed, so 0 -> -1
        to = -1,
        force = force
    })
end

---wraps `vim.api.nvim_buf_get_lines`
---@param from? integer 1-indexed
---@param to? integer 1-indexed
---@return string[]
function WinAPI:get_lines(from, to)
    if not self:buf_is_valid() then return {} end

    from = from or 1
    to = to or -1
    return api.nvim_buf_get_lines(self.bufnr, from - 1, to, false)
end

---get a single line
---@param lnum? integer 1-indexed line number
---@return string
function WinAPI:get_line(lnum)
    lnum = lnum or 1
    return self:get_lines(lnum, lnum)[1]
end

---wraps `vim.api.nvim_win_set_cursor`
---@param lnum integer 1-indexed line number
---@param col integer 0-indexed col number
---@return self
function WinAPI:set_cursor(lnum, col)
    if not self:win_is_valid() or not self:buf_is_valid() then
        vim.notify("window is not in a valid state", vim.log.levels.ERROR, {})
        return self
    end
    api.nvim_win_set_cursor(self.winid, { lnum, col })
    return self
end

---wraps `vim.api.nvim_win_get_cursor`
---@return [integer, integer] | nil (1,0)-indexed cursor position
function WinAPI:get_cursor()
    if not self:win_is_valid() or not self:buf_is_valid() then
        vim.notify("window is not in a valid state", vim.log.levels.ERROR, {})
        return
    end
    return api.nvim_win_get_cursor(self.winid)
end

---@param direction "up" | "down"
function WinAPI:move_cursor(direction)
    if not vim.tbl_contains({"up", "down"}, direction) then
        error("direction must be one of `up` or `down`")
    end
    local line, _ = unpack(api.nvim_win_get_cursor(self.winid))
    local next = direction == "down" and line + 1 or line - 1

    if next < 1 or next > api.nvim_buf_line_count(self.bufnr) then
        return
    end

    self:win_call(function()
        api.nvim_win_set_cursor(self.winid, { next, 0 })
    end)
end

function WinAPI:scroll_down()
    local key = vim.api.nvim_replace_termcodes("<C-e>", true, true, true)
    self:win_call(function()
        vim.cmd("normal! " .. key)
    end)
end

function WinAPI:scroll_up()
    local key = vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
    self:win_call(function()
        vim.cmd("normal! " .. key)
    end)
end

function WinAPI:get_parent_dimensions()
    if self.opts.relative == "win" and api.nvim_win_is_valid(self.opts.win) then
        vim.print(self.opts.win)
        local width = api.nvim_win_get_width(self.opts.win)
        local height = api.nvim_win_get_height(self.opts.win)
        return { width = width, height = height }
    end
    return { width = vim.o.columns, height = vim.o.lines }
end

---@return boolean
function WinAPI:is_open()
    return self:buf_is_valid() and self:win_is_valid()
end

---@return boolean
function WinAPI:is_focused()
    return self:win_is_valid() and self.winid == api.nvim_get_current_win()
end

---@return boolean
function WinAPI:buf_is_valid()
    return self.bufnr and api.nvim_buf_is_valid(self.bufnr) or false
end

---@return boolean
function WinAPI:win_is_valid()
    return self.winid and api.nvim_win_is_valid(self.winid) or false
end

---@param event string | string[]
---@param cb fun(win: Window, ev: vim.api.keyset.create_autocmd.callback_args):boolean?
---@param opts? EventOpts
function WinAPI:create_autocmd(event, cb, opts)
    opts = opts or {}

    ---@type vim.api.keyset.create_autocmd
    local autocmd_opts = {}
    -- excluding `callback` key here since I set it manually below
    -- also `command` key isn't supported...
    -- see `:h nvim_create_autocmd()`
    for _, key in ipairs {
        "buffer",
        "desc",
        "group",
        "nested",
        "once",
        "pattern",
    } do
        autocmd_opts[key] = opts[key]
    end

    autocmd_opts.group = opts.group or self.augroup
    autocmd_opts.callback = function(ev) return cb(self, ev) end

    if opts.buf and not autocmd_opts.buffer then
        autocmd_opts.buffer = self.bufnr
    end

    api.nvim_create_autocmd(event, autocmd_opts)
end

---@param mode string | string[]
---@param lhs string
---@param rhs string | fun(win: Window)
---@param opts? vim.keymap.set.Opts
function WinAPI:keymap(mode, lhs, rhs, opts)
    if not self:buf_is_valid() then return end

    local _rhs = type(rhs) == "function" and function() return rhs(self) end or rhs

    opts = opts or {}
    opts.nowait = true
    opts.remap = false
    opts.buffer = self.bufnr

    vim.keymap.set(mode, lhs, _rhs, opts)
end

-- function WinAPI:on_buf_win_enter()
-- end

-- Internal helpers ============================================================

internal.ensure_valid_buf = function(win)
    if win:buf_is_valid() then return win.bufnr end

    if win.opts.file then
        win.bufnr = vim.fn.bufadd(win.opts.file)
        if not api.nvim_buf_is_loaded(win.bufnr) then
            vim.fn.bufload(win.bufnr)
        end
    elseif win.opts.bufnr then
        win.bufnr = (type(win.opts.bufnr) == "function" and win.opts.bufnr(win)) or win.opts.bufnr --[[@as integer]]
    else
        win.bufnr = api.nvim_create_buf(false, true)
    end

    internal.win_set_keymaps(win, win.opts.keymaps or {})

    return win.bufnr
end

local VALID_FLOAT_OPTS = {
    "anchor",    "border", "bufpos",     "col",    "external",  "fixed",
    "focusable", "footer", "footer_pos", "height", "hide",      "noautocmd",
    "relative",  "row",    "style",      "title",  "title_pos", "width",
    "win",       "zindex",
}
internal.resolve_win_opts_as_float = function(win, override_opts)
    local config = {}
    for _, opt in ipairs(VALID_FLOAT_OPTS) do
        config[opt] = override_opts and override_opts[opt] or win.opts[opt]
    end

    config.relative = config.relative or "editor"
    config.border = config.border or vim.o.winborder

    local config_proxy = internal.create_config_proxy(win, config)
    for k in pairs(config) do
        _ = config_proxy[k]
    end

    local parent_dimensions = win:get_parent_dimensions()
    config.width = internal.compute_width_or_height(config.width, parent_dimensions.width)
    config.height = internal.compute_width_or_height(config.height, parent_dimensions.height)

    config.row, config.col = internal.compute_float_position(win, config)

    win._config = config

    return config_proxy
end

internal.compute_float_position = function(win, config)

    local position = win.opts.position or "center"
    local anchor = win.opts.anchor or config.anchor or "NW"

    local has_border = config.border ~= "" and config.border ~= "none"
    local w = config.width + (has_border and 2 or 0)
    local h = config.height + (has_border and 2 or 0)
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
        top      = { 0, 0.5 * (W - w) },
        topright = { 0, W - w },
        left     = { 0.5 * (H - h), 0 },
        center   = { 0.5 * (H - h), 0.5 * (W - w) },
        right    = { 0.5 * (H - h), W - w },
        botleft  = { H - h, 0 },
        bot      = { H - h, 0.5 * (W-w) },
        botright = { H - h, W - w },
    }

    local Ay, Ax = unpack(anchor_map[anchor])
    local y, x = unpack(auto_pos_map[position])

    local row = math.floor(Ay*h + y - yoffset)
    local col = math.floor(Ax*w + x + xoffset)

    return row, col
end

local VALID_SPLIT_OPTS = {
    "anchor", "bufpos",    "external", "fixed", "focusable", "height",
    "hide",   "noautocmd", "split",    "style", "width",     "win",
}
internal.resolve_win_opts_as_split = function(win, override_opts)
    local config = {}
    for _, opt in ipairs(VALID_SPLIT_OPTS) do
        config[opt] = override_opts and override_opts[opt] or win.opts[opt]
    end

    config.split = config.split or "right"

    local config_proxy = internal.create_config_proxy(win, config)
    for k in pairs(config) do
        _ = config_proxy[k]
    end

    local parent_dimensions = win:get_parent_dimensions()
    config.width = internal.compute_width_or_height(config.width, parent_dimensions.width)
    config.height = internal.compute_width_or_height(config.height, parent_dimensions.height)

    win._config = config
    return config_proxy
end

internal.create_config_proxy = function(win, config)
    local config_proxy = { _accessed = {} }

    setmetatable(config_proxy, {
        __index = function(_, key)
            local val = config[key]
            if type(val) ~= "function" then return val end

            if vim.tbl_contains(config_proxy._accessed, key) then
                local msg = "[ERROR] win.lua: circular win_config detected: " .. key
                error(msg, 0)
            end
            config_proxy._accessed[#config_proxy._accessed + 1] = key
            config[key] = val(win, config_proxy)

            return config[key]
        end,
    })

    return config_proxy
end

internal.compute_width_or_height = function(width_or_height, parent_width_or_height)

    if width_or_height == nil then
        width_or_height = math.floor(0.5 * parent_width_or_height)
    elseif width_or_height <= 0 then
        width_or_height = parent_width_or_height
    elseif width_or_height < 1 then
        width_or_height = math.floor(width_or_height * parent_width_or_height)
    else
        width_or_height = math.floor(width_or_height)
    end

    return width_or_height
end

internal.win_set_keymaps = function(win, keymaps)
    for _, spec in ipairs(keymaps) do
        local mode, lhs, rhs, keymap_opts = unpack(spec)
        win:keymap(mode, lhs, rhs, keymap_opts)
    end
end


-- Exported module =============================================================

local FLOAT_DEFAULTS = {
    position = "center",
    relative = "editor",
    style = "minimal",
    enter = true,
    height = 0.5,
    width = 0.5,
    keymaps = {},
    bo = {},
    wo = {},
}
local SPLIT_DEFAULTS = {
    split = "below",
    style = "minimal",
    keymaps = {},
    bo = {},
    wo = {},
}

local function to_float(win, override_opts)
    win.resolve_win_opts = internal.resolve_win_opts_as_float
    win.is_float = true
    if win:is_open() then
        win:close():open(override_opts)
    end
    return win
end

local function to_split(win, override_opts)
    win.resolve_win_opts = internal.resolve_win_opts_as_split
    win.is_float = false
    if win:is_open() then
        win:close():open(override_opts)
    end
    return win
end

local function new(kind, opts)

    local self = setmetatable({}, WinAPI)
    self._config = {}
    self.is_float = kind == "float"

    local defaults = kind == "float" and FLOAT_DEFAULTS or SPLIT_DEFAULTS
    self.opts = vim.tbl_deep_extend("force", defaults, opts or {})

    local resolve_func = kind == "float" and internal.resolve_win_opts_as_float or internal.resolve_win_opts_as_split
    self.resolve_win_opts = resolve_func
    self.to_float = to_float
    self.to_split = to_split

    return self
end

return {
    float = setmetatable({}, {
        __call = function(_, ...) return new("float", ...) end
    }),
    split = setmetatable({}, {
        __call = function(_, ...) return new("split", ...) end
    })
}
