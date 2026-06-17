-- blink config ===============================================================
local keymap = {
  preset = "default",
  ["<C-e>"] = { "show", "hide", "fallback" },
  -- ["<C-j>"] = { "select_next" },
  -- ["<C-k>"] = { "select_prev" },
  ["<C-j>"] = {
    function(cmp)
      cmp.show()
      cmp.select_next()
      return true
    end,
    "fallback_to_mappings"
  },
  ["<C-k>"] = {
    function(cmp)
      cmp.show()
      cmp.select_prev()
      return true
    end,
    "fallback_to_mappings"
  },
  ["<Tab>"] = { "snippet_forward", "accept", "fallback" },
  ["<S-Tab>"] = { "snippet_backward", "fallback" },
  ["<C-d>"] = { function(cmp) return cmp.select_next({ count = 5 }) end, "fallback" },
  ["<C-u>"] = { function(cmp) return cmp.select_prev({ count = 5 }) end, "fallback" },
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
local _winhl = table.concat({
  "Normal:BlinkCmpMenu",
  "FloatBorder:BlinkCmpMenuBorder",
  "CursorLine:BlinkCmpMenuSelection",
  "Search:None",
}, ",")

local _auto_show = true
local completion = {} ---@type blink.cmp.CompletionConfigPartial
completion.list = { max_items = 250 }
completion.menu = {
  auto_show = function(_) return _auto_show end,
  -- min_width = vim.o.columns,
  border = "none",
  -- border = "bold",
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

---@type blink.cmp.CmdlineConfig
local cmdline = {
  enabled = true,
  keymap = {
    preset = "inherit",
    ["<Up>"] = false,
    ["<Down>"] = false,
    ["<C-space>"] = { "show", "hide", "fallback" },
  },
  completion = {
    menu = {
      -- auto_show = true,
      auto_show = function(_) return vim.fn.getcmdtype() == ':' end,
      draw = { columns = { { "label" }, { "label_description" } }, },
    }
  },
  sources = function()
    local type = vim.fn.getcmdtype()
    if type == "/" or type == "?" then return { "buffer" } end
    if type == ":" or type == "@" then return { "cmdline", "buffer" } end
    return { "lsp" }
  end,
}

local excmds_cache = {}
local function populate_excmds_cache()
  local ts = vim.treesitter

  local path = vim.api.nvim_get_runtime_file("doc/index.txt", false)[1]
  local bufnr = vim.fn.bufadd(path)
  local buf_was_already_loaded = vim.api.nvim_buf_is_loaded(bufnr)
  if not buf_was_already_loaded then
    vim.fn.bufload(bufnr)
  end

  local parser = ts.get_parser(bufnr, "vimdoc")
  local tree = assert(parser):parse()[1]
  local root = tree:root()
  local query = ts.query.parse("vimdoc", [[
    (h1 (tag text: (_) @tag) (#eq? @tag "ex-cmd-index")) @heading
    (block (line (column_heading))) @block
  ]])

  local ex_cmd_heading_end
  local target_block
  for id, node, _ in query:iter_captures(root, bufnr, 0, -1) do
    local name = query.captures[id]
    if name == "heading" then
      ex_cmd_heading_end = select(3, node:range())
    end
    if name == "block" and ex_cmd_heading_end and node:start() >= ex_cmd_heading_end then
      target_block = node
      break
    end
  end

  local text = ts.get_node_text(target_block, bufnr)
  local lines = vim.split(text, "\n")
  local pattern = "^|:([^|]+)|%s+:%S+%s+(.+)$"
  for i, line in ipairs(lines) do
    local cmd, description = line:match(pattern)
    if cmd then
      -- HACK: some descriptions in index.txt are wrapped to
      -- the next line. I want to append those bits to this line
      -- and this heuristic seems to work
      local next_line = lines[i + 1]
      if next_line and not vim.startswith(next_line, "|:") then
        description = description .. " " .. vim.trim(next_line)
      end
      excmds_cache[cmd] = description
    end
  end

  -- clean up after ourselves
  if not buf_was_already_loaded then
    vim.api.nvim_buf_delete(bufnr, { force = true })
  end
end

local usercmds_cache = {}
local function populate_usercmds_cache()
  for cmd, cmd_spec in pairs(vim.api.nvim_get_commands({})) do
    usercmds_cache[cmd] = cmd_spec.desc ~= "" and cmd_spec.desc or cmd_spec.definition ~= "" and cmd_spec.definition or ""
  end
end

---@type blink.cmp.SourceConfigPartial
local sources = {
  default = { "lazydev", "lsp", "buffer", "path" },
  providers = {
    lazydev = {
      name = "LazyDev",
      module = "lazydev.integrations.blink",
      score_offset = 100,
    },
    cmdline = {
      transform_items = function(ctx, items)
        -- HACK: some labels will incorrectly match descriptions, for example
        -- "lsp stop" will match the "stop" label for ":stop" command
        -- which is incorrect. Here I just check if there are any
        -- whitespaces before the cursor and don't match on those occurances
        local text_before_cursor = ctx.line:sub(1, ctx.cursor[2])
        if text_before_cursor:find("%s") then return items end

        return vim
          .iter(ipairs(items))
          :map(function(_, item)
            item.labelDetails = item.labelDetails or {}
            item.labelDetails.description =
              excmds_cache[item.label] or usercmds_cache[item.label] or ""
            return item
          end)
          :totable()
      end,
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
    data = { enabled = false },
  },
  {
    src = "https://github.com/saghen/blink.cmp",
    version = vim.version.range("^1"),
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        local blink = require "blink.cmp"
        blink.setup({
          keymap = keymap,
          completion = completion,
          signature = signature,
          cmdline = cmdline,
          sources = sources,
          fuzzy = fuzzy,
          appearance = appearance,
        })

        vim.schedule(function()
          populate_excmds_cache()
          populate_usercmds_cache()
        end)

        vim.lsp.config("*", {
          capabilities = require("blink.cmp").get_lsp_capabilities()
        })

        Config.nmap_leader("tp", function()
          _auto_show = not _auto_show
          vim.notify("blink.cmp auto_show: " .. tostring(_auto_show))
        end, { desc = "blink auto_show" })
      end
    }
  },
  {
    src = "https://github.com/saghen/blink.pairs",
    data = { enabled = false }
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
