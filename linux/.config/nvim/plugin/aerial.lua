pack.add({
  {
    src = "https://github.com/stevearc/aerial.nvim",
    data = {
      enable = true,
      defer = true,
      loader = function()
        require("aerial").setup()
      end
    }
  }
})
