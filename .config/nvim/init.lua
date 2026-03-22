if vim.loader then vim.loader.enable() end

vim.g.mapleader = " "

vim.cmd.colorscheme "kanagawa"

require "ui.winbar"
require "ui.statusline"
require "ui.statuscol"
require "ui.wildermenu"
require("helpout").setup()
-- require("inspector").setup()

_G.P = vim.print

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
  _G.Win = lazy_require("win")
  _G.Edis = lazy_require("edis")
  _G.Arglist = lazy_require("arglist")
  _G.Terminal = lazy_require("floaterminal")
  _G.Session = lazy_require("session")
  _G.Quickfix = lazy_require("quickfix")
end

_G.Config = {}

Config.map = function(modes, lhs, rhs, opts)
  modes = type(modes) == "string" and vim.split(modes, "") or modes
  opts = vim.tbl_deep_extend("force", { silent = true }, opts or {})
  vim.keymap.set(modes, lhs, rhs, opts)
end

---wraps vim.pack.add with a custom loader
---@param specs (string | vim.pack.Spec)[]
Config.add = function(specs)
  vim.pack.add(specs, {
    load = function(plug_data)
      local data = plug_data.spec.data or {}
      if data.enabled == false then return end

      local name = plug_data.spec.name
      if data.loader then
        data.loader(name)
        return
      end
      vim.cmd.packadd(name)
    end,
  })
end

Config.on_event = function(event, loader)
  return function(name)
    local event_str = type(event) == "table" and table.concat(event, ", ") or event
    -- NOTE: when you want to lazy load on multiple events like { "CmdlineEnter", "InsertEnter" },
    -- it seems to fire the callback on both events, which is NOT what I want...
    -- so i use this loaded flag to prevent multiple events from loading multiple times
    local loaded = false
    vim.api.nvim_create_autocmd(event, {
      once = true,
      desc = "lazy load " .. name .. " on event: " .. event_str,
      group = vim.api.nvim_create_augroup("lazy-load-" .. name, {}),
      callback = function(ev)
        if loaded then return true end
        loader(name, ev)
        loaded = true
      end,
    })
  end
end

pcall(function()
  -- require("vim._core.ui2").enable {}
end)
