local api = vim.api
local M = {}

local STC = "%{%v:lua.Stc()%}"

local cache = { git = {}, diag = {}, dap = {}, extmarks = {} }
local DEBOUNCE_MS = 100
local timer = assert(vim.uv.new_timer())
timer:start(DEBOUNCE_MS, DEBOUNCE_MS, function()
  cache.git = {}
  cache.diag = {}
  cache.dap = {}
  cache.extmarks = {}
end)

local function with_hl(text, hl)
  return (hl and "%#" .. hl .. "#" .. text or text) .. "%*"
end

local recompute_cache = function(bufnr)
  if not cache.extmarks[bufnr] then
    local extmarks = api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, { type = "sign", details = true })
    local seen = {}
    cache.extmarks[bufnr] = vim
      .iter(ipairs(extmarks))
      :map(function(_, mark)
        local lnum, details = mark[2] + 1, mark[4]
        if details.sign_hl_group and details.sign_hl_group:match("Diagnostic") then
          if seen[lnum] and seen[lnum] > details.priority then
            return
          end
          seen[lnum] = details.priority
        end
        return mark
      end)
      :totable()
  end

  cache.git[bufnr] = {}
  cache.diag[bufnr] = {}
  cache.dap[bufnr] = {}
  for _, mark in ipairs(cache.extmarks[bufnr]) do
    local lnum, details = mark[2] + 1, mark[4]
    local text, hl = details.sign_text, details.sign_hl_group
    if hl and hl:match("GitSigns") then
      cache.git[bufnr][lnum] = with_hl(vim.trim(text), hl)
    elseif hl and hl:match("Diagnostic") then
      cache.diag[bufnr][lnum] = with_hl(text, hl)
    elseif hl and hl:match("Dap") then
      cache.dap[bufnr][lnum] = with_hl(text, hl)
    end
  end
end

on("BufWinEnter", nil, function()
  local w = api.nvim_get_current_win()
  vim.wo[w].statuscolumn = STC
end)

M.render = function()
  local bufnr, lnum = api.nvim_get_current_buf(), vim.v.lnum
  return M.git(bufnr, lnum) .. M.dap(bufnr, lnum) .. M.diag(bufnr, lnum) .. M.lnum() .. M.pad()
end

M.pad = function()
  return not (vim.o.nu or vim.o.rnu) and  "" or "  "
end

M.lnum = function()
  if not (vim.o.nu or vim.o.rnu) then return "" end
  local nu, rnu = vim.v.lnum, vim.v.relnum
  if vim.o.rnu then
    return rnu == 0 and "%=" .. nu .. " " or " %=" .. rnu
  elseif vim.o.nu then
    return "%l"
  end
end

M.git = function(bufnr, lnum)
  if not cache.git[bufnr] then recompute_cache(bufnr) end
  return cache.git[bufnr][lnum] or ""
end

M.diag = function(bufnr, lnum)
  if not vim.diagnostic.is_enabled() then return "" end
  if not cache.diag[bufnr] then recompute_cache(bufnr) end
  return cache.diag[bufnr][lnum] or "  "
end

M.dap = function(bufnr, lnum)
  if not cache.dap[bufnr] then recompute_cache(bufnr) end
  return cache.dap[bufnr][lnum] or ""
end

_G.Stc = M.render
vim.o.statuscolumn = STC
