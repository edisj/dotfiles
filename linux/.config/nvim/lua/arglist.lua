local fn = vim.fn
local api = vim.api

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

local KEYS = { "q", "w", "e", "r", "s", "d", "f" }
-- local KEYS = { "q", "w", "e", "r" }

local arglist = setmetatable({}, {
  __index = function(t, k)
    if type(k) == "number" then
      return fn.argv()[k]
    elseif vim.tbl_contains(KEYS, k) then
      return vim.g["Arglist_" .. k]
    elseif k == false then
      return ""
    else
      return rawget(t, k)
    end
  end,
  __newindex = function(t, k, v)
    if type(k) == "number" then
      e("cannot set array portion of Arglist")
    elseif vim.tbl_contains(KEYS, k) then
      vim.g["Arglist_" .. k] = v
    elseif k == false then
      e("false is reserved")
    else
      rawset(t, k, v)
    end
  end,
  __call = function(_, i)
    return i == nil and fn.argv() or fn.argv()[i]
  end,
})

arglist.keys = function()
  return KEYS
end

-- NOTE: scheduled to give session file time to load
vim.schedule(function()
  for _, k in ipairs(KEYS) do
    arglist[k] = vim.g["Arglist_" .. k] or false
  end
end)

local function not_pointed_to(i)
  for _, k in ipairs(KEYS) do
    if arglist[k] == i then return false end
  end
  return true
end

local function set_first_empty(i)
  for _, k in ipairs(KEYS) do
    if not arglist[k] then
      arglist[k] = i
      return
    end
  end
end

function arglist.sync()
  -- remove overflow
  while fn.argc() > #KEYS do
    vim.cmd(fn.argc() .. "argdelete")
  end

  -- clear keys that don't point to valid args anymore
  for i = fn.argc() + 1, #KEYS do
    for _, k in ipairs(KEYS) do
      if arglist[k] == i then
        arglist[k] = false
      end
    end
  end

  -- ensure every arg is pointed to by at least one key
  for i, _ in ipairs(arglist()) do
    if not_pointed_to(i) then set_first_empty(i) end
  end
end

local function with_sync(f)
  return function(...)
    arglist.sync()
    f(...)
    arglist.sync()
  end
end

local function del_key(k)
  if arglist[k] == false then return end
  local i = arglist[k]
  vim.cmd(i .. "argdelete")
  for _, key in ipairs(KEYS) do
    if arglist[key] and arglist[key] == i then arglist[key] = false end
    if arglist[key] and arglist[key] > i then arglist[key] = arglist[key] - 1 end
  end
end

local function set_key(k, file)
  del_key(k)
  if fn.argc() == #KEYS then return e("arglist is full") end
  file = file or api.nvim_buf_get_name(0)
  vim.cmd(fn.argc() .. "argadd " .. file)
  arglist[k] = fn.argc()
end

arglist.set_key = with_sync(set_key)
arglist.del_key = with_sync(del_key)
arglist.wipe = function()
  vim.cmd("argdelete *")
  arglist.sync()
end

arglist.jump_to = with_sync(function(k)
  if not arglist[k] then return end
  local file = arglist[arglist[k]]
  if fn.fnamemodify(file, ":p") == fn.expand("%:p") then return end
  vim.cmd.edit(file)
end)

function arglist.statuscol()
  return KEYS[vim.v.lnum] and ("  %s "):format(KEYS[vim.v.lnum]) or "  ~ "
end

local _win
function arglist.win()
  if _win then return _win end
  local winopts = {
    relative = "minibuffer",
    bufnr = function(_)
      local bufnr = api.nvim_create_buf(false, true)
      local name = ("arglist://%s//"):format(bufnr)
      api.nvim_buf_set_name(bufnr, name)
      return bufnr
    end,
    position = "center",
    enter = true,
    width = 50,
    height = #KEYS,
    title = " arglist ",
    -- footer = { { "arglist", "NormalFloat" } },
    -- footer_pos = "center",
    -- style = "minimal",
    bo = {
      bufhidden = "wipe",
      filetype = "arglist"
    },
    wo = {
      statuscolumn = "%{%v:lua.Arglist.statuscol()%}",
      cursorline = true,
      winhl = "LineNr:NormalFloat",
      winfixbuf = true,
    },
  }
  _win = Win.float(winopts)

  _win:on({ "BufLeave", "WinLeave" }, function()
    vim.defer_fn(function()
      if not _win:is_focused() then
        _win:close()
      end
    end, 250)
  end, { win = true })

  return _win
end

function arglist.open(override_opts)
  arglist.sync()
  local lines = vim
    .iter(ipairs(KEYS))
    :map(function(_, k) return arglist[arglist[k]]
    end)
    :totable()
  return arglist.win():open(override_opts):set_lines(lines).winid
end

function arglist.toggle(override_opts)
  return not arglist.win():is_open() and arglist.open(override_opts) or arglist.win():close() and false
end

return arglist
