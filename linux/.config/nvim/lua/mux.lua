local api, fn, fs, uv = vim.api, vim.fn, vim.fs, vim.uv
local json = vim.json

local M = {}

local current_server
local current_listing
local augroup = api.nvim_create_augroup("mux-server", {})

local ROOT_MARKERS           = { { ".edis.json", ".edis.toml" }, ".git" }
local TIMEOUT_REMOTE_EXPR_MS = 5000
local TIMEOUT_ATTACH_MS      = 500
local TIMEOUT_LISTENING_MS   = 500

local session_dir   = function()   return fs.joinpath(fn.stdpath("state"), "mux")       end
local socket_dir    = function()   return fs.joinpath(fn.stdpath("run"), "nvim", "mux") end
local id_to_name    = function(id) return id:match("^(.*)-")                            end
local id_to_socket  = function(id) return fs.joinpath(socket_dir(), id .. ".sock")      end
local id_to_session = function(id) return fs.joinpath(session_dir(), id .. ".vim")      end
local id_to_json    = function(id) return fs.joinpath(session_dir(), id .. ".json")     end

local function cksum(s)
  local res = vim.system({ "cksum" }, { text = true, stdin = s }):wait()
  if not (res and res.code == 0 and res.stdout) then
    return nil, "cksum failed"
  end
  return res.stdout:match("^(%d+)")
end

local ids = {}
local root_to_id = function(root)
  if ids[root] then return ids[root] end
  local hash = cksum(root)
  local id = fs.basename(root) .. "-" .. hash
  ids[root] = id
  return id
end

local read_datafile = function(datafile)
  local data = table.concat(fn.readfile(datafile), "\n")
  return json.decode(data)
end

local find_project_root = function()
  local cwd = fn.getcwd(-1, -1, -1)
  local root = fs.root(cwd, ROOT_MARKERS)
  if not root then
    return nil, "no project root detected"
  else
    return root
  end
end

local spawn_nvim = function(args, opts, on_exit)
  local progpath = vim.v.progpath
  progpath = fn.executable(progpath) == 1 and progpath or "nvim"
  local cmd = { progpath }
  vim.list_extend(cmd, args)

  local ok, proc = pcall(vim.system, cmd, opts, on_exit)
  if not ok then
    return nil, tostring(proc)
  else
    return proc, nil
  end
end

-- [remote api] ---------------------------------------------------------------
local RPC_REQUEST = [[
local reply_chan, id, expr, deadline = ...

local out, err

local status

if vim.uv.now() >= deadline then
  out, err = nil, "PASSED DEADLINE!"
  status = "timeout"
else
  local f, loadstring_err = loadstring(expr)
  if not f then
    out, err = nil, loadstring_err
    status = "error"
  else
    pcall(vim.rpcnotify,
      reply_chan,
      "nvim__exec_lua_fast",
      "local id = ... _G.__mux_pending[id].status = 'running'",
      { id }
    )
    local f_ok, f_out, f_err = pcall(f)
    if not f_ok then
      out, err = nil, f_out
      status = "error"
    else
      out, err = f_out, f_err
      status = "done"
    end
  end
end

pcall(vim.rpcnotify,
  reply_chan,
  "nvim_exec_lua",
  "local id, o, e, s = ... local p = _G.__mux_pending[id] p.status = s p.fn(o,e)",
  { id, out, err, status }
)
]]

local _id = 0
local next_id = function() _id = _id + 1; return _id end

local remote_expr = function(socket, expr, cb)
  local chan_ok, chan = pcall(fn.sockconnect, "pipe", socket, { rpc = true })
  local timer = assert(uv.new_timer())
  local done = false

  local res_out, res_err
  local finish = function(out, err)
    if done then return end
    if not timer:is_closing() then timer:close() end
    done = true

    res_out, res_err = out, err
    if res_out == vim.NIL then res_out = nil end
    if res_err == vim.NIL then res_err = nil end

    pcall(fn.chanclose, chan)
    if cb == nil then
      return res_out, res_err
    else
      vim.schedule(function() cb(res_out, res_err) end)
      return nil
    end
  end

  if not chan_ok then return finish(nil, chan) end
  local reply_ok, api_info = pcall(vim.rpcrequest, chan, "nvim_get_api_info")
  if not reply_ok then return nil, api_info end
  if not api_info then return nil, "could not get api info" end
  local reply_chan = api_info[1]

  local id = next_id()
  local deadline = uv.now() + TIMEOUT_REMOTE_EXPR_MS
  _G.__mux_pending = _G.__mux_pending or {}
  _G.__mux_pending[id] = {
    fn = finish,
    status = "pending",
    deadline = deadline,
  }

  local rpc_ok, rpc_err = pcall(
    vim.rpcnotify,
    chan,
    "nvim_exec_lua",
    RPC_REQUEST,
    { reply_chan, id, expr, deadline }
  )
  if not rpc_ok then return finish(nil, rpc_err) end

  local cancel_request = function()
    local pending = _G.__mux_pending[id]
    if not pending or pending.status == "running" then
      return
    end
    finish(nil, "TIMEOUT")
  end

  if cb then
    timer:start(TIMEOUT_REMOTE_EXPR_MS + 100, 0, function() cancel_request() end)
  else
    timer:close()
    vim.wait(TIMEOUT_REMOTE_EXPR_MS + 100, function() return done end, 10)
    if not done then
      cancel_request()
      if not done then return nil, "still running" end
    end
    return res_out, res_err
  end
