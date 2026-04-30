-- blink config ===============================================================
local keymap = {
  preset = "default",
  ["<C-e>"] = { "show", "hide", "fallback" },
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
completion.list = { max_items = 500 }
completion.menu = {
  auto_show = function(_) return _auto_show end,
  -- min_width = vim.o.columns,
  border = "none",
  max_height = _max_height,
  auto_show_delay_ms = 0,
  direction_priority = { "s", "n" },
  draw = {
    columns = { { "kind_icon" }, { "label", "label_description" }, { "source_name" } },
    ---@type blink.cmp.DrawComponent[]
    components = {
      label = {
        width = { max = function(_) return math.floor(0.4*vim.o.columns) end },
      },
      label_description = {
        width = { fill = true, max = math.huge },
        -- width = { max = function(_) return math.floor(0.4*vim.o.columns) end },
      },
    },
  },
}

completion.documentation = {
  auto_show = true,
  window = {
    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
    winblend = 5,
  },
}

local signature = {
  enabled = true,
  window = { max_width = 100 },
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
    usercmds_cache[cmd] = cmd_spec.definition
  end
end

---@type blink.cmp.SourceConfigPartial
local sources = {
  default = { "lazydev", "lsp", "path" },
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
-------------------------------------------------------------------------------

-- local function reset_cmdheight(ev)
--   local config = require("blink.cmp.config")
--   local menu_win_config = require("blink.cmp.completion.windows.menu").win.config
--   config.max_height = _max_height
--   config.min_width = nil
--   menu_win_config.max_height = _max_height
--   menu_win_config.min_width = nil
--
--   local ui2 = require("vim._core.ui2")
--
--   -- NOTE: this needs to be schedule as the message doesn't exist until
--   -- we actually exit the command line
--   vim.schedule(function()
--     local has_messages = next(ui2.msg.cmd.ids) ~= nil
--     if not has_messages then
--       vim.o.cmdheight = 0
--       vim.cmd("redraw")
--     else
--       Config.on("CursorMoved", function()
--         vim.o.cmdheight = 0
--         pcall(vim.api.nvim_win_set_config, ui2.wins.cmd, {
--           hide = true,
--           height = 1,
--         })
--       end, { once = true, group = "blink-cmp-height-toggle" })
--     end
--   end)
-- end

Pack.add({
  {
    src = "https://github.com/saghen/blink.cmp",
    data = {
      enabled = true,
      loader = Pack.load_on_loop(function(name)
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

        populate_excmds_cache()
        populate_usercmds_cache()

        vim.lsp.config("*", {
          capabilities = require("blink.cmp").get_lsp_capabilities()
        })

        local menu = require("blink.cmp.completion.windows.menu")
        local _update_position =  menu.update_position
        ---@diagnostic disable-next-line: duplicate-set-field
        menu.update_position = function()
          _update_position()
          if not (menu.win:is_open() and vim.fn.mode() == "c") then return end
          local cmd_win = require("vim._core.ui2").wins.cmd
          menu.win:set_win_config({
            relative = "win",
            -- relative = "minibuffer",
            win = cmd_win,
            -- height = math.max(1, vim.o.cmdheight - 1),
            width = vim.api.nvim_win_get_width(cmd_win),
            row = 1,
            col = 0,
            zindex = vim.api.nvim_win_get_config(cmd_win).zindex + 1,
          })
        end

        local function set_blink_config(min_width, max_height, winhl)
          -- NOTE: for whatever reason both fields in the regular
          -- blink config and the completion.windows.menu config
          -- need to be set for this to work
          local menu_config_1 = require("blink.cmp.config").completion.menu
          local menu_config_2 = require("blink.cmp.completion.windows.menu").win.config
          menu_config_1.max_height = max_height
          menu_config_1.min_width = min_width
          menu_config_2.max_height = max_height
          menu_config_2.min_width = min_width
          menu_config_1.winhighlight = winhl
          menu_config_2.winhighlight = winhl
        end

        local group = vim.api.nvim_create_augroup("blink-cmp-height-toggle", {})
        local on = function(event, pattern, desc, cb)
          Config.on(event, cb, { group = group, pattern = pattern, desc = desc })
        end

        on("CmdlineEnter", "*", "set blink max_height", function()
          if vim.fn.getcmdtype() ~= ":" then return end
          local winhl = table.concat({
            "NormalFloat:MsgArea",
            "BlinkCmpMenu:MsgArea",
            "BlinkCmpSelection:CursorLine",
            "CursorLine:CursorLine"
          }, ",")
          set_blink_config(10000, vim.g.minibuffer_height - 1, winhl)
        end)

        local _cmdheight_saved = vim.o.cmdheight
        local function refresh_cmdheight(height)
          vim.o.cmdheight = height
          vim.cmd.redraw()
        end

        on("CmdlineLeave", "*", "reset cmdheight and blink config", function()
          set_blink_config(nil, _max_height, _winhl)
          -- vim.schedule(function() refresh_cmdheight(_cmdheight_saved) end)
          require("ui.minibuffer").try_close_minibuffer()
        end)

        on("User", "BlinkCmpMenuOpen", "expand cmdheight when blink has completions", function()
          if vim.fn.mode() ~= "c" then return end
          vim.schedule(function() refresh_cmdheight(vim.g.minibuffer_height) end)
        end)

        on("User", "BlinkCmpMenuClose", "collapse cmdheight when no completions and input empty", function()
          -- NOTE: if you don't schedule this things BAD THINGS HAPPEN
          vim.schedule(function()
            if
              vim.fn.mode() == "c"
              and vim.fn.getcmdline() == ""
              and not require("ui.minibuffer").is_occupied()
            then
              refresh_cmdheight(1)
            end
          end)
        end)

        on("CmdlineChanged", "*", "collapse cmdheight on no input", function()
          if vim.fn.getcmdtype() ~= ":" then return end
          -- NOTE: need to defer the update rather than vim.schedule
          -- because blink needs more time to update after keystroke
          vim.defer_fn(function()
            if vim.fn.mode() ~= "c" then return end
            local items = require("blink.cmp").get_items()
            if #items > 0 then
              refresh_cmdheight(vim.g.minibuffer_height)
            elseif vim.fn.getcmdline() == "" then
              refresh_cmdheight(1)
            end
          end, 10)
        end)

        Config.nmap_leader("tp", function()
          _auto_show = not _auto_show
          vim.notify("blink.cmp auto_show: " .. tostring(_auto_show))
        end, { desc = "blink auto_show" })

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
