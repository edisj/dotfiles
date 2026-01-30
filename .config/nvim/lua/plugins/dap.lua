local arrows = require('icons').arrows

-- Set up icons.
local icons = {
    Stopped = { '', 'DiagnosticWarn', 'DapStoppedLine' },
    Breakpoint = { '', "DiagnosticError" },
    BreakpointCondition = { '', "DiagnosticWarn" },
    BreakpointRejected = { '', 'DiagnosticError' },
    LogPoint = arrows.right,
}
for name, sign in pairs(icons) do
    sign = type(sign) == 'table' and sign or { sign }
    vim.fn.sign_define('Dap' .. name, {
        -- stylua: ignore
        text = sign[1] --[[@as string]] .. ' ',
        texthl = sign[2] or 'DiagnosticInfo',
        linehl = sign[3],
        numhl = sign[3],
    })
end

return {
    "mfussenegger/nvim-dap",
    dependencies = {
        "mfussenegger/nvim-dap-python",
        {
            "igorlfs/nvim-dap-view",
            cmd = {
                "DapViewOpen",
                "DapViewClose",
            },
            -- keys = {
            --     { "<leader>dv", "<Cmd>DapViewToggle<CR>", desc = "dap-view toggle" },
            -- },
            opts = {
                winbar = {
                    -- sections = { "scopes", "breakpoints", "threads", "exceptions", "repl", "console" },
                    sections = { "watches", "scopes", "breakpoints", "threads", "exceptions", "repl" },
                    default_section = "scopes",
                },
                -- windows = {
                --     position = "below",
                --     -- width = 12,
                --     terminal = {
                --         position = "right",
                --     },
                -- },
                -- When jumping through the call stack, try to switch to the buffer if already open in
                -- a window, else use the last window to open the buffer.
                switchbuf = "usetab,uselast",
            },
        },
        {
            "theHamsta/nvim-dap-virtual-text",
            opts = { virt_text_pos = "eol" },
        },
        {
            "jbyuki/one-small-step-for-vimkind",
            -- keys = {
            --     { "<leader>dl", function() require("osv").launch({ port = 8086 }) end, desc = "Launch Lua adapter" },
            -- },
        },
    },
    -- stylua: ignore
    keys = {
        {
            "<leader>dc",
            function() require("dap").set_breakpoint(vim.fn.input('Breakpoint condition: ')) end,
            desc = "Breakpoint Condition"
        },
        {
            "<leader>db",
            function() require("dap").toggle_breakpoint() end,
            desc = "Toggle breakpoint",
        },
        { "<F1>", function() require("dap").continue() end,  desc = "Debug continue" },
        { "<F2>", function() require("dap").restart() end,   desc = "Debug retstart" },
        { "<F3>", function() require("dap").step_out() end,  desc = "Debug step out" },
        { "<F4>", function() require("dap").step_into() end, desc = "Debug step into" },
        { "<F5>", function() require("dap").step_back() end, desc = "Debug step back" },
        { "<F6>", function() require("dap").step_over() end, desc = "Debug step over" },

        { "<leader>dv", "<Cmd>DapViewToggle<CR>", desc = "dap-view toggle" },
        { "<leader>dl", function() require("osv").launch({ port = 8086 }) end, desc = "Launch Lua adapter" },
    },
    config = function(_, opts)
        local dap = require("dap")

        dap.configurations.lua = {
            {
                type = "nlua",
                request = "attach",
                name = "Attach to running Neovim instance",
            }
        }
        dap.adapters.nlua = function(callback, config)
            callback({
                type = "server",
                host = config.host or "127.0.0.1",
                port = config.port or 8086
            })
        end

        local dv = require("dap-view")
        dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
        dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
        dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
        dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end
    end,
}
