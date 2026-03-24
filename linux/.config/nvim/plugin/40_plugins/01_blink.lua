local keymap = {
  preset = "default",
  ["<C-e>"] = { "show", "hide", "fallback" },
  ["<C-j>"] = { "select_next", "fallback_to_mappings" },
  ["<C-k>"] = { "select_prev", "fallback_to_mappings" },
  ["<C-d>"] = { function(cmp) return cmp.select_next({ count = 5 }) end, "fallback" },
  ["<C-u>"] = { function(cmp) return cmp.select_prev({ count = 5 }) end, "fallback" },
  ["<C-h>"] = { "show_signature", "hide_signature", "fallback" },
  -- ["<C-q>"] = { "show_signature" },
  ["<M-j>"] = { function(cmp) cmp.scroll_documentation_down(1) end, "fallback" },
  ["<M-k>"] = { function(cmp) cmp.scroll_documentation_up(1) end, "fallback" },
}

local completion = {}
completion.list = { max_items = 100 }
completion.menu = {
  border = "none",
  winblend = 1,
  max_height = 15,
  auto_show = true,
  auto_show_delay_ms = 0,
  draw = {
    columns = { { "kind_icon" }, { "label", "label_description" }, { "label_description" }, { "source_name" }},
    components = {
      kind_icon = {},
      source_name = {},
      label = {},
    },
  },
}
completion.documentation = {
  auto_show = false,
  window = {
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
    winblend = 5,
  },
}

local signature = {
  enabled = true,
  window = { max_width = 200 },
}

local cmdline = {
  enabled = true,
  keymap = {
    preset = "inherit",
    ["<Up>"] = false,
    ["<Down>"] = false,
    ["<C-space>"] = { "show", "hide", "fallback" },
  },
  completion = { menu = { auto_show = true } },
  sources = function()
    local type = vim.fn.getcmdtype()
    if type == "/" or type == "?" then return { "buffer" } end
    if type == ":" or type == "@" then return { "cmdline", "buffer" } end
    return {}
  end,
}

local sources = {
  default = { "lazydev", "lsp", "path" },
  providers = {
    lazydev = {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    }
  },
}

local fuzzy = {
  implementation = "prefer_rust_with_warning",
  sorts = { "exact", "score", "sort_text" },
  -- prebuilt_binaries = { download = true },
}

local appearance = {
  nerd_font_variant = "mono",
  kind_icons = {
    Array         = '󰅪',
    Boolean       = "󰺟",
    Class         = '󱡠',
    Color         = '󰏘',
    Constant      = '󰏿',
    Constructor   = '',
    Enum          = '',
    EnumMember    = '',
    Event         = '',
    Field         = '󰜢',
    File          = '󰈙',
    Folder        = '󰉋',
    Function      = '󰊕',
    Interface     = '',
    Keyword       = '',
    Method        = '󰊕',
    Module        = "",
    Operator      = '󰆕',
    Property      = '󰜢',
    Reference     = '󰈇',
    Snippet       = '',
    Struct        = '󱡠',
    Text          = '󰉿',
    TypeParameter = '',
    Unit          = '',
    Value         = "󰎠",
    Variable      = '󰀫',
  }
}

Config.add({

  {
    src = "https://github.com/saghen/blink.cmp",
    data = {
      enabled = true,
      loader = Config.on_event({ "InsertEnter", "CmdlineEnter" }, function(name)
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

        vim.lsp.config("*", {
          capabilities = require("blink.cmp").get_lsp_capabilities()
        })
      end)
    }
  },

  {
    src = "https://github.com/saghen/blink.pairs",
    data = { enabled = false }
  },

  {
    src = "https://github.com/windwp/nvim-autopairs",
    data = {
      enabled = true,
      loader = Config.on_event("InsertEnter", function(name)
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
