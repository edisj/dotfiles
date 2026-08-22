local fn, fs, uv = vim.fn, vim.fs, vim.uv
local pack = {}
_G.pack = pack

pack.loaded = {}

local _load = function(plug_data, name)
  name = name or plug_data.spec.name
  local data = plug_data.spec.data or {}
  if data.enable == false then return end

  pack.loaded[assert(name)] = {
    path = plug_data.path,
    src = plug_data.spec.src,
    loaded = false
  }

  local do_load = function(...)
    if pack.loaded[name].loaded then return end
    local t1 = uv.hrtime()
    vim.cmd.packadd(name)
    if data.loader then data.loader(...) end
    local t2 = uv.hrtime()
    pack.loaded[name].loaded = true
    pack.loaded[name].load_time_ms = (t2 - t1) / 1e6
  end

  if not (data.event or data.defer) then
    -- load immediately
    do_load(name)
    return
  end
  if data.defer then pack.gen_loop_loader(do_load)(name) end
  if data.event then pack.gen_event_loader(data.event, do_load)(name) end
end

---wraps vim.pack.add with a custom loader
---@param specs (string | vim.pack.Spec)[]
pack.add = function(specs)
  vim.pack.add(specs, { load = _load })
end

local LOCAL_PACKPATH = fs.joinpath(fn.stdpath("data"), "/site/pack/dev/opt/")
local fs_symlink = function(src_path)
  if not uv.fs_stat(src_path) then
    local err = src_path .. " not found"
    return nil, err
  end
  fn.mkdir(LOCAL_PACKPATH, "p")
  local name = fn.fnamemodify(src_path, ":t")
  local symlink = LOCAL_PACKPATH .. name
  local ok, err, err_name = uv.fs_symlink(src_path, symlink)
  if ok or err_name == "EEXIST" then
    return symlink, nil
  else
    return nil, err
  end
end

pack.add_local = function(specs)
  for _, spec in ipairs(specs) do
    local src_path = fn.expand(spec.src)
    local symlink, err = fs_symlink(src_path)
    if symlink then
      spec.name = fn.fnamemodify(src_path, ":t")
      -- mimic vim.pack's plug_data structure
      local plug_data = { path = symlink, spec = spec }
      _load(plug_data)
    else
      vim.notify(tostring(err), vim.log.levels.ERROR)
    end
  end
end

pack.gen_event_loader = function(events, do_load)
  return function(name)
    local event_str = type(events) == "table" and table.concat(events, ", ") or events
    local group = vim.api.nvim_create_augroup("lazy-load-" .. name, {})
    local desc = "lazy load " .. name .. " on event: " .. event_str
    on(events, group, { desc = desc, once = true }, do_load)
  end
end

-- vimenter queue idea from
-- https://fredrikaverpil.github.io/blog/2026/04/15/from-lazy.nvim-to-vim.pack/
local queue = {}
pack.gen_loop_loader = function(do_load)
  return function(name)
    queue[#queue + 1] = {
      name = name,
      load = function() do_load(name) end,
    }
  end
end

do
  -- timer delay idea from
  -- https://github.com/nvim-mini/mini.nvim/blob/main/lua/mini/misc.lua#L378
  local function drain_queue_w_debounce(debounce, verbose)
    local timer = assert(vim.loop.new_timer())
    local REPEAT = 0
    local f
    f = vim.schedule_wrap(function()
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

      timer:start(debounce, REPEAT, f)
    end)

    timer:start(1, REPEAT, f)
  end

  on("VimEnter", nil, { once = true }, function() drain_queue_w_debounce(5, false) end)
end
