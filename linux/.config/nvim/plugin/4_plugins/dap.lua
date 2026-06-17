
-- local function is_truncated(sections, section, width)
--   local sections_as_str = table.concat(sections, "  ") .. "  "
--   local gap_indices = {}
--   for i in sections_as_str:gmatch("()%s%s") do
--     gap_indices[#gap_indices + 1] = i
--   end
-- end

local nmap = function(...) Config.map("n", ...) end
local nmap_leader = function(lhs, ...) Config.map("n", "<leader>"..lhs, ...) end

Pack.add({
  { src = "https://codeberg.org/mfussenegger/nvim-jdtls", data = { enabled = true } },
  {
    src = "https://codeberg.org/mfussenegger/nvim-dap",
    data = {
      enabled = true,
      loader = Pack.load_on_loop(function(name)
        vim.cmd.packadd(name)
        local dap = require("dap")

        -- - switchbuf. (string|fun). Controls the behavior when jumping to a
        --   breakpoint. See |'switchbuf'|. Defaults to the global `'switchbuf'` setting.
        --
        --   nvim-dap provides an additional `usevisible` option
        --   that can be used to prevent jumps within the active
        --   window if a stopped event is within the visible region.
        --   Best used in combination with other options. For
        --   example: 'usevisible,usetab,uselast'
        --
        --   For more complex use cases, nvim-dap allows overriding with a function. The
        --   function receives 3 arguments: (bufnr, line, column). It has full control of
        --   how Neovim should behave and it is not expected to return anything.
        dap.defaults.fallback.switchbuf = "usevisible,usetab,newtab"

        dap.adapters.codelldb = {
          type = "executable",
          command = "codelldb",
        }
        dap.adapters.nlua = function(callback, config)
          callback({
            type = "server",
            host = config.host or "127.0.0.1",
            port = config.port or 8086
          })
        end

        dap.configurations.lua = {
          {
            type = "nlua",
            request = "attach",
            name = "Attach to running Neovim instance",
          }
        }

        dap.configurations.c = {
          {
            type = "codelldb",
            name = "launch",
            request = "launch",
            program = function()
              return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
            end,
            cwd = "${workspaceFolder}",
            stopOnEntery = false,
            args = {},
          }
        }
        dap.configurations.cpp = dap.configurations.c

        nmap("<M-CR>",    function() dap.continue() end,          { desc = "dap: continue" })
        nmap("<M-Left>",  function() dap.step_out() end,          { desc = "dap: step out" })
        nmap("<M-Right>", function() dap.step_into() end,         { desc = "dap: step into" })
        nmap("<M-Up>",    function() dap.step_back() end,         { desc = "dap: step back" })
        nmap("<M-Down>",  function() dap.step_over() end,         { desc = "dap: step over" })
        -- nmap("<F2>",      function() dap.restart() end,           { desc = "dap: restart" })
        -- nmap("<F1>",      function() dap.toggle_breakpoint() end, { desc = "dap: toggle breakpoint" })
        nmap("<M-.>",      function() dap.toggle_breakpoint() end, { desc = "dap: toggle breakpoint" })

        nmap_leader("dr", function() dap.restart() end,           { desc = "restart" })
        nmap_leader("dt", function() dap.terminate() end,         { desc = "terminate" })
        nmap_leader("db", function() dap.list_breakpoints() end,  { desc = "list breakpoints" })
        nmap_leader("dc", function() dap.clear_breakpoints() end, { desc = "clear breakpoints" })
        nmap_leader("dp", function() dap.repl.open() end,         { desc = "repl" })
        nmap_leader("d.", function() dap.run_to_cursor() end,     { desc = "run to cursor" })

        nmap_leader("d<C-q>", function()
          dap.list_breakpoints()
          -- require("quicksys").quickfix_open()
        end,  { desc = "quickfix breakpoints" })

        nmap_leader("d?", function()
          vim.ui.input({
            prompt = "Condition: ",
          })
        end, { desc = "conditional" })

        nmap_leader("dl", function()
          vim.ui.input({
            prompt = "Log: ",
          })
        end, { desc = "log point" })

        vim.fn.sign_define("DapBreakpoint", {
          text = require("ui.icons").dap.breakpoint or "B ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapBreakPointRejected", {
          text = require("ui.icons").dap.rejected or "R ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapBreakpointCondition", {
          text = require("ui.icons").dap.conditional or "C ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapLogPoint", {
          text = require("ui.icons").dap.logpoint or "L ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapStopped", {
          text = require("ui.icons").dap.pc or "→ ",
          texthl = "DapStopped",
          linehl = "DapStoppedLine",
          -- numhl = "DapStoppedLine",
        })

        local refresh_statusline = function(_, _) vim.cmd("redrawstatus") end
        dap.listeners.after.event_initialized["statusline"] = refresh_statusline
        dap.listeners.after.event_terminated["statusline"] = refresh_statusline
        dap.listeners.after.event_stopped["statusline"] = refresh_statusline
        dap.listeners.after.event_continued["statusline"] = refresh_statusline
      end),
    },
  },

  {
    src = "https://github.com/igorlfs/nvim-dap-view",
    data = {
      enabled = true,
      loader = Pack.load_on_loop(function(name)
        vim.cmd.packadd(name)

        local dv = require("dap-view")
        local sections = { "breakpoints", "watches", "scopes", "repl", "disassembly", "threads", "exceptions" }
        dv.setup({
          -- auto_toggle = true,
          -- switchbuf = 'usetab,useopen',
          windows = {
            size = 0.15,
            position = "below",
            terminal = {
              size = 0.50,
              position = "right",

            },
          },
          icons = {
            collapsed = " ",
          },
          winbar = {
            sections = sections,
            default_section = "scopes",
            base_sections = {
              watches     = { label = "Watches", keymap = "W" },
              scopes      = { label = "Scopes", keymap = "S" },
              breakpoints = { label = "Breakpoints", keymap = "B" },
              exceptions  = { label = "Exceptions", keymap = "E" },
              threads     = { label = "Threads", keymap = "T" },
              repl        = { label = "Repl", keymap = "R" },
            },
            show_keymap_hints = false,
            controls = {
              enabled = false,
            },
          },
        })

        local function find_target_ft_in_windows(target)
          for _, winid in ipairs(vim.api.nvim_list_wins()) do
            local bufnr = vim.api.nvim_win_get_buf(winid)
            if vim.bo[bufnr].filetype == target then
              return winid
            end
          end
        end

        local send_dapview_to_sidebar = vim.schedule_wrap(function()
          local winid =
            find_target_ft_in_windows("dap-view")
            or find_target_ft_in_windows("dap-repl")
            or find_target_ft_in_windows("dap-disassembly")
          if not (winid and vim.api.nvim_win_is_valid(winid)) then return end
          vim.api.nvim_win_call(winid, function()
            vim.cmd.wincmd("H")
          end)
          local width = math.floor(0.25 * vim.o.columns)
          vim.api.nvim_win_set_width(winid, width)
        end)

        local function dapview_open()
          dv.open()
          send_dapview_to_sidebar()
        end
        local function dapview_toggle()
          dv.toggle(true)
          send_dapview_to_sidebar()
        end

        local function dapview_focus_term()
          local winid = find_target_ft_in_windows("dap-view-term")
          if not winid then return end
          vim.api.nvim_set_current_win(winid)
          vim.cmd.startinsert()
        end

        local dap = require("dap")
        dap.listeners.before.attach["dap-view-config"] = function() dapview_open() end
        dap.listeners.before.launch["dap-view-config"] = function() dapview_open() end
        -- dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close(true) end
        -- dap.listeners.before.event_exited["dap-view-config"] = function() dv.close(true) end

        nmap("<C-`>", function() dapview_toggle() end, { desc = "Explorer" })
        nmap_leader("do", function() dapview_toggle() end, { desc = "open dap-view" })
        nmap_leader("df", function() dapview_focus_term() end, { desc = "focus dap-view-term" })
        nmap_leader("dk", function()
          dap.terminate()
          dap.clear_breakpoints()
          dv.close(true)
        end, { desc = "kill" })

        -- Config.on("BufEnter", function(ev)
        --   if vim.bo[ev.buf].filetype ~= "dap-view-term" then return end
        --   vim.cmd.startinsert()
        -- end)

        for i, section in ipairs(sections) do
          nmap("<C-"..i..">", function() dv.show_view(section) end, {
            desc = "dap-view: show " .. section,
          })
        end
        Config.on("FileType", function(args)
          nmap("q", "<C-w>q", { buffer = args.buf })
          vim.opt_local.fillchars:append({ eob = " " })
        end, { pattern = { "dap-view", "dap-view-term", "dap-repl", "dap-disassembly" }})
      end),
    },
  },

  {
    src = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
    data = {
      enabled = true,
      loader = Pack.load_on_loop(function(name)
        vim.cmd.packadd(name)
        require("dap-disasm").setup({
          dapview_register = true,
          dapview = {
            keymap = "D",
            label = function() return "[D]" end,
            short_label = "󰒓 [D]",
          },
          winbar = { enabled = false },
        })
      end),
    },
  },

})
