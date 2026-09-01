return function(local_opts, opts)
  local default_local_opts = {
    -- scope = "current",
    preserve_order = true,
    group_by = "bufnr",
    show_header = true,
  }
  local_opts = vim.tbl_deep_extend("force", default_local_opts, local_opts or {})

  local showopts = {
    show_header = local_opts.show_header,
    group_by = local_opts.group_by,
    extmark_cache = {},
    parse_item = function(item)
      local text = vim.split(item.text, "\0")
      local prefix = tostring(item.lnum) .. ":"
      return { bufnr = item.bufnr, lnum = item.lnum, text = text[#text], prefix = prefix }
    end,
  }
  local show = function(bufnr, items, query)
    require("pickers._shared").show_grouped(bufnr, items, query, showopts)
  end
  local choose = function(item)
    -- vim.print(item)
    vim.schedule(function() MiniPick.default_choose(item) end)
    MiniPick.stop()
  end

  local prompt_prefix = " Goto Line" .. (local_opts.scope == "current" and " (current)" or "") .. ": "
  opts = vim.tbl_deep_extend("keep", { source = { show = show, choose = choose } }, opts or {}, {
    window = { prompt_prefix = prompt_prefix },
  })
  MiniExtra.pickers.buf_lines(local_opts, opts)
end
