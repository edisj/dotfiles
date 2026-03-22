local api = vim.api
local fn = vim.fn

local M = {}

M.render = function()
  return table.concat {
    M.mode(), M.git(), M.file(), M.diagnostics(),
    "%=",
    M.lsp(), M.session(), M.location(),
  }
end

M.restart = function()
  package.loaded["ui.statusline"] = nil
  vim.go.statusline = "%!v:lua.require('ui.statusline').render()"
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
  return ("%s%s%s"):format("%#"..hl.."#", text, "%*")
end

M.mode = function()
  -- local m = fn.mode()
  -- local hl = modes[m].hl
  local text, hl
  if vim.bo.filetype == "fzf" then
    text = "> fzf-lua"
    hl = modes["c"].hl
  elseif vim.fn.getcmdwintype() == ":" then
    text = "Cmdwin"
    hl = modes["c"].hl
  else
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
  text[#text + 1]= gitsigns.added and gitsigns.added ~= 0 and "+" .. gitsigns.added or nil
  text[#text + 1] = gitsigns.changed and gitsigns.changed ~= 0 and "~" .. gitsigns.changed or nil
  text[#text + 1] = gitsigns.removed and gitsigns.removed ~= 0 and "-" .. gitsigns.removed or nil
  local out = table.concat(text, " ")
  return with_hl(out, "StatusLine2", 1)
end

M.file = function()
  local fname = fn.expand("%")
  local ft = vim.bo.filetype
  if fname == "" then return with_hl(ft, "StatusLine") end

  local has_mini, mini_icons = pcall(require, "mini.icons")
  local icon, hl
  if not has_mini then
    icon, hl = " ", "Statusline"
  else
    icon, hl = mini_icons.get("filetype", ft)
  end

  fname = fname:match("^(%w+://).+") and fname or fn.fnamemodify(fname, ":~:.")
  fname = vim.bo.modified and fname .. " [+]" or not vim.bo.modifiable and fname .. " " or fname
  local out = with_hl(icon, hl, 0) .. "" .. with_hl(fname, "StatusLine")
  return with_hl(out, hl)
end

local diagnostic_signs = {
  { icon = "", hl = "DiagnosticError" },
  { icon = "", hl = "DiagnosticWarn" },
  { icon = "", hl = "DiagnosticInfo" },
  { icon = "󰌶", hl = "DiagnosticHint" },
}
local diagnostic_before_entering_insert = ""
M.diagnostics = function()
  if fn.mode() == "i" then return diagnostic_before_entering_insert end
  local count = vim.diagnostic.count(0)
  local signs = {}
  for i, c in pairs(count) do
    local text = diagnostic_signs[i].icon .. " " .. tostring(c)
    signs[#signs + 1] = with_hl(text, diagnostic_signs[i].hl, 0)
  end
  local out = table.concat(signs, " ")
  diagnostic_before_entering_insert = out
  return out
end

M.session = function()
  local out = require("session").this_session()
  return out and " ".. out .. " " or ""
end

M.filetype = function()
  local ft = vim.bo.filetype
  if ft == "" then return ft end

  local has_mini, mini_icons = pcall(require, "mini.icons")
  local icon, hl
  if not has_mini then
    icon, hl = " ", "Statusline2"
  else
    icon, hl = mini_icons.get("filetype", ft)
  end
  local out = "%#Statusline2#" .. " " .. with_hl(icon, hl) .. "" .. with_hl(ft, "StatusLine2")
  return out
end

M.lsp = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return "" end
  local names = vim
    .iter(ipairs(clients))
    :map(function(_, client)
      if client.server_capabilities.completionProvider ~= nil then
        return string.format("%s (%d)", client.name, client.id)
      end
    end)
    :totable()
  -- local out = table.concat(names, " ┃ ")
  local out = table.concat(names, "｜")
  return " " .. out .. " "
end

M.location = function()
  local m = fn.mode()
  local hl = modes[m].hl
  local out = with_hl("%2l:%-2v %p%%", hl)
  -- local out = with_hl(' %l|%L│%2v|%-2{virtcol("$") - 1} ', hl)
  return out
end

return M
