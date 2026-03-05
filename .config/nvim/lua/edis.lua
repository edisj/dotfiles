local fs = vim.fs
local fn = vim.fn
local api = vim.api

local qf = require("quickfix")
local sources = require("quickfix.sources")

local ROOT_MARKER = ".edis"

local state = {
    project_root = "",
    stdout = {},
    stderr = {},
}

local sys = {}
local ui = {}
local internal = {}

local function build()
    local ctx = internal.parse_marker_and_build_context()
    if ctx == nil then return end

    local cmd = ctx.build
    sys.schedule_cmd_with_context(ctx, cmd)
end

local function build_and_run()
    local ctx = internal.parse_marker_and_build_context()
    if ctx == nil then return end

    local build_cmd = ctx.build
    local run_cmd = ctx.run
    sys.schedule_cmd_with_context(ctx, build_cmd, run_cmd)
end

local function run()
    local ctx = internal.parse_marker_and_build_context()
    if ctx == nil then return end

    local cmd = ctx.run
    sys.schedule_cmd_with_context(ctx, cmd)
end

-- internal helpers ============================================================

internal.parse_marker_and_build_context = function()
    local project_root = fs.root(0, ROOT_MARKER)
    if project_root == nil then
        local msg = string.format("no '%s' file detected", ROOT_MARKER)
        vim.notify(msg, vim.log.levels.ERROR, { title = "edis.build" })
        return
    end

    state.project_root = project_root
    local marker_file  = project_root .. "/" .. ROOT_MARKER
    local metadata = internal.parse_marker_file(marker_file)
    local ctx = internal.build_context_from_metadata(metadata)

    return ctx
end

internal.parse_marker_file = function(filename)

    local file = io.open(filename)
    assert(file ~= nil, "why is file nil???")
    local lines = vim.split(file:read("*all"), "\n")
    file:close()

    local metadata = {}
    for _, line in ipairs(lines) do
        if line ~= "" then
            local line_split = vim.split(line, "=")
            local key = vim.trim(line_split[1])
            local value = vim.trim(line_split[2])
            metadata[key] = value
        end
    end

    return metadata
end

internal.build_context_from_metadata = function(metadata)

    local ctx = {}
    ctx.build = vim.split(metadata.build, " ") or {}
    ctx.run = vim.split(metadata.run, " ") or {}
    ctx.project_root = state.project_root
    ctx.compiler = metadata.compiler
    ctx.source = metadata.compiler

    return ctx
end

internal.apply_stdout_highlights = function()
    vim.fn.matchadd("Comment", [[\v^\[\zs.+\ze\]+]])
    vim.fn.matchadd("DiagnosticInfo", [[\v^\[.+\]+\[\zsINFO\ze\] ]])
    vim.fn.matchadd("DiagnosticError", [[\v^\[.+\]+\[\zsERROR\ze\] ]])
    vim.fn.matchadd("DiagnosticWarn", [[\v^\[.+\]+\[\zsWARNING\ze\] ]])
    vim.fn.matchadd("DiagnosticOk", [[\v^\[.+\]+\[\zsSUCCESS\ze\] ]])
    vim.fn.matchadd("Special", [[\v^\[.+\]+\[(SUCCESS|INFO|WARNING|ERROR)\]\s\zs[^:]+\ze:]])
    vim.fn.matchadd("@punctuation.bracket", [[\v(\[|\]|:)]])
end

internal.clear_quickfix = function()
    fn.setqflist({}, "r")
    qf.close()
end

internal.open_ui_and_scroll = function()
end

-- system calls ================================================================

sys.schedule_cmd_with_context = function(ctx, cmd, after_cmd)

    local on_exit = function(obj)
        local dont_scroll = obj.code == 0 and after_cmd ~= nil
        sys.on_stdout(ctx, obj.stdout, dont_scroll)
        sys.on_stderr(ctx, obj.stderr)

        if after_cmd and obj.code == 0 then
            sys.schedule_cmd_with_context(ctx, after_cmd)
            return
        end

        vim.schedule(ui.open)
    end

    vim.system(cmd, { text = true }, on_exit)
