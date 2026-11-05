on("TextYankPost", "highlight-yank", { desc = "Highlight when yanking (copying) text." }, function()
  if vim.hl.hl_op then
    vim.hl.hl_op({ timeout = 250 })
  else
    vim.hl.on_yank({ timeout = 250 })
  end
end)

local dirty = true
on({
  "WinEnter", "WinLeave", "WinNew", "WinClosed",
  "TabEnter", "InsertEnter", "InsertLeave", "BufEnter",
}, "config.auto-cursorline", function() dirty = true end)
on("SafeState", "config.auto-cursorline", function()
  if not dirty then return end
  dirty = false
  local cur = vim.api.nvim_get_current_win()
  local insert = vim.startswith(vim.fn.mode(), "i")
  for _, win in ipairs(vim.api.nvim_tabpage_list_wins(0)) do
    -- local buf = vim.api.nvim_win_get_buf(win)
    -- vim.wo[win].cursorline = vim.bo[buf].filetype == "NvimTree" or win == cur and not insert
    if vim.api.nvim_win_get_config(win).relative == "" then
      local buf = vim.api.nvim_win_get_buf(win)
      vim.wo[win].cursorline = vim.bo[buf].filetype == "NvimTree" or win == cur and not insert
    end
  end
end)

vim.api.nvim_create_autocmd("ModeChanged", {
  pattern = { "*:[vV\x16]*", "[vV\x16]*:*" },
  callback = function()
    vim.wo.cursorlineopt = vim.fn.mode():match("^[vV\x16]") and "line" or "both"
  end,
})

on("CmdwinEnter", nil, function(ev)
  map("<C-e>", "<Nop>", { buffer = true })
  map("<S-CR>", "<CR>q:", { buffer = ev.buf, mode = { "n", "i" } })
end)

on("BufWritePre", "auto-create-dir", { pattern = "*" }, [[%s/\s\+$//e]])

on("BufReadPost", nil, function(args)
  local valid_line = vim.fn.line([['"]]) >= 1 and vim.fn.line([['"]]) < vim.fn.line('$')
  local not_commit = vim.b[args.buf].filetype ~= 'commit'
  if valid_line and not_commit then vim.cmd([[normal! g`"]]) end
end)

on("FileType", "detect-shebang-ft", { pattern = "sh" }, function(ev)
  local first_line = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1]
  if #first_line == nil then return end
  if not vim.startswith(first_line, "#!") then return end
  if vim.endswith(first_line, "bash") then
    vim.bo.filetype = "bash"
  elseif vim.endswith(first_line, "zsh") then
    vim.bo.filetype = "zsh"
  end
end)

-- ty justin
-- https://github.com/justinmk/config/blob/60a0e1b28e0ba49a629af3d38e255753046a76df/.config/nvim/init.lua#L682-L706
-- Never scroll past end-of-buffer. (Never show "filler lines".)
on("WinScrolled", nil, function(ev)
  local win = assert(tonumber(ev.match))
  if vim.wo[win].scrollbind or vim.bo[vim.api.nvim_win_get_buf(win)].filetype == "markdown" then
    -- XXX: Disabled for "scrollbind" windows because it sometimes makes them out of sync.
    return
  end
  local buf = vim.api.nvim_win_get_buf(win)
  local line_count = vim.api.nvim_buf_line_count(buf)
  local win_height = math.min(vim.api.nvim_win_get_height(win), line_count)

  -- top line number + window height should be <= line_count
  local last_visible_line = vim.fn.line("w0", win) + win_height - 1
  local out_of_buf_lines = last_visible_line - line_count

  if out_of_buf_lines > 0 then
    vim._with({ win=win }, function()
      local extra = vim.wo.winbar == "" and 1 or 2
      vim.fn.winrestview({
        topline = math.max(1, line_count - win_height + extra),
      })
      -- https://github.com/neovim/neovim/issues/35633#issuecomment-3256274806
      vim.api.nvim_feedkeys(vim.keycode("<Ignore>"), "ni", false)
    end)
  end
end)
