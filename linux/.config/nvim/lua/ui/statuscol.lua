local api = vim.api

-- saw this cache idea used in https://github.com/folke/snacks.nvim/blob/main/lua/snacks/statuscolumn.lua#L322
-- the idea is that the statuscolumn is only computed when the cache is empty,
-- but the timer wipes the cache every `DEBOUNCE` ms so its effectively a throttle
local cache = {}
local signs_cache = {}
local dapPC = {}
local DEBOUNCE = 20 -- ms
local timer = assert(vim.uv.new_timer(), "how did timer fail???")
timer:start(DEBOUNCE, DEBOUNCE, function()
  cache = {}
  signs_cache = {}
  dapPC = {}
end)

local M = {}

M.render = function()
  -- NOTE: have to use something like vim.g.statusline_winid here otherwise
  -- all open windows update with the currently focused buffer
  local winid = vim.g.statusline_winid
  local bufnr = api.nvim_win_get_buf(winid)
  local key = ("%d:%d:%d"):format(winid, bufnr, vim.v.lnum)
  if cache[key] then return cache[key] end

  -- signs_cache[bufnr] = M.get_signs(bufnr)
  local statuscolumn = table.concat({ M.signs(bufnr), M.lnum(bufnr) }, "")
  cache[key] = statuscolumn
  return statuscolumn
end

local function with_hl(text, hl)
  return hl and "%#" .. hl .. "#" .. text or text
end

local function is_sign(extmark, sign)
  local details = extmark[4]
  return details.sign_name and details.sign_name:match(sign) or details.sign_hl_group:match(sign)
end

local function extmark_to_sign(extmark)
  local details = extmark[4]
  return {
    lnum = extmark[2] + 1,
    text = details.sign_text,
    hl = details.sign_hl_group,
  }
end

local function fill_signs_cache(bufnr)
  local buf_signs = {}
  local extmarks = api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, { details = true, type = "sign" })
  for _, extmark in ipairs(extmarks) do
    if is_sign(extmark, "DapStopped") then
      local lnum = extmark[2] + 1
      local sign = extmark_to_sign(extmark)
      sign.bufnr = bufnr
      dapPC = sign
    elseif is_sign(extmark, "GitSigns") or is_sign(extmark, "Dap") then
      local lnum = extmark[2] + 1
      buf_signs[lnum] = extmark_to_sign(extmark)
    end
  end
  signs_cache[bufnr] = buf_signs
  return buf_signs
end

M.signs = function(bufnr)
  if not signs_cache[bufnr] then
    fill_signs_cache(bufnr)
  end
  local line_sign = signs_cache[bufnr][vim.v.lnum]
  return with_hl(line_sign and line_sign.text or "", line_sign and line_sign.hl) .. "%*"
end

M.lnum = function(bufnr)
  if not (vim.wo.relativenumber or vim.wo.number) then return "" end
  local width = #tostring(api.nvim_buf_line_count(bufnr))
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum
  local num =
    (vim.wo.relativenumber and relnum ~= 0 and relnum)
    or (vim.wo.number and lnum)
  local text = ("%" .. width .. "d"):format(num)
  return text .. ""
end

M.dapPC = function(bufnr)
  -- local pc = dapPC and dapPC[bufnr][vim.v.lnum]
  local lnum = vim.v.lnum
  local out = dapPC.text
    and bufnr == dapPC.bufnr
    and lnum == dapPC.lnum
    and with_hl("", "Normal") ..with_hl(dapPC.text, dapPC.hl) or "  "
  -- P(dapPC)
  -- local text = pcand vim.trim(pc.text) or " "
  -- local hl = pc and pc.hl or "%*"
  -- P(text)
  return out
end

M.restart = function()
  package.loaded["ui.statuscol"] = nil
  vim.o.statuscolumn = "%!v:lua.require('ui.statuscol').render()"
end
M.restart()

return M
