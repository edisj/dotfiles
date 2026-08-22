local defer = function(module, opts)
  local loader = pack.gen_loop_loader(function()
    require(module).setup(opts or {})
  end)
  loader(module)
end

local show_peek = false
pack.add({
  {
    src = "https://github.com/nvim-mini/mini.nvim",
    data = {
      enable = true,
      loader = function()
          -- Create mappings for swapping adjacent arguments. Notes:
          -- - Relies on `a` argument textobject from 'mini.ai'.
          -- - It is not 100% reliable, but mostly works.
          -- - It overrides `:h (` and `:h )`.
          -- Explanation: `gx`-`ia`-`gx`-`ila` <=> exchange current and last argument
          -- Usage: when on `a` in `(aa, bb)` press `)` followed by `(`.
          -- vim.keymap.set('n', '(', 'gxiagxila', { remap = true, desc = 'Swap arg left' })
          -- vim.keymap.set('n', ')', 'gxiagxina', { remap = true, desc = 'Swap arg right' })
        defer("mini.operators")
        defer("mini.splitjoin")
        defer("mini.align")
        defer("mini.extra")
        defer("mini.trailspace")
        defer("mini.notify")
        defer("mini.jump", { delay = { highlight = 100 } })
        defer("mini.icons", {
          default = {
            directory = { hl = "Folder" },
          },
          filetype = {
            c = { glyph = "" },
            java = { hl = "DiagnosticError" },
          },
        })
        defer("mini.surround", {
          mappings = { add = "sp" },
          highlight_duration = 2000,
        })

        local gen_ai_spec = require("mini.extra").gen_ai_spec
        local gen_ts_spec = require("mini.ai").gen_spec.treesitter
        defer("mini.ai", {
          n_lines = 200,
          mappings = {
            around = "o",
            inside = "i",
            around_next = "on",
            inside_next = "in",
            around_last = "ol",
            inside_last = "il",
          },
          custom_textobjects = {
            f = gen_ts_spec({ a = "@function.outer", i = "@function.inner" }),
            F = gen_ts_spec({ a = "@call.outer", i = "@call.inner" }),
            c = gen_ts_spec({ a = "@class.outer", i = "@class.inner" }),
            g = gen_ai_spec.buffer(),
            D = gen_ai_spec.diagnostic(),
            i = gen_ai_spec.indent(),
            L = gen_ai_spec.line(),
            u = gen_ai_spec.number(),
          },
        })

        vim.api.nvim_set_hl(0, "Folder", { fg = "#caaa67" })

        defer("mini.hipatterns", {
          highlighters = {
            -- Highlight standalone "FIXME", "HACK", "TODO", "NOTE"
            fixme = { pattern = "%f[%w]()FIXME()%f[%W]", group = "MiniHipatternsFixme" },
            important  = { pattern = "%f[%w]()IMPORTANT()%f[%W]",  group = "MiniHipatternsFixme"  },
            hack  = { pattern = "%f[%w]()HACK()%f[%W]",  group = "MiniHipatternsHack"  },
            todo  = { pattern = "%f[%w]()TODO()%f[%W]",  group = "MiniHipatternsTodo"  },
            note  = { pattern = "%f[%w]()NOTE()%f[%W]",  group = "MiniHipatternsNote"  },
            -- Highlight hex color strings (`#rrggbb`) using that color
            hex_color = require("mini.hipatterns").gen_highlighter.hex_color(),
          },
        })

        if vim.g.cmp == "mini.cmdline" then
          local process_items = function(items, base)
            return MiniCompletion.default_process_items(items, base, {
              kind_priority = { Text = -1, Snippet = 99 }
            })
          end
          require("mini.completion").setup({
            lsp_completion = {
              source_func = "omnifunc",
              auto_setup = false,
              process_items = process_items,
            },
          })
          local on_attach = function(ev)
            vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
          end
          on("LspAttach", nil, on_attach)
          vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
        end

        require("mini.cmdline").setup({
          autocorrect = { enable = vim.g.cmp == "mini.cmdline" },
          autocomplete = {
            enable = vim.g.cmp == "mini.cmdline",
            predicate = function() return vim.fn.getcmdtype() == ":" end,
          },
          autopeek = {
            enable = true,
            n_context = 5,
            predicate = function() return show_peek end,
            window = {
              config = function()
                return { relative = package.loaded["msgarea"] and "msgarea" or nil }
              end,
            },
          },
        })

        vim.keymap.set("c", "<C-Tab>", function() show_peek = not show_peek end)
        on("CmdlineLeave", nil, function() show_peek = false end)
      end,
    },
  }
})
