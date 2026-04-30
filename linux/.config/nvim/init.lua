if vim.loader then vim.loader.enable() end
vim.g._start_time = vim.uv.hrtime()
vim.g.mapleader = " "

vim.g.hl_suspended = true
vim.g.minibuffer_height = 11

_G.P = vim.print
_G.Config = {}
_G.Pack = {}

-- local group = vim.api.nvim_create_augroup("")
---@param event vim.api.keyset.events|vim.api.keyset.events[]
---@param cb fun(ev: vim.api.keyset.create_autocmd.callback_args): boolean?
---@param opts? vim.api.keyset.create_autocmd
Config.on = function(event, cb, opts)
  opts = opts or {}
  opts.callback = cb
  vim.api.nvim_create_autocmd(event, opts)
end

vim.cmd.colorscheme "kanordwa2"

do
  local function lazy_require(modname)
    return setmetatable({}, {
      __index = function(t, k)
        local mod = require(modname)
        setmetatable(t, { __index = mod })
        return mod[k]
      end,
    })
  end
  _G.Win = lazy_require("ui.win")
  _G.Edis = lazy_require("edis")
  _G.Terminal = lazy_require("floaterminal")
  _G.Session = lazy_require("session")
  _G.Arglist = require "arglist" -- no lazy

  local quicksys = require("quicksys")
  quicksys.setup()
  local builtin = require("quicksys.builtin").sources
  quicksys.sources.default = builtin.flat
  quicksys.sources.Diagnostics = builtin.nested
  quicksys.sources.References = builtin.nested
  _G.Quickfix = require "quicksys.quickfix"
end


---wraps vim.pack.add with a custom loader
---@param specs (string | vim.pack.Spec)[]
function Pack.add(specs)
  vim.pack.add(specs, {
    load = function(plug_data)
      local name = plug_data.spec.name
      local data = plug_data.spec.data or {}
      if data.enabled == false then return end
      if data.loader then
        data.loader(name)
      else
        vim.cmd.packadd(name)
      end
    end,
  })
end

---@alias loader fun(name: string, ev?: vim.api.keyset.create_autocmd.callback_args)
---
---@param event vim.api.keyset.events
---@param loader loader
---@return loader
function Pack.load_on_event(event, loader)
  return function(name)
    local event_str = type(event) == "table" and table.concat(event, ", ") or event
    local desc = "lazy load " .. name .. " on event: " .. event_str
    local group = vim.api.nvim_create_augroup("lazy-load-" .. name, {})
    -- NOTE: when you want to lazy load on multiple events like { "CmdlineEnter", "InsertEnter" },
    -- it seems to fire the callback on both events, which is NOT what I want...
    -- so i use this loaded flag to prevent multiple events from loading multiple times
    local loaded = false
    Config.on(event, function(ev)
      if loaded then return true end
      loader(name, ev)
      loaded = true
    end, { desc = desc, group = group })
  end
end

do
  -- vimenter queue idea from
  -- https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/
  local queue = {}

  ---@param loader loader
  ---@return loader
  function Pack.load_on_loop(loader)
    return function(name)
      queue[#queue + 1] = {
        name = name,
        load = function() loader(name) end,
      }
    end
  end

  -- timer delay idea from
  -- https://github.com/nvim-mini/mini.nvim/blob/main/lua/mini/misc.lua#L378
  local function drain_queue_w_debounce(debounce, verbose)
    local timer = assert(vim.loop.new_timer())
    local REPEAT = 0
    local fn
    fn = vim.schedule_wrap(function()
      local next_up = queue[1]
      if next_up == nil then
        if not timer:is_closing() then timer:close() end
        return
      end
      table.remove(queue, 1)

      local start = vim.loop.hrtime()
      next_up.load()
      local stop = vim.loop.hrtime()

      if verbose then
        local time_in_ms = (stop - start) / 1e6
        local msg = ("LOADED: %s in %.2fms"):format(next_up.name, time_in_ms)
        vim.api.nvim_echo({{ msg }}, true, {
          kind = "progress", status = "success", source = "config"
        })
      end

      timer:start(debounce, REPEAT, fn)
    end)

    timer:start(1, REPEAT, fn)
  end

  Config.on("VimEnter", function() drain_queue_w_debounce(5, false) end, { once = true })
end


require "ui.statusline"
require "ui.statuscol"
require "ui.winbar"
require "vim._core.ui2".enable {
  enable = true,
  msg = {
    targets = {
      confirm      = "cmd",
      echo         = "cmd",
      echomsg      = "cmd",
      search_cmd   = "cmd",
      search_count = "cmd",
      lua_print    = "cmd",
      wmsg         = "cmd",
      list_cmd     = "cmd",
      emsg         = "cmd",
      lua_error    = "cmd",

      bufwrite = "msg",
      progress = "msg",
      undo     = "msg",

      rpc_error = "pager",

      -- shell_cmd = "cmd",
      -- shell_err = "cmd",
    },
    msg = { timeout = 4000 },
    pager = { height = 0.75 },
  }
}
-- require "ui.messages"
require "ui.minibuffer"
