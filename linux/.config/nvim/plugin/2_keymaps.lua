local api = vim.api
local fn = vim.fn

Config.map = function(modes, lhs, rhs, opts)
  modes = type(modes) == "string" and vim.split(modes, "") or modes
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(modes, lhs, rhs, opts)
end
Config.nmap = function(...) Config.map("n", ...) end
Config.nmap_leader = function(lhs, ...) Config.map("n", "<leader>"..lhs, ...) end

local map = Config.map
local nmap = Config.nmap
local nmap_leader = Config.nmap_leader
local imap = function(...) map("i", ...) end
local xmap = function(...) map("x", ...) end
local cmap = function(...) map("c", ...) end
local tmap = function(...) map("t", ...) end
local inmap = function(...) map("in", ...) end
local oxmap = function(...) map("ox", ...) end
local icmap = function(...) map("ic", ...) end
-- local coxmap = function(...) map("cox", ...) end
local noxmap = function(...) map("nox", ...) end
local nixmap = function(...) map("nix", ...) end

local function edit(file)
  local path = ("%s/plugin/%s"):format(vim.fn.stdpath("config"), file)
  return function() vim.cmd.edit(path) end
end
nmap_leader("eo", edit("1_options.lua"),    { desc = "1_options.lua" })
nmap_leader("ek", edit("2_keymaps.lua"),    { desc = "2_keymaps.lua" })
nmap_leader("ea", edit("3_autocmds.lua"),   { desc = "3_autocmds.lua" })
nmap_leader("ei", "<Cmd>edit $MYVIMRC<CR>", { desc = "init.lua" })
nmap_leader("ee", function()
  local root_marker = ".edis.toml"
  local project_root = vim.fs.root(0, root_marker)
  if project_root == nil then
    local msg = ("no '%s' file detected"):format(root_marker)
    api.nvim_echo({
      { "(", "@punctuation.bracket" },
      { "error", "DiagnosticError" },
      { ") ", "@punctuation.bracket" },
      { msg, "MsgArea" }
    }, true, {})
    return
  end
  local marker_file  = vim.fs.joinpath(project_root, root_marker)
  vim.cmd.edit(marker_file)
end, { desc = ".edis.toml" })


-- motions =====================================================================
nmap("j", "v:count == 0 ? 'gj' : 'j'", { expr = true })
nmap("k", "v:count == 0 ? 'gk' : 'k'", { expr = true })
nmap("<M-j>", "jzz", { desc = "j and center" })
nmap("<M-k>", "kzz", { desc = "k and center" })
noxmap("<S-h>", "^", { desc = "beginning of line" })
noxmap("<S-l>", "g_", { desc = "end of line" })

nmap("<C-c>", "<Esc>")

nmap("<C-i>", "<C-o>", { desc = "back" })
nmap("<C-o>", "<C-i>", { desc = "forward" })
noxmap("G", "gg", { desc = "first line" })
noxmap("gg", "G", { desc = "last line" })
noxmap("q", "b", { desc = "previous word" })
noxmap("Q", "B", { desc = "previous WORD" })
nmap("]t", "gt", { desc = "tab next" })
nmap("[t", "gT", { desc = "tab prev" })


noxmap("<C-u>", function()
  local half = math.floor(0.5 * vim.o.lines)
  vim.cmd(("normal! %sk"):format(half))
end, { desc = "move halfpage up"})

noxmap("<C-d>", function()
  local half = math.floor(0.5 * vim.o.lines)
  vim.cmd(("normal! %sj"):format(half))
end, { desc = "move halfpage down" })

imap("<M-h>", "<C-Left>")
imap("<M-l>", "<C-Right>")
imap("<M-k>", function() vim.cmd("normal! gk") end )
imap("<M-j>", function() vim.cmd("normal! gj") end )

-- misc ========================================================================
nixmap("<C-s>", function()
  vim.cmd.stopinsert()
  vim.cmd.update()
end, { desc = "save" })

nmap_leader("%", function()
  vim.cmd.update()
  vim.cmd.source("%")
end, { desc = "source %" })

