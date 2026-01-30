local M = {}

local function _set_hls()
    vim.api.nvim_set_hl(0, "HelpoutNormalFloat",     { link = "NormalFloat", default = true })
    vim.api.nvim_set_hl(0, "HelpoutFloatBorder",     { link = "FloatBorder", default = true })
    vim.api.nvim_set_hl(0, "HelpoutFloatTitle",      { link = "FloatTitle", default = true })
    vim.api.nvim_set_hl(0, "HelpoutFloatFooter",     { link = "FloatFooter", default = true })
    vim.api.nvim_set_hl(0, "HelpoutSearchBar",       { link = "HelpoutNormalFloat", default = true })
    vim.api.nvim_set_hl(0, "HelpoutSearchBarBorder", { link = "HelpoutFloatBorder", default = true })
    vim.api.nvim_set_hl(0, "HelpoutIncSearch",       { link = "IncSearch", default = true })
    vim.api.nvim_set_hl(0, "HelpoutCursorLine",      { link = "CursorLine", default = true })
end

local _did_setup = false
M.setup = function(opts)
    if _did_setup then
        return vim.notify("`helpout` has already been setup", vim.log.levels.ERROR, { title = "helpout" })
    end
    _did_setup = true

    local config = require("helpout.config")
    config.setup(opts)

    if config.cabbrev_help then
        -- see :h cabbrev
        -- <expr> flag signifies rhs is a vimscript expression
        vim.cmd(
            "cabbrev <expr> h (getcmdtype() == ':' && getcmdline() == 'h') ? 'Helpout' : 'h'"
        )
        vim.cmd(
            "cabbrev <expr> help (getcmdtype() == ':' && getcmdline() == 'help') ? 'Helpout' : 'help'"
        )
        vim.cmd(
            "cabbrev <expr> helpout (getcmdtype() == ':' && getcmdline() == 'helpout') ? 'Helpout' : 'helpout'"
        )
    end

    vim.keymap.set({"n", "t"}, "<C-n>", function()
        local main_win = require("helpout.windows.main").get()
        if not main_win:is_focused() then
            M.focus()
        else
            M.toggle()
        end
    end)

    vim.keymap.set({"n", "t"}, "<Leader><C-n>", M.help_cursor)
    vim.keymap.set("x", "<C-n>", M.help_visual)

    _set_hls()

end

---@param query? string
M.help = function(query)
    -- is this cursed short circuit evaluation?
    query = (query and query:match("%S") and query) or nil

    local win = require("helpout.windows.main").open()

    local ok = pcall(win.win_call, win, function() vim.cmd.help(query) end)
    if not ok then
        local msg = ("no tag found for query: `%s`"):format(query)
        vim.notify(msg, vim.log.levels.ERROR, { title = "helpout.nvim" })
    end
    return ok
    -- require("helpout.windows.toc").get()
    --     :set_cursor()

    -- if require("helpout.windows.table_of_contents").get():is_open() then
    --     require("helpout.windows.table_of_contents").update()
    -- end
end

M.help_cursor = function()
    local query = vim.fn.expand("<cword>")
    if query == "" then return end

    M.help(query)
end

M.help_visual = function()
    local pos1 = vim.fn.getpos("v")
    local pos2 = vim.fn.getpos(".")
    local selection = vim.fn.getregion(pos1, pos2)
    if #selection ~= 1 then return end

    M.help(selection[1])
end

M.open = function()
    require("helpout.windows.main").open()
end

M.close = function()
    require("helpout.windows.main").close()
end

M.focus = function()
    require("helpout.windows.main").focus()
end

M.toggle = function()
    require("helpout.windows.main").toggle()
end

-- see :h lua-guide-commands-create
vim.api.nvim_create_user_command("Helpout", function(opts) M.help(opts.fargs[1]) end, {
    nargs = "?",
    complete = "help"
})

return M
