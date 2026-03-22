local api = vim.api

-- saw this cache idea used in https://github.com/folke/snacks.nvim/blob/main/lua/snacks/statuscolumn.lua#L322
-- the idea is that the statuscolumn is only computed when the cache is empty,
-- but the timer wipes the cache every `DEBOUNCE` ms so its effectively a throttle
local cache = {}
local signs_cache = {}
local DEBOUNCE = 25 -- ms
local timer = assert(vim.uv.new_timer(), "how did timer fail???")
timer:start(DEBOUNCE, DEBOUNCE, function()
  cache = {}
  signs_cache = {}
  -- gitsigns_cache = {}
  -- diagnostics_cache = {}
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
  local statuscolumn = table.concat { M.gitsigns(bufnr), M.lnum(bufnr), M.margin(1) }
  cache[key] = statuscolumn
  return statuscolumn
end

M.restart = function()
  package.loaded["ui.statuscol"] = nil
  vim.go.statuscolumn = "%!v:lua.require('ui.statuscol').render()"
end
M.restart()

local function with_hl(text, hl)
  return hl and "%#" .. hl .. "#" .. text or text
end

local function is_gitsign(extmark)
  local details = extmark[4]
  return details.sign_hl_group:match("GitSigns")
end

local function extmark_to_sign(extmark)
  local details = extmark[4]
  return {
    lnum = extmark[2] + 1,
    text = details.sign_text,
    hl = details.sign_hl_group,
  }
end

M.gitsigns = function(bufnr)
  local buf_signs = signs_cache[bufnr]
  if not buf_signs then
    buf_signs = {}
    local extmarks = api.nvim_buf_get_extmarks(bufnr, -1, 0, -1, { details = true, type = "sign" })
    for _, extmark in ipairs(extmarks) do
      if is_gitsign(extmark) then
        local lnum = extmark[2] + 1
        buf_signs[lnum] = extmark_to_sign(extmark)
      end
    end
    signs_cache[bufnr] = buf_signs
  end

  local line_sign = signs_cache[bufnr][vim.v.lnum]
  return with_hl(line_sign and line_sign.text or "  ", line_sign and line_sign.hl) .. "%*"
end

M.lnum = function(bufnr)
  local width = #tostring(api.nvim_buf_line_count(bufnr))
  local lnum = vim.v.lnum
  local relnum = vim.v.relnum
  local num = (vim.wo.relativenumber and relnum ~= 0 and relnum) or lnum
  local text = ("%" .. width .. "d"):format(num)
  -- local border = "▕"
  local border = "🮇"
  -- local border = "🮈"
  return text .. with_hl(border, "StatusColBorder")
end

-- FIXME: update margin outside of cache cycle so cursorline doesn't lag
M.margin = function(amount)
  local text = string.rep(" ", amount or 1)
  -- local hl = fn.line(".") == vim.v.lnum and "CursorLine" or "Normal"
  local hl = vim.v.relnum == 0 and "CursorLine" or "Normal"
  return with_hl(text, hl)
end

return M
