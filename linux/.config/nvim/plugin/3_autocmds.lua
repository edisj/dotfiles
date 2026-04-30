local create_autocmd = vim.api.nvim_create_autocmd
local function augroup(name)
    vim.api.nvim_create_augroup(name, { clear = true })
end

local on = Config.on

on("TextYankPost", function() vim.hl.on_yank({ timeout = 250 }) end, {
  desc = "Highlight when yanking (copying) text.",
  group = augroup("highlight-yank"),
})

-- NOTE: trying to do this with winleave/winenter alone seems buggy
on({ "WinEnter", "BufWinEnter", "WinClosed" }, function()
  vim.schedule(function()
    local current_win = vim.api.nvim_get_current_win()
    for _, win in ipairs(vim.api.nvim_list_wins()) do
      local buf = vim.api.nvim_win_get_buf(win)
      vim.wo[win].cursorline =
        (win == current_win)
        and (vim.bo[buf].buftype ~= "terminal")
        and (vim.bo[buf].buftype ~= "quickfix")
        and (vim.bo[buf].filetype ~= "blink-cmp-menu")
        -- and (vim.bo[buf].buftype ~= "nofile")
        or vim.wo[win].cursorline
    end
  end)
end, { group = augroup("auto-cursor-line") })

on({ "BufWinEnter", "FileType" }, function()
  vim.wo.winhl = "Normal:NormalSplit"
end, {
    desc = "set special splits to darker color",
    pattern = {
      "dap-view",
      "dap-view-term",
      "fugitive",
      "git",
      -- "quickfix",
      "vim",
    },
  })

on("CmdwinEnter", function()
  Config.nmap("<C-q>", ":q<CR>", { buffer = true })
  Config.nmap("<C-;>", ":q<CR>", { buffer = true })
  Config.nmap("<C-e>", "<Nop>", { buffer = true })
  vim.wo.number = false
  vim.wo.relativenumber = false
  vim.wo.signcolumn = "no"
  vim.wo.scrolloff = 1
  vim.opt_local.statuscolumn = ""
end
)

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

on("FileType", function(ev)
  vim.keymap.set({ "n", "v" }, "q", vim.cmd.close, { buffer = ev.buf, silent = true })
end, {
    desc = "Close these filetypes with q instead of :q",
    group = augroup("close-with-q"),
    pattern = {
      -- "help",
      "lspinfo",
      "qf",
      "notify",
      "tsplayground",
      "checkhealth",
    },
})

on("FileType", function(ev)
  local first_line = vim.api.nvim_buf_get_lines(ev.buf, 0, 1, false)[1]
  if #first_line == nil then return end
  if not vim.startswith(first_line, "#!") then return end

  if vim.endswith(first_line, "bash") then
    vim.bo.filetype = "bash"
  elseif vim.endswith(first_line, "zsh") then
    vim.bo.filetype = "zsh"
  end
end, { group = augroup("detect-shbang-ft"), pattern = "sh" })

-- ty justin
-- https://github.com/justinmk/config/blob/60a0e1b28e0ba49a629af3d38e255753046a76df/.config/nvim/init.lua#L682-L706
-- Never scroll past end-of-buffer. (Never show "filler lines".)
on("WinScrolled", function(ev)
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
