local defer = function(module, opts_or_fn)
  local loader
  if type(opts_or_fn) == "function" then
    loader = pack.gen_loop_loader(opts_or_fn)
  else
    loader = pack.gen_loop_loader(function()
      require(module).setup(opts_or_fn or {})
    end)
  end
  loader(module)
end

local show_peek = false
pack.add({
  {
    src = "https://github.com/nvim-mini/mini.nvim",
    data = {
      enable = true,
      loader = function()
        require("mini.icons").setup {
          default = {
            directory = { hl = "Folder" },
          },
          filetype = {
            c = { glyph = "" },
            java = { hl = "DiagnosticError" },
            directory = { glyph = "", hl = "Folder" },
            terminal = { hl = "Number" },
            ["dap-view"] = { glyph = require("icons").misc.bug, hl = "MiniIconsRed" },
            ["dap-view-term"] = { glyph = "", hl = "MiniIconsRed" },
          },
          extension = {
            class = { hl = "MiniIconsBlue" },
            jar = { glyph = "󰬷", hl = "MiniIconsAzure" },
            so = { glyph = "", hl = "MiniIconsGreen" },
            db = { glyph = "" },
          },
        }

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
        defer("mini.notify", {
          content = {
            format = function(notif)
              return notif.msg
            end,
          },
          lsp_progress = { enable = false },
          window = { config = function() return { title = nil, width = math.floor(0.3 * vim.o.columns) }end }
        })
        defer("mini.jump", { delay = { highlight = 100 } })
        defer("mini.surround", {
          mappings = { add = "sp" },
          highlight_duration = 2000,
        })

        defer("mini.ai", function()
          local gen_ai_spec = require("mini.extra").gen_ai_spec
          local gen_ts_spec = require("mini.ai").gen_spec.treesitter
          require("mini.ai").setup({
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
        end)

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
          vim.g.minicompletion_disable = true

          map("<Tab>", function()
            local curline = vim.api.nvim_get_current_line()
            local cursor = vim.api.nvim_win_get_cursor(0)
            if
              vim.trim(curline) == ""
              or vim.trim(curline:sub(0, cursor[2])) == ""
            then
              return "<Tab>"
            end
            vim.g.minicompletion_disable = false
            MiniCompletion.complete_twostage(true, true)
          end, { expr = true, mode = {"i"} })

          map("<C-s>", vim.lsp.buf.signature_help, { mode = {"i"} })
          vim.keymap.set('n', '<C-b>', '<Plug>(nvim.lsp.ctrl-s)')


          local function enable(kind)
            return function()
              local c = vim.b.minicompletion_config or {}
              c.delay = vim.tbl_extend('force', c.delay or {}, { [kind] = 10 })
              vim.b.minicompletion_config = c
              vim.api.nvim_feedkeys(vim.keycode('<C-n><C-p>'), 'n', false)
              vim.api.nvim_create_autocmd('InsertLeave', {
                buffer = 0, once = true,
                callback = function() vim.b.minicompletion_config = nil end,
              })
            end
          end

          vim.keymap.set("i", "<C-space>", enable("info"))
          vim.keymap.set("i", "<C-k>", enable("signature"))

          require("mini.completion").setup({
            delay = { completion = 100, info = 9999, signature = 9999 },
            window = {
              signature = { border = { "", "", "", " ", "", "", "", " " } },
            },
            mappings = {
              -- Force two-step/fallback completions
              force_twostep = "<C-n>",
              force_fallback = "<A-Space>",
              -- Scroll info/signature window down/up. When overriding, check for
              -- conflicts with built-in keys for popup menu (like `<C-u>`/`<C-o>`
              -- for 'completefunc'/'omnifunc' source function; or `<C-n>`/`<C-p>`).
              scroll_down = "<M-j>",
              scroll_up = "<M-k>",
            },
            lsp_completion = {
              source_func = "omnifunc",
              auto_setup = false,
              process_items = function(items, base)
                return MiniCompletion.default_process_items(items, base, {
                  kind_priority = { Text = -1, Snippet = 99 } })
              end,
            },
          })

          local on_attach = function(ev)
            vim.bo[ev.buf].omnifunc = "v:lua.MiniCompletion.completefunc_lsp"
          end
          on("LspAttach", nil, on_attach)
          vim.lsp.config("*", { capabilities = MiniCompletion.get_lsp_capabilities() })
        end

        local auto_show = false
        require("mini.cmdline").setup({
          autocorrect = { enable = vim.g.cmp == "mini.cmdline" },
          autocomplete = {
            enable = vim.g.cmp == "mini.cmdline",
            predicate = function()
              return auto_show and vim.fn.getcmdtype() == ":"
            end,
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

        vim.o.wildcharm = "<C-z>"
        map("<Tab>", function()
          auto_show = true
          return "<C-z>"
        end, { silent = false, expr = true, mode = 'c' })

        vim.keymap.set("c", "<C-Tab>", function() show_peek = not show_peek end, { silent = false})
        -- vim.keymap.set("c", "<C-Tab>", function() show_peek = not show_peek end)
        on("CmdlineLeave", nil, function() show_peek = false; auto_show=false end)
        -- on("InsertLeave", nil, function() vim.g.minicompletion_disable=true end)
      end,
    },
  }
})
