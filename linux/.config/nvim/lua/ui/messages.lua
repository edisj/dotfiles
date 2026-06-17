local msg = require("vim._core.ui2.messages")
local uv = vim.uv
local fs = vim.fs
local fn = vim.fn
local api = vim.api

local group = vim.api.nvim_create_augroup("ui-messages", { clear = true })
Config.on("FileType", function()
  local ui2 = require("vim._core.ui2")
  local win = ui2.wins and ui2.wins.msg
  if win and vim.api.nvim_win_is_valid(win) then
    api.nvim_win_set_config(win, {
      border = { "", "", "", " ", "", "", "", " " },
    })
  end
end, { pattern = "msg", group = group })

local a = true
if a then return end


local function append_item(items, filename, lnum, text, type)
  items[#items + 1] = {
    filename = filename,
    text = text,
    lnum = lnum,
    type = type,
  }
end

local function resolve_filepath(filename)

  local tail = fn.fnamemodify(filename, ":t")
  local matches = {}
  for _, rtp in ipairs(api.nvim_list_runtime_paths()) do
    local match = fs.find(tail, {
      path = rtp,
      type = "file",
      limit = math.huge,
    })[1]
    -- NOTE: VERY important to cast all paths to realpath if you do ANY
    -- symlinking (with stow for example)
    matches[#matches + 1] = match and uv.fs_realpath(match) or nil
  end

  local truncated = filename:match("^%.%.%.") -- if path starts with '...'
  local longest_path = truncated and filename:match("^%.%.%..-/(.+)") or filename
  local escaped_path = vim.pesc(truncated and longest_path or uv.fs_realpath(longest_path))
  for _, match in ipairs(matches) do
    if match:find(escaped_path) then return match end
  end
end

local function send_lua_errors_to_quickfix(content)
  local lines = {}
  for _, chunks in ipairs(content) do
    local text = chunks[2]
    vim.list_extend(lines, vim.split(text, "\n"))
  end
  if #lines == 0 then return end

  local error_pattern = "^(E%d+): Lua: ([^:]+):(%d+): (.+)$"
  local error_pattern2 = "^(E%d+): Lua: vim/loader.lua:%d+: ([^:]+):(%d+): (.+)$"
  local stacktrace_pattern = "^([^:]+):(%d+): (.+)$"

  local items = {}
  for _, line in ipairs(lines) do
    local trimmed = vim.trim(line)

    -- E1234: Lua: .../path/to/file:10: text
    local errcode, filename, lnum, text = trimmed:match(error_pattern2)
    if not errcode then
      errcode, filename, lnum, text = trimmed:match(error_pattern)
    end
    if errcode then
      filename = resolve_filepath(filename)
      local qf_text = ("%s: %s"):format(errcode, text)
      append_item(items, filename, lnum, qf_text, "E")
    end

    -- .../path/to/file:10: text
    filename, lnum, text = trimmed:match(stacktrace_pattern)
    if filename then
      filename = resolve_filepath(filename)
      local qf_text = ("%s"):format(text)
      append_item(items, filename, lnum, qf_text, "S")
    end
  end

  if #items > 0 then
    fn.setqflist(items)
  end
end

local lua_error_handler = function(_, content)
  vim.schedule(function()
    send_lua_errors_to_quickfix(content)
  end)
  return true
end

local intercept_handlers = setmetatable({}, {
  __index = function()
    return function() return true end
  end
})
-- intercept_handlers["lua_error"] = lua_error_handler
-- intercept_handlers["emsg"] = lua_error_handler

local _msg_show = msg.msg_show
msg.msg_show = function(kind, ...)
  local handler = intercept_handlers[kind]
  return handler(kind, ...) and _msg_show(kind, ...)
end
