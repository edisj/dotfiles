local fn = vim.fn
local api = vim.api

local sources = require("quickfix.sources")

local M = {}

--- This function exists because you need to be very careful with how
--- you "create" a quickfix buffer. If one naively creates a scratch buffer
--- and sets its filetype to "qf" and buftype to "quickfix", neovim treats
--- it as a "Location List" that is window local, meaning a subsequent call to
--- :copen will create a NEW buffer that acts as the global "real" quickfix buffer.
--- The problem with there is that all the facilities that populate the quickfix
--- and even vim.fn.setqflist() will interact with the buffer neovim created, where I
--- want my window to be attached to the REAL quickfix. Therefore, I do a hacky thing
--- where if a quickfix buffer doesn't exist, "create" one by calling :copen,
--- capture the bufnr, then immediately :cclose.
--- Now, the buffer associated with my `Window` interface will always be bound
--- to the actual vim quickfix buffer, so its contents will react to vim.fn.setqflist()
--- @return integer buf
local function _find_or_create_qf_buffer()

  for _, buf in ipairs(api.nvim_list_bufs()) do
    if vim.bo[buf].filetype == "qf" and api.nvim_buf_get_name(buf):match("^[Quickfix List]$") then
      return buf
    end
  end

  vim.cmd("copen")
  local buf = api.nvim_get_current_buf()
  vim.cmd("cclose")

  return buf
end

local _qf_win = nil
M.win = function()
  if _qf_win then return _qf_win end

  local win_opts = {
    enter = false,
    split = "below",
    bufnr = _find_or_create_qf_buffer,
    -- stickybuf = false,
    style = "minimal",
    height = 12,
    yoffset = 3,
    keymaps = {
      { "n", "q", function(self) self:close() end },
    },
    title = " Quickfix ",
    title_pos = "left",
    wo = {
      number = true,
    },
  }

  _qf_win = require("win").split(win_opts)
  return _qf_win
end

M.is_qf_open = function()
  return fn.getqflist({ winid = 0 }).winid ~= 0
end

M.length = function()
  return #fn.getqflist()
end

M.open = function(override_opts)
  if M.is_qf_open() then return M.win() end

  local qf_list = vim.fn.getqflist { context = true }
  local source = qf_list.context.source
  local highlight_func = sources[source].highlight_func

  return M
    .win()
    :open(override_opts)
    :win_call(highlight_func)
end

M.close = function()
  return
    (M.win():is_open() and M.win():close())
    or (M.is_qf_open() and vim.cmd("cclose") and M.win())
    or M.win()
end

M.toggle = function()
  return M.is_qf_open() and M.close() or M.open()
end

M.next = function()
  if M.length() == 0 then return end

  local idx = fn.getqflist({ idx = 0 }).idx
  if M.length() == idx then
    return vim.cmd "clast"
  end

  vim.cmd "cnext"
end

M.prev = function()
  if M.length() == 0 then return end

  local idx = fn.getqflist({ idx = 0 }).idx
  if M.length() == idx or idx == 1 then
    return vim.cmd "cfirst"
  end

  vim.cmd "cprev"
end

---@class QuickFixTextFuncInfo
---@field id integer quickfix or locaiton list identifier
---@field quickfix 0|1 1 if called for quickfix, 0 if called for loclist
---@field winid integer 0 for quickfix, otherwise winid associated with loclist
---@field start_idx integer index of first entry for which text should be returned
---@field end_idx integer index of last entry for which text should be returned

---@param _ QuickFixTextFuncInfo
M.quickfixtextfunc = function(_)
  local qf_list = vim.fn.getqflist { items = true, context = true }
  local items_to_qftf_func = sources[qf_list.context.source].items_to_qftf
  local formatted_lines = items_to_qftf_func(qf_list.items)

  return formatted_lines
end

return M
