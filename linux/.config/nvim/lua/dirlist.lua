local api, fn, fs, uv = vim.api, vim.fn, vim.fs, vim.uv
local M = {}

M.normalize = function(path)
  return path and fs.normalize(fs.abspath(path))
end

M.get_dirlist_items = function(dirname)
  if not dirname then return {} end
  local items = vim
    .iter(fs.dir(dirname))
    :map(function(name)
      local path = fs.joinpath(dirname, name)
      local item = M.path_to_item(path)
      return item
    end)
    :totable()
  return items
end

M.path_to_item = function(path)
  local stat = uv.fs_lstat(path) or {}
  local type = stat.type
  local actual_type = type
  if type == "link" then actual_type = (uv.fs_stat(path) or {}).type end
  if actual_type == nil then actual_type = false end
  local name = fs.basename(path)
  local text = stat.type == "directory" and name .. "/" or name
  return {
    text = text,
    path = path,
    type = type,
    isdir = type == "directory",
    actual_type = actual_type,
    size = stat.size,
    permissions = stat.mode,
    modified = stat.mtime,
  }
end

M.buf_set_dirlist = function(bufnr, what)
  local items = what.items
  local sort = what.sort or M.default_sort
  local filter = what.filter or M.default_filter
  local decorate = what.decorate or M.default_decorate

  table.sort(items, sort)
  local lines = vim.iter(items):map(function(item) return item.text end):totable()
  api.nvim_buf_set_lines(bufnr, 0, -1, false, lines)
  decorate(bufnr, items)
  vim.b[bufnr].dirlist = items
end

M.default_sort = function(a, b)
  -- local a_isdir = a.type == "directory"
  -- local b_isdir = b.type == "directory"
  local a_isdir = (a.actual_type or a.type) == "directory"
  local b_isdir = (b.actual_type or b.type) == "directory"
  if a_isdir ~= b_isdir then
    return a_isdir
  else
    return a.text < b.text
  end
end

M.default_filter = function(item) return item end

local ns
M.default_decorate = function(bufnr, items, opts)
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    format_size = M.default_format_size,
    format_modified = M.default_format_modified,
    format_permissions = M.default_format_permissions,
  })

  ns = ns or api.nvim_create_namespace("")
  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)

  local text_col_width = opts.text_col_width or
    vim.iter(items)
      :fold({}, function(acc, item)
        acc.max = math.max(#item.text, acc.max or #item.text)
        return acc
      end).max or 0

  local decorate_line = function(lnum, extmark_opts)
    local start_col = extmark_opts.start_col or 0
    -- extmark_opts.start_col = nil
    api.nvim_buf_set_extmark(bufnr, ns, lnum-1, start_col, extmark_opts)
  end

  local permissions_offset = math.max(8 + text_col_width + 4, 40)
  for lnum, item in ipairs(items) do
    local category = item.type
    if item.type == "link" then category = (uv.fs_stat(item.path) or {}).type end
    local icon, icon_hl
    if not category then
      -- broken link
      icon, icon_hl =  " ", "DiagnosticError"
    elseif not (category == "file" or category == "directory") then
      icon, icon_hl = "  ", nil
    else
      icon, icon_hl = require("icons").get(category, item.path)
    end

    local size_str = opts.format_size(item)
    local permissions_str = opts.format_permissions(item)
    local modified_str = opts.format_modified(item)

    decorate_line(lnum, {
      virt_text = { { ("%6s  "):format(size_str), "String" }, { icon, icon_hl } },
      virt_text_pos = "inline"
    })
    if item.type == "directory" then
      decorate_line(lnum, {
        hl_group = "Directory",
        end_col = #item.text,
        priority = 190,
      })
    end
    decorate_line(lnum, {
      virt_text = { { permissions_str, "Number" } },
      virt_text_win_col = permissions_offset,
      hl_mode = "combine"
    })
    decorate_line(lnum, {
      virt_text = { { modified_str, "Comment" } },
      virt_text_win_col = permissions_offset + 2*(#permissions_str),
      hl_mode = "combine",
    })
  end
end

local KB = 1000
local MB = KB*KB
local GB = KB*KB*KB
local TB = KB*KB*KB*KB
M.default_format_size = function(item)
  local size = item.size
  if not size then return "" end
  local out = ""
  if     size < KB then out = ("%s"):format(size)
  elseif size < MB then out = ("%.1fk"):format(size / KB)
  elseif size < GB then out = ("%.1fM"):format(size / MB)
  elseif size < TB then out = ("%.1fG"):format(size / GB)
  else                  out = ("%.1fT"):format(size / TB)
  end
  return out
end

local OCTAL_MAP = {
  ["0"] = "---", ["1"] = "--x", ["2"] = "-w-", ["3"] = "-wx",
  ["4"] = "r--", ["5"] = "r-x", ["6"] = "rw-", ["7"] = "rwx",
}
M.default_format_permissions = function(item)
  local type, mode = item.type, item.permissions
  if not mode then return string.rep("-", 10) end
  type = ({ directory = "d", link = "l" })[type] or "-"
  local octal_str = ("%03o"):format(mode % (8*8*8)) -- keep bottom 3 octal-digits
  local user  = OCTAL_MAP[octal_str:sub(1, 1)]
  local group = OCTAL_MAP[octal_str:sub(2, 2)]
  local other = OCTAL_MAP[octal_str:sub(3, 3)]
  return type .. user .. group .. other
end

M.default_format_modified = function(item)
  local mtime = item.modified
  if not mtime then return "" end
  return fn.strftime("%b %d %H:%M", mtime.sec)
end

return M
