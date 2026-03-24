local map = Config.map
local nmap = function(...) map("n", ...) end
local imap = function(...) map("i", ...) end
local xmap = function(...) map("x", ...) end
local cmap = function(...) map("c", ...) end
local inmap = function(...) map("in", ...) end
local icmap = function(...) map("ic", ...) end
-- local coxmap = function(...) map("cox", ...) end


local nmap_leader = function(lhs, ...) map("n", "<leader>" .. lhs, ...) end

local function edit(file)
  local path = ("%s/plugin/%s"):format(vim.fn.stdpath("config"), file)
  return function() vim.cmd.edit(path) end
end

nmap_leader("eo", edit("10_options.lua"),  { desc = "10_options.lua" })
nmap_leader("ek", edit("20_keymaps.lua"),  { desc = "20_keymaps.lua" })
nmap_leader("ea", edit("30_autocmds.lua"), { desc = "30_autocmds.lua" })
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>",  { desc = "init.lua" })

nmap("<C-f>", function() FzfLua.files() end)
nmap_leader("/",  function() FzfLua.live_grep() end,  { desc = "live grep" })
nmap_leader("ff", function() FzfLua.builtin() end,    { desc = "builtin" })
nmap_leader("fb", function() FzfLua.buffers() end,    { desc = "buffers" })
nmap_leader("ft", function() FzfLua.filetypes() end,  { desc = "filetypes" })
nmap_leader("fa", function() FzfLua.args() end,       { desc = "arglist" })
nmap_leader("fA", function() FzfLua.autocmds() end,   { desc = "autocmds" })
nmap_leader("fk", function() FzfLua.keymaps() end,    { desc = "keymaps" })
nmap_leader("fh", function() FzfLua.helptags() end,   { desc = "helptags" })
nmap_leader("fH", function() FzfLua.highlights() end, { desc = "highlights" })
nmap_leader("fc", function() FzfLua.files{ prompt = false, cwd = vim.fn.stdpath("config") } end, { desc = "config" })
nmap_leader("fp", function()
  local packroot = vim.fn.stdpath("data") .. "/site/pack/core/opt"
  FzfLua.files({
    prompt = "opt/**/lua/",
    cwd = packroot,
    cwd_prompt_shorten_len = 5,
    fd_opts = [[-e lua -p '.*/lua/']],
  })
end, { desc = "pack" })

nmap("gd", function() vim.lsp.buf.definition() end)
nmap("gD", function() vim.lsp.buf.declaration() end)
nmap_leader("la", function() vim.lsp.buf.code_action() end,     { desc = "code action" })
nmap_leader("ld", function() vim.lsp.buf.definition() end,      { desc = "definition" })
nmap_leader("lD", function() vim.lsp.buf.declaration() end,     { desc = "declaration" })
nmap_leader("li", function() vim.lsp.buf.implementation() end,  { desc = "declaration" })
nmap_leader("ls", function() vim.lsp.buf.document_symbol() end, { desc = "symbols" })
nmap_leader("lr", function() vim.lsp.buf.rename() end,          { desc = "rename" })
nmap_leader("lK", function() vim.diagnostic.open_float() end,   { desc = "diagnostic" })

nmap("<S-v>", "<C-v>")
xmap("v", "<S-v>")

-- map("i", "<C-h>", "<C-Left>")
-- map("i", "<C-l>", "<C-Right>")
icmap("<C-h>", "<C-Left>", { silent = false })
icmap("<C-l>", "<C-Right>", { silent = false })

imap("<M-h>", "<Left>")
imap("<M-l>", "<Right>")
imap("<M-k>", function() vim.cmd("normal! gkzz") end )
imap("<M-j>", function() vim.cmd("normal! gjzz") end )

nmap("<C-/>", ":nohlsearch<cr>")

map("xoc", "<M-a>", "<esc>")
imap("<M-a>", "<esc>l")
nmap("<M-a>", "<nop>")
cmap("<M-a>", "<c-c>")

map("nox", "<S-h>", "^", { desc = "goto beginning of line" })
map("nox", "<S-l>", "g_", { desc = "goto end of line" })

