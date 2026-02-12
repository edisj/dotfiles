local api = vim.api

---@type integer
local _id = 1

---@param win Window
local function _win_set_keymaps(win)
    for _, spec in ipairs(win.opts.keymaps) do
        if spec then
            local mode, lhs, rhs, keymap_opts = unpack(spec)
            win:keymap(mode, lhs, rhs, keymap_opts)
        end
    end
end

---@param win Window
local function _on_buf_win_enter(win, _)
    local win_entered = api.nvim_get_current_win()
    if win_entered ~= win.winid then
        return
    end

    local stickybuf = win.opts.stickybuf
    local buf_entered = api.nvim_win_get_buf(win_entered)

    if stickybuf == false then
        win:set_buf(buf_entered)
        _win_set_keymaps(win)
        return
    end

    if type(stickybuf) == "string" then
        local ft = api.nvim_get_option_value("filetype", { buf = buf_entered })
        local bt = api.nvim_get_option_value("buftype", { buf = buf_entered })
        if not (ft == stickybuf or bt == stickybuf) then
            vim.notify("This window is locked to type `" .. stickybuf .. "` because `stickybuf="..stickybuf.."`", vim.log.levels.ERROR, { title = "window.Float" })
            api.nvim_win_set_buf(win.winid, win.bufnr)
            win:set_wo()
            return
        end
        win:set_buf(buf_entered)
        _win_set_keymaps(win)
        return
    end

    assert(stickybuf == true, "stickybuf must be true at this point")
    if buf_entered ~= win.bufnr then
        vim.notify("This window is locked to bufnr=" .. win.bufnr .. " because `stickybuf=true`", vim.log.levels.ERROR, { title = "window.Float" })
        api.nvim_win_set_buf(win.winid, win.bufnr)
        return
    end

    win:set_buf(buf_entered)
    _win_set_keymaps(win)
end

---@param win Window
---@return integer
local function _initialize_buf(win)
    if win:buf_is_valid() then
        -- should keymaps be set here??
        return win.bufnr
    end

    if win.opts.file then
        win.bufnr = vim.fn.bufadd(win.opts.file)
        if not api.nvim_buf_is_loaded(win.bufnr) then
            vim.fn.bufload(win.bufnr)
        end
    elseif win.opts.bufnr then
        win.bufnr = (type(win.opts.bufnr) == "function" and win.opts.bufnr(win)) or win.opts.bufnr --[[@as integer]]
        -- self.bufnr = self.opts.bufnr
    else
        win.bufnr = api.nvim_create_buf(false, true)
    end

    win:set_bo(win.opts.bo)
    _win_set_keymaps(win)

    return win.bufnr
end

---@class window.Base
---@field opts WinOpts
---@field id integer
---@field bufnr integer
---@field winid? integer
---@field parent? Window
---@field augroup? integer
---@field win_config? vim.api.keyset.win_config
local M = {}
M.__index = M

---@param opts WinOpts
---@return window.Base
M.new = function(opts)
    local self = setmetatable({}, M)
    self.opts = opts
    self.parent = self.opts.parent
    self.id = _id
    _id = _id + 1

    self.bufnr = _initialize_buf(self)

    self.augroup = api.nvim_create_augroup("custom-win-" .. self.id, { clear = true })

    self:create_autocmd("WinClosed", function(win, ev)
        if ev.match == tostring(win.winid) then
            win.winid = nil
        end
    end, { group = self.augroup })

    if self.opts.auto_resize then
        self:create_autocmd("WinResized", function(win, ev)
            if ev.buf ~= win.bufnr then return end

            local w = api.nvim_win_get_width(self.winid)
            -- if win.opts.width and win.opts.width > 0 and win.opts.width < 1 then
            --     w = tonumber(string.format("%.3f", w / vim.o.columns))
            -- end
            local h = api.nvim_win_get_height(self.winid)
            -- if win.opts.height and win.opts.height > 0 and win.opts.height < 1 then
            --     h = tonumber(string.format("%.3f", h / vim.o.lines))
            -- end

            vim.schedule(function()
                win:update({ width = w, height = h })
            end)
        end, { group = self.augroup })

        self:create_autocmd("VimResized", function(win, _) win:refresh() end, {
            desc = "Automatically resize window when vim is resized",
            group = self.augroup,
        })
    end

    if self.parent then
        self:create_autocmd("WinClosed", function(_, ev)
            if ev.buf == self.parent.bufnr then
                self:close()
            end
        end, {
            desc = "Close window when parent window closes",
            group = self.augroup,
        })
    end

    return self
