local fn = vim.fn
local api = vim.api

local M = {}

M.on_click_fname = function(minwid, _, _, _)
  -- NOTE: using arg passed to click handler to get winid instead of
  -- vim.api.nvim_get_current_win() since that uses the cursor window,
  -- not the clicked window
  local winid = minwid

  local fname_win = Win.float({
    focusable = false,
    enter = false,
    position = "topleft",
    relative = "win",
    win = winid,
    width = 15,
    height = 2,
    style = "minimal",
    bo = {
      bufhidden = "wipe",
    },
  })

  local TIMEOUT = 500
  fname_win:create_autocmd("CursorMoved", function(win, _)
    vim.defer_fn(function() win:close() end, TIMEOUT)
  end, { once = true })

  local bufnr = api.nvim_get_current_buf()
  local lines = {
    ("winid: %d"):format(winid),
    ("bufnr: %d"):format(bufnr),
  }

  fname_win
    :open()
    :set_lines(lines)

  local ns = api.nvim_create_namespace("winbar-fname-popup")
  for i, line in ipairs(lines) do
    local start = line:find("%d+")
    api.nvim_buf_set_extmark(fname_win.bufnr, ns, i-1, start-1, {
      end_col = #line,
      hl_group = "Number",
    })
  end
end

local function with_click(component, f, winid)
  return "%" .. (winid or 0) .. "@v:lua.require'ui.winbar'." .. f .. "@" .. component .. "%X"
end

local function with_hl(text, hl)
  return "%#" .. hl .. "#" .. text
end

M.render = function()
  return table.concat({
    with_click(M.fname(), "on_click_fname", api.nvim_get_current_win()),
    M.diagnostics(),
    "%*"
  })
end

M.fname = function()
  local fname = fn.expand("%")
  local ft = vim.bo.filetype
  if fname == "" then return "[No Name]" end
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
