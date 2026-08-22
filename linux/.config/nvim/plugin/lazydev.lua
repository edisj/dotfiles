pack.add({
  {
    src = "https://github.com/folke/lazydev.nvim",
    data = {
      enable = true,
      loader = function()
        pack.add({ "https://github.com/Bilal2453/luvit-meta" })
        require("lazydev").setup({
          library = {
            "nvim-dap-ui",
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
          },
        })
      end
    },
  }
})
