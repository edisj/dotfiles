pack.add({
  {
    src = "https://github.com/meanderingprogrammer/render-markdown.nvim",
    data = {
      enable = true,
      loader = function()
        vim.treesitter.language.register("markdown", "nvim-pack")
        require("render-markdown").setup({
          heading = {
            backgrounds = { "Normal" },  -- indexed per level with clamp; one entry covers all
          },
          anti_conceal = { disabled_modes = { "n" } },
          file_types = { "markdown", "nvim-pack" },
          code = {
            position  ="right",
            left_pad = 2,
            right_pad = 2,
            width = "block",
            style = "normal",
            border = "thick",
          },
        })
      end,
    },
  },
})
