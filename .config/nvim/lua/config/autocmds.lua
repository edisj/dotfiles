local create_autocmd = vim.api.nvim_create_autocmd
local function create_augroup(name)
    vim.api.nvim_create_augroup(name, { clear = true })
end

create_autocmd({ "InsertLeave", "WinEnter", "BufEnter" }, { callback = function() vim.wo.cursorline = true end })
create_autocmd({ "InsertEnter", "WinLeave", "BufLeave", }, { callback = function() vim.wo.cursorline = false end })

-- using this because it's annoying that <c-c> doesnt trigger insertleave
create_autocmd("ModeChanged", {
    -- any mode -> n
    pattern = "*:n",
    callback = function() vim.wo.cursorline = true end,
    desc = "turn cursorline on when entering normal mode"
})

create_autocmd("TextYankPost", {
    desc = "Highlight when yanking (copying) text.",
    group = create_augroup("highlight-yank"),
    callback = function()
        vim.hl.on_yank({ timeout = 250 })
    end,
})

create_autocmd("BufWritePre", {
    group = create_augroup("auto-create-dir"),
    pattern = "*",
    command = [[%s/\s\+$//e]],
})

create_autocmd("BufReadPost", {
    desc = "Return to last edit position when opening files.",
    group = create_augroup("return-to-pos"),
    pattern = "*",
    command =
    [[if line("'\"") > 0 && line("'\"") <= line("$") && expand('%:t') != 'COMMIT_EDITMSG' | exe "normal! g`\"" | endif]],
})

create_autocmd("FileType", {
    desc = "Close these filetypes with q instead of :q",
    group = create_augroup("close-with-q"),
    pattern = {
        -- "help",
        "lspinfo",
        "notify",
        "tsplayground",
        "checkhealth",
    },
    callback = function(event)
        -- vim.bo[event.buf].buflisted = false
        vim.keymap.set({ "n", "v" }, "q",     "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})
