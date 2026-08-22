map("<A-o>", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_parent(vim.v.count1)
	else
		vim.lsp.buf.selection_range(vim.v.count1)
	end
end, { desc = "Select parent treesitter node or outer incremental lsp selections", mode = { "n", "o", "x" } })

map("<A-i>", function()
	if vim.treesitter.get_parser(nil, nil, { error = false }) then
		require("vim.treesitter._select").select_child(vim.v.count1)
	else
		vim.lsp.buf.selection_range(-vim.v.count1)
	end
end, { desc = "Select child treesitter node or inner incremental lsp selections", mode = { "n", "o", "x" } })

map("<M-h>", function()
  require "vim.treesitter._select".select_prev(vim.v.count1)
end, { desc = "Select previous node", mode = { "n", "o", "x" } })
map("<M-l>", function()
  require "vim.treesitter._select".select_next(vim.v.count1)
end, { desc = "Select next node", mode = { "n", "o", "x" } })

map("<M-k>", function()
  require "vim.treesitter._select".select_prev(vim.v.count1)
end, { desc = "Select previous node", mode = { "x" } })
map("<M-j>", function()
  require "vim.treesitter._select".select_next(vim.v.count1)
end, { desc = "Select next node", mode = { "x" } })

