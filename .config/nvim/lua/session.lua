local api = vim.api
local fn = vim.fn
local uv = vim.uv

local _dir = fn.stdpath("state") .. "/sessions/"
local _augroup
local _this_session

local M = {}

local _did_setup = false
M.setup = function()
    if _did_setup then return end
    _did_setup = true

    fn.mkdir(_dir, "p")
    vim.opt.sessionoptions = {
        "blank",
        -- "buffers",
        "curdir",
        "folds",
        "help",
        "tabpages",
        "winsize",
        "terminal"
    }

    api.nvim_create_autocmd("VimLeavePre", {
        desc = "save session on vim leave",
        group = M.augroup(),
        callback = function(_)
            if M.this_session() ~= nil then
                M.save()
            end
        end,
    })
end

M.this_session = function()
    return _this_session
end

M.augroup = function()
    return _augroup or api.nvim_create_augroup("edis-sessioner", { clear = true })
end

---@param compator? fun(a: any, b: any):boolean
---@return string[]
M.get_sessions = function(compator)
    compator = compator or function(a, b)
        return uv.fs_stat(a).mtime.sec > uv.fs_stat(b).mtime.sec
    end
    local sessions = fn.glob(_dir .. "*.vim", true, true)
    table.sort(sessions, compator)
    return sessions
end

---@param name string session name
---@return string path full path
M.get_path_from_name = function(name)
    local fname = _dir .. name .. ".vim"
    local path = fn.fnamemodify(fname, ":p")
    return path
end

local function _try_cmd(cmd)
    local ok, err = pcall(vim.cmd --[[@as fun(cmd: string)]], cmd)
    if not ok then
        vim.notify(err, vim.log.levels.ERROR, {})
        return false
    end
    return true
end

local function _success(...)
    local msg = table.concat({...}, " ")
    vim.notify(msg, vim.log.levels.INFO, { title = "session" })
    return true
end

local function _set_this_session(name)
    _this_session = name
end

---@param name string session name
M.load = function(name)
    local path = M.get_path_from_name(name)
    path = fn.fnameescape(path)
    if fn.filereadable(path) == 0 then
        return vim.notify("session not found: " .. tostring(name), vim.log.levels.ERROR, { title = "session" })
    end
    local cmd = "silent! source " .. path

    return _try_cmd(cmd) and _success("session loaded:", name) and _set_this_session(name)
end

-- ---@param name? string session name
-- M.save = function(name)
--     vim.print(name)
--     if name == "" then
--         local opts = { prompt = "Enter session name: " }
--         local on_confirm = function(input)
--             vim.cmd.redraw()
--             M.save(input)
--         end
--         return vim.ui.input(opts, on_confirm)
--     end
--     if name == nil then return end
--     assert(type(name) == "string", "name must exist at this point")
--     local path = M.get_path_from_name(name)
--     local cmd = "mksession! " .. fn.fnameescape(path)
--
--     return _try_cmd(cmd) and _success("session saved:", name) and _set_this_session(name)
-- end

M.new = function()
end

M.last = function()
    local last = M.get_sessions()[1]
    -- first get tail, then root (removing extension)
    local name = fn.fnamemodify(last, ":t:r")
    M.load(name)
end

-- TODO
M.select = function()
    local items = vim.tbl_map(function(session)
        return fn.fnamemodify(session, ":t:r")
    end, M.get_sessions())
    local opts = {
        prompt = "PROMPT TEST",
        format_item = function(item) return "I'd like to choose " .. tostring(item) end,
    }
    local on_choice = function(choice) vim.notify("CHOICE MADE: " .. tostring(choice), vim.log.levels.INFO, {}) end

    vim.ui.select(items, opts, on_choice)
end

return M
