local api, fn, fs = vim.api, vim.fn, vim.fs

-- local TAB_ACTIVE = "󰝥"
-- local TAB_INACTIVE = "󰝦"
local augroup = api.nvim_create_augroup("plugin.tabline", { clear = true })

local create_hl = function(target, ...)
  local merged_hl = {}
  for _, name in ipairs { ... } do
    local hl = type(name) == "string" and api.nvim_get_hl(0, { name = name, link = false }) or name
    merged_hl = vim.tbl_deep_extend("keep", merged_hl, hl)
  end
  api.nvim_set_hl(0, target, merged_hl)
end

local function create_hls()
  create_hl("TabLineSelN", "Function",     "TabLineSel")
  create_hl("TabLineN",    "LineNr",       "TabLine")
  create_hl("TabLineSelI", "String",       "TabLineSel")
  create_hl("TabLineI",    "LineNr",       "TabLine")
  create_hl("TabLineSelV", "Keyword",      "TabLineSel")
  create_hl("TabLineV",    "LineNr",       "TabLine")
  create_hl("TabLineSelC", "DiagnosticOk", "TabLineSel")
  create_hl("TabLineC",    "LineNr",       "TabLine")

  create_hl("NInverted", { bold = true, reverse = true }, "Function")
  create_hl("IInverted", { bold = true, reverse = true }, "String")
  create_hl("VInverted", { bold = true, reverse = true }, "Keyword")
  create_hl("CInverted", { bold = true, reverse = true }, "DiagnosticOk")

  create_hl("TabLineKeySel", "Comment", "TabLineSel")
  create_hl("TabLineKey",    "LineNr", "TabLine")
end
create_hls()
on("ColorScheme", augroup, create_hls)

local with_hl = function(text, hl)
  return (hl and "%#" .. hl .. "#" .. text or text)
end

local function with_pad(text, pad)
  local spaces = string.rep(" ", pad or 1)
  return spaces .. text .. spaces
end

local mode_hlmap = setmetatable({
  n = { "TabLineSelN", "TabLineN" },
  i = { "TabLineSelI", "TabLineI" },
  v = { "TabLineSelV", "TabLineV" },
  c = { "TabLineSelC", "TabLineC" },
}, { __index = function(self, k) return {} end })

local mode_hlmap2 = setmetatable({
  n = { "NInverted", "TabLineN" },
  i = { "IInverted", "TabLineI" },
  v = { "VInverted", "TabLineV" },
  c = { "CInverted", "TabLineC" },
}, { __index = function() return {} end })

local tabnr = function()
  local tabpages = api.nvim_list_tabpages()
  if #tabpages == 1 then return "" end

  local active_tabnr = api.nvim_tabpage_get_number(0)
  local tabs = {}
  local mode = fn.mode()
  for _, tabnr in ipairs(tabpages) do
    local id = tabpages[active_tabnr]
    -- local icon = id == tabnr and TAB_ACTIVE or TAB_INACTIVE
    local hl = id == tabnr and mode_hlmap2[mode][1] or "TabLine"
    table.insert(tabs, with_hl(" " .. tabnr .." ", hl))
  end
  return table.concat(tabs, "")
end

local border = function(active)
  local mode = fn.mode()
  local hl = active and mode_hlmap[mode][1] or mode_hlmap[mode][2]
  return with_hl("▎", hl)
end

-- local superscript_numbers = {
--   ["1"] = "¹", ["2"] = "²", ["3"] = "³", ["4"] = "⁴", ["5"] = "⁵",
--   ["6"] = "⁶", ["7"] = "⁷", ["8"] = "⁸", ["9"] = "⁹", ["0"] = "⁰",
-- }
-- local subscript_numbers = {
--   ["1"] = "₁", ["2"] = "₂", ["3"] = "₃", ["4"] = "₄", ["5"] = "₅",
--   ["6"] = "₆", ["7"] = "₇", ["8"] = "₈", ["9"] = "₉", ["0"] = "₀",
-- }
local format_tab = function(name, key)
  local prevbuf = fs.abspath(api.nvim_buf_get_name(api.nvim_win_get_buf(fn.win_getid(fn.winnr("#")))))
  local curbuf = api.nvim_buf_get_name(0)
  local active = curbuf == fs.abspath(name) or prevbuf == fs.abspath(name)
  local hl = active and "TabLineSel" or "TabLine"
  local key_hl = active and "TabLineKeySel" or "TabLineKey"
  local isdir = name:sub(#name) == "/"
  local basename = fn.fnamemodify(name, isdir and ":h:t" or ":t") .. (isdir and "/" or "")
  local tabtext = with_hl(with_pad(basename .. ' ' .. with_hl(key, key_hl), 2), hl)
  local text = border(active) .. tabtext
  return text
end

local arglist_tabs = function()
  if not (fn.argc() > 0 and _G.arglist) then return "" end
  -- vim.notify("ARGLIST TABS!!!")
  return arglist.tabline(format_tab, " ")
end

local _show_tabs = true
local show_tabs = function() return _show_tabs and fn.argc() > 0 end
local render = function()
  local tabline = ""
  if show_tabs() then
    tabline = tabline .. arglist_tabs() .. "%*%=" .. tabnr()
  else
    if #api.nvim_list_tabpages() > 1 then tabline = tabline .. tabnr() .. "%*" end
  end
  return tabline
end

map("<Leader>tt", function()
  _show_tabs = not _show_tabs
  vim.o.showtabline = _show_tabs and fn.argc() > 0 and 2 or 1
  vim.cmd("redrawtabline")
end)

on("User", augroup, { pattern = "ArgUpdate" }, function()
  vim.o.showtabline = _show_tabs and fn.argc() > 0 and 2 or 1
end)

on("ModeChanged", augroup, "redrawtabline")

_G.Tabline = render
vim.go.tabline = "%{%v:lua.Tabline()%}"
vim.schedule(function()
  vim.o.showtabline = fn.argc() > 0 and 2 or 1
end)
-- vim.notify("ARGC(): " .. fn.argc())
-- vim.notify("SHOWTABLINE: " .. vim.o.showtabline)
