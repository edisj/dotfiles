local ok, dap = pcall(require, "dap")
if not ok then return end

local disasm_spec = {
  src = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
  data = {
    enable = true,
    -- defer = true,
    loader = function()
      require("dap-disasm").setup({
        dapview_register = true,
        dapview = {
          keymap = "D",
          label = function() return "[D]" end,
          short_label = "󰒓 [D]",
        },
        winbar = { enabled = false },
      })
    end,
  },
}

local layout = function()
  return {
    {
      position = "left",
      size = 0.25,
      elements = {
        { id = "scopes", size = 0.80 }, { id = "watches", size = 0.20 }
      }
    },
    {
      position = "bottom",
      size = 0.22,
      elements = { { id = "console", size = 1.0 } }
    }
  }
end

pack.add({
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  { src = "https://github.com/theHamsta/nvim-dap-virtual-text" },
  {
    src = "https://github.com/rcarriga/nvim-dap-ui",
    data = {
      enable = true,
      defer = true,
      loader = function()
        local dapui = require("dapui")
        ---@diagnostic disable-next-line: missing-fields
        dapui.setup({
          ---@diagnostic disable-next-line: missing-fields
          -- controls = { enabled = false },
          layouts = layout(),
        })

        local dapbp = require("dap.breakpoints")
        dap.listeners.after.event_initialized["dapui_config"] = function()
          local args = next(dapbp.get()) and {} or { layout = 2 }
          dapui.open(args)
        end
        -- dap.listeners.before.event_terminated["dapui_config"] = function()
        --   dapui.close({})
        -- end
        -- dap.listeners.before.event_exited["dapui_config"] = function()
        --   dapui.close({})
        -- end

        on({"FileType"}, nil, { pattern = "dapui_*" }, function(ev)
          vim.opt.fillchars:append({ eob = " " })
          vim.wo[0][0].statuscolumn = ""
        end)

        on("BufWinEnter", nil, function(ev)
          local ft = vim.bo[ev.buf].filetype
          if ft ~= "dapui_console" then return end
          vim.schedule(function()
            local winid = vim.fn.bufwinid(ev.buf)
            if winid ~= -1 then
              local pos = { vim.api.nvim_buf_line_count(ev.buf), 0 }
              vim.api.nvim_win_set_cursor(winid, pos)
            end
          end)
        end)
      end,
    }
  },
})
