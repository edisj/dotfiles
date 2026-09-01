local api, cmd = vim.api, vim.cmd

local _return_buf, _return_tab
local bring_me_back = function()
  if not _return_buf then return end
  if _return_buf == "" then _return_buf = nil; _return_tab = nil; return end
  if api.nvim_get_current_tabpage() ~= _return_tab then
    cmd("tabclose")
    -- cmd("edit " .. _return_buf)
  else
    api.nvim_win_close(0, true)
  end
  _return_buf, _return_tab = nil, nil
end

local _buf
local buf = function()
  if _buf and api.nvim_buf_is_valid(_buf) then return _buf end
  _buf = api.nvim_create_buf(true, true)
  api.nvim_buf_call(_buf, vim.cmd.terminal)
  map("<C-s>", bring_me_back,           { buf = _buf, nowait = true, mode = { "n", "t" } })
  return _buf
end

map("<C-s><C-.>", function()
  _return_buf = api.nvim_buf_get_name(0)
  _return_tab = api.nvim_get_current_tabpage()
  local bufnr = buf()
  vim.cmd("tabnew | b " .. bufnr)
  vim.wo.winfixbuf = true
end)
map("<C-s><C-h>", function()
  cmd("topleft vsplit")
  cmd("b " .. buf())
end)
map("<C-s><C-j>", function()
  cmd("botright split")
  cmd("b " .. buf())
end)
map("<C-s><C-k>", function()
  cmd("topleft split")
  cmd("b " .. buf())
end)
map("<C-s><C-l>", function()
  cmd("botright vsplit")
  cmd("b " .. buf())
end)
map("<C-s>" .. vim.g.CTRL_M, function()
  local win_cfg = { relative = "msgarea", height = 10 }
  local win = api.nvim_open_win(buf(), false, win_cfg)
  -- api.nvim_win_call(win, function() vim.cmd("normal! G") end)
end)

on({ "TermRequest" }, nil, {
  desc = "Handles OSC 7 dir change requests"
}, function(ev)
    if string.match(ev.data.sequence, '^\027]133;A') then
      -- OSC 133: shell-prompt
      local lnum = ev.data.cursor[1]
      vim.api.nvim_buf_set_extmark(ev.buf, vim.api.nvim_create_namespace("my.terminal.prompt"), lnum - 1, 0, {
        -- Replace with sign text and highlight group of choice
        sign_text = "∙",
        sign_hl_group = "LineNr",
      })
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