end
M.remote_expr = remote_expr

---@return boolean?
local socket_listening = function(socket, cb)
  local exit = function(has_listener)
    if cb then
      vim.schedule(function() cb(has_listener) end)
      return nil
    else
      return has_listener
    end
  end

  if not uv.fs_stat(socket) then return exit(false) end

  local ok, pipe = pcall(uv.new_pipe, false)
  if not (ok and pipe) then return exit(false) end

  local timer = assert(uv.new_timer())
  local done, listening = false, nil

  local connect_cb = function(has_listener)
    if done then return end
    done = true
    if not timer:is_closing() then timer:close() end
    pipe:close()
    listening = exit(has_listener)
  end
  timer:start(TIMEOUT_LISTENING_MS, 0, function() connect_cb(false) end)
  pipe:connect(socket, function(err) connect_cb(err == nil) end)

  if cb == nil then
    vim.wait(TIMEOUT_LISTENING_MS, function() return done end, 10)
  end

  return listening
end

M.remote_call = function(socket, opts, cb)
  opts = opts or {}
  local f = M[opts.fn]
  if not f then return nil, tostring(opts.fn) .. " is not a valid function" end
  if not (type(f) == "function") then return nil, "invalid field" end

  if not socket_listening(socket) and opts.autostart then
    local id = fn.fnamemodify(socket, ":t:r")
    local ok, data = pcall(read_datafile, id_to_json(id))
    if not ok then return nil, data end
    if not (data.id and data.root) then return nil, "could not find root to initialize" end

    fs.mkdir(socket_dir(), { parents = true })
    local root = data.root
    local nvim_args = { "--headless", "--listen", socket, "-c", ("lua require'mux'.init(%q)"):format(root) }
    local system_opts = { cwd = root, detach = true, stdout = false, stderr = false }
    spawn_nvim(nvim_args, system_opts)

    local is_listening
    if not vim.wait(TIMEOUT_ATTACH_MS, function()
      -- vim.api.nvim__redraw({ flush = true })
      socket_listening(socket, function(listening) is_listening = listening end)
      return is_listening
    end, 20) then
      return nil, "server never listened"
    end
  end

  local expr = (
       [[vim.g.who_called_me = '%s' ]]
    .. [[local out,err = require'mux'.%s() ]]
    .. [[vim.g.who_called_me = nil ]]
    .. [[return out, err ]]
  ):format(vim.v.servername, opts.fn)

  return remote_expr(socket, expr, cb)
end


-- [public api] ---------------------------------------------------------------
M.attach = function()
  local who_called_me = vim.g.who_called_me
  if not who_called_me                 then return nil, "attach can only be called from a remote context" end
  if who_called_me == vim.v.servername then return nil, "cannot attach to self" end

  local state = M.remote_call(who_called_me, { fn = "get_state" })
  local bang = state == nil or state == vim.NIL

  local expr = ([[
    vim.schedule(function()
      vim.cmd.connect({ bang = %s, args = { %q } })
    end)
  ]]):format(bang, vim.v.servername)

  return remote_expr(who_called_me, expr)
  -- local expr = ("nvim_echo([['SUCCESS', 'DiagnosticOk'], [' connected to %s']], v:false, {})"):format(target.socket)
end

local save_session = function()
  fs.mkdir(session_dir(), { parents = true })
  vim.cmd.mksession { args = { fn.fnameescape(current_server.session) }, bang = true }
end

