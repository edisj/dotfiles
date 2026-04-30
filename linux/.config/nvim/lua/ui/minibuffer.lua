
local minibuffer = {}

local api = vim.api
local ui2 = require("vim._core.ui2")

local _cmdheight_saved
vim.schedule(function()
  -- NOTE: need to schedule this because options are loaded later
  _cmdheight_saved = vim.o.cmdheight
end)

vim.g.minibuffer_height = vim.g.minibuffer_height or 11

function minibuffer.is_occupied()
  for _, win in ipairs(api.nvim_list_wins()) do
    if vim.w[win].minibuffer then return true end
  end
  return false
end

local try_close_minibuffer = vim.schedule_wrap(function()
  if minibuffer.is_occupied() then return end
  vim.o.cmdheight = _cmdheight_saved
  vim.cmd.redraw()
end)
minibuffer.try_close_minibuffer = try_close_minibuffer

Config.on("CmdlineEnter", function()
  for _, win in ipairs(api.nvim_list_wins()) do
    if vim.w[win].minibuffer then
      api.nvim_win_set_config(win, { hide = true })
      vim.cmd.redraw()
    end
  end
end)

Config.on("CmdlineLeave", function()
  for _, win in ipairs(api.nvim_list_wins()) do
    if vim.w[win].minibuffer then
      api.nvim_win_set_config(win, { hide = false })
    end
  end
end)

Config.on("OptionSet", function(ev)
  if vim.fn.mode() == "c" then return end
  for _, win in ipairs(api.nvim_list_wins()) do
    if vim.w[win].minibuffer then
      api.nvim_win_set_config(win, { height = vim.v.option_new - 1 })
    end
  end
end, { pattern = "cmdheight" })

local _nvim_open_win = vim.api.nvim_open_win
---@diagnostic disable-next-line: duplicate-set-field
vim.api.nvim_open_win = function(buf, enter, opts)
  if opts.relative ~= "minibuffer" then return _nvim_open_win(buf, enter, opts) end

  local cmd_win = ui2.wins.cmd

  opts.border = opts.border or { "▔", "▔", "▔", "", "", "", "", "" }
  local border_height = 0
  local b = opts.border
  if type(b) == "table" then
    if b[2] ~= "" then border_height = border_height + 1 end
    if b[6] ~= "" then border_height = border_height + 1 end
  elseif type(b) == "string" and b ~= "none" then
    border_height = border_height + 2
  end

  opts.relative = nil
  opts = vim.tbl_deep_extend("keep", {
    anchor = "SW",
    row = vim.o.lines,
    col = 0,
    win = cmd_win,
    zindex = api.nvim_win_get_config(cmd_win).zindex + 1,
    width = api.nvim_win_get_width(cmd_win),
    height = vim.g.minibuffer_height - border_height,
  }, opts or {})

  opts.relative = "editor"
  opts.split = nil
  opts.title = opts.title or " minibuffer "

  vim.o.cmdheight = vim.g.minibuffer_height
  vim.cmd.mode()

  local winid = _nvim_open_win(buf, enter, opts)
  local function set_hl(win)
    vim.wo[win].winhl = "NormalFloat:MsgArea,FloatBorder:MiniBufferBorder,FloatTitle:MiniBufferTitle," .. vim.wo[win].winhl
  end
  vim.schedule(function()
    pcall(set_hl, winid)
  end)

  vim.w[winid].minibuffer = true

  Config.on("WinClosed", function()
    minibuffer.try_close_minibuffer(winid)
  end, { once = true, pattern = tostring(winid) })

  return winid
end

minibuffer.open_as_minibuffer = function(open_fn, opts)
  -- P(Quickfix.win():is_open())
  local win = open_fn()
  if not win then return end

  local cmd_win = ui2.wins.cmd

  local winconfig = api.nvim_win_get_config(win)
  winconfig.border =  { "▔", "▔", "▔", "", "", "", "", "" }
  local border_height = 0
  local b = winconfig.border
  if type(b) == "table" then
    if b[1] ~= "" or b[2] ~= "" or b[3] ~= "" then border_height = border_height + 1 end
    if b[5] ~= "" or b[6] ~= "" or b[7] ~= "" then border_height = border_height + 1 end
  end

  winconfig = vim.tbl_deep_extend("force", winconfig, {
    relative = "win",
    win = cmd_win,
    border = { "▔", "▔", "▔", "", "", "", "", "" },
    zindex = api.nvim_win_get_config(cmd_win).zindex,
    width = api.nvim_win_get_width(cmd_win),
    height = vim.g.minibuffer_height - border_height,
    anchor = "NW",
    title = "MiniBuffer",
    row = 0,
    col = 1,
  }, opts or {})
  winconfig.split = nil

  vim.o.cmdheight = vim.g.minibuffer_height
  vim.cmd.mode()
  -- vim.cmd.redraw()

  if vim.api.nvim_win_get_config(win).zindex == nil then
    local buf = vim.api.nvim_win_get_buf(win)
    vim.api.nvim_win_close(win, true)
    win = vim.api.nvim_open_win(buf, false, winconfig)
  else
    vim.api.nvim_win_set_config(win, winconfig)
  end
  vim.wo[win].winhl = "NormalFloat:MsgArea,FloatBorder:MiniBufferBorder"

  Config.on("WinClosed", function()
    vim.schedule(function()
      vim.o.cmdheight = _cmdheight_saved
      vim.cmd.redraw()
    end)
  end, { once = true, pattern = tostring(win) })

end

return minibuffer
