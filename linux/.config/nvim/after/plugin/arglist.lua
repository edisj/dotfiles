local api, fn, fs = vim.api, vim.fn, vim.fs

local augroup = api.nvim_create_augroup("plugin.arglist", { clear = true })

local function e(msg)
  local chunks = {
    { "[Arglist] ", "comment" },
    { "(", "@punctuation.bracket" },
    { "error", "DiagnosticError" },
    { "): ", "@punctuation.bracket" },
    { msg, "MsgArea" },
  }
  api.nvim_echo(chunks, true, {})
end

local emit_update = function()
  api.nvim_exec_autocmds("User", { pattern = "ArgUpdate" })
end

local vtable = { "1", "2", "3", "4", "5", "6", "7", "8", "9", "0" }
local arglist = setmetatable({}, {
  __index = function(self, k)
    return type(k) == "number" and fn.argv()[k]
           or vim.list_contains(vtable, k) and vtable[k]
           or rawget(self, k)
  end,
  __newindex = function(self, k, v)
    if type(k) == "number" then
      e("cannot set array portion of Arglist")
    elseif vim.list_contains(vtable, k) then
      vtable[k] = v
    else
      rawset(self, k, v)
    end
  end,
  __call = function(_, i)
    return i == nil and fn.argv() or fn.argv()[i]
  end,
})
_G.arglist = arglist
arglist.vtable = vtable

local function has_vtable_pointer(argidx)
  for _, k in ipairs(vtable) do
    if vtable[k] == argidx then return true end
  end
  return false
end

