local api = vim.api

local sev = vim.diagnostic.severity
local icons = require("icons")

local sign_text = {
  [sev.ERROR] = icons.diagnostic2.error,
  [sev.WARN] = icons.diagnostic2.warn,
  [sev.INFO] = icons.diagnostic2.info,
  [sev.HINT] = icons.diagnostic2.hint,
}

vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  signs = {
    -- severity = { min = sev.WARN },
    text = sign_text,
  },
  float = {
    source = false,
    -- prefix = "",
    -- header = "",
    -- suffix = "",
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
  },
})

map("<Leader>td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
  vim.api.nvim__redraw({ flush = true, statuscolumn = true })
end, { desc = "toggle diagnostics" })

map("<C-q><C-d>", function()
  vim.diagnostic.setqflist()
end)

local jump = function(sign)
  return function()
    vim.diagnostic.jump {
      count = sign * vim.v.count1,
      on_jump = function(diag)
        if not diag then return end
        vim.diagnostic.config({ virtual_lines = { current_line = true }, virtual_text = false })
        on("CursorMoved", nil, { once = true }, function()
          vim.diagnostic.config({ virtual_lines = false, virtual_text = false })
        end)
      end,
    }
  end
end
map("<C-.>", jump(1))
map("<C-,>", jump(-1))
