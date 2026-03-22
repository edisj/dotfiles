local severity = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = false,
  -- virtual_text = { severity = { min = severity.ERROR } },
  signs = {
    severity = { min = severity.WARN },
    numhl = {
      [severity.ERROR] = "DiagnosticSignError",
      [severity.WARN] = "DiagnosticSignWarn",
    }
  },
  float = {
    source = false,
    prefix = "",
    header = "",
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
  },
})

local nmap = function(...) Config.map("n", ...) end

nmap("<leader>vd", function()
  if vim.diagnostic.is_enabled() then
    return vim.diagnostic.enable(false)
  end
  return vim.diagnostic.enable(true)
end, { desc = "vim diagnostic toggle" })

local diag_float_winid
nmap("<C-M-j>", function()
  vim.diagnostic.jump({
    count = vim.v.count == 0 and 1 or vim.v.count,
    on_jump = function()
      if diag_float_winid and vim.api.nvim_win_is_valid(diag_float_winid) then vim.api.nvim_win_close(diag_float_winid, true) end
      _, diag_float_winid = vim.diagnostic.open_float()
    end,
  })
end)
nmap("<C-M-k>", function()
  vim.diagnostic.jump({
    count = vim.v.count == 0 and -1 or -vim.v.count,
    on_jump = function()
      if diag_float_winid and vim.api.nvim_win_is_valid(diag_float_winid) then vim.api.nvim_win_close(diag_float_winid, true) end
      _, diag_float_winid = vim.diagnostic.open_float()
    end,
  })
end)