function arglist.sync()
  -- remove overflow
  if fn.argc() > #vtable then
    vim.cmd((#vtable+1) .. ",$argdel")
  end
  for _, k in ipairs(vtable) do
    if vtable[k] and vtable[k] > fn.argc() then
      vtable[k] = nil
    end
  end

  -- ensure every arg is pointed to by at least one key
  for argidx, _ in ipairs(arglist()) do
    if not has_vtable_pointer(argidx) then
      for _, k in ipairs(vtable) do
        if not vtable[k] then vtable[k] = argidx; break end
      end
    end
  end
end

local function with_sync(f)
  return function(...)
    arglist.sync()
    f(...)
    arglist.sync()
  end
end

local function del(key)
  if not vtable[key] then return end
  local argidx = vtable[key]
  vim.cmd(argidx .. "argdelete")
  for _, k in ipairs(vtable) do
    if vtable[k] and vtable[k] == argidx then vtable[k] = nil end
    if vtable[k] and vtable[k] > argidx then vtable[k] = vtable[k] - 1 end
  end
  emit_update()
end

---@param key string
local function add(key, file)
  del(key)
  if fn.argc() == #vtable then return e("arglist is full") end
  file = file or api.nvim_buf_get_name(0)
  vim.cmd(fn.argc() .. "argadd " .. file)
  vtable[key] = fn.argc()
  emit_update()
end

arglist.add = with_sync(add)
arglist.del = with_sync(del)
arglist.wipe = function()
  vim.cmd("%argd")
  arglist.sync()
end
arglist.jump_to = with_sync(function(k)
  local argidx = type(k) == "string" and vtable[k] or k
  local file = arglist[argidx]
  if
    not file
    or fs.abspath(api.nvim_buf_get_name(0)) == fs.abspath(file)
  then
    return
  end
  vim.cmd(argidx .. "argument")
end)

function arglist.statuscol()
  return vtable[vim.v.lnum] and ("  %s "):format(vtable[vim.v.lnum]) or "  ~ "
end

function arglist.tab_on_click(argidx, _, button, _)
  if button == "l" then
    arglist.jump_to(argidx)
  elseif button == "r" then
    vim.notify("R: " .. argidx)
  end
end

function arglist.tabline(format_tab, sep)
  format_tab = format_tab or function(name, key) return name end
  return table.concat(vim
    .iter(ipairs(vtable))
    :map(function(_, k)
      local argidx = vtable[k]
      local name = arglist[argidx]
      if not (name and name ~= "") then return end
      return "%" .. argidx .. "@v:lua.arglist.tab_on_click@" .. format_tab(name, k) .. "%X"
    end)
    :totable(), sep or "")
end

local win
local win_valid = function() return win and api.nvim_win_is_valid(win) end
local open_arglist = function()
  if win_valid() then return win end

  local buf = api.nvim_create_buf(false, true)
  api.nvim_buf_set_name(buf, "arglist://" .. buf .. "/listing")
  vim.bo[buf].bufhidden = "wipe"
  vim.bo[buf].filetype = "arglist"
  vim.bo[buf].buftype = "nofile"
  -- vim.bo[buf].omnicomplete = "v:lua.vim.fn.pathcomplete"
  local lines = vim
    .iter(ipairs(vtable))
    :map(function(_, k) return arglist[vtable[k]] or "" end)
    :totable()
  api.nvim_buf_set_lines(buf, 0, -1, false, lines)

  local compute_width = function(buflines)
    -- local width = math.floor(0.5 * vim.o.columns)
    local width = 40
    for _, line in ipairs(buflines) do
      if #line > width then width = #line end
    end
    return width + 5
  end
  local compute_pos = function(h, w)
    local row = math.floor(0.5*(vim.o.lines - h))
    local col = math.floor(0.5*(vim.o.columns - w))
    return row, col
  end

  local height = #vtable
  local width = compute_width(lines)
  local row, col = compute_pos(height, width)
  local win_cfg = {
    relative = "editor",
    row = row,
    col = col,
    width = compute_width(lines),
    height = height,
    style = "minimal",
    title = " arglist ",
    title_pos = "center",
    border = "solid",
  }

  win = api.nvim_open_win(buf, true, win_cfg)
  vim.wo[win].statuscolumn = "%{%v:lua.arglist.statuscol()%}"
  vim.wo[win].winfixbuf = true
  vim.wo[win].cursorline = true
  vim.wo[win].scrolloff = 0
  vim.wo[win].sidescrolloff = 0

  local update_win = function(buflines)
    local w = compute_width(buflines)
    local r, c = compute_pos(height, w)
    api.nvim_win_set_config(win, { relative = "editor", width = w, row = r, col = c })
  end

  on("TextChanged", augroup, { buf = buf }, function(ev)
    if not win_valid() then return true end
    arglist.wipe()
    local buflines = api.nvim_buf_get_lines(buf, 0, -1, false)
    for i, path in ipairs(buflines) do
      if i > #vtable then goto continue end
      local k = tostring(i % 10)
      if path == "" then
        vtable[k] = nil
      else
        add(k, path)
      end
      ::continue::
    end
    emit_update()
    update_win(buflines)
  end)

  on("TextChangedI", augroup, { buf = buf }, function()
    local buflines = api.nvim_buf_get_lines(buf, 0, -1, false)
    vim.schedule(function()update_win(buflines) end)
  end)

  on("WinLeave", augroup, function(ev)
    if not win_valid() then return true end
    vim.defer_fn(function()
      if win_valid() then
        api.nvim_win_close(win, true)
      end
    end, 50)
  end)
end

api.nvim_create_user_command("Arglist", function(args)
  if win_valid() and args.bang then
    api.nvim_win_close(win, true)
  else
    open_arglist()
  end
end, { bang = true, nargs = 0, desc = "Open Arglist" })

-- api.nvim_create_user_command("ArgAdd", function(args)
--   local file = args.fargs[1] and fn.expand(args.fargs[1]) or fn.expand("%")
--   arglist.add(nil, file)
-- end, { nargs = "*" })

map("<M-`>", "<Cmd>Arglist!<CR>")

for _, k in ipairs(vtable) do
  map("<M-"..k..">", function() arglist.jump_to(k) end, {
    desc = ("arglist %s"):format(k)})

  map("<M-S-" .. k .. ">", function() arglist.add(k, nil) end, {
    desc = ("set arglist %s"):format(k) })

  map("d<M-"..k..">", function() arglist.del(k) end)
end

on("SessionWritePre", augroup, function()
  for _, k in ipairs(vtable) do
    local argidx = vtable[k]
    vim.g["Arglist_" .. k] = argidx
  end
  vim.schedule(function()
    for _, k in ipairs(vtable) do
      vim.g["Arglist_" .. k] = nil
    end
  end)
end)

local pending = false
on("SessionLoadPost", augroup, function()
  if pending then return end
  pending = true
  vim.schedule(function()
    pending = false
    for _, k in ipairs(vtable) do
      vtable[k] = vim.g["Arglist_" .. k]
      vim.g["Arglist_" .. k] = nil
    end
  end)
end)

if vim.v.startreason == "normal" then
  if vim.v.this_session ~= "" then
    for _, k in ipairs(vtable) do
      vtable[k] = vim.g["Arglist_" .. k]
      vim.g["Arglist_" .. k] = nil
    end
  else
    for i = fn.argc(), 1, -1 do
      local arg = fn.argv(i-1) --[[@as string]]
      if vim.uv.fs_stat(arg).type == "directory" then
        vim.cmd((i) .. "argdel")
      end
    end
    arglist.sync()
  end
end
