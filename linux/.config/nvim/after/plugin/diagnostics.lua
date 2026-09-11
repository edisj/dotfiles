local api, diag = vim.api, vim.diagnostic

local sev = diag.severity
local icons = require("icons")

local sign_text = {
  [sev.ERROR] = icons.diagnostic2.error,
  [sev.WARN] = icons.diagnostic2.warn,
  [sev.INFO] = icons.diagnostic2.info,
  [sev.HINT] = icons.diagnostic2.hint,
}

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
})

-- map("<Leader>td", function()
--   diag.enable(not diag.is_enabled())
--   vim.api.nvim__redraw({ flush = true, statuscolumn = true })
-- end, { desc = "toggle diagnostics" })

map("<C-q><C-d>", function()
  diag.setqflist()
end)

local jumping = false
local reset_virt = vim.schedule_wrap(function()
  if not jumping then
    diag.config({ virtual_lines = false })
  end
  jumping = false
end)
local jump = function(sign)
  return function()
    jumping = true
    diag.jump {
      count = sign * vim.v.count1,
      on_jump = function(d)
        if not d then return end
        diag.config({ virtual_lines = { current_line = true } })
        vim.schedule(function() on("CursorMoved", nil, { once = true }, reset_virt) end)
      end,
    }
  end
end
map("<C-.>", jump(1))
map("<C-,>", jump(-1))
