local ok, dap = pcall(require, "dap")
if not ok then return end

local fn, uv = vim.fn, vim.uv

-- adapted from https://github.com/ibhagwan/nvim-lua/blob/49d9f452c4f0fc89b9165dfacc81f31f1a1c4102/lua/plugins/dap/lua.lua
local server, channel
local launch_server = function(opts)
  assert(dap.adapters.nlua, "no nlua adapter?")

  if channel then
    local pid = fn.rpcnotify(channel, "nvim_exec_lua", [[return require("osv").stop()]])
    fn.jobstop(channel)
    if type(uv.os_getpriority(pid) == "number") then
      uv.kill(pid, 9)
    end
    channel = nil
  end

  local cmd = { vim.v.progpath, "-u", "NONE", "-n", "--embed", "--headless" }
  channel = assert(fn.jobstart(cmd, { rpc = true }), "failed to jobstart nvim")

  local mode = fn.rpcrequest(channel, "nvim_get_mode")
  assert(not mode.blocking, "nvim is blocking")

  local request = "vim.opt.packpath:append({ vim.fn.stdpath('data') .. '/site' })"
  fn.rpcrequest(channel, "nvim_exec_lua", request, {})
  fn.rpcrequest(channel, "nvim_command", "packadd one-small-step-for-vimkind")

  server = fn.rpcrequest(channel, "nvim_exec_lua", "return require('osv').launch(...)", { opts })
  vim.wait(100)

  local msg = ("Server started on port %d, channel-id %d"):format(server.port, channel)
  vim.notify(msg)

  return server
end

dap.adapters.nlua = function(callback, config)
  if not config.port then
    launch_server()
    config.host = server.host
    config.port = server.port
  end
  callback({ type = "server", host = config.host, port = config.port })
  if type(config.after) == "function" then config.after() end
end

dap.configurations.lua = {
  {
    type = "nlua",
    name = "Debug current file",
    request = "attach",
    after = function()
      dap.listeners.after["setBreakpoints"]["osv"] = function(_, _)
        assert(channel, "RPC channel is nil")
        fn.rpcnotify(channel, "nvim_command", "luafile " .. fn.expand("%:p"))
        dap.listeners.after["setBreakpoints"]["osv"] = nil
      end
    end,
  },
  {
    type = "nlua",
    request = "attach",
    name = "Attach to running Neovim instance",
  },
  {
    name = "default?",
    type = "nlua",
    request = "attach",
  }
} -- }}}
