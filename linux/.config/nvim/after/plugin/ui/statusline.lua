local api, fn, fs = vim.api, vim.fn, vim.fs

local icons = require("icons")
local M = {}

local function is_active()
  return api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
end

local function reset_hl()
  return is_active() and "%#Statusline#" or "%#StatuslineNC#"
end

local function with_hl(text, hl)
  -- return hl and "%#" .. (is_active() and hl or hl) .. "#" .. text .. "%*" or text
  return hl and "%#" .. (is_active() and hl or "StatuslineNC") .. "#" .. text .. reset_hl() or text
end

local function with_pad(text, pad)
  local spaces = string.rep(" ", pad or 1)
  return spaces .. text .. spaces
end

local function not_nil(s)
  return not (s and s == "")
end

M.name = function()
  local name, bt = api.nvim_buf_get_name(0), vim.bo.buftype
  if name == "" then
    if bt == "nofile" then return " [Scratch] " end
    if bt == "" or bt == "nowrite" then return " [No Name] " end
  end

  -- just grab tail of uri
  if name:match("^(%w+://)") then return with_pad(name:match(".*//(.*)$")) end
  local ft = vim.bo.filetype
  if ft == "directory" then
    local dirname = fn.fnamemodify(fs.dirname(api.nvim_buf_get_name(0)), ":t") .. "/"
    return with_pad(with_hl(icons.lsp_kinds.Folder, "Folder")) .. dirname
  end

  name = fn.fnamemodify(name, ":t")
  local icon, icon_hl = icons.get("file", name)
  local modified, modifiable = "", ""
  if bt == "" then
    modified = vim.bo.modified and with_hl("[+]", "DiagnosticOk") or ""
    modifiable = vim.bo.modifiable and "" or with_hl("[-]", "DiagnosticError")
  end
  return (" %s%s%s%s "):format(with_hl(icon, icon_hl), name, modifiable, modified)
end

M.searchcount = function()
  if not vim.o.hlsearch or (MiniPick and MiniPick.is_picker_active()) then return "" end
  local out = (" [%s/%s]"):format(fn.searchcount().current, fn.searchcount().total)
  return with_pad(out)
end

M.dap = function()
  if not package.loaded["dap"] then return "" end
  local dap = require("dap")
  local status = dap.status()
  local type = dap.session() and dap.session().config.type
  return status == "" and status or type and ("dap[%s]: "):format(type) .. status or "dap: " .. status
end

-- M.session = function()
--   local out = require("session").this_session()
--   return out and " ".. out .. " " or ""
-- end

M.filetype = function()
  local ft, bt = vim.bo.filetype, vim.bo.buftype
  if bt == "terminal" then
    return with_pad(with_hl(icons.misc.terminal, "DiagnosticError") .. " " ..bt)
  elseif ft == "" then
    return ft
  else
    return with_pad(M.icon("filetype", ft) .. " " .. ft)
  end
end

M.icon = function(category, name)
  if not name then
    name, category = category, nil
  end
  local icon, icon_hl, default = icons.get(category, name)
  return with_hl(vim.trim(icon), not default and icon_hl or nil)
end

local diagnostic_before_entering_insert = ""
local diag_map = {
  { icon = icons.diagnostic2.error, hl = "DiagnosticError" },
  { icon = icons.diagnostic2.warn, hl = "DiagnosticWarn" },
  { icon = icons.diagnostic2.info, hl = "DiagnosticInfo" },
  { icon = icons.diagnostic2.hint, hl = "DiagnosticHint" },
}
M.diagnostics = function()
  if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then return "" end
  if fn.mode() == "i" then return diagnostic_before_entering_insert end
  local counts = vim.diagnostic.count(0)
  local items = {}
  for i = 1,3 do
    local icon = diag_map[i].icon
    local count = counts[i] == nil and 0 or counts[i]
    local hl = count == 0 and "LineNr" or diag_map[i].hl
    items[#items + 1] = with_hl(icon .. " " .. count, hl)
  end
  local out = with_pad(table.concat(items, " "))
  diagnostic_before_entering_insert = out
  return out
end

M.lsp = function()
  local clients = vim.lsp.get_clients({ bufnr = 0 })
  if #clients == 0 then return M.filetype() end
  local names = vim
    .iter(ipairs(clients))
    :map(function(_, client)
      if client.server_capabilities.completionProvider ~= nil then
        -- return ({ lua_ls = "LuaLS" })[client.name] or client.name
        return client.name
      end
    end)
    :totable()
  local attached_servers = table.concat(names, "｜")
  local icon = with_hl(" ", "Folder")
  local diagnostics = M.diagnostics()
  if diagnostics ~= "" then diagnostics = "(" .. diagnostics .. ")" end
  local out = icon .. attached_servers .. diagnostics
  return with_pad(out)
end

M.git = function()
  local gitsigns = vim.b.gitsigns_status_dict
  if not gitsigns then return "" end
  local branch = with_hl(" ", "DiagnosticError") .. gitsigns.head
  local changes = {}
  changes[#changes + 1] = gitsigns.added and gitsigns.added ~= 0 and "+" .. gitsigns.added or nil
  changes[#changes + 1] = gitsigns.removed and gitsigns.removed ~= 0 and "-" .. gitsigns.removed or nil
  changes[#changes + 1] = gitsigns.changed and gitsigns.changed ~= 0 and "~" .. gitsigns.changed or nil
  local text = table.concat(changes, " ")
  if not_nil(text) then text = "(" .. text .. ")" end
  return with_pad(branch .. text)
end

M.loc2 = function()
  return with_hl(with_pad("%2l:%-2v"), "LineNr")
end

M.loc5 = function()
  return with_pad(with_hl(" ", "Operator") .. "%P")
end

local mode_hlmap = {
  n = "Function",
  i = "String",
  v = "Keyword",
  V = "Keyword",
  c = "DiagnosticOk",
}
M.border = function(char)
  return with_hl(char, mode_hlmap[fn.mode()])
end

local is_sidebar = function(ft)
  local fts = {
    "NvimTree",
    "dap-view"
  }
  return vim.tbl_contains(fts, ft)
end

M.render = function()
  if _G.MiniPick then
    local state = _G.MiniPick.get_picker_state()
    if state and state.windows.main == tonumber(vim.g.actual_curwin) then
      vim.g.actual_curwin = state.windows.target
    end
  end

  local components = { M.border("▌") }
  local bt, ft = vim.bo.buftype, vim.bo.filetype
  if is_sidebar(ft) then
    vim.list_extend(components, {
      with_pad(M.icon("filetype", ft) .. ft), "%="
    })
  else
    vim.list_extend(components, {
      M.name(), M.loc2(), M.searchcount(),
      "%=",
      M.dap(),
      "%=",
      M.diagnostics(), M.filetype(), M.loc5(),
    })
  end
  vim.list_extend(components, { M.border("▐") })

  return table.concat(vim.tbl_filter(not_nil, components), "")
end

_G.Stl = M.render
vim.go.statusline = "%{%v:lua.Stl()%}"

return M
