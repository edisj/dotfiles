local fn = vim.fn
local api = vim.api

local M = {}

M.on_click_fname = function(minwid, _, _, _)
  -- NOTE: using arg passed to click handler to get winid instead of
  -- vim.api.nvim_get_current_win() since that uses the cursor window,
  -- not the clicked window
  local winid = minwid

  local fname_win = Win.float({
    focusable = false,
    enter = false,
    position = "topleft",
    relative = "win",
    win = winid,
    width = 15,
    height = 2,
    style = "minimal",
    bo = {
      bufhidden = "wipe",
    },
  })

  local TIMEOUT = 500
  fname_win:on("CursorMoved", function(win, _)
    vim.defer_fn(function() win:close() end, TIMEOUT)
  end, { once = true })

  local bufnr = api.nvim_get_current_buf()
  local lines = {
    ("winid: %d"):format(winid),
    ("bufnr: %d"):format(bufnr),
  }

  fname_win
    :open()
    :set_lines(lines)

  local ns = api.nvim_create_namespace("winbar-fname-popup")
  for i, line in ipairs(lines) do
    local start = line:find("%d+")
    api.nvim_buf_set_extmark(fname_win.bufnr, ns, i-1, start-1, {
      end_col = #line,
      hl_group = "Number",
    })
  end
end

local function with_click(component, f, winid)
  return "%" .. (winid or 0) .. "@v:lua.require'ui.winbar'." .. f .. "@" .. component .. "%X"
end

local function with_hl(text, hl)
  return "%#" .. hl .. "#" .. text
end

M.render = function()
  return table.concat({
    -- M.pad(),
    with_click(M.fname(), "on_click_fname", api.nvim_get_current_win()),
    M.diagnostics(),
    "%*"
  })
end

local mini_icon_cache = {}
Config.on("ColorScheme", function() mini_icon_cache = {} end)
local function get_ft_icon(bg_hl)
  if not package.loaded["mini.icons"] then
    return " ", bg_hl
  end
  local ft = vim.bo.filetype
  local icon, mini_icon_hl = require("mini.icons").get("filetype", ft)
  local hl_name = bg_hl .. "_" .. ft
  if mini_icon_cache[hl_name] then
    return unpack(mini_icon_cache[hl_name])
  end

  local fg = vim.api.nvim_get_hl(0, { name = mini_icon_hl, link = false }).fg
  local bg = vim.api.nvim_get_hl(0, { name = bg_hl }).bg
  vim.api.nvim_set_hl(0, hl_name, { fg = fg, bg = bg })
  mini_icon_cache[hl_name] = { icon, hl_name }
  return icon, hl_name
end

M.pad = function()
  local winid = vim.api.nvim_get_current_win()
  local textoff = vim.fn.getwininfo(winid)[1].textoff
  local out = string.rep(" ", textoff)
  return with_hl(out, "LineNr")
end

M.fname = function()
  local fname = fn.expand("%")
  local ft = vim.bo.filetype
  if fname == "" then return "[No Name]" end
  fname = fn.fnamemodify(fname, ":t")
  local hl
  if vim.bo.modified then
    -- fname = fname .. " [+]"
    hl = "WinBarModified"
  elseif not vim.bo.modifiable then
    -- fname = fname .. " "
    hl = "WinBarModifiable"
  else
    hl = "WinBarNormal"
  end
  local icon, icon_hl
  if not package.loaded["mini.icons"] then
    icon, icon_hl = " ", hl
  else
    icon, icon_hl = get_ft_icon("WinBarNormal")
  end

  local out = with_hl(" " .. icon .. " ", icon_hl) .. with_hl(fname .. " ", hl)
  return out
end

local diagnostics_before_entering_insert = ""
M.diagnostics = function()
  if fn.mode() == "i" then return diagnostics_before_entering_insert end
  local count = vim.diagnostic.count(0)
  local signs = {}
  signs[#signs + 1] = count[1] and with_hl("", "WinBarError")
  signs[#signs + 1] = count[2] and with_hl("", "WinBarWarn")
  local out = table.concat(signs, "  ")
  out = out == "" and out or " " .. out .. " "
  diagnostics_before_entering_insert = out
  return out
end

api.nvim_create_autocmd("BufWinEnter", {
  group = api.nvim_create_augroup("winbar", { clear = true }),
  desc = "Attach winbar",
  callback = function(args)
    if
      not api.nvim_win_get_config(0).zindex
      and vim.bo[args.buf].buftype == ""
      and api.nvim_buf_get_name(args.buf) ~= ""
      and not vim.wo[0].diff
    then
      vim.wo.winbar = "%{%v:lua.require'ui.winbar'.render()%}"
    end
  end,
})

return M
