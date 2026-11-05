local api = vim.api
local shared = require("ui.shared")

local M = {}

local cache = {}
local timer = assert(vim.uv.new_timer())
local DEBOUNCE_MS = 50
timer:start(DEBOUNCE_MS, DEBOUNCE_MS, function() cache = {} end)
on("ColorScheme", nil, function() cache = {} end)

local function signs(bufnr)
  if cache[bufnr] then return cache[bufnr] end

  local by_group = { git = {}, diag = {}, dap = {}, other = {} }
  local diag_priority = {}
  for _, mark in ipairs(api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, { type = "sign", details = true })) do
    local lnum = mark[2] + 1
    local details = mark[4]
    local text = details.sign_text
    local hl = details.sign_hl_group
    if text then
      local group = hl and (hl:match("GitSigns") and "git"
                         or hl:match("Diagnostic") and "diag"
                         or hl:match("Dap") and "dap")
                         or "other"
      if group ~= "diag" then
        by_group[group][lnum] = shared.with_hl(vim.trim(text), hl)
      elseif (diag_priority[lnum] or 0) <= details.priority then
        diag_priority[lnum] = details.priority
        by_group.diag[lnum] = shared.with_hl(vim.trim(text), hl)
      end
    end
  end

  cache[bufnr] = by_group
  return by_group
end

local function sign_chunk(group, fallback, enabled)
  return function()
    if enabled and not enabled() then return {} end
    return { signs(api.nvim_get_current_buf())[group][vim.v.lnum] or fallback }
  end
end

M.git  = { chunks = { sign_chunk("git", " ", function() return vim.g.Gitsigns == 1 end) } }
M.dap  = { chunks = { sign_chunk("dap", "") } }
M.sign = { chunks = { sign_chunk("other", "") } }
M.diag = { chunks = { sign_chunk("diag", "  ", function() return vim.g.Diag == 1 and vim.g.DiagCol == 1 end) } }

M.fold = { chunks = { "%C" } }

M.lnum = {
  chunks = {
    function()
      -- if vim.g.Nu ~= 1 and vim.g.Rnu ~= 1 then return {} end
      if not (vim.wo.number or vim.wo.relativenumber) then return {} end
      local relative = vim.wo.relativenumber and vim.v.relnum ~= 0
      return { { "%=" }, { tostring(relative and vim.v.relnum or vim.v.lnum) } }
    end,
  },
  padding = 1,
}

local default_stc = { "fold", "git", "diag", "lnum", "dap" }

function M.render()
  if vim.v.virtnum ~= 0 then return "" end
  return shared.render(vim.b.stc or default_stc, M)
end

local function notify(setting, on)
  local chunks = {
    { setting },
    { on and " enabled" or " disabled", on and "OkMsg" or "DiagnosticError" }
  }
  api.nvim_echo(chunks, false, {})
  api.nvim__redraw({ statuscolumn = true })
end

local function flip(v, msg)
  vim.g[v] = not vim.g[v] and 1 or (1 - vim.g[v])
  local on = vim.g[v] == 1
  if msg then notify(msg, on) end
  return on
end

map("<Leader>tg", function()
  flip("Gitsigns", "gitsigns")
  require("gitsigns").toggle_signs()
end, { desc = "gitsigns" })

map("<Leader>tD", function()
  local on = flip("Diag", "diagnostics")
  vim.diagnostic.enable(on)
end, { desc = "diagnostics" })

map("<Leader>td", function()
  flip("DiagCol", "diagnostic column")
end, { desc = "diagnostic column" })

map("<Leader>tn", function()
  local on = flip("Nu", "number")
  vim.o.nu = on
  if not vim.o.nu then vim.o.rnu = false end
end, { desc = "number" })

map("<Leader>tr", function()
  local on = flip("Rnu", "relative number")
  vim.o.rnu = on
  if vim.o.rnu then vim.o.nu = true end
end, { desc = "relative number" })

return M
