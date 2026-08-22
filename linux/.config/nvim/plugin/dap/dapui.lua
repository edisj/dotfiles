local ok, dap = pcall(require, "dap")
if not ok then return end

pack.add({
  {
    src = "https://github.com/igorlfs/nvim-dap-view",
    data = {
      enable = true,
      defer = true,
      loader = function()
        local dv = require("dap-view")
        local sections = { "breakpoints", "watches", "scopes", "repl", "disassembly", "threads", "exceptions" }
        dv.setup({
          -- auto_toggle = true,
          -- switchbuf = 'usetab,useopen',
          windows = {
            size = 0.40,
            position = "left",
            terminal = {
              size = 0.50,
              position = "below",
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

        dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
        dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
        -- dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close(true) end
        -- dap.listeners.before.event_exited["dap-view-config"] = function() dv.close(true) end

        -- map("<C-`>", function() dapview_toggle() end, { desc = "Explorer" })
        map("<Leader>do", function() dv.toggle() end, { desc = "open dap-view" })
        -- map("<Leader>df", function() dapview_focus_term() end, { desc = "focus dap-view-term" })
        map("<Leader>dk", function()
          dap.terminate()
          dap.clear_breakpoints()
          dv.close(true)
        end, { desc = "kill" })

        for i, section in ipairs(sections) do
          map("<C-"..i..">", function() dv.show_view(section) end, {
            desc = "dap-view: show " .. section,
          })
        end
        on("FileType", nil, { pattern = { "dap-view", "dap-view-term", "dap-repl", "dap-disassembly" } }, function(args)
          map("q", "<C-w>q", { buf = args.buf })
          vim.opt_local.fillchars:append({ eob = " " })
        end)
      end,
    },
  },
  { src = "https://github.com/rcarriga/nvim-dap-ui" },
})
