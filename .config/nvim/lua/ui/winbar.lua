local fn = vim.fn
local api = vim.api

local M = {}

M.render = function()
  return table.concat { M.fname(), M.diagnostics(), "%*" }
end

local function with_hl(text, hl)
  return "%#" .. hl .. "#" .. text
end

M.fname = function()
  local fname = fn.expand("%")
  local ft = vim.bo.filetype
  if fname == "" then return ft end
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
  local has_mini, mini_icons = pcall(require, "mini.icons")
  local icon = has_mini and mini_icons.get("filetype", ft) or " "
  local out = with_hl(" " .. icon .. " " .. fname .. " ", hl)
  return out
end

local diagnostics_before_entering_insert = ""
M.diagnostics = function()
  if fn.mode() == "i" then return diagnostics_before_entering_insert end
  local count = vim.diagnostic.count(0)
  local signs = {}
  signs[#signs + 1] = count[1] and with_hl("", "DiagnosticError")
  signs[#signs + 1] = count[2] and with_hl("", "DiagnosticWarn")
  local out = with_hl("  ", "%*") .. table.concat(signs, "  ")
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
