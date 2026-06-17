local api = vim.api
local fn = vim.fn

local M = {}

M.render = function()
  return table.concat {
    M.file(), M.loc4(), M.searchcount(),
    "%=",
    M.dap(),
    "%=",
    M.diag2(), M.lsp(), M.git(), M.session(), M.mode(),
  }
end

M.restart = function()
  package.loaded["ui.statusline"] = nil
  -- vim.o.statusline = "%!v:lua.require('ui.statusline').render()"
  vim.o.statusline = "%{%v:lua.require('ui.statusline').render()%}"
end
M.restart()

-- grabbed this table from https://github.com/nvim-mini/mini.nvim/blob/main/lua/mini/statusline.lua#L553
local CTRL_S = api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = api.nvim_replace_termcodes("<C-V>", true, true, true)
local modes = setmetatable({
  ["n"]    = { long = "Normal",   short = "N",   hl = "StatuslineNormal" },
  ["v"]    = { long = "Visual",   short = "V",   hl = "StatuslineVisual" },
  ["V"]    = { long = "V-Line",   short = "V-L", hl = "StatuslineVisual" },
  [CTRL_V] = { long = "V-Block",  short = "V-B", hl = "StatuslineVisual" },
  ["s"]    = { long = "Select",   short = "S",   hl = "StatuslineVisual" },
  ["S"]    = { long = "S-Line",   short = "S-L", hl = "StatuslineVisual" },
  [CTRL_S] = { long = "S-Block",  short = "S-B", hl = "StatuslineVisual" },
  ["i"]    = { long = "Insert",   short = "I",   hl = "StatuslineInsert" },
  ["R"]    = { long = "Replace",  short = "R" ,  hl = "StatuslineVisual" },
  ["c"]    = { long = "Command",  short = "C",   hl = "StatuslineCmd" },
  ["r"]    = { long = "Prompt",   short = "P",   hl = "StatuslineCmd" },
  ["!"]    = { long = "Shell",    short = "Sh",  hl = "StatuslineCmd" },
  ["t"]    = { long = "Terminal", short = "T",   hl = "StatuslineCmd" },
}, {
    -- By default return 'Unknown' but this shouldn't be needed
    __index = function()
      return { long = "Unknown",  short = "U" }
    end,
  })

local function with_hl(text, hl, pad)
  local spaces = string.rep(" ", pad or 1)
  text = spaces .. text .. spaces
  -- return ("%s%s%s"):format("%#"..hl.."#", text, "%#Statusline#")
  -- return ("%s%s%s"):format("%#"..hl.."#", text, "%*")
  return ("%s%s"):format("%#"..hl.."#", text)
end

M.border = function()
  local mode = fn.mode()
  local hl = modes[mode].hl
  return with_hl("█", hl, 0)
end

M.mode = function()
  -- local m = fn.mode()
  -- local hl = modes[m].hl
  local text, hl
  if vim.bo.filetype == "fzf" then
    text = "> fzf-lua"
    hl = "Function"
  elseif vim.fn.getcmdwintype() == ":" then
    text = "Cmdwin"
    hl = modes["c"].hl
  else
    -- text = modes[fn.mode()].short
    text = modes[fn.mode()].long
    hl = modes[fn.mode()].hl
  end
  return with_hl(text, hl)
end

