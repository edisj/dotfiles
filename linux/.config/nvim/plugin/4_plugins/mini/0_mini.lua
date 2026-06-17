-- local header = {
--   "                   │ ╲ ││",
--   "                   ││╲╲││",
--   "                   ││ ╲ │",
--   "────────────────────────────────────────────",
-- }
-- "",
-- N_("Nvim is open source and freely distributable"),
-- "https://neovim.io/#chat",
-- "────────────────────────────────────────────",
-- N_("type  :help nvim<Enter>     if you are new! "),
-- N_("type  :checkhealth<Enter>   to optimize Nvim"),
-- N_("type  :q<Enter>             to exit         "),
-- local header_width = vim.fn.strdisplaywidth(header[1])

Pack.add({
  {
    src = "https://github.com/nvim-mini/mini.nvim",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("mini.ai").setup()
        require("mini.operators").setup()
        require("mini.splitjoin").setup()
        require("mini.align").setup()
        require("mini.extra").setup()
        require("mini.trailspace").setup()
        require("mini.icons").setup({
          default = {
            directory = { hl = "Folder" },
          },
          filetype = {
            c = { glyph = "" },
            java = { hl = "DiagnosticError" },
          },
        })
        require("mini.surround").setup({
          mappings = { add = "sp" },
          highlight_duration = 3000,
        })
        -- require("mini.starter").setup({
        --   header = function()
        --     local v = vim.version()
        --     local version_str = string.format(
        --       "NVIM v%d.%d.%d (%s)",
        --       v.major,
        --       v.minor,
        --       v.patch,
        --       v.prerelease and "Nightly" or "Stable"
        --     )
        --     return table.concat(header, "\n") .. "\n" .. version_str
        --   end,
        --   footer = function()
        --     local ms = math.floor((vim.uv.hrtime() - vim.g._start_time) / 1e6)
        --     return center_text(string.format("  Neovim started in %dms", ms))
        --   end
        --
        -- })

        local hipatterns = require("mini.hipatterns")
        hipatterns.setup({
          highlighters = {
            -- Highlight standalone "FIXME", "HACK", "TODO", "NOTE"
            fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
            important  = { pattern = "%f[%w]()IMPORTANT()%f[%W]",  group = "MiniHipatternsFixme"  },
            hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack"  },
            todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo"  },
            note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote"  },

            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = hipatterns.gen_highlighter.hex_color(),
          },
        })

        require("mini.cmdline").setup({
          autocomplete = { enable = false },
          autopeek = { enable = true, n_context = 5 },
          autocorrect = {
            enable = true,
            -- func = function(...)
            --   local result = MiniCmdline.default_autocorrect_func(...)
            --   if result then
            -- HACK: feed a backspace -> space so that blink.cmp completion window
            -- pops up, otherwise it can't recognize the autocorrected result
            -- local bs = vim.api.nvim_replace_termcodes("<BS>", true, false, true)
            -- local space = vim.api.nvim_replace_termcodes(" ", true, false, true)
            -- vim.api.nvim_feedkeys(bs .. space, "n", false)
            -- end
            -- return result
            -- end,
          },
        })

        require("mini.icons").mock_nvim_web_devicons()
      end,
    },
  }
})
