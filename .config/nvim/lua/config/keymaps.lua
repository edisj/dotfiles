local function map(modes, lhs, rhs, opts)
    modes = type(modes) == "string" and vim.split(modes, "") or modes
    opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
    vim.keymap.set(modes, lhs, rhs, opts)
end


map("n", "<C-q>", "q:")
vim.api.nvim_create_autocmd("CmdwinEnter", {
    callback = function()
        vim.keymap.set("n", "<C-q>", ":q<CR>", { buffer = true })
        vim.wo.number = false
        vim.wo.relativenumber = false
        vim.wo.signcolumn = "no"
        vim.opt_local.statuscolumn = " "
    end,
})

map("i", "<C-j>", function()
    return vim.fn.pumvisible() == 1 and "<C-n>" or "<Down>"
end, { expr = true })
map("i", "<C-k>", function()
    return vim.fn.pumvisible() == 1 and "<C-p>" or "<Up>"
end, { expr = true })
map("c", "<C-j>", function()
    return vim.fn.wildmenumode() == 1 and "<C-n>" or "<C-j>"
end, { expr = true })
map("c", "<C-k>", function()
  return vim.fn.wildmenumode() == 1 and "<C-p>" or "<C-k>"
end, { expr = true })

map("x", "v", "<S-v>")
map("n", "<S-v>", "<C-v>")

-- map("i", "<C-h>", "<C-Left>")
-- map("i", "<C-l>", "<C-Right>")
map("ic", "<C-h>", "<C-Left>", { silent = false })
map("ic", "<C-l>", "<C-Right>", { silent = false })

map("i", "<M-h>", "<Left>")
map("i", "<M-l>", "<Right>")
map("i", "<M-k>", function() vim.cmd("normal! gkzz") end )
map("i", "<M-j>", function() vim.cmd("normal! gjzz") end )

map("n", "<C-_>", ":nohlsearch<cr>")
map("o", "o", "a", { desc = "outside" })
map("c", "<M-q>", "<C-c>")
map("xoc", "<M-a>", "<esc>")
map("xoc", "<M-s>", "<esc>")
map("i", "<M-a>", "<esc>l")
map("n", "<M-a>", "<nop>")
map("c", "<M-a>", "<c-c>")
map("i", "<M-s>", "<esc>l")

map("nox", "gg", "G", { desc = "goto end of page" })
map("nox", "G", "gg", { desc = "goto beginning of page" })
map("nox", "<S-h>", "^", { desc = "goto beginning of line" })
map("nox", "<S-l>", "g_", { desc = "goto end of line" })

map("n", "<C-d>", function()
    vim.diagnostic.jump{ count = 1, float = true }
end, { desc = "next diagnostic" })

map("n", "<C-o>", "<C-i>")
map("n", "<C-i>", "<C-o>")

map("nx", "q", "b", { desc = "Previous word" })
map("nx", "Q", "B", { desc = "Previous WORD" })

map("x", "p", '"_dP', { desc = "Paste Over Visual without Yanking" })
map("n", "x", '"_x', { desc = "Delete Char without Yanking" })
map("n", "X", '"_X', { desc = "Delete Char without Yanking" })

-- map("nixo", "<C-c>",     "<Esc>",           { desc = "Escape" })
map("n", "<C-s>",     "<cmd>update<cr><esc>", { desc = "Save file" })
map("i", "<C-s>",     "<cmd>update<cr><esc>", { desc = "Save file" })

map("n", "<M-j>", "jzz")
map("n", "<M-k>", "kzz")
map("n", "<C-M-j>", "<C-d>", { desc = "Scroll half page down" })
map("n", "<C-M-k>", "<C-u>", { desc = "Scroll half page up" })

map("x", "J", ":m '>+1<CR>gv=gv", { desc = "Move highlight down" })
map("x", "K", ":m '<-2<CR>gv=gv", { desc = "Move highlight up" })
map("x", "<", "<gv", { desc = "Indent left and reselect" })
map("x", ">", ">gv", { desc = "Indent right and reselect" })

-- map("n", "<leader>x", "<cmd>.lua<CR>", "Execute the current line")
map("n", "<leader>%",     ":update<CR>:source %<CR>", { desc =  "Execute the current file" })

map("n", "<C-j>", "<C-w>j")
map("n", "<C-k>", "<C-w>k")
map("n", "<C-h>", "<C-w>h")
map("n", "<C-l>", "<C-w>l")
map("n", "<C-Left>",  "<C-w>4<")
map("n", "<C-Right>", "<C-w>4>")
map("n", "<C-Up>",    "<Cmd>resize +2<CR>")
map("n", "<C-Down>",  "<Cmd>resize -2<CR>")

map("t", "<M-a>", "<c-\\><c-n>", { desc = "Escape in terminal mode" })
map("t", "<M-s>", "<c-\\><c-n>", { desc = "Escape in terminal mode" })

map("n", "<leader>vd", function()
    if vim.diagnostic.is_enabled() then
        return vim.diagnostic.enable(false)
    end
    return vim.diagnostic.enable(true)
end, { desc = "vim diagnostic toggle" })

map("n", "<leader>L", "<cmd>Lazy<CR>", { desc = "Open Lazy" })

