local api, fn = vim.api, vim.fn
local M = {}

local function is_active()
  return api.nvim_get_current_win() == tonumber(vim.g.actual_curwin)
end

local function reset_hl()
  return is_active() and "%#Statusline#" or "%#StatuslineNC#"
end

local function with_hl(text, hl)
  -- return hl and "%#" .. (is_active() and hl or "StatuslineNC") .. "#" .. text .. "%*" or text
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
  local name = fn.expand("%")
  if name == "" then return with_pad("[Scratch]") end

  local has_mini, mini_icons = pcall(require, "mini.icons")
  local icon, icon_hl
  if not has_mini then
    icon, icon_hl = " ", nil
  else
    icon, icon_hl = mini_icons.get("file", name)
  end

  name = name:match("^(%w+://).+") and name or fn.fnamemodify(name, ":~:.")
  name = vim.bo.modified and name .. "[+]" or not vim.bo.modifiable and name .. "   " or name
  return with_pad(with_hl(icon, icon_hl) .. " " .. name .. "%m")
end

M.searchcount = function()
  if not vim.o.hlsearch then return "" end
  local out = (" [%s/%s]"):format(fn.searchcount().current, fn.searchcount().total)
  return with_pad(out)
end
do
  -- local group = vim.api.nvim_create_augroup("clear-search-status", { clear = true })
  -- Config.on("CmdlineEnter", function()
  --   if not (fn.getcmdtype() == "/" or fn.getcmdtype() == "?") then return end
  --   vim.g.hl_suspended = true
  --   vim.cmd.redrawstatus()
  -- end, { group = group })
  -- Config.on("CmdlineLeave", function()
  --   if not (fn.getcmdtype() == "/" or fn.getcmdtype() == "?") then return end
  --   vim.g.hl_suspended = false
  --   vim.cmd.redrawstatus()
  -- end, { group = group })
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

M.filetype = function()
  local ft = vim.bo.filetype
  if ft == "" then return ft end

  -- local icon, hl = get_ft_icon("StatusLine")
  local icon, hl = require("mini.icons").get("filetype", ft)
  local out = with_hl(icon, hl) .. " " .. ft
  return with_pad(out)
end

local diagnostic_before_entering_insert = ""
M.diagnostics = function()
  if fn.mode() == "i" then return diagnostic_before_entering_insert end
  local out = vim.diagnostic.status()
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
        return ({ lua_ls = "LuaLS" })[client.name] or client.name
      end
    end)
    :totable()
  local attached_servers = table.concat(names, "｜")
  local icon = with_hl("  ", "Folder")
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

M.loc1 = function()
  return "%l:%v"
end

M.loc2 = function()
  return with_pad("%2l:%-2v")
end

M.loc3 = function()
  return with_pad('%l|%L│%2v|%-2{virtcol("$") - 1}')
end

M.loc4 = function()
  return with_pad("Ln %l, Col %-2v")
end

M.loc5 = function()
  return with_pad(" %P")
end

M.active = function()
  if _G.MiniPick then
    local state = _G.MiniPick.get_picker_state()
    if state and state.windows.main == tonumber(vim.g.actual_curwin) then
      vim.g.actual_curwin = state.windows.target
    end
  end
  local components
  local bt = vim.bo.buftype
  if bt == "" then
    components = {
      M.name(), M.loc2(), M.searchcount(),
      "%=",
      M.dap(),
      "%=",
      M.lsp(), M.git(), M.session(), M.loc5(),
    }
  elseif bt == "nofile" then
    components = { M.name(), "%=", M.filetype() }
  else
    components = { M.name(), "%=", M.filetype(), M.loc5() }
  end
  return table.concat(vim.tbl_filter(not_nil, components), "")
end

M.inactive = function()
  local components
  local bt = vim.bo.buftype
  if bt == "" then
    components = {
      M.name(), M.loc5(), M.loc2(),
      "%=",
      M.lsp(), M.git(), M.session(), with_pad(" %P"),
    }
  elseif bt == "nofile" then
    components = { M.name(), "%=", M.filetype() }
  else
    components = { M.name(), "%=", M.filetype(), M.loc5() }
  end
  return table.concat(vim.tbl_filter(not_nil, components), "")
end

M.restart = function()
  package.loaded["ui.statusline"] = nil
  _G.Statusline = M
  vim.go.statusline = "%{%v:lua.Statusline.active()%}"
end


M.restart()
return M
