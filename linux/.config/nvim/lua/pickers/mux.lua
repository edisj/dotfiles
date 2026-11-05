local pick = require("mini.pick")

local get_items = function(discover)
  return vim
    .iter(require("mux").list({ discover = discover }))
    :map(function(item) item.text = item.name; return item end)
    :totable()
end

return function(local_opts, opts)
  local default_local_opts = {
    preserve_order = true,
    group_by = "active",
    show_header = true,
    discover = false,
  }
  local_opts = vim.tbl_deep_extend("force", default_local_opts, local_opts or {})

  local showopts = {
    show_header = local_opts.show_header,
    format_header = function(key)
      return key and { " Active ", "DiagnosticOK"}  or {" Inactive ", "LineNr"}
    end,
    group_by = local_opts.group_by,
    extmark_cache = {},
    parse_item = function(item)
      if item.socket == vim.v.servername then
        item.prefix = { ">> ", "Function" }
      else
        item.prefix = "   "
      end
      item.bufnr = 0
      item.suffix = { item.root, "Comment" }
      -- item.suffix = tostring(item.root)
      return item
    end,
  }
  local show = function(bufnr, items, query)
    require("pickers._shared").show_grouped(bufnr, items, query, showopts)
  end

  local choose = function(item)
    -- pick.stop()
    require("mux").remote_call(item.socket, { fn = "attach", autostart = true }, function() end)
    pick.stop()
  end

  local match = function(stritems, inds, query)
    return pick.default_match(stritems, inds, query, { preserve_order = local_opts.preserve_order })
  end

  local mandatory_opts = { source = { items = get_items(local_opts.discover), show = show, choose = choose, match = match } }
  opts = vim.tbl_deep_extend("keep", mandatory_opts, opts or {}, {
    source = { name = "Mux" },
    mappings = {
      kill_marked = { char = "<C-b>", func = function()
        local marked = pick.get_picker_matches().marked
        for _, item in ipairs(marked) do
          require("mux").remote_call(item.socket, { fn = "kill" })
        end

        vim.defer_fn(function()
          pick.set_picker_items(get_items(local_opts.discover))
        end, 100)
      end }
    },
    window = {
      prompt_prefix = " Select Session: ",
      config = {
        zindex = 500,
        border = { " ", " ", " ", " ", "", "", "", " " },
        height = 999,
        width = vim.o.columns + 2,
        relative = "editor",
      }},
  })
  pick.start(opts)
end
