local api, cmd = vim.api, vim.cmd

local origin = { winid = nil, tabpage = nil }
local record_origin = function()
  origin.winid = api.nvim_get_current_win()
  origin.tabpage = api.nvim_get_current_tabpage()
end

local bring_me_back = function()
  if not origin.winid then return end
  if api.nvim_get_current_tabpage() ~= origin.tabpage then
    cmd("tabclose")
  else
    api.nvim_win_close(0, true)
  end
  if api.nvim_win_is_valid(origin.winid) then
    api.nvim_set_current_win(origin.winid)
  end
  origin.winid, origin.tabpage = nil, nil
end

local _buf
local buf = function()
  if _buf and api.nvim_buf_is_valid(_buf) then return _buf end
  _buf = api.nvim_create_buf(true, true)
  api.nvim_buf_call(_buf, vim.cmd.terminal)
  map("<C-s>", bring_me_back,{ buf = _buf, nowait = true, mode = { "n", "t" } })
  return _buf
end

local get_shell_win = function(bufnr)
  for _, win in ipairs(api.nvim_list_wins()) do
    if
      api.nvim_win_get_buf(win) == bufnr
      and api.nvim_win_get_config(win).relative == ""
    then
      return win
    end
  end
end

local get_valid_tabwins = function(win)
  local tabpage_wins = api.nvim_tabpage_list_wins(api.nvim_win_get_tabpage(win))
  return vim.tbl_filter(function(w)
    return api.nvim_win_get_config(w).relative == ""
  end, tabpage_wins)
end

map("<C-s><C-.>", function()
  record_origin()
  local bufnr = buf()
  local win = get_shell_win(bufnr)
  if win then
    local tabwins = get_valid_tabwins(win)
    if #tabwins == 1 then
      api.nvim_set_current_win(win)
      return
    end
    api.nvim_win_close(win, true)
  end
  cmd("tabnew | b " .. bufnr)
  vim.wo.winfixbuf = true
end)

local place_shell = function(split)
  record_origin()
  local bufnr = buf()
  local win = get_shell_win(bufnr)
  local tabwins = win and get_valid_tabwins(win) or {}
  if win and #tabwins > 1 then
    api.nvim_win_set_config(win, { split = split, win = -1 })
  else
    if win then api.nvim_win_close(win, true) end
    win = api.nvim_open_win(bufnr, true, { split = split, win = -1 })
    vim.wo[win].winfixbuf = true
  end
  api.nvim_set_current_win(win)
end

map("<C-s><C-h>", function() place_shell("left") end)
map("<C-s><C-j>", function() place_shell("below") end)
map("<C-s><C-k>", function() place_shell("above") end)
map("<C-s><C-l>", function() place_shell("right") end)

map("<C-s>" .. vim.g.CTRL_M, function()
  local win_cfg = { relative = "msgarea", height = 10 }
  local win = api.nvim_open_win(buf(), false, win_cfg)
  -- api.nvim_win_call(win, function() vim.cmd("normal! G") end)
end)

local _win
map("<C-t>", function()
  local win_cfg = { relative = "msgarea", title = " Terminal ", height = 8 }
  -- if not (_win and api.nvim_win_is_valid(_win)) then
    _win = api.nvim_open_win(buf(), true, win_cfg)
  -- end
end)

-- local ns = vim.api.nvim_create_namespace("my.terminal.prompt")
on("TermRequest", nil, { desc = "Handles OSC 7 dir change requests" }, function(ev)
  if string.match(ev.data.sequence, "^\027]133;A") then
    -- OSC 133: shell-prompt
    -- local lnum = ev.data.cursor[1]
    -- vim.api.nvim_buf_set_extmark(ev.buf, ns, lnum - 1, 0, {
    --   sign_text = ("%d "):format(x),
    --   sign_hl_group = "LineNr",
    -- })
    vim.api.nvim__redraw({ statuscolumn = true })
  end

  local val, n = string.gsub(ev.data.sequence, '\027]7;file://[^/]*', '')
  if n > 0 then
    -- OSC 7: dir-change
    local dir = val
    if vim.fn.isdirectory(dir) == 0 then
      vim.notify("invalid dir: " .. dir)
      return
    end
    vim.cmd.bcd(dir)
  end
end)

-- map("<C-l>", function()
--   -- vim.api.nvim_buf_clear_namespace(_buf, ns, 0, -1)
--   vim.schedule(function() vim.api.nvim__redraw({ statuscolumn = true }) end)
--   return "<C-l>"
-- end, { expr = true, mode = { "t" } })
