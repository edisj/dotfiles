pack.add({
  "https://github.com/antoinemadec/fixcursorhold.nvim",
  "https://github.com/rcasia/neotest-java",
  {
    src = "https://github.com/nvim-neotest/neotest",
    data = {
      enable = true,
      loader = function()
        require("neotest").setup({
          adapters = {
            require("neotest-java")({
              -- Optional configuration here
            }),
          },
        })
      end,
    },
  }
})
