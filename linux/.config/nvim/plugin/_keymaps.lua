local fn = vim.fn

local map = function(lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true, remap = false }, opts or {})
  local mode = opts.mode or { "n" }
  opts.mode = nil
  vim.keymap.set(mode, lhs, rhs, opts)
end
_G.map = map

-- insert --------------------------------------------------------------------
for _, k in ipairs {
  "q", "b", "w", "e",
  "Q", "B", "W", "E",
} do
  map("<M-"..k..">", "<C-o>" .. k, { mode = { "i" }, remap = true })
end

-- normal --------------------------------------------------------------------
map("j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
map("k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
map("<M-j>", "<C-e>", { desc = "" })
map("<M-k>", "<C-y>", { desc = "" })
map("<M-C-j>", "<C-d>")
map("<M-C-k>", "<C-u>")
map("<C-j>", function()
  return math.floor(0.5 * vim.o.lines) .. "gj"
end, { expr = true })
map("<C-k>", function()
  return math.floor(0.5 * vim.o.lines) .. "gk"
end, { expr = true })

-- map("<Tab>", "zA")
map("<Tab>", "<Cmd>e #<CR>")
map("<C-i>", "<C-i>", { remap = true })

map("<C-c>", "<Esc>")

map("<C-i>", "<C-o>", { desc = "back" })
map("<C-o>", "<C-i>", { desc = "forward" })
map("G", "gg", { desc = "first line", mode = { "n", "o", "x" } })
map("gg", "G", { desc = "last line", mode = { "n", "o", "x" } })
map("q", "b", { desc = "previous word", mode = { "n", "o", "x" } })
map("Q", "B", { desc = "previous WORD", mode = { "n", "o", "x" } })
map("H", "^", { desc = "beginning of line", mode = { "n", "o", "x" } })
map("L", "$", { desc = "end of line", mode = { "n", "o", "x" } })

map("]t", "gt", { desc = "tab next" })
map("[t", "gT", { desc = "tab prev" })
map("<C-M-h>", function()
  if fn.tabpagenr() > 1 then vim.cmd("tabNext") end
end)
map("<C-M-l>", function()
  if fn.tabpagenr() ~= fn.tabpagenr("$") then vim.cmd("tabnext") end
end)

-- misc ========================================================================
map("<M-s>", function()
  vim.cmd.stopinsert()
  vim.cmd.update()
end, { desc = "save", mode = { "n", "i", "x" } })

map("<Leader>%", function()
  vim.cmd.update()
  vim.cmd.source("%")
end, { desc = "source %" })

-- nmap("+", "<C-a>", { desc = "++" })
-- nmap("-", "<C-x>", { desc = "--" })

-- better escape -------------------------------------------------------------
map("<M-a>", "<Esc>l", { mode = "i" })
map("<M-a>", "<Esc>", { mode = { "n", "o", "x" } })
map("<M-a>", "<C-c>", { remap = true, mode = { "c" } })
map("<M-a>", "<c-\\><c-n>", { desc = "escape in terminal mode", mode = { "t" } })

-- better n/N ----------------------------------------------------------------
do
  map("n", function()
    return vim.v.searchforward == 1 and "n" or "N"
  end, { expr = true, mode = { "n", "o", "x" } })
  map("<M-n>", function()
    return vim.v.searchforward == 1 and "nzz" or "Nzz"
  end, { expr = true, mode = { "n", "o", "x" } })
  map("N", function()
    return vim.v.searchforward == 1 and "N" or "n"
  end, { expr = true, mode = { "n", "o", "x" } })
  map("<M-N>", function()
    return vim.v.searchforward == 1 and "Nzz" or "nzz"
  end, { expr = true, mode = { "n", "o", "x" } })

  map("*", "*N",   { mode = { "n", "x" } })
  map("#", "#N",   { mode = { "n", "x" } })
  map("g*", "g*N", { mode = { "n", "x" } })
  map("g#", "g#N", { mode = { "n", "x" } })
end

map("U", function() vim.cmd("redo") end, { mode = { "n", "x" } })
map("p", '"_dP', { desc = "Paste Over Visual without Yanking", mode = { "x" } })
map("x", '"_x',  { desc = "Delete Char without Yanking" })
map("X", '"_X',  { desc = "Delete Char without Yanking" })

-- visual --------------------------------------------------------------------
map("<S-v>", "<C-v>", { desc = "v-block" })
map("v", "<S-v>", { desc = "v-line", mode = { "x" } })

map("J", ":m '>+1<CR>gv=gv", { desc = "Move highlight down",       mode = { "x" } })
map("K", ":m '<-2<CR>gv=gv", { desc = "Move highlight up",         mode = { "x" } })
map("<", "<gv",              { desc = "Indent left and reselect",  mode = { "x" } })
map(">", ">gv",              { desc = "Indent right and reselect", mode = { "x" } })


map("<C-;>", "q:", { desc = "Open cmdwin" })

-- icmap("<C-h>", "<C-Left>", { silent = false })
-- icmap("<C-l>", "<C-Right>", { silent = false })
-- icmap("<C-j>", function()
--   return fn.wildmenumode() == 1 and "<C-n>" or "<C-j>"
-- end, { expr = true, silent = true })
--
-- icmap("<C-k>", function()
--   return fn.wildmenumode() == 1 and "<C-p>" or "<C-k>"
-- end, { expr = true, silent = true })

vim.keymap.set("c", "<M-p>", "<Up>", { silent = false })
vim.keymap.set("c", "<M-n>", "<Down>", { silent = false })

vim.keymap.set('c', '<M-h>', '<Left>',  { silent = false, desc = 'Left' })
vim.keymap.set('c', '<M-l>', '<Right>', { silent = false, desc = 'Right' })

-- Don't `noremap` in insert mode to have these keybindings behave exactly
-- like arrows (crucial inside TelescopePrompt)
vim.keymap.set('i', '<M-h>', '<Left>',  { noremap = false, desc = 'Left' })
vim.keymap.set('i', '<M-j>', '<Down>',  { noremap = false, desc = 'Down' })
vim.keymap.set('i', '<M-k>', '<Up>',    { noremap = false, desc = 'Up' })
vim.keymap.set('i', '<M-l>', '<Right>', { noremap = false, desc = 'Right' })

-- Copy/paste with system clipboard
vim.keymap.set(  'n',        'gp', '"+p', { desc = 'Paste from system clipboard' })
vim.keymap.set({ 'n', 'x' }, 'gy', '"+y', { desc = 'Copy to system clipboard' })
-- - Paste in Visual with `P` to not copy selected text (`:h v_P`)
vim.keymap.set(  'x',        'gp', '"+P', { desc = 'Paste from system clipboard' })

-- Reselect latest changed, put, or yanked text
vim.keymap.set('n', 'gV', '"g`[" . strpart(getregtype(), 0, 1) . "g`]"', { expr = true, replace_keycodes = false, desc = 'Visually select changed text' })

-- Search inside visually highlighted text. Use `silent = false` for it to
-- make effect immediately.
vim.keymap.set('x', 'g/', '<esc>/\\%V', { silent = false, desc = 'Search inside visual selection' })

local function edit(file)
  local path = ("%s/plugin/%s"):format(vim.fn.stdpath("config"), file)
  return function() vim.cmd.edit(path) end
end
map("<Leader>eo", edit("_options.lua"),    { desc = "options.lua" })
map("<Leader>ek", edit("_keymaps.lua"),    { desc = "keymaps.lua" })
map("<Leader>ea", edit("_autocmds.lua"),   { desc = "autocmds.lua" })
map("<Leader>ei", "<Cmd>edit $MYVIMRC<CR>", { desc = "init.lua" })


-- wincmds -------------------------------------------------------------------
map("<M-S-k>", "<C-w>K", { desc = "move window up" })
map("<M-S-j>", "<C-w>J", { desc = "move window down" })
map("<M-S-h>", "<C-w>H", { desc = "move window left" })
map("<M-S-l>", "<C-w>L", { desc = "move window right" })
map("<C-w>e", "<C-w>c", { desc = "Close" })
map("<C-w><C-e>", "<C-w>c", { desc = "Close" })

map("<C-w><C-x>", function()
  local ft = vim.bo.filetype
  vim.cmd("wincmd n")
  local bufnr = vim.api.nvim_get_current_buf()
  vim.bo[bufnr].buftype = "nofile"
  vim.bo[bufnr].filetype = ft
end, { desc = "scratch window" })
map("<C-w>x", "<C-w><C-x>", { remap = true })

local function smart_resize(direction)
  local left_right = direction == "h" or direction == "l"
  local only_win = fn.winnr("j") == fn.winnr("k")
  local make_bigger =
  (left_right and "vertical resize +5")
  or (only_win and "resize +5")
  or "resize +5"
  local make_smaller =
  (left_right and "vertical resize -5")
  or (only_win and direction == "j" and "resize +5")
  or "resize -5"
  local has_neighbor = fn.winnr(direction) ~= fn.winnr()
  return has_neighbor and vim.cmd(make_bigger) or vim.cmd(make_smaller)
end
map("<C-Left>",  function() smart_resize("h") end, { desc = "smart resize left" })
map("<C-Right>", function() smart_resize("l") end, { desc = "smart resize right" })
map("<C-Down>",  function() smart_resize("j") end, { desc = "smart resize down" })
map("<C-Up>",    function() smart_resize("k") end, { desc = "smart resize up" })

-- {{{ toggle
map("<Leader>tn", function()
  vim.o.nu = not vim.o.nu
  if not vim.o.nu then vim.o.rnu = false end
end, { desc = "number" })
map("<Leader>tr", function()
  vim.o.rnu = not vim.o.rnu
  if vim.o.rnu then vim.o.nu = true end
end, { desc = "relative number" })
map("<Leader>tg", function()
  if not package.loaded["gitsigns"] then return end
  vim.cmd("Gitsigns toggle_signs")
  vim.api.nvim__redraw({ flush = true, statuscolumn = true })
end, { desc = "gitsigns" })
map("<Leader>ts", function()
  local scl = vim.o.signcolumn
  vim.o.signcolumn = scl == "no" and "yes:1" or "no"
end, { desc = "signcolumn" })
-- }}}


-- lsp =========================================================================
map("gd", function() vim.lsp.buf.definition() end, { desc = "Goto definition" })
map("gD", function() vim.lsp.buf.declaration() end, { desc = "Goto declaration" })
map("<Leader>la", function() vim.lsp.buf.code_action() end,     { desc = "code action" })
map("<Leader>ld", function() vim.lsp.buf.definition() end,      { desc = "definition" })
map("<Leader>lD", function() vim.lsp.buf.declaration() end,     { desc = "declaration" })
map("<Leader>li", function() vim.lsp.buf.implementation() end,  { desc = "declaration" })
map("<Leader>ls", function() vim.lsp.buf.document_symbol() end, { desc = "symbols" })
map("<Leader>lr", function() vim.lsp.buf.references() end,      { desc = "references" })
map("<Leader>ln", function() vim.lsp.buf.rename() end,          { desc = "rename" })
map("<Leader>lK", function() vim.diagnostic.open_float() end,   { desc = "diagnostic" })
