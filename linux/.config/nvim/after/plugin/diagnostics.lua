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
  virtual_text = false,
  -- virtual_text = { severity = { min = severity.ERROR } },
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
end, { desc = "toggle diagnostics" })

map("<C-q><C-d>", function()
  vim.diagnostic.setqflist()
end)

local diag_float_winid
map("<C-.>", function()
  vim.diagnostic.jump({
    count = vim.v.count1,
    on_jump = function()
      if diag_float_winid and api.nvim_win_is_valid(diag_float_winid) then
        api.nvim_win_close(diag_float_winid, true)
      end
      _, diag_float_winid = vim.diagnostic.open_float()
    end,
  })
end)
map("<C-,>", function()
  vim.diagnostic.jump({
    count = -vim.v.count1,
    on_jump = function()
      if diag_float_winid and api.nvim_win_is_valid(diag_float_winid) then
        api.nvim_win_close(diag_float_winid, true)
      end
      _, diag_float_winid = vim.diagnostic.open_float()
    end,
  })
end)
