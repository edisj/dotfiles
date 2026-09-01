vim.bo.tabstop = 2
vim.bo.shiftwidth = 2
vim.bo.softtabstop = 2
vim.bo.expandtab = true


local filter_items = function(items)
  local seen, unique_items = {}, {}
  for _, item in ipairs(items) do
    local loc = ("%s:%d"):format(item.filename, item.lnum)
    if not seen[loc] then
      seen[loc] = true
      unique_items[#unique_items + 1] = item
    end
  end
  return unique_items
end

local goto_loc = function(loc)
  local bufnr = loc.bufnr or vim.fn.bufadd(loc.filename)
  vim.bo[bufnr].buflisted = true
  vim.api.nvim_win_set_buf(0, bufnr)
  vim.api.nvim_win_set_cursor(0, { loc.lnum, loc.col-1 })
  vim.cmd("normal! zv")
end

local on_list = function(what)
  local items = filter_items(what.items)
  if #items > 1 then
    vim.fn.setqflist({}, " ", { title = "LSP locations", items = items })
    vim.cmd("botright copen")
    vim.cmd.wincmd("p")
  else
    goto_loc(items[1])
  end
end

map("gd", function()
  vim.lsp.buf.definition({ on_list = on_list })
end, { buf = 0, desc = "lsp: unique definitions" })

map("<Leader>lr", function()
  vim.lsp.buf.references(nil, { on_list = on_list })
end, { buf = 0, desc = "lsp: unique references" })