end

sys.on_stdout = function(ctx, stdout, dont_scroll)
    if stdout == "" then return end

    local append_stdout = function()
        local lines = vim.split(stdout, "\n")

        ui.stdout()
            :ensure_buf()
            :append_lines(lines, { force = true })

        if ui.stdout():is_open() and not dont_scroll then
            ui.stdout()
                :win_call(function() vim.cmd("normal! zt") end)
                :set_cursor(#ui.stdout():get_lines(), 0)
                :scroll_down()
        end
    end

    vim.schedule(append_stdout)
end

sys.on_stderr = function(ctx, stderr)
    if stderr == "" then
        vim.schedule(internal.clear_quickfix)
        return
    end

    local lines = vim.split(stderr, "\n")
    local qf_items = {}
    local source = sources[ctx.source]
    local error_format = source.error_format
    local line_to_item = source.line_to_item
    for _, line in ipairs(lines) do
        if line:match(error_format) then
            local item = line_to_item(line)
            qf_items[#qf_items + 1] = item
        end
    end

    state.stderr = stderr
    local set_qf_and_open_ui = function()
        fn.setqflist({}, " ", {
            items = qf_items,
            quickfixtextfunc = "v:lua.require'quickfix'.quickfixtextfunc",
            context = ctx,
        })
        ui.open()
    end

    vim.schedule(set_qf_and_open_ui)
end

-- ui table ====================================================================

local _stdout = nil
ui.stdout = function()
    if _stdout then return _stdout end

    local win_opts = {
        enter = false,
        style = "minimal",
        split = "below",
        height = 12,
        keymaps = {
            { "n", "q", function(self) self:close() end },
        },
        bo = {
            modifiable = false,
        },
        wo = {
            -- number = true,
            -- winbar = "stdout",
            scrolloff = 0,
            statuscolumn = "  ",
            winhl = table.concat({
                "Normal:NormalFloat",
                "WinSeparator:WinSeparator2",
                "WinBar:NormalFloat",
                "StatusColumn:NormalFloat",
            }, ",")
        },
    }

    _stdout = require("win").split(win_opts)
    return _stdout
end

ui.open = function()
    ui.stdout()
        :open()
        :win_call(internal.apply_stdout_highlights)
        :set_cursor(#ui.stdout():get_lines(), 0)

    if #fn.getqflist() ~= 0 then
        qf.open({
            split = "left",
            win = ui.stdout().winid,
            width = 0.50,
            wo = {
                winhl = table.concat({
                    "Normal:NormalFloat",
                    "WinSeparator:WinSeparator2",
                    "WinBar:NormalFloat",
                    "StatusColumn:NormalFloat",
                }, ",")
            },
        })
    else
        qf.close()
    end

end

ui.close = function()
    ui.stdout():close()
    qf.close()
end

ui.toggle = function()
    if ui.stdout():is_open() then
        ui.close()
    else
        ui.open()
    end
end

ui.clear = function()
    ui.stdout():set_lines({}, { force = true })
end

vim.keymap.set({"n", "i"}, "<M-m>", function()
    vim.cmd.stopinsert()
    vim.cmd("update")
    build()
end)

vim.keymap.set({"n", "i"}, "<M-S-m>", function()
    vim.cmd.stopinsert()
    vim.cmd("update")
    build_and_run()
end)

vim.keymap.set("n", "<C-l>", ui.clear)
vim.keymap.set("n", "<C-h>", ui.toggle)

vim.keymap.set({"n", "i"}, "<M-S-Enter>", function()
    vim.cmd.stopinsert()
    run()
end)

return {
    build = build,
    run = run,
    build_and_run = build_and_run,
    ui = ui
}
