local create_autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
    vim.api.nvim_create_augroup(name, { clear = true })
end

---See require("vim._core.util").nvim_on
---@param events vim.api.keyset.events|vim.api.keyset.events[] Event(s) to watch. See |autocmd-events|.
---@param group string|integer? Group name or id, or `nil`.
---@param opts_or_fn vim.api.keyset.create_autocmd Options.
---@param fn string|fun(ev: vim.api.keyset.create_autocmd.callback_args): boolean? Event handler.
---@return integer # Autocmd id (see |nvim_create_autocmd()|).
---@overload fun(events: vim.api.keyset.events|vim.api.keyset.events[], group: string|integer?, fn: fun(ev: vim.api.keyset.create_autocmd.callback_args): boolean?): integer
local on = function(events, group, opts_or_fn, fn)
  local opts ---@type vim.api.keyset.create_autocmd
  if type(opts_or_fn) == "table"  then
    opts = opts_or_fn
  else
    fn, opts = opts_or_fn, {}
  end
  if type(group) == "string" then
    opts.group = vim.api.nvim_create_augroup(group --[[@as string]], { clear = false })
  else
    opts.group = group
  end
  opts[type(fn) == "function" and "callback" or "command"] = fn
  return vim.api.nvim_create_autocmd(events, opts)
end
_G.on = on

-- on("TextYankPost", "highlight-yank", { desc = "Highlight when yanking (copying) text." }, function()
--   if vim.hl.hl_op then
--     vim.hl.hl_op({ timeout = 250 })
--   else
--     vim.hl.on_yank({ timeout = 250 })
--   end
-- end)

-- local auto_cursorline_group = augroup("auto-cursorline")
-- on({"InsertLeave", "WinEnter" }, function()
--   vim.schedule(function()
--     if vim.w.auto_cursorline then
--       vim.wo.cursorline = true
--       vim.w.auto_cursorline = nil
--     end
--   end)
-- end, { group = auto_cursorline_group })
-- on({ "InsertEnter", "WinLeave" }, function()
--   vim.schedule(function()
--     if vim.wo.cursorline then
--       vim.w.auto_cursorline = true
--       vim.wo.cursorline = false
--     end
--   end)
-- end, { group = auto_cursorline_group })

on("CmdwinEnter", nil, function(ev)
  map("<C-q>", ":q<CR>", { buffer = true })
  map("<C-;>", ":q<CR>", { buffer = true })
  map("<C-e>", "<Nop>", { buffer = true })
  map("<S-CR>", "<CR>q:", { buffer = ev.buf, mode = { "n", "i" } })
end)

create_autocmd("BufWritePre", {
  group = augroup("auto-create-dir"),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

create_autocmd("BufReadPost", {
  desc = "Return to last edit position when opening files.",
  group = augroup("return-to-pos"),
  pattern = "*",
  command =
    [[if line("'\"") > 0 && line("'\"") <= line("$") && expand('%:t') != 'COMMIT_EDITMSG' | exe "normal! g`\"" | endif]],
})

on("FileType", augroup("detect-shebang-ft"), { pattern = "sh" }, function(ev)
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
  if vim.wo[win].scrollbind then
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
