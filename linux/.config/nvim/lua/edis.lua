local fs = vim.fs
local fn = vim.fn
local uv = vim.uv
local api = vim.api

local M = {}

-- local _stdout_win = nil
-- function M.win()
--   if _stdout_win then return _stdout_win end
--
--   local winopts = {
--     enter = false,
--     style = "minimal",
--     split = "below",
--     height = 10,
--     keymaps = {
--       { "n", "q", function(self) self:close() end },
--     },
--     bo = {
--       modifiable = false,
--       bufhidden = "wipe",
--     },
--     wo = {
--       scrolloff = 0,
--       winhl = "Normal:NormalSplit",
--     },
--   }
--
--   _stdout_win = Win.split(winopts)
--   return _stdout_win
-- end
--
-- local function on_stdout(ctx)
--   return function(err, data)
--     if err then return vim.print(err) end
--     if data == nil then return end
--
--     data = data:gsub("\n$", "")
--     local lines = vim.split(data, "\n")
--     vim.schedule(function()
--       vim.cmd.cclose()
--       local winopts = {
--         bufnr = function(_)
--           local bufnr = api.nvim_create_buf(false, true)
--           api.nvim_buf_set_name(bufnr, table.concat(ctx.__cmd, " "))
--           return bufnr
--         end,
--       }
--       M.win()
--         :open(winopts)
--         :append_lines(lines, true)
--     end)
--   end
-- end
--
-- local LEVEL_TO_HL = {
--   INFO = "DiagnosticInfo",
--   WARN = "DiagnosticWarn",
--   ERROR = "DiagnosticError",
--   DONE = "DiagnosticOk",
--   SUCCESS = "DiagnosticOk",
-- }
--
-- local echo = vim.schedule_wrap(function(ctx, chunks)
--   local id =  api.nvim_echo(chunks, true, {
--     -- id = tostring(ctx.__start_time),
--     -- kind = "progress",
--     -- status = "running",
--   } )
--   return id
-- end)
--
-- local function on_stderr(ctx)
--   return function(err, data)
--     if err then return vim.print(err) end
--     if data == nil then return end
--
--     data = data:gsub("\n$", "")
--     vim.schedule(function()
--       local qf_context = vim.fn.getqflist({ context = true }).context
--       -- NOTE: using __start_time as a unique id to tell if
--       -- current quickfix list is the result of current command
--       local current_quickfix_from_this_cmd = type(qf_context) == "table" and qf_context.__start_time == ctx.__start_time
--       -- NOTE: this is perhaps unwanted behavior if chaining commands?
--       if current_quickfix_from_this_cmd then
--         return Quickfix.append(ctx, data)
--       end
--       -- otherwise create a new quickfix list for this context
--       Quickfix.close()
--       Quickfix.set(ctx, data)
--     end)
--
--     -- [timestamp] [level] program: message
--     local timestamp, level, program, message = data:match("^%[(.-)%]%s*%[(.-)%] (.-): (.+)$")
--     if timestamp then
--       local chunks = {
--         { "[",       "@punctuation.bracket" },
--         { timestamp, "Comment" },
--         { "] ",      "@punctuation.bracket" },
--         { "[",       "@punctuation.bracket" },
--         { level,     LEVEL_TO_HL[level] },
--         { "] ",      "@punctuation.bracket" },
--         { program,   "Function" },
--         { ": ",      "@punctuation.bracket" },
--         { message,   "MsgArea" },
--       }
--       echo(ctx, chunks)
--       return
--     end
--
--     -- [level] program: message
--     level, program, message = data:match("^%[(.-)%] (.-): (.+)$")
--     if level then
--       local chunks = {
--         { "[",     "@punctuation.bracket" },
--         { level,   LEVEL_TO_HL[level] },
--         { "] ",    "@punctuation.bracket" },
--         { program, "Function" },
--         { ": ",    "@punctuation.bracket" },
--         { message, "MsgArea" },
--       }
--       echo(ctx, chunks)
--       return
--     end
--
--     -- everything else
--     local chunks = { { data, "MsgArea" }}
--     echo(ctx, chunks)
--   end
-- end
--
-- local function on_exit(ctx)
--   return function(obj)
--     local end_time = uv.hrtime()
--     local elapsed = (end_time - ctx.__start_time) / 1e9
--     local chunks = {
--       { tostring(ctx.__cmd[1]), "Function" },
--       obj.code == 0 and { " finished ", "DiagnosticOk" } or { " exited ", "DiagnosticError" },
--       { ("in %.3fs with code " ):format(elapsed) },
--       { tostring(obj.code), "Number" },
--     }
--     ctx.__message_id = echo(ctx, chunks)
--
--     vim.schedule(function()
--       local qf_context = fn.getqflist({ context = true }).context
--       local current_quickfix_from_this_cmd = type(qf_context) == "table" and qf_context.__start_time == ctx.__start_time
--       if not current_quickfix_from_this_cmd then return end
--       qf_context.__end_time = end_time
--       fn.setqflist({}, "r", { context = qf_context })
--       if obj.code == 0 then
--         -- ctx.__end_time = end_time
--         Quickfix.replace(ctx, "")
--         Quickfix.close()
--       elseif obj.code ~= 0 and Quickfix.length() > 0 then
--         M.win():close()
--       end
--     end)
--   end
-- end
--
-- local function pop(t)
--   return table.remove(t, 1)
-- end
--
-- function M.syscall(ctx, handlers, ...)
--   if select("#", ...) == 0 then return end
--
--   local cmd = select(1, ...)
--   cmd = type(cmd) == "string" and vim.split(cmd, " ") or cmd
--   ctx.__cmd = cmd
--
--   handlers = vim.tbl_deep_extend("force", {
--     stdout = on_stdout,
--     stderr = on_stderr,
--     exit = on_exit,
--   }, handlers or {})
--
--   local rest_of_args = { select(2, ...) }
--   ---@diagnostic disable-next-line: redefined-local
--   local on_exit = #rest_of_args > 0 and function(obj)
--     if type(handlers.exit) == "table" then
--       pop(handlers.exit)(ctx)(obj)
--     else
--       handlers.exit(ctx)(obj)
--     end
--     if obj.code == 0 then
--       M.syscall(ctx, handlers, unpack(rest_of_args))
--     end
--   end or handlers.exit(ctx)
--
--   vim.schedule(Quickfix.close)
--   ctx.__start_time = uv.hrtime()
--   return vim.system(cmd, {
--     text = true,
--     stdout = type(handlers.stdout) == "table" and pop(handlers.stdout)(ctx) or handlers.stdout(ctx),
--     stderr = type(handlers.stderr) == "table" and pop(handlers.stderr)(ctx) or handlers.stderr(ctx),
--   }, on_exit)
-- end

