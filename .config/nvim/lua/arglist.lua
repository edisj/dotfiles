local api = vim.api

local MAX_ENTRIES = 6

local _valid_indices = {}
for i = 1, MAX_ENTRIES do
    _valid_indices[i] = i
end

local _scratch_buf = vim.api.nvim_create_buf(false, true)
local _scratch_name = string.format("arglist://%s/null-buf", _scratch_buf)
api.nvim_buf_set_name(_scratch_buf, _scratch_name)

local M = {}

M.arglist = setmetatable({}, {
    __newindex = function(_, k, v)

        if not vim.tbl_contains(_valid_indices, k) then
            local err_msg = k.." is out of bounds for [[1.."..MAX_ENTRIES.."]]"
            vim.notify(err_msg, vim.log.levels.ERROR, { title = "arglist" })
            return
        end

        if M.arglist[k] then
            vim.cmd(k .. "argdelete")
        end

        if vim.fn.argc() < k then
            for i = vim.fn.argc(), k-2 do
                vim.cmd(i .. "argadd ".. _scratch_name)
            end
        end
        v = vim.fn.fnamemodify(v, ":p")
        local cmd = string.format("%sargadd %s", k - 1, v)
        vim.cmd(cmd)
    end,
    __index = function(_, k)
        return vim.fn.argv()[k]
    end,
    __call = function(_)
        return vim.fn.argv()
    end,
})

local function _create_arglist_win()
    local win_opts = {
        auto_position = "center",
        bufnr = function(_)
            local bufnr = api.nvim_create_buf(false, true)
            api.nvim_buf_set_name(bufnr, "arglist")
            return bufnr
        end,
        stickybuf = true,
        width = 0.30,
        height = MAX_ENTRIES,
        style = "minimal",
        footer = { {"arglist", "NormalFloat"} },
        footer_pos = "center",
        bo = {
            filetype = "arglist",
            bufhidden = "hide",
            buflisted = false,
        },
        wo = {
            number = true,
            cursorline = true,
        },
    }

    local win = require("window.float").new(win_opts)
    win:set_lines(M.arglist())

    return win
end

M.win = _create_arglist_win()

M.arg_add = function(new)
    new = new or vim.api.nvim_buf_get_name(0)

    local function find_first_empty()
        if vim.fn.argc() < MAX_ENTRIES then
            return vim.fn.argc() + 1
        end

        for i = 1, vim.fn.argc() do
            if M.arglist[i] == _scratch_name then
                return i
            end
        end

        return false
    end

    local i = find_first_empty()
    if not i then
        return vim.notify("`arglist` is full", vim.log.levels.ERROR, { title = "arglist" })
    end

    M.arglist[i] = new
end

M.wipe_arglist = function()
    vim.cmd("argdelete *")
end

M.jump_to = function(i)
    if not M.arglist[i] or M.arglist[i] == _scratch_name then
        return
    end
    if M.arglist[i] == vim.api.nvim_buf_get_name(0) then
        return
    end
    vim.cmd(i .. "argument")
    if vim.fn.mode() == "i" then
        vim.cmd.stopinsert()
        vim.cmd("normal! l")
    end
end

M.open = function()
    local map = function(value)
        return value == _scratch_name and "" or value
    end

    local lines = vim.tbl_map(map, M.arglist())
    M.win:set_lines(lines):open()
end

M.close = function()
    M.win:close()
end

M.toggle = function()
    if not M.win:is_open() then
        M.open()
    else
        M.close()
    end
end

vim.api.nvim_create_autocmd("WinClosed", {
    buffer = M.win.bufnr,
    group = vim.api.nvim_create_augroup("arglist", { clear = true }),
    desc = "sync arglist with arglist window when exiting buffer",
    callback = function()

        local lines = {}
        for i = 1, MAX_ENTRIES do
            lines[i] = ""
        end
        lines = vim.tbl_deep_extend("force", lines, M.win:get_lines())
        lines = vim.tbl_map(function(value)
            return value == "" and _scratch_name or value
        end, lines)

        for i, line in ipairs(lines) do
            -- this is added to suppress annoying out of bounds errors caused
            -- by trailing _'s when you add lines to the window
            if i > MAX_ENTRIES and line == _scratch_name then
                goto continue
            end

            M.arglist[i] = line

            ::continue::
        end

        if vim.fn.mode() == "i" then
            vim.cmd.stopinsert()
            vim.cmd("normal! l")
        end
        vim.bo[_scratch_buf].bufhidden = "hide"
        vim.bo[_scratch_buf].buflisted = false
    end
})

vim.keymap.set("n", "<C-space>", M.arg_add)
vim.keymap.set({"n", "i"}, "<M-`>", M.toggle)
-- vim.keymap.set({"n", "i"}, "<C-A-S-Find>q", M.toggle)

for i, key in ipairs({ "q", "w", "e", "u", "i", "o" }) do
    vim.keymap.set({ "n", "i" }, "<M-"..key..">", function()
        vim.cmd.stopinsert()
        M.jump_to(i)
    end)
    -- vim.keymap.set("n", ",<M-"..key..">", function() M.arglist[i] = vim.api.nvim_buf_get_name(0) end)
    -- vim.keymap.set("n", "<leader><M-" .. key .. ">", function() M.arglist[i] = vim.fn.expand("%:p") end)
    vim.keymap.set("n", "<M-S-" .. key .. ">", function() M.arglist[i] = vim.fn.expand("%:p") end)
end

local ok, mini_files = pcall(require, "mini.files")
if not ok then return M end

local function go_in_and_arglist(i)
    local path = (mini_files.get_fs_entry() or {}).path
    if path == nil then return vim.notify('Cursor is not on valid entry') end
    if vim.uv.fs_stat(path).type ~= "file" then return end
    M.arglist[i] = vim.fn.fnamemodify(path, ":p")
    mini_files.go_in({ close_on_file = true })
end

vim.api.nvim_create_autocmd("User", {
    pattern = "MiniFilesBufferCreate",
    callback = function(ev)
        local buf_id = ev.data.buf_id
        for i, key in ipairs({ "q", "w", "e", "u", "i", "o" }) do
            vim.keymap.set("n", "<M-S-" .. key .. ">", function() go_in_and_arglist(i) end, { buffer = buf_id })
        end
    end,
})

return M
