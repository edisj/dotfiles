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
          cmp.show()
        else
          cmp.accept()
        end
      end,},
    ["<C-space>"] = { "show", "hide", "fallback" },
    ["<CR>"] = { "accept_and_enter", "fallback" }
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
  kind_icons = require("icons").lsp_kinds,
}

on("PackChanged", "config.blink.rebuild", function(ev)
  local name = ev.data.spec.name
  local kind = ev.data.kind
  if name == "blink.cmp" and (kind == "update" or kind == "install") then
    vim.notify('Building blink.cmp', vim.log.levels.INFO)
    local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = ev.data.path }):wait()
    if obj.code == 0 then
      vim.notify('Building blink.cmp done', vim.log.levels.INFO)
    else
      vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
    end
  end
end)

pack.add({
  {
    src = "https://github.com/saghen/blink.lib",
    data = { enable = true },
  },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("^1"),
    data = {
      enable = vim.g.cmp == "blink.cmp",
      loader = function()
        require("blink.cmp").setup({
          keymap = keymap,
          completion = completion,
          signature = signature,
          cmdline = cmdline,
          sources = sources,
          fuzzy = fuzzy,
          appearance = appearance,
        })

        on("CmdlineLeave", nil, function() cmd_auto_show = false end)

        vim.lsp.config("*", { capabilities = require("blink.cmp").get_lsp_capabilities() })

        map("<Leader>tp", function()
          _auto_show = not _auto_show
          vim.notify("blink.cmp auto_show: " .. tostring(_auto_show))
        end, { desc = "blink auto_show" })
      end
    }
  },
  {
    src = "https://github.com/saghen/blink.pairs",
    data = {
      enable = true,
      event = "InsertEnter",
      loader = function()
        require("blink.pairs").build():pwait(60000)
        require("blink.pairs").setup({
          mappings = {
            cmdline = false,
            wrap = {
              ["<C-l>"] = "motion",
              ["<C-h>"] = "motion_reverse",
            },
            pairs = {
              blink_pairs_wrap
            },
          },
          highlights = {
            enabled = true,
            cmdline = true,
            groups = { "BlinkPairs" },
            unmatched_group = "BlinkPairsUnmatched",
            matchparen = {
              include_surrounding = true,
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
      enable = false,
      event = "InsertEnter",
      loader = function()
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

      end
    },
  },
})
