-- vim.pack.add({
--   "https://github.com/rachartier/tiny-cmdline.nvim"
-- })
-- require("tiny-cmdline").setup()

local ui2 = require("vim._core.ui2")
local cmdline = ui2.cmd

local function centered(offset)
  offset = 5
  local border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
  ---@diagnostic disable-next-line: cast-local-type
  border = "rounded"
  local height = 1
  -- local width = math.floor(0.5 * vim.o.columns)
  local width = 60
  local row = math.floor(0.5 * (vim.o.lines - (height+2))) - (offset or 0)
  local col = math.floor(0.5 * (vim.o.columns - (width+2)))
  -- NOTE: blink.cmp anchor
  vim.g.ui_cmdline_pos = { row + height + 2, col - 1 }
  return {
    relative = "editor",
    height = height,
    width = width,
    row = row,
    col = col,
    border = border,
  }
end

local _enabled = true
local _win_config_saved
local _cmdheight_saved

vim.schedule(function()
  _cmdheight_saved = vim.o.cmdheight
  _win_config_saved = vim.api.nvim_win_get_config(ui2.wins.cmd)
  vim.api.nvim_win_set_config(ui2.wins.cmd, centered(10))
end)

local _blink_patched = false
local timer = assert(vim.loop.new_timer())
local count = 0
timer:start(0, 500, function()
  count = count + 1
  if _blink_patched or count == 10 then
    if not timer:is_closing() then timer:close() end
    return
  end
  local ok, menu = pcall(require, "blink.cmp.completion.windows.menu")
  if not ok then return end

  _blink_patched = true

  local _update_position =  menu.update_position
  ---@diagnostic disable-next-line: duplicate-set-field
  menu.update_position = function()
    _update_position()
    if not (menu.win:is_open() and vim.fn.mode() == "c") then return end
    local cmd_win = ui2.wins.cmd
    menu.win:set_win_config({
      relative = "win",
      win = cmd_win,
      -- border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
      border = { "▏", " ", "▕", "▕", "🭿", "▁", "🭼", "▏" },
      -- border = "rounded",
      -- height = math.max(1, vim.o.cmdheight - 1),
      width = vim.api.nvim_win_get_width(cmd_win),
      row = 1,
      col = -1,
      zindex = vim.api.nvim_win_get_config(cmd_win).zindex + 1,
    })
  end
end)

local function set_cmdheight(height)
  vim._with({ noautocmd = true, o = { splitkeep = "screen" } }, function()
    vim.o.cmdheight = height
  end)
end

local _cmdline_show = cmdline.cmdline_show
cmdline.cmdline_show = function(...)  -- (content, pos, firstc, prompt, indent, level, hl_id)
  _cmdline_show(...)
  set_cmdheight(_cmdheight_saved)
  vim.api.nvim_win_set_config(ui2.wins.cmd, centered(10))
end

local group = vim.api.nvim_create_augroup("ui-cmdline", { clear = true })

Config.on("FileType", function()
  if not _enabled then return true end
  vim.schedule(function()
    local win = ui2.wins.cmd
    if _win_config_saved == nil then
      _win_config_saved = vim.api.nvim_win_get_config(win)
    end
    vim.api.nvim_win_set_config(win, centered(10))
    vim.wo[win].cursorline = false
  end)
end, { pattern = "cmd", group = group })

local function set_blink_config(min_width, max_height, winhl)
  -- NOTE: for whatever reason both fields in the regular
  -- blink config and the completion.windows.menu config
  -- need to be set for this to work
  local menu_config_1 = require("blink.cmp.config").completion.menu
  local menu_config_2 = require("blink.cmp.completion.windows.menu").win.config
  menu_config_1.max_height = max_height
  -- menu_config_1.min_width = min_width
  menu_config_2.max_height = max_height
  -- menu_config_2.min_width = min_width
  -- menu_config_1.winhighlight = winhl
  -- menu_config_2.winhighlight = winhl
end

Config.on("CmdlineEnter", function()
  if not _enabled then return true end
  _cmdheight_saved = vim.o.cmdheight
  vim.wo[ui2.wins.cmd].winhl = "Normal:Normal,Search:Search,IncSearch:IncSearch,FloatBorder:FloatBorder2"
  -- vim.cmd.redraw()
  set_blink_config(nil, 20, nil)
end, { group = group })

Config.on("CmdlineLeave", function()
  if not _enabled then return true end
  set_blink_config(nil, 10, nil)
  local win = ui2.wins.cmd
  vim.wo[win].winhl = "Normal:MsgArea,Search:,CurSearch:,IncSearch:"
  vim.api.nvim_win_set_config(win, _win_config_saved)
  vim.schedule(function()
    vim.o.cmdheight = _cmdheight_saved
  end)
end, { group = group })

Config.on({ "VimResized", "TabEnter" }, function()
  if not _enabled then return true end
  vim.schedule(function()
    set_cmdheight(_cmdheight_saved)
    vim.api.nvim_win_set_config(ui2.wins.cmd, centered(10))
  end)
end, { group = group })