---initialize `root` as a Mux server
---@param root? string
---@return boolean? success
---@return string? error
M.init = function(root)
  if current_server then return nil, "a mux server is already active" end

  if not root then
    local err
    root, err = find_project_root()
    if not root then return nil, err end
  end
  local id = root_to_id(root)
  local server = {
    root = root,
    id = id,
    name = id_to_name(id),
    session = id_to_session(id),
    socket = id_to_socket(id),
  }

  current_server = server
  pcall(vim.cmd.source, {
    args = { fn.fnameescape(current_server.session) },
    mods = { silent = true },
  })

  api.nvim_create_autocmd("VimLeavePre", {
    desc = "save session on vim leave",
    group = augroup,
    callback = function() save_session() end,
  })

  local set_detachBANG = function()
    pcall(function() vim.cmd("silent detach!") end)
  end
  api.nvim_create_autocmd("UIEnter", { group = augroup, callback = set_detachBANG })
  if next(api.nvim_list_uis()) then set_detachBANG() end

  return M.save()
end

--- write session and json file
M.save = function()
  if not current_server then return nil, "no active mux server" end
  save_session()
  local data = json.encode(current_server)
  local jsonfile = id_to_json(current_server.id)
  fn.writefile(data, jsonfile)
  return true
end

M.get_state = function()
  if not current_server then
    return nil, "not an active mux server"
  else
    return current_server
  end
end

M.delete = function()
  if not current_server then
    return nil, "not an active mux server"
  else
    local ok, err = pcall(fs.rm, current_server.session)
    if not ok then return nil, err end

    local jsonfile = id_to_json(current_server.id)
    ok, err = pcall(fs.rm, jsonfile)
    if not ok then return nil, err end

    pcall(api.nvim_del_augroup_by_id, augroup)
    vim.v.this_session = ""
    current_server = nil
    return true
  end
end

M.kill = function()
  local safe_to_close = true
  for _, bufnr in ipairs(api.nvim_list_bufs()) do
    if vim.bo[bufnr].modified then
      safe_to_close = false
      break
    end
  end
  if not safe_to_close then
    return nil, "server has unsaved changes"
  else
    vim.defer_fn(function() vim.cmd("qall") end, 50)
    return current_server
  end
end

M.list = function(opts)
  opts = opts or {}
  -- if current_listing then return current_listing end

  local items = {}
  local datafiles = fn.glob(session_dir() .. "/*.json", true, true)
  for _, datafile in ipairs(datafiles) do
    local item = read_datafile(datafile)
    item.active = socket_listening(item.socket)
    items[#items + 1] = item
  end

  -- if opts.discover then
  --   local seen, dirs = {}, {}
  --   for _, path in ipairs(vim.fs.find({ ".git", ".edis.json" }, { path = vim.env.HOME, limit = math.huge })) do
  --     local dir = vim.fs.dirname(path)
  --     if not seen[dir] then seen[dir] = true; items[#items + 1] = dir end
  --   end
  -- end

  table.sort(items, function(a, b)
    return a.active
  end)

  return items
end

M.pick = function()
  if package.loaded["mini.pick"] then
    vim.schedule(function() pcall(require("mini.pick").registry.mux) end)
    return true
  elseif package.loaded["snacks"] then
    return true
  end
  return nil, "no valid picker found"
end

local e = function(errmsg)
  local chunks = {
    { "(", "@punctuation.bracket" },
    { "error", "DiagnosticError" },
    { ") ", "@punctuation.bracket" },
    { errmsg, "MsgArea" }
  }
  api.nvim_echo(chunks, false, {})
end


-- [usercmd] ------------------------------------------------------------------
local subcmds = {
  init = M.init,
  list = function() vim.print(M.list()) end,
  attach = M.attach,
  save = M.save,
  pick = M.pick,
}
api.nvim_create_user_command("Mux", function(opts)
  local subcmd = subcmds[opts.fargs[1]] or function() end
  subcmd()
end, {
  nargs = "*",
    complete = function(arglead, cmdline, _)
      return vim.tbl_filter(function(k) return k:find('^' .. vim.pesc(arglead)) end,
        vim.tbl_keys(subcmds))
    end
  })

vim.keymap.set({"n"}, "<C-f><C-p>", "<Cmd>Mux pick<CR>")
vim.keymap.set({"n"}, "<C-f>p", "<C-f><C-p>", { remap = true })
vim.keymap.set({"n"}, "<C-w><C-d>", "<Cmd>detach<CR>")
vim.keymap.set({"n"}, "<C-w>d", "<C-w><C-d>", { remap = true })

return M