local ROOT_MARKER = ".edis.toml"
local function parse_marker_and_get_context()
  local project_root = fs.root(0, ROOT_MARKER)
  if project_root == nil then
    local msg = ("no '%s' file detected"):format(ROOT_MARKER)
    local chunks = {
      { "(", "@punctuation.bracket" },
      { "error", "DiagnosticError" },
      { ") ", "@punctuation.bracket" },
      { msg, "MsgArea" }
    }
    api.nvim_echo(chunks, true, {})
    return
  end
  local marker_file  = fs.joinpath(project_root, ROOT_MARKER)
  local popen_prog = ("yq -p toml -o json %s"):format(marker_file)
  local ctx = vim.json.decode(io.popen(popen_prog):read("*a"))
  ctx.__project_root = project_root
  return ctx
end

function M.build(handlers)
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.build) then return end
  ctx.__source = ctx.compiler
  vim.fn.setqflist({}, " ")
  return require("quicksys.system").syscall(ctx, handlers, ctx.build)
end

function M.run(handlers)
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.run) then return end
  ctx.__source = ctx.compiler
  return require("quicksys.system").syscall(ctx, handlers, ctx.run)
end

function M.build_and_run(handlers)
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.build and ctx.run) then return end
  ctx.__source = ctx.compiler
  return require("quicksys.system").syscall(ctx, handlers, ctx.build, ctx.run)
end

return M
