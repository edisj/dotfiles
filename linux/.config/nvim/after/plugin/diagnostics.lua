local api, diag = vim.api, vim.diagnostic

local sev = diag.severity
local icons = require("icons")

local sign_text = {
  [sev.ERROR] = icons.diagnostic2.error,
  [sev.WARN] = icons.diagnostic2.warn,
  [sev.INFO] = icons.diagnostic2.info,
  [sev.HINT] = icons.diagnostic2.hint,
}

vim.schedule(function()
  diag.config({
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
    virtual_text = {
      current_line = true,
      prefix = function(d, i, total)
        return i < total and d.message .. " · " or ""
      end,
    },
    virtual_lines = false,
  })
end)

map("<C-q><C-d>", function()
  diag.setqflist()
end)

local jump = function(sign)
  return function()
    diag.jump { count = sign * vim.v.count1 }
  end
end
map("<C-.>", jump(1))
map("<C-,>", jump(-1))
