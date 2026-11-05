pack.add({
  {
    src = "https://codeberg.org/vi6jm/scry.nvim",
    data = {
      enable = false,
      loader = function()
        local ns = vim.api.nvim_create_namespace("config.scry")
        require("scry").setup({
          ["reveal-cursor"] = false,
          filetypes = { "markdown" },
          -- filetypes = { "markdown", help },
          -- renderers = {
          --   vimdoc = {
          --     h1 = function(bufnr, node)
          --       local row = node:range()
          --       local rule = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, true)[1]
          --       vim.api.nvim_buf_set_extmark(bufnr, ns, row, 0, { conceal_lines = "" })
          --       vim.api.nvim_buf_set_extmark(bufnr, ns, row + 1, 0, {
          --         end_row = row + 2,
          --         hl_group = "ScryHeading1",
          --         hl_eol = true,
          --         virt_lines = { { { ("▔"):rep(#rule), "ScryHr" } } },
          --         -- virt_lines = { { { ("‾"):rep(#rule), "ScryHr" } } },
          --         virt_lines_above = false,
          --       })
          --     end,
          --   }
          -- },
        })
      end
    }
  },
  {
    src = "https://github.com/meanderingprogrammer/render-markdown.nvim",
    data = {
      enable = false,
      loader = function()
        vim.treesitter.language.register("markdown", "nvim-pack")
        require("render-markdown").setup({
          render_modes = { "n", "c", "t", "v", "V", "\22" },
          anti_conceal = { disabled_modes = { "n", "v", "V", "\22" } },
          heading = {
            -- backgrounds = { "Normal" },  -- indexed per level with clamp; one entry covers all
            sign = false,
            icons = { "" },
            border = { true, true, false },
            border_virtual = true,
            -- above = "▁",
            above = "",
            below = "─",
            width = "full",
          },
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
