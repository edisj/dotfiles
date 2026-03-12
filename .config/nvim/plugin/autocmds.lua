vim.print "autocmds"

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

local exclude = {
    qf = true,
    nofile = true,
}
create_autocmd("ModeChanged", {
    pattern = "*:[vV\x16]*",
    group = create_augroup("relnum on visual mode"),
    callback = function(ev)
        if exclude[vim.bo[ev.buf].filetype] then return end
        vim.wo.relativenumber = true
    end,
    desc = "turn on relative numbers when entering visual mode",
})
create_autocmd("ModeChanged", {
    pattern = "[vV\x16]*:*[^vV\x16]",
    group = create_augroup("relnum on visual mode"),
    callback = function(ev)
        if exclude[vim.bo[ev.buf].filetype] then return end
        vim.wo.relativenumber = false
    end,
    desc = "turn off relative numbers when leaving visual mode",
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
        "qf",
        "notify",
        "tsplayground",
        "checkhealth",
    },
    callback = function(event)
        -- vim.bo[event.buf].buflisted = false
        vim.keymap.set({ "n", "v" }, "q",     "<cmd>close<cr>", { buffer = event.buf, silent = true })
    end,
})


create_autocmd("FileType", {
    group = create_augroup("detect-shebang-ft"),
    pattern = "sh",
    callback = function(args)
        local first_line = vim.api.nvim_buf_get_lines(args.buf, 0, 1, false)[1]
        if #first_line == nil then return end
        if not vim.startswith(first_line, "#!") then return end

        if vim.endswith(first_line, "bash") then
            vim.bo.filetype = "bash"
        elseif vim.endswith(first_line, "zsh") then
            vim.bo.filetype = "zsh"
        end

    end,
})