map("nox", "G", "gg", { desc = "first line" })
map("nox", "gg", "G", { desc = "last line" })
nmap("<C-i>", "<C-o>", { desc = "back" })
nmap("<C-o>", "<C-i>", { desc = "forward" })
map("nox", "q", "b", { desc = "previous word" })
map("nox", "Q", "B", { desc = "previous WORD" })

xmap("p", '"_dP', { desc = "Paste Over Visual without Yanking" })
nmap("x", '"_x', { desc = "Delete Char without Yanking" })
nmap("X", '"_X', { desc = "Delete Char without Yanking" })

-- map("nixo", "<C-c>",     "<Esc>",           { desc = "Escape" })
map("in", "<C-s>", function()
  vim.cmd.stopinsert()
  vim.cmd.update()
end, { desc = "save" })

nmap("<M-j>", "jzz")
nmap("<M-k>", "kzz")

xmap("J", ":m '>+1<CR>gv=gv", { desc = "Move highlight down" })
xmap("K", ":m '<-2<CR>gv=gv", { desc = "Move highlight up" })
xmap("<", "<gv", { desc = "Indent left and reselect" })
xmap(">", ">gv", { desc = "Indent right and reselect" })

-- map("n", "<leader>x", "<cmd>.lua<CR>", "Execute the current line")
nmap_leader("%", function()
  vim.cmd.update()
  vim.cmd.source("%")
end, { desc = "source %" })

nmap("<M-S-j>", "<C-w>j")
nmap("<M-S-k>", "<C-w>k")
nmap("<M-S-h>", "<C-w>h")
nmap("<M-S-l>", "<C-w>l")
nmap("<C-Left>",  "<C-w>4<")
nmap("<C-Right>", "<C-w>4>")
nmap("<C-Up>",    "<Cmd>resize +2<CR>")
nmap("<C-Down>",  "<Cmd>resize -2<CR>")

map("t", "<M-a>", "<c-\\><c-n>", { desc = "Escape in terminal mode" })
map("t", "<M-s>", "<c-\\><c-n>", { desc = "Escape in terminal mode" })
nmap("<C-q>", "q:", { desc = "Open cmdwin" })


-- imap("<C-j>", function()
--     return vim.fn.pumvisible() == 1 and "<C-n>" or "<Down>"
-- end, { expr = true })

-- imap("<C-k>", function()
--     return vim.fn.pumvisible() == 1 and "<C-p>" or "<Up>"
-- end, { expr = true })

cmap("<C-j>", function()
  return vim.fn.wildmenumode() == 1 and "<C-n>" or "<C-j>"
end, { expr = true })

cmap("<C-k>", function()
  return vim.fn.wildmenumode() == 1 and "<C-p>" or "<C-k>"
end, { expr = true })

inmap("<M-`>", function() Arglist.toggle() end)

for i, key in ipairs({ "q", "w", "e", "u", "i", "o" }) do

  inmap("<M-"..key..">", function()
    vim.cmd.stopinsert()
    Arglist.jump_to(i)
  end, { desc = ("arglist %s"):format(i)})

  -- vim.keymap.set("n", ",<M-"..key..">", function() M.arglist[i] = vim.api.nvim_buf_get_name(0) end)
  nmap("<M-S-" .. key .. ">", function()
    Arglist.arglist[i] = vim.fn.expand("%:p")
  end, { desc = ("set arglist %s"):format(i) })
end

map("ntix", "<c-t>", function() Terminal.smart_toggle() end)

map("ni", "<M-m>", function()
  vim.cmd.stopinsert()
  vim.cmd("update")
  Edis.build()
end)

map("ni", "<M-S-m>", function()
  vim.cmd.stopinsert()
  vim.cmd("update")
  Edis.build_and_run()
end)

map("n", "<C-l>", Edis.ui.clear)
map("n", "<C-h>", Edis.ui.toggle)

map("ni", "<M-S-Enter>", function()
  vim.cmd.stopinsert()
  Edis.run()
end)

nmap("<C-j>", function() Quickfix.next() end)
nmap("<C-k>", function() Quickfix.prev() end)


map("nx", "<C-u>", function()
  local half = math.floor(0.5 * vim.o.lines)
  vim.cmd(("normal! %sk"):format(half))
end)
map("nx", "<C-d>", function()
  local half = math.floor(0.5 * vim.o.lines)
  vim.cmd(("normal! %sj"):format(half))
end)