nmap("<S-v>", "<C-v>", { desc = "v-block" })
xmap("v", "<S-v>", { desc = "v-line" })
nmap("+", "<C-a>", { desc = "++" })
nmap("-", "<C-x>", { desc = "--" })

imap("<M-a>", "<esc>l")
oxmap("<M-a>", "<esc>")
cmap("<M-a>", "<C-c>")
nmap("<M-a>", function()
  vim.cmd("nohlsearch")
  vim.g.hl_suspended = true
  vim.cmd.redrawstatus()
end)
do
  local function search_cmd(lhs, rhs)
    nmap(lhs, function()
      vim.g.hl_suspended = false
      vim.cmd.redrawstatus()
      return rhs
    end, { expr = true })
  end
  search_cmd("*", "*N")
  search_cmd("#", "#N")
  search_cmd("g*", "g*N")
  search_cmd("g#", "g#N")
  noxmap("n", function()
    vim.g.hl_suspended = false
    vim.cmd.redrawstatus()
    return vim.v.searchforward == 1 and "nzz" or "Nzz"
  end, { expr = true })
  noxmap("N", function()
    vim.g.hl_suspended = false
    vim.cmd.redrawstatus()
    return vim.v.searchforward == 1 and "Nzz" or "nzz"
  end, { expr = true })
end

xmap("p", '"_dP', { desc = "Paste Over Visual without Yanking" })
nmap("x", '"_x', { desc = "Delete Char without Yanking" })
nmap("X", '"_X', { desc = "Delete Char without Yanking" })

xmap("J", ":m '>+1<CR>gv=gv", { desc = "Move highlight down" })
xmap("K", ":m '<-2<CR>gv=gv", { desc = "Move highlight up" })
xmap("<", "<gv", { desc = "Indent left and reselect" })
xmap(">", ">gv", { desc = "Indent right and reselect" })

nmap("<C-/>", ":nohlsearch<cr>")
nmap("<C-;>", "q:", { desc = "Open cmdwin" })

-- icmap("<C-h>", "<C-Left>", { silent = false })
-- icmap("<C-l>", "<C-Right>", { silent = false })
icmap("<C-j>", function()
  return fn.wildmenumode() == 1 and "<C-n>" or "<C-j>"
end, { expr = true, silent = true })

icmap("<C-k>", function()
  return fn.wildmenumode() == 1 and "<C-p>" or "<C-k>"
end, { expr = true, silent = true })


-- treesitter =================================================================
noxmap("<A-o>", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_parent(vim.v.count1)
	else
		vim.lsp.buf.selection_range(vim.v.count1)
	end
end, { desc = "Select parent treesitter node or outer incremental lsp selections" })

noxmap("<A-i>", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_child(vim.v.count1)
	else
		vim.lsp.buf.selection_range(-vim.v.count1)
	end
end, { desc = "Select child treesitter node or inner incremental lsp selections" })

noxmap("<M-h>", function()
  require "vim.treesitter._select".select_prev(vim.v.count1)
end, { desc = "Select previous node" })
noxmap("<M-l>", function()
  require "vim.treesitter._select".select_next(vim.v.count1)
end, { desc = "Select next node" })

xmap("<M-k>", function()
  require "vim.treesitter._select".select_prev(vim.v.count1)
end, { desc = "Select previous node" })
xmap("<M-j>", function()
  require "vim.treesitter._select".select_next(vim.v.count1)
end, { desc = "Select next node" })


-- wincmds =====================================================================
local function wincmd(lhs, key, desc)
  nmap(lhs, "<C-w>"..key, { desc = desc })
end
wincmd("<C-j>",   "j", "jump to window below")
wincmd("<C-k>",   "k", "jump to window above")
wincmd("<C-h>",   "h", "jump to window left")
wincmd("<C-l>",   "l", "jump to window right")
wincmd("<M-S-j>", "J", "move window down")
wincmd("<M-S-k>", "K", "move window up")
wincmd("<M-S-h>", "H", "move window left")
wincmd("<M-S-l>", "L", "move window right")

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
nmap("<C-Left>",  function() smart_resize("h") end, { desc = "smart resize left" })
nmap("<C-Right>", function() smart_resize("l") end, { desc = "smart resize right" })
nmap("<C-Down>",  function() smart_resize("j") end, { desc = "smart resize down" })
nmap("<C-Up>",    function() smart_resize("k") end, { desc = "smart resize up" })


