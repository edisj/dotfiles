-- blink config ===============================================================
local keymap = {
  preset = "default",
  ["<C-e>"] = { "show", "hide", "fallback" },
  ["<C-n>"] = {
    function(cmp)
      cmp.show()
      cmp.select_next()
      return true
    end,
    "fallback_to_mappings"
  },
  ["<C-p>"] = {
    function(cmp)
      cmp.show()
      cmp.select_prev()
      return true
    end,
    "fallback_to_mappings"
  },
  ["<Tab>"] = { "snippet_forward", "accept", "fallback" },
  ["<S-Tab>"] = { "snippet_backward", "fallback" },
  ["<C-j>"] = { function(cmp) return cmp.select_next({ count = 5 }) end, "fallback" },
  ["<C-k>"] = { function(cmp) return cmp.select_prev({ count = 5 }) end, "fallback" },
  ["<C-h>"] = { "show_signature", "hide_signature", "fallback" },
  ["<M-j>"] = {
    function(cmp)
      if cmp.is_visible() then
        cmp.scroll_documentation_down(2)
        return true
      end
    end,
    "fallback",
  },
  ["<M-k>"] = {
    function(cmp)
      if cmp.is_visible() then
        cmp.scroll_documentation_up(2)
        return true
      end
    end,
    "fallback",
  },
}

local _max_height = 10
local _auto_show = true
local completion = {} ---@type blink.cmp.CompletionConfigPartial
completion.list = { max_items = 250 }
completion.menu = {
  auto_show = function(_) return _auto_show end,
  border = "none",
  max_height = _max_height,
  auto_show_delay_ms = 0,
  direction_priority = { "s", "n" },
  draw = {
    columns = { { "kind_icon" }, { "label", "label_description" }, { "source_name" } },
    ---@type blink.cmp.DrawComponent[]
    components = {
      label = {
        -- width = { max = 30 },
        width = { max = function(_) return math.floor(0.25*vim.o.columns) end },
      },
      label_description = {
        width = { fill = true, max = math.huge },
        -- width = { max = function(_) return math.floor(0.4*vim.o.columns) end },
      },
    },
  },
}
completion.documentation = {
  auto_show = false,
  window = {
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
    winblend = 5,
    -- max_width = 100,
  },
}

---@type blink.cmp.SignatureConfigPartial
local signature = {
  enabled = true,
  window = {
    -- border = "none",
    border = { "", "", "", " ", "", "", "", " " },
    max_width = 100,
  },
}


local cmd_auto_show = false

---@type blink.cmp.CmdlineConfig
local cmdline = {
  enabled = true,
  keymap = {
    preset = "inherit",
    ["<Tab>"] = {
      function(cmp)
        if not cmp.is_visible() then
          cmd_auto_show = true
          cmp.show_and_insert()
        end
        cmp.accept()
      end,},
    ["<C-space>"] = { "show", "hide", "fallback" },
  },
  completion = {
    -- trigger = { show_on_blocked_trigger_characters = { "/" }, },
    menu = {
      auto_show = function() return cmd_auto_show end,
      -- auto_show = function(_) return vim.fn.getcmdtype() == ':' end,
      draw = { columns = { { "label" }, { "label_description" } }, },
    }
  },
  sources = function()
    local type = vim.fn.getcmdtype()
    if type == "/" or type == "?" then return { "buffer" } end
    if type == ":" or type == "@" then return { "cmdline" } end
    return { "lsp" }
  end,
}

---@type blink.cmp.SourceConfigPartial
local sources = {
  default = { "lazydev", "lsp", "buffer", "path" },
  providers = {
    lazydev = {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    },
  },
}

local fuzzy = {
  implementation = "prefer_rust_with_warning",
  sorts = { "exact", "score", "sort_text" },
  -- prebuilt_binaries = { download = true },
}

local appearance = {
  nerd_font_variant = "mono",
  kind_icons = require("ui.icons").lsp_kinds,
}

Pack.add({
  {
    src = "https://github.com/saghen/blink.lib",
    data = { enabled = true },
  },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("^1"),
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("blink.cmp").setup({
          keymap = keymap,
          completion = completion,
          signature = signature,
          cmdline = cmdline,
          sources = sources,
          fuzzy = fuzzy,
          appearance = appearance,
        })

        Config.on("CmdlineLeave", function() cmd_auto_show = false end)

        vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

        Config.nmap_leader("tp", function()
          _auto_show = not _auto_show
          vim.notify("blink.cmp auto_show: " .. tostring(_auto_show))
        end, { desc = "blink auto_show" })
      end
    }
  },
  {
    src = "https://github.com/saghen/blink.pairs",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("blink.pairs").build():pwait(60000)
        require("blink.pairs").setup({
          highlights = {
            enabled = true,
            cmdline = true,
            groups = { "BlinkPairs" },
            unmatched_group = "BlinkPairsUnmatched",
            matchparen = {
              enabled = true,
            },
          }
        })
      end,
    }
  },
  {
    src = "https://github.com/windwp/nvim-autopairs",
    data = {
      enabled = false,
      loader = Pack.load_on_event("InsertEnter", function(name)
        vim.cmd.packadd(name)
        local autopairs = require("nvim-autopairs")

        autopairs.setup({
          disable_filetype = { "helpout_search" },
          map_cr = true,
          map_bs = true,
          -- map_c_w = true,
          check_ts = true,
          -- ts_config = { lua = { 'string' } },
          fast_wrap = {
            map = '<C-e>',
            chars = { '{', '[', '(', '"', "'" },
            pattern = [=[[%'%"%>%]%)%}%,]]=],
            end_key = '$',
            before_key = 'h',
            after_key = 'l',
            cursor_pos_before = true,
            keys = 'qwertyuiopzxcvbnmasdfghjkl',
            manual_position = true,
            highlight = 'Search',
            highlight_grey='Comment'
          }
        })

        autopairs.remove_rule("`")
        autopairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))

      end)
    },
  },
})
