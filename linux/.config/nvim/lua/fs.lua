local api, fn, fs, uv = vim.api, vim.fn, vim.fs, vim.uv
local M = {}

M.normalize = function(path)
  return path and fs.normalize(fs.abspath(path))
end

local KB = 1000
local MB = KB*KB
local GB = KB*KB*KB
local TB = KB*KB*KB*KB
local size_str = function(size)
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
local permissions_str = function(type, mode)
  if not mode then return string.rep("-", 10) end
  type = ({ directory = "d", link = "l" })[type] or "-"
  local octal_str = ("%03o"):format(mode % (8*8*8)) -- keep bottom 3 octal-digits
  local user  = OCTAL_MAP[octal_str:sub(1, 1)]
  local group = OCTAL_MAP[octal_str:sub(2, 2)]
  local other = OCTAL_MAP[octal_str:sub(3, 3)]
  return type .. user .. group .. other
end

local modified_str = function(mtime)
  if not mtime then return "" end
  return fn.strftime("%b %d %H:%M", mtime.sec)
end

M.get_fs_info = function(path)
  local stat = uv.fs_stat(path) or {}
  local name = fs.basename(path)
  local text = stat.type == "directory" and name .. "/" or name
  local size = size_str(stat.size)
  return {
    text = text,
    path = path,
    type = stat.type,
    size = size,
    permissions = permissions_str(stat.type, stat.mode),
    modified = modified_str(stat.mtime),
  }
end

local default_sort = function(a, b)
  local a_isdir, b_isdir = a.type == "directory", b.type == "directory"
  if a_isdir ~= b_isdir then return a_isdir end
  return a.text < b.text
end

M.get_dir_info = function(dirname, sort)
  if not dirname then return { items = {}, widths = {} } end
  local text_col_width = 0
  local size_col_width = 0
  local items = vim
    .iter(fs.dir(dirname))
    :map(function(name)
      local path = fs.joinpath(dirname, name)
      local item = M.get_fs_info(path)
      text_col_width = math.max(text_col_width, #item.text)
      size_col_width = math.max(size_col_width, #item.size)
      return item
    end)
    :totable()

  sort = sort or default_sort
  table.sort(items, sort)

  return { items = items, widths = { text = text_col_width, size = size_col_width } }
end

return M
