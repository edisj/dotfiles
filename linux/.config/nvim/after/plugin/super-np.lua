local api = vim.api
local fn = vim.fn

local loclist_is_open = function()
  local curwin = api.nvim_get_current_win()
  return fn.getloclist(curwin, { winid = 1 }).winid ~= 0
end

local quickfix_is_open = function()
  return fn.getqflist({ winid = 1 }).winid ~= 0
end

local nvim_tree_is_open = function()
  local ok, ret = pcall(require("nvim-tree.api").tree.is_visible)
  return ok and ret or false
end

local ns = api.nvim_create_namespace("")

local flash_line = function(lnum, col, end_col)
  local bufnr = api.nvim_get_current_buf()
  if not api.nvim_buf_is_valid(bufnr) then return end
  -- local lnum = api.nvim_win_get_cursor(0)[1]
  local row = math.min(lnum, api.nvim_buf_line_count(bufnr)) - 1
  local pos1 = { row, col or 0 }
  local pos2 = end_col and { row, end_col - 1 } or pos1
  local regtype = end_col and "v" or "V"
  vim.hl.range(bufnr, ns, "Search", pos1, pos2, { regtype = regtype, timeout = 250 })
end

local function goto_next(which)
  if which == "loclist" then
    local curwin = api.nvim_get_current_win()
    local len = #fn.getloclist(curwin)
    if len ~= 0 then
      pcall(vim.cmd.lnext)
      local list = fn.getloclist(0, { idx = 0, items = 0 })
      local current_item = list.items[list.idx]
      flash_line(current_item.lnum)
    end
  elseif which == "quickfix" then
    local len = #fn.getqflist()
    if len ~= 0 then
      pcall(vim.cmd.cnext)
      local list = fn.getqflist({ idx = 0, items = 0 })
      local current_item = list.items[list.idx]
      flash_line(current_item.lnum)
    end
  elseif which == "nvim_tree" then
    -- local nt = require("nvim-tree.api")
    -- local winid = nt.tree.winid()
    -- if not winid then return end
    -- nt.node.navigate.sibling.next()
  end
end

local function goto_prev(which)
  if which == "loclist" then
    local curwin = api.nvim_get_current_win()
    local len = #fn.getloclist(curwin)
    if len ~= 0 then
      pcall(vim.cmd.lprev)
      local list = fn.getloclist(0, { idx = 0, items = 0 })
      local current_item = list.items[list.idx]
      flash_line(current_item.lnum)
    end
  elseif which == "quickfix" then
    local len = #fn.getqflist()
    if len ~= 0 then
      pcall(vim.cmd.cprev)
      local list = fn.getqflist({ idx = 0, items = 0 })
      local current_item = list.items[list.idx]
      flash_line(current_item.lnum)
    end
  elseif which == "nvim_tree" then
    -- local nt = require("nvim-tree.api")
    -- local winid = nt.tree.winid()
    -- if not winid then return end
    -- nt.node.navigate.sibling.prev()
  end
end

local ctrl_n = function()
  if     loclist_is_open()   then goto_next("loclist")
  elseif quickfix_is_open()  then goto_next("quickfix")
  elseif nvim_tree_is_open() then goto_next("nvim_tree")
  end
end

local ctrl_p = function()
  if     loclist_is_open()   then goto_prev("loclist")
  elseif quickfix_is_open()  then goto_prev("quickfix")
  elseif nvim_tree_is_open() then goto_prev("nvim_tree")
  end
end

map("<C-n>", function() ctrl_n() end)
map("<C-p>", function() ctrl_p() end)

_G.np = {
  loclist_is_open = loclist_is_open,
  quickfix_is_open = quickfix_is_open,
  nvim_tree_is_open = nvim_tree_is_open,
}