M.git = function()
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns then return "" end

  local text = {}
  text[#text + 1] = " " .. gitsigns.head
  text[#text + 1] = gitsigns.added and gitsigns.added ~= 0 and "+" .. gitsigns.added or nil
  text[#text + 1] = gitsigns.changed and gitsigns.changed ~= 0 and "~" .. gitsigns.changed or nil
  text[#text + 1] = gitsigns.removed and gitsigns.removed ~= 0 and "-" .. gitsigns.removed or nil
  local out = table.concat(text, " ")
  return with_hl(out, "StatusLine", 1)
end

M.file = function()
  local fname = fn.expand("%")
  local ft = vim.bo.filetype
  if fname == "" then return with_hl("[No Name]", "StatusLine") end

  -- local has_mini, mini_icons = pcall(require, "mini.icons")
  -- local icon, hl
  -- if not has_mini then
  --   icon, hl = " ", "Statusline"
  -- else
  --   icon, hl = mini_icons.get("filetype", ft)
  -- end

  fname = fname:match("^(%w+://).+") and fname or fn.fnamemodify(fname, ":~:.")
  fname = vim.bo.modified and fname .. " [+]" or not vim.bo.modifiable and fname .. " " or fname
  return with_hl(fname, "Statusline") .. "%*"

end

M.searchcount = function()
  if fn.mode() == "c" or vim.g.hl_suspended then return "" end
  local out = ("🔍%s/%s"):format(fn.searchcount().current, fn.searchcount().total)
  return with_hl(out, "CurSearchInv" ) .. "%*"
end
do
  local group = vim.api.nvim_create_augroup("clear-search-status", { clear = true })
  Config.on("CmdlineEnter", function()
    if not (fn.getcmdtype() == "/" or fn.getcmdtype() == "?") then return end
    vim.g.hl_suspended = true
    vim.cmd.redrawstatus()
  end, { group = group })
  Config.on("CmdlineLeave", function()
    if not (fn.getcmdtype() == "/" or fn.getcmdtype() == "?") then return end
    vim.g.hl_suspended = false
    vim.cmd.redrawstatus()
  end, { group = group })
end

M.dap = function()
  local has_dap, dap = pcall(require, "dap")
  if not has_dap then return "" end
  local status = dap.status()
  local type = dap.session() and dap.session().config.type
  return status == "" and status or type and ("dap[%s]: "):format(type) .. status or "dap: " .. status
end

M.session = function()
  local out = require("session").this_session()
  return out and " ".. out .. " " or ""
end

local mini_icon_cache = {}
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

M.filetype = function()
  local ft = vim.bo.filetype
  if ft == "" then return ft end

  -- local icon, hl = get_ft_icon("StatusLine")
  local icon, hl = require("mini.icons").get("filetype", ft)
  local out = with_hl(" " ..icon, hl, 0).. with_hl(ft, "StatusLine")
  return out
end

-- local diag_hls2 = {}
-- local function make_hl2(hl)
--   if diag_hls2[hl] then return diag_hls2[hl] end
--   local fg = api.nvim_get_hl(0, { name = hl }).fg
--   local bg = api.nvim_get_hl(0, { name = "StatusLine2" }).bg
--   local name = hl .. "2"
--   api.nvim_set_hl(0, name, { fg = fg, bg = bg })
--   diag_hls2[hl] = name
--   return name
-- end
local diagnostic_signs = {
  { icon = "", hl = "DiagnosticError",},
  { icon = "", hl = "DiagnosticWarn", },
  { icon = "", hl = "DiagnosticInfo", },
  { icon = "󰌶", hl = "DiagnosticHint", },
}
-- local diagnostic_signs2 = {
--   { icon = "E", hl = "DiagnosticError", hl2 = make_hl2("DiagnosticError") },
--   { icon = "W", hl = "DiagnosticWarn", hl2 = make_hl2("DiagnosticWarn") },
--   { icon = "I", hl = "DiagnosticInfo", hl2 = make_hl2("DiagnosticInfo") },
--   { icon = "H", hl = "DiagnosticHint", hl2 = make_hl2("DiagnosticHint") },
-- }
local diagnostic_before_entering_insert = ""
M.diagnostics = function()
  if fn.mode() == "i" then return diagnostic_before_entering_insert end
  local count = vim.diagnostic.count(0)
  local signs = {}
  for i, c in pairs(count) do
    -- local text = diagnostic_signs[i].icon .. " " .. tostring(c)
    local text = diagnostic_signs[i].icon .. ":" .. tostring(c)
  signs[#signs + 1] = with_hl(text, diagnostic_signs[i].hl, 0)
  end
  local out = table.concat(signs, " ")
  diagnostic_before_entering_insert = out
  return out
end

M.diag2 = function()
  return vim.diagnostic.status() .. " "
end

M.lsp = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return M.filetype() end
  local names = vim
    .iter(ipairs(clients))
    :map(function(_, client)
      if client.server_capabilities.completionProvider ~= nil then
        return client.name
      end
    end)
    :totable()
  local attached_servers = table.concat(names, "｜")
  local ft = vim.bo.filetype
  local icon, hl = require("mini.icons").get("filetype", ft)
  local out = with_hl(" " ..icon, hl, 0).. with_hl(attached_servers,  "StatusLine", 1)
  return out
end

M.loc1 = function()
  return "%l:%v"
end

M.loc2 = function()
  return with_hl("%2l:%-2v %p%%", "Statusline")
end

M.loc3 = function()
  return ' %l|%L│%2v|%-2{virtcol("$") - 1} '
end

M.loc4 = function()
  return with_hl("Ln %l, Col %-2v (%p%%)", "Statusline")
end

return M
