local severity = vim.diagnostic.severity
vim.diagnostic.config({
  severity_sort = true,
  update_in_insert = false,
  virtual_text = false,
  -- virtual_text = { severity = { min = severity.ERROR } },
  signs = {
    severity = { min = severity.WARN },
    numhl = {
      [severity.ERROR] = "DiagnosticSignColError",
      [severity.WARN] = "DiagnosticSignColWarn",
    }
  },
  float = {
    source = false,
    -- prefix = "",
    header = "",
    suffix = "",
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
  },
})
