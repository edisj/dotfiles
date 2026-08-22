local augroup = vim.api.nvim_create_augroup("config.auto-cursorline", { clear = true })
on({ "WinEnter", "InsertLeave" }, augroup, function()
  local win = vim.api.nvim_get_current_win()
  -- Schedule to preserve the correct order of events when synchronously
  -- changing between windows a bunch of times (like in `<c-w>t`)
  vim.schedule(function()
    if not vim.api.nvim_win_is_valid(win) then return end
    if not vim.w[win].cached_cursorline then return end
    vim.wo[win].cursorline = vim.w[win].cached_cursorline
    vim.w[win].cached_cursorline = nil
  end)
end)
on({ "WinLeave", "InsertEnter" }, augroup, function()
  local win = vim.api.nvim_get_current_win()
  -- Copying the current window options seems to be done after `WinLeave`
  -- when opening a new tab. Delay setting `cursorline` to `false` until
  -- after the options are copied
  vim.schedule(function()
    if not vim.api.nvim_win_is_valid(win) then return end
    vim.w[win].cached_cursorline = vim.wo[win].cursorline
    vim.wo[win].cursorline = false
  end)
end)
