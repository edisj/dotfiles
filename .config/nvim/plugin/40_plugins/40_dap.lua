



Config.add({
  "https://codeberg.org/mfussenegger/nvim-jdtls",

  {
    src = "https://codeberg.org/mfussenegger/nvim-dap",
    data = {
      loader = function(name)
        vim.cmd.packadd(name)
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

        dap.adapters.codelldb = {
          type = "executable",
          command = "codelldb",
        }
        dap.configurations.c = {
          name = "launch",
          type = "lldb",
          request = "launch",
          program = function()
            return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
          end,
          cwd = "${workspaceFolder}",
          stopOnEntery = false,
          args = {},

        }
        dap.configurations.cpp = dap.configurations.c

        local nmap = function(...) Config.map("n", ...) end
        nmap("<leader>db", function() dap.toggle_breakpoint() end, { desc = "Dap: Toggle Breakpoint" })

        nmap("<M-Enter>", function() dap.continue() end,  { desc = "Debug continue" })
        nmap("<M-Left>",  function() dap.step_out() end,  { desc = "Debug step out" })
        nmap("<M-Right>", function() dap.step_into() end, { desc = "Debug step into" })
        nmap("<M-Up>",    function() dap.step_back() end, { desc = "Debug step back" })
        nmap("<M-Down>",  function() dap.step_over() end, { desc = "Debug step over" })
        nmap("<F2>",      function() dap.restart() end,   { desc = "Debug retstart" })
      end,
    },
  },

  {
    src = "https://github.com/igorlfs/nvim-dap-view",
    data = {
      loader = function(name)
        vim.cmd.packadd(name)
        require("dap-view").setup({
          winbar = {
            sections = { "watches", "scopes", "breakpoints"  },
            base_sections = {
              watches = { label = "Watches", keymap = "W" },
              scopes = { label = "Scopes", keymap = "S" },
              breakpoints = { label = "Breakpoints", keymap = "B" },
              exceptions = { label = "Exceptions", keymap = "E" },
              threads = { label = "Threads", keymap = "T" },
              repl = { label = "REPL", keymap = "R" },
              sessions = { label = "Sessions", keymap = "K" },
              console = { label = "Console", keymap = "C" },
            },
            show_keymap_hints = false,
            controls = {
              enabled = true,
              buttons = { "play" },
            },
          },
          icons = {
            collapsed = "  ",
            disabled = " ",
            disconnect = " ",
            enabled = " ",
            expanded = "  ",
            filter = " ",
            negate = "  ",
            pause = " ",
            play = " ",
            run_last = " ",
            step_back = " ",
            step_into = " ",
            step_out = " ",
            step_over = " ",
            terminate = " ",
          },
          -- switchbuf = "usetab,uselast",
          auto_toggle = false,
        })

        -- local dap = require("dap")
        -- local dv = require("dap-view")
        -- dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
        -- dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
        -- dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
        -- dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end

        vim.keymap.set("n", "<leader>dv", "<Cmd>DapViewToggle<CR>")
        local nmap = function(...) Config.map("n", ...) end
        nmap("<C-1>", "<Cmd>DapViewShow watches<CR>")
        nmap("<C-2>", "<Cmd>DapViewShow scopes<CR>")
        nmap("<C-3>", "<Cmd>DapViewShow breakpoints<CR>")
      end,
    },
  },

  {
    src = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("dap-disasm").setup({
          dapview_register = true,
          dapview = {
            keymap = "D",
            label = "Disassembly",
            short_label = "󰒓 [D]",
          },
        })
      end
    },
  },


})
