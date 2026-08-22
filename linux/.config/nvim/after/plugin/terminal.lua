local _terminal = nil
local api = vim.api

local _buf
local buf = function()
  if _buf and api.nvim_buf_is_valid(_buf) then return _buf end
  _buf = api.nvim_create_buf(false, true)
  vim.api.nvim_open_term(_buf)
  -- api.nvim_buf_call(_buf, vim.cmd.terminal)
  return _buf
end

local function terminal()
  if _terminal then return _terminal end

  local msg = package.loaded["msgarea"]
  local win_opts = {
    bufnr = function()
      local bufnr = vim.api.nvim_create_buf(false, true)
      vim.api.nvim_buf_call(bufnr, function() vim.cmd.terminal() end)
      return bufnr
    end,
    position = "center",
    split = "below",
    relative = msg and "msgarea" or "editor",
    width = function(self, _) return self:is_floating() and 0.75 or 0.5 end,
    height = 0.25,
    border = msg and "none" or require("icons").border.thinblock,
    -- title = " Terminal ",
    title = nil,
    wo = {
      winfixbuf = true,
      signcolumn = "no",
    },
  }

  _terminal = Win.float(win_opts)

  return _terminal
end

local win
local open = function(win_cfg)
  if win and api.nvim_win_is_valid(win) then return win end
  win = api.nvim_open_win(buf(), false, win_cfg)
  return win
end

local M = {
  focus = function() terminal():focus() end,
  close = function() terminal():close() end,
  toggle = function() terminal():toggle() end,
  smart_toggle = function()
    if terminal() and not terminal():is_focused() then
      terminal():focus()
    else
      terminal():toggle()
    end
  end,
  to_split = function() terminal():to_split() end,
  to_float = function() terminal():to_float() end,
}

_G.terminal = M

vim.keymap.set({ "n", "t", "i", "x" }, "<c-t>", function()
  _G.terminal.smart_toggle()
end, { desc = "toggle terminal" })

map("<C-x><C-.>", function()
  vim.cmd("tabnew")
  vim.cmd(buf() .. "buffer")
end)
map("<C-x><f13>", function()
  local win = open({ relative = "msgarea", height = 10 })
  api.nvim_win_call(win, function() vim.cmd("normal! G") end)
end)


on({ "TermRequest" }, nil, {
  desc = 'Handles OSC 7 dir change requests'
}, function(ev)
    if string.match(ev.data.sequence, '^\027]133;A') then
      -- OSC 133: shell-prompt
      local lnum = ev.data.cursor[1]
      vim.api.nvim_buf_set_extmark(ev.buf, vim.api.nvim_create_namespace('my.terminal.prompt'), lnum - 1, 0, {
        -- Replace with sign text and highlight group of choice
        sign_text = '∙',
        -- sign_hl_group = 'SpecialChar',
      })
    end

    local val, n = string.gsub(ev.data.sequence, '\027]7;file://[^/]*', '')
    if n > 0 then
      -- OSC 7: dir-change
      local dir = val
      if vim.fn.isdirectory(dir) == 0 then
        vim.notify('invalid dir: '..dir)
        return
      end
      vim.cmd.bcd(dir)
    end
  end)
