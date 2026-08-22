pack.add_local({
  {
    src = "~/dev/win.nvim",
    data = { enable = true, loader = function() _G.Win = require("win") end },
  }
})
