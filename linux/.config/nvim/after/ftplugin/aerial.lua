vim.api.nvim_set_option_value("winhl", "Normal:NormalSplit,NormalNC:NormalSplit,WinSeparator:AerialWinSeparator", { scope = "local" })
vim.api.nvim_set_option_value("winfixbuf", true, { scope = "local" })

vim.b.stl = {
  {
    chunks = {
      { "󱘎 ", "Function" }, { "Aerial", "Normal" }
    },
    padding = 1,
  },
}
