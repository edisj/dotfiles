pack.add({
  { src = "https://github.com/jbyuki/one-small-step-for-vimkind", data = { enable = true } },
  {
    src = "https://codeberg.org/mfussenegger/nvim-jdtls",
    data = {
      enable = true ,
    }
  },
  {
    src = "https://codeberg.org/mfussenegger/nvim-dap",
    data = {
      enable = true,
      defer = false,
      loader = function()
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
        dap.defaults.fallback.switchbuf = "usevisible,uselast,newtab"

        local dapmap = function(lhs, dap_fn)
          local opts = { desc = ("dap: " .. dap_fn):gsub("_", " ") }
          _G.map(lhs, function() dap[dap_fn]() end, opts)
        end
        dapmap("<M-CR>",    "continue")
        dapmap("<M-Left>",  "step_out")
        dapmap("<M-Right>", "step_into")
        dapmap("<M-Up>",    "step_back")
        dapmap("<M-Down>",  "step_over")
        dapmap("<M-.>",     "toggle_breakpoint")
        dapmap("<Leader>dr", "restart")
        dapmap("<Leader>dt", "terminate")
        dapmap("<Leader>db", "list_breakpoints")
        dapmap("<Leader>dc", "clear_breakpoints")
        -- dapmap("<Leader>dp", "repl.open() end,         { desc = "repl" })
        dapmap("<Leader>d.", "run_to_cursor")

        -- map("<Leader>d?", function()
        --   vim.ui.input({
        --     prompt = "Condition: ",
        --   })
        -- end, { desc = "conditional" })
        --
        -- map("<Leader>dl", function()
        --   vim.ui.input({
        --     prompt = "Log: ",
        --   })
        -- end, { desc = "log point" })

        local icons = require("icons")
        vim.fn.sign_define("DapBreakpoint", {
          text = icons.dap.breakpoint or "B ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapBreakPointRejected", {
          text = icons.dap.rejected or "R ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapBreakpointCondition", {
          text = icons.dap.conditional or "C ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapLogPoint", {
          text = icons.dap.logpoint or "L ",
          texthl = "DapBreakpoint",
        })
        vim.fn.sign_define("DapStopped", {
          text = icons.dap.pc or "→ ",
          texthl = "DapStopped",
          linehl = "DapStoppedLine",
          -- numhl = "DapStoppedLine",
        })

        dap.listeners.after.event_breakpoint["my_dap"] = function()
          vim.o.signcolumn="auto:1"
        end

        local refresh_statusline = function(_, _) vim.cmd("redrawstatus") end
        dap.listeners.after.event_initialized["statusline"] = refresh_statusline
        dap.listeners.after.event_terminated["statusline"] = refresh_statusline
        dap.listeners.after.event_stopped["statusline"] = refresh_statusline
        dap.listeners.after.event_continued["statusline"] = refresh_statusline

      end
    },
  },
  -- {
  --   src = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
  --   data = {
  --     enable = true,
  --     defer = true,
  --     loader = function()
  --       require("dap-disasm").setup({
  --         dapview_register = true,
  --         dapview = {
  --           keymap = "D",
  --           label = function() return "[D]" end,
  --           short_label = "󰒓 [D]",
  --         },
  --         winbar = { enabled = false },
  --       })
  --     end,
  --   },
  -- },
})
