local tiny_devicons_spec = {
  src = "https://github.com/rachartier/tiny-devicons-auto-colors.nvim",
  data = {
    enable = true,
    defer = true,
    loader = function()
      require('tiny-devicons-auto-colors').setup({
        colors = require("colorscheme.palettes").get(vim.g.colors_name)
      })
    end,
  },
}

pack.add({
  {
    src = "https://github.com/nvim-tree/nvim-web-devicons",
    data = {
      enable = true,
      loader = function()
        require("nvim-web-devicons").setup({
          default = true,
        })
        pack.add({ tiny_devicons_spec })
      end,
    }
  },
  {
    src = "https://github.com/Mirsmog/real-icons.nvim",
    data = {
      enable = false,
      defer = true,
      loader = function()
        require("real-icons").setup({
          pack = "material",
          size = {
            cols = 2,
            rows = 1,
            pixels = 64,
            padding = 0,
            trim = true,
          },
          integrations = {
            mini_files = true,
            nvim_tree = true,
          }
        }) end,
    }
  }
})
