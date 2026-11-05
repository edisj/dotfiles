local api, fn = vim.api, vim.fn
local ns = api.nvim_create_namespace("pickers.buf_lines")

return function(local_opts, opts)
  local default_local_opts = {
    -- scope = "current",
    preserve_order = true,
    group_by = "bufnr",
    show_header = true,
    follow = true,
  }
  local_opts = vim.tbl_deep_extend("force", default_local_opts, local_opts or {})

  local origin = {
    win = api.nvim_get_current_win(),
    buf = api.nvim_get_current_buf(),
    view = fn.winsaveview(),
  }
  local hl_buf, chosen
  local clear_hl = function()
    if hl_buf and api.nvim_buf_is_valid(hl_buf) then api.nvim_buf_clear_namespace(hl_buf, ns, 0, -1) end
    hl_buf = nil
  end
  local follow = function()
    local state = MiniPick.get_picker_state()
    local win = state and state.windows.target
    if not (win and api.nvim_win_is_valid(win)) then return end
    local item = MiniPick.get_picker_matches().current
    clear_hl()
    if not (item and item.bufnr and api.nvim_buf_is_valid(item.bufnr)) then return end
    if api.nvim_win_get_buf(win) ~= item.bufnr then api.nvim_win_set_buf(win, item.bufnr) end
    api.nvim_win_set_cursor(win, { item.lnum, 0 })
    api.nvim_win_call(win, function() vim.cmd("normal! zz") end)
    hl_buf = item.bufnr
    api.nvim_buf_set_extmark(hl_buf, ns, item.lnum - 1, 0, {
      line_hl_group = "Visual",
      priority = 150,
    })
  end
  if local_opts.follow then
    api.nvim_create_autocmd("User", {
      pattern = "MiniPickStop",
      once = true,
      callback = function()
        if chosen then return end
        clear_hl()
        if not api.nvim_win_is_valid(origin.win) then return end
        if api.nvim_win_get_buf(origin.win) ~= origin.buf then api.nvim_win_set_buf(origin.win, origin.buf) end
        api.nvim_win_call(origin.win, function() fn.winrestview(origin.view) end)
      end,
    })
  end

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
    if local_opts.follow then follow() end
  end
  local choose = function(item)
    chosen = true
    vim.schedule(function()
      MiniPick.default_choose(item)
      clear_hl()
      if not (item.bufnr and api.nvim_buf_is_valid(item.bufnr)) then return end
      local pos = { item.lnum - 1, 0 }
      vim.hl.range(item.bufnr, ns, "Search", pos, pos, { regtype = "V", timeout = 300 })
    end)
    MiniPick.stop()
  end

  local prompt_prefix = " Goto Line" .. (local_opts.scope == "current" and " (current)" or "") .. ": "
  opts = vim.tbl_deep_extend("keep", { source = { show = show, choose = choose } }, opts or {}, {
    window = { prompt_prefix = prompt_prefix },
  })
  MiniExtra.pickers.buf_lines(local_opts, opts)
end