-- diagnostics =================================================================
nmap_leader("td", function()
  vim.diagnostic.enable(not vim.diagnostic.is_enabled())
end, { desc = "toggle diagnostics" })

local diag_float_winid

nmap("<C-.>", function()
  vim.diagnostic.jump({
    count = vim.v.count1,
    on_jump = function()
      if diag_float_winid and api.nvim_win_is_valid(diag_float_winid) then
        api.nvim_win_close(diag_float_winid, true)
      end
      _, diag_float_winid = vim.diagnostic.open_float()
    end,
  })
end)

nmap("<C-,>", function()
  vim.diagnostic.jump({
    count = - vim.v.count1,
    on_jump = function()
      if diag_float_winid and api.nvim_win_is_valid(diag_float_winid) then
        api.nvim_win_close(diag_float_winid, true)
      end
      _, diag_float_winid = vim.diagnostic.open_float()
    end,
  })
end)


-- messages ====================================================================
nmap_leader("mo", function()
  if vim.bo.filetype == "pager" then return api.nvim_win_close(0, true) end
  if fn.execute("messages"):match("%S") == nil then return end
  local cmd = vim.v.count == 0 and "messages" or ("%smessages"):format(vim.v.count)
  vim.cmd(cmd)
  -- NOTE: need to schedule this otherwise it goes to bottom of original window
  vim.schedule(function()
    vim.cmd("normal! G")
  end)
end, { desc = "open" })

nmap_leader("mc", function()
  if vim.bo.filetype == "pager" then api.nvim_win_close(0, true) end
  vim.cmd("messages clear")
  -- if Edis.win():is_open() then Edis.win():set_lines({}, { force = true }) end
end, { desc = "clear" })

-- nmap("<C-,>", function()
--   if vim.bo.filetype == "pager" then return api.nvim_win_close(0, true) end
--   vim.cmd("normal! g<")
-- end, { desc = "ui2 g<" })


-- lsp =========================================================================
nmap("gd", function() vim.lsp.buf.definition() end, { desc = "Goto definition" })
nmap("gD", function() vim.lsp.buf.declaration() end, { desc = "Goto declaration" })
nmap_leader("la", function() vim.lsp.buf.code_action() end,     { desc = "code action" })
nmap_leader("ld", function() vim.lsp.buf.definition() end,      { desc = "definition" })
nmap_leader("lD", function() vim.lsp.buf.declaration() end,     { desc = "declaration" })
nmap_leader("li", function() vim.lsp.buf.implementation() end,  { desc = "declaration" })
nmap_leader("ls", function() vim.lsp.buf.document_symbol() end, { desc = "symbols" })
nmap_leader("lr", function() vim.lsp.buf.references() end,      { desc = "references" })
nmap_leader("ln", function() vim.lsp.buf.rename() end,          { desc = "rename" })
nmap_leader("lK", function() vim.diagnostic.open_float() end,   { desc = "diagnostic" })


-- plugins =====================================================================

--------------------------------------------------------------------------------
-- arglist
inmap("<M-`>", function()
  Arglist.toggle()
end, { desc = "toggle arglist" })

for _, k in ipairs(Arglist.keys()) do
  inmap("<M-"..k..">", function()
    vim.cmd.stopinsert()
    Arglist.jump_to(k)
  end, { desc = ("arglist %s"):format(k)})

  -- vim.keymap.set("n", ",<M-"..key..">", function() M.arglist[i] = vim.api.nvim_buf_get_name(0) end)
  nmap("<M-S-" .. k .. ">", function()
    Arglist.set_key(k, nil)
  end, { desc = ("set arglist %s"):format(k) })
end

--------------------------------------------------------------------------------
-- terminal
map("ntix", "<c-t>", function()
  Terminal.smart_toggle()
end, { desc = "toggle terminal" })
tmap("<M-a>", "<c-\\><c-n>", { desc = "escape in terminal mode" })