end

function M:resolve_win_opts()
    error("Not implemented in `window.Base`")
end

---@param event string | string[]
---@param cb fun(win: Window, ev: vim.api.keyset.create_autocmd.callback_args):boolean?
---@param opts? EventOpts
function M:create_autocmd(event, cb, opts)
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

    -- if opts.win and not opts.pattern then
    --     autocmd_opts.pattern = tostring(self.winid)
    -- end
    if opts.buf and not autocmd_opts.buffer then
        autocmd_opts.buffer = self.bufnr
    end

    if opts.win then
        autocmd_opts.callback = function(ev)
            if ev.buf ~= self.bufnr then
                return
            end
            return cb(self, ev)
        end
    else
        autocmd_opts.callback = function(ev)
            return cb(self, ev)
        end
    end

    api.nvim_create_autocmd(event, autocmd_opts)
end

---@param mode string | string[]
---@param lhs string
---@param rhs string | fun(win: Window)
---@param opts? vim.keymap.set.Opts
function M:keymap(mode, lhs, rhs, opts)
    if not self:buf_is_valid() then return end

    local _rhs = type(rhs) == "function" and function() return rhs(self) end or rhs

    opts = opts or {}
    opts.nowait = true
    opts.remap = false
    opts.buffer = self.bufnr

    vim.keymap.set(mode, lhs, _rhs, opts)
end

---@return self
function M:open()
    if self:is_open() then return self end
    if self.parent and not self.parent:is_open() then return self end

    if not self:buf_is_valid() then
        self.bufnr = _initialize_buf(self)
    end

    if self.win_config.relative == "win" then
        local parent_id = (self.parent and self.parent.winid) or self.opts.win or api.nvim_get_current_win()
        local parent_zindex = api.nvim_win_get_config(parent_id).zindex
        self.win_config.win = parent_id
        self.win_config.zindex = self.opts.zindex or (parent_zindex and parent_zindex + 1)
    end

    -- have to set enter like this because doing _ and _ or _ ternaries with boolean values doesn't work
    local enter = self.opts.enter == nil or self.opts.enter or false
    if self.win_config.focusable == false then
        enter = false
    end
    self.winid = api.nvim_open_win(self.bufnr, enter, self.win_config)
    if self.opts.stickybuf == true then
        vim.api.nvim_set_option_value("winfixbuf", true, { win = self.winid })
    end

    -- need to set window options AFTER window has opened
    self:set_wo()

    self:create_autocmd("BufWinEnter", _on_buf_win_enter)

    return self
end

---@return self
function M:refresh()
    return self:update()
end

---@param opts? WinOpts
---@return self
function M:update(opts)
    opts = opts or {}
    self.opts = vim.tbl_deep_extend("force", self.opts, opts)
    self.win_config = self:resolve_win_opts()

    if not self:is_open() then return self end

    self:set_bo()
    api.nvim_win_set_config(self.winid, self.win_config)
    self:set_wo()

    return self
end

---@return self
function M:close()
    if not self:is_open() then
        return self
    end

    api.nvim_win_close(self.winid, true)
    self.winid = nil
    -- self.win_config.win = nil

    return self
end

---@return self
function M:focus()
    if not self:is_open() then
        self:open()
    end
    api.nvim_set_current_win(self.winid)
    return self
end

---@return self
function M:toggle()
    return self:is_open() and self:close() or self:open()
end

---@return WinDimensions
function M:get_parent_dimensions()
    if self.win_config.relative ~= "win" then
        return { width = vim.o.columns, height = vim.o.lines }
    end

    if self.parent then
        return { width = self.parent.win_config.width, height = self.parent.win_config.height }
    end

    local parent_id = self.opts.win or 0
    local width = api.nvim_win_get_width(parent_id)
    local height = api.nvim_win_get_height(parent_id)

    return { width = width, height = height }
end

---@param bo? vim.bo | {}
function M:set_bo(bo)
    -- bo = bo or {}
    bo = vim.tbl_deep_extend("keep", bo or {}, self.opts.bo)
    for k, v in pairs(bo) do
        api.nvim_set_option_value(k, v, { buf = self.bufnr })
    end
end

---@param wo? vim.wo | {}
function M:set_wo(wo)
    -- wo = wo or self.opts.wo or {}
    wo = vim.tbl_deep_extend("keep", wo or {}, self.opts.wo)
    for k, v in pairs(wo) do
        api.nvim_set_option_value(k, v, { scope = "local", win = self.winid })
    end
end

---@param bufnr integer
---@return self
function M:set_buf(bufnr)
    if bufnr == self.bufnr then
        return self
    end
    assert(self:win_is_valid(), "not a valid win")
    assert(api.nvim_buf_is_valid(bufnr), "not a valid bufnr")
    self.bufnr = bufnr
    api.nvim_win_set_buf(self.winid, self.bufnr)
    self:set_bo(self.opts.bo)
    return self
end

---@param fn fun(win: window.Float)
---@return self
function M:win_call(fn)
    assert(self:win_is_valid(), "not a valid win")
    api.nvim_win_call(self.winid, fn)
    return self
end

---@param fn fun(win: window.Float): any
---@return self
function M:buf_call(fn)
    assert(self:buf_is_valid(), "not a valid buffer")
    api.nvim_buf_call(self.bufnr, fn)
    return self
end

---Get the real win config straight from the horse's mouth.
---Returns nil if the window is not currently open.
---@return vim.api.keyset.win_config | nil
function M:get_win_config()
    if self:is_open() then
        return api.nvim_win_get_config(self.winid)
    end
end

---@param lines string[]
---@param opts? { start: integer, end_: integer, force?: boolean }
---@return self
function M:set_lines(lines, opts)
    if not self:buf_is_valid() then
        vim.notify(string.format("bufnr `%s` is invalid", self.bufnr), vim.log.levels.ERROR, {})
        return self
    end
    opts = opts or {}
    local start = opts.start and opts.start - 1 or 0
    local end_ = opts.end_ and opts.end_ or -1

    local is_modifiable = api.nvim_get_option_value("modifiable", { buf = self.bufnr })
    if not is_modifiable then
        api.nvim_set_option_value("modifiable", true, { buf = self.bufnr })
        api.nvim_buf_set_lines(self.bufnr, start, end_, false, lines)
        api.nvim_set_option_value("modifiable", false, { buf = self.bufnr })
        return self
    end

    api.nvim_buf_set_lines(self.bufnr, start, end_, false, lines)
    return self
end

---@param start_lnum? integer 1-indexed
---@param end_lnum? integer 1-indexed
---@return string[]
function M:get_lines(start_lnum, end_lnum)
    if not self:buf_is_valid() then
        return {}
    end
    start_lnum = start_lnum or 1
    end_lnum = end_lnum or -1

    return api.nvim_buf_get_lines(self.bufnr, start_lnum - 1, end_lnum, false)
end

---@param lnum? integer 1-indexed line number
---@return string
function M:get_line(lnum)
    lnum = lnum or 1
    return self:get_lines(lnum, lnum)[1]
end

---@param lnum integer 1-indexed line number
---@param col integer 0-indexed col number
---@return self
function M:set_cursor(lnum, col)
    if not self:win_is_valid() or not self:buf_is_valid() then
        vim.notify("window is not in a valid state", vim.log.levels.ERROR, {})
        return self
    end
    api.nvim_win_set_cursor(self.winid, { lnum, col })
    return self
end

---@return [integer, integer] | nil (1,0)-indexed cursor position
function M:get_cursor()
    if not self:win_is_valid() or not self:buf_is_valid() then
        vim.notify("window is not in a valid state", vim.log.levels.ERROR, {})
        return
    end
    return api.nvim_win_get_cursor(self.winid)
end

---@param direction "up" | "down"
function M:move_cursor(direction)
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

function M:scroll_down()
    local key = vim.api.nvim_replace_termcodes("<C-e>", true, true, true)
    self:win_call(function()
        vim.cmd("normal! " .. key)
    end)
end

function M:scroll_up()
    local key = vim.api.nvim_replace_termcodes("<C-y>", true, true, true)
    self:win_call(function()
        vim.cmd("normal! " .. key)
    end)
end

---@return boolean
function M:is_open()
    return self:win_is_valid() and self:buf_is_valid()
end

---@return boolean
function M:is_focused()
    return self:win_is_valid() and self.winid == api.nvim_get_current_win()
end

---@return boolean
function M:buf_is_valid()
    return self.bufnr and api.nvim_buf_is_valid(self.bufnr) or false
end

---@return boolean
function M:win_is_valid()
    return self.winid and api.nvim_win_is_valid(self.winid) or false
end

return M
