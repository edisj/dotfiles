local snacks = require("snacks")
local explorer_width = 30
local explorer_box_width = explorer_width
local explorer_preview = false
local explorer_preview_width = 0.6

local function explorer_on_show(picker)

  local on_update_pre = picker.layout.opts.on_update_pre
  picker.layout.opts.on_update_pre = function(layout)
    if on_update_pre then on_update_pre(layout) end
    if not layout.opts.fullscreen then return end
    local avail = vim.o.lines - vim.o.cmdheight - (vim.o.laststatus == 3 and 1 or 0)
    for _, win in pairs(layout.wins) do
      if win.enabled and win.opts.row + win.opts.height >= avail then
        win.opts.height = win.opts.height - 1
      end
    end
  end

  -- local update_cursorline = picker.list.update_cursorline
  -- picker.list.update_cursorline = function(self, ...)
  --   local ret = update_cursorline(self, ...)
  --   if self.win:win_valid() then
  --     Snacks.util.wo(self.win.win, { winhighlight = self.win.opts.wo.winhighlight })
  --   end
  --   return ret
  -- end

  local function keep_fillchars()
    local fillchars = "eob: ,lastline:…,vert:▕"
    local box = picker.layout.root.win
    if vim.api.nvim_win_is_valid(box) and vim.wo[box].fillchars ~= fillchars then
      vim.wo[box].fillchars = fillchars
    end
  end
  local on_update = picker.layout.opts.on_update
  picker.layout.opts.on_update = function(layout)
    on_update(layout)
    keep_fillchars()
  end
  keep_fillchars()

  local base = explorer_width
  local resize = vim.schedule_wrap(function()
    local root = picker.layout.root.win
    if not (root and vim.api.nvim_win_is_valid(root)) then return end
    local actual = vim.api.nvim_win_get_width(root)
    if actual ~= explorer_box_width then
      base, explorer_box_width = actual, actual
    end
    local want = math.min(
      math.min(vim.api.nvim_strwidth(picker.opts.prompt), 30)
      + vim.api.nvim_strwidth(picker.input:get())
      + vim.api.nvim_strwidth(picker.input.totals)
      + 2,
      math.floor(vim.o.columns * 0.6)
    )
    want = math.max(math.ceil(want / 10) * 10, base)
    if want == actual then return end

    explorer_box_width = want
    vim.api.nvim_win_resize(root, want, -1)
  end)

  picker.input.win:on({ "TextChangedI", "TextChanged" }, resize, { buf = true })

  picker.input.win:on("WinLeave", function()
    if not picker.layout.opts.fullscreen then return end
    vim.schedule(function()
      if picker.closed or not picker.layout.opts.fullscreen then return end
      picker:action("toggle_maximize")
    end)
  end, { buf = true })

  local input_update = picker.input.update
  picker.input.update = function(self, ...)
    local totals = self.totals
    local ret = input_update(self, ...)
    if self.totals ~= totals then resize() end
    return ret
  end

  local update_titles = picker.update_titles
  picker.update_titles = function(self, ...)
    local cwd = vim.fn.fnamemodify(self:cwd(), ":~")
    -- self.title = "Explorer " .. vim.fn.pathshorten(cwd)
    -- self.title = vim.fn.pathshorten(cwd)
    self.opts.prompt = vim.fn.pathshorten(cwd) .. "/"
    self.input:update()
    resize()
    return update_titles(self, ...)
  end
  picker:update_titles()

  -- local matcher_on_done = picker.matcher.opts.on_done
  -- picker.matcher.opts.on_done = function(matcher)
  --   if matcher_on_done then matcher_on_done(matcher) end
  --   for item, idx in picker:iter() do
  --     if not item.child_match_only then
  --       picker.list:set_target(idx, nil, { force = true })
  --       picker:update()
  --       break
  --     end
  --   end
  -- end

  -- local list = picker.list
  -- local render = list.render
  -- list.render = function(self, ...)
  --   local item = self.cursor == 1 and self.items[1] or nil
  --   if item and item.child_match_only then
  --     for it, idx in picker:iter() do
  --       if not it.child_match_only then
  --         self.target = { cursor = idx, top = self.top }
  --         break
  --       end
  --     end
  --   end
  --   return render(self, ...)
  -- end

  local list = picker.list

  local clear = list.clear
  list.clear = function(self, ...)
    local cursor = self.cursor
    local top = self.top
    local ret = clear(self, ...)
    self.cursor = cursor
    self.top = top
    return ret
   end

  -- local render = list.render
  -- list.render = function(self, ...)
  --   if picker:is_active() and self.cursor == 1 then
  --     for it, idx in picker:iter() do
  --       if not it.child_match_only then
  --         self:_move(idx, true, false)
  --         break
  --       end
  --     end
  --   end
  --   return render(self, ...)
  -- end

end

local function file_step(picker, step)
  for _ = 1, picker.list:count() do
    local prev = picker.list.cursor
    picker.list:move(step)
    if picker.list.cursor == prev then return end
    local item = picker:current()
    -- if item and not item.dir then return end
    if item and not item.child_match_only then return end
  end
end

local explorer_actions = {

  explorer_pick = function(picker, item, action)
    if item and not item.dir then
      snacks.picker.actions.jump(picker, item, action)
      vim.schedule(function()
        if picker.closed then return end
        picker.input:set("", "")
        picker:find()
        local main = vim.api.nvim_get_current_win()
        picker.list.win:focus()
        vim.api.nvim_set_current_win(main)
      end)
      return
    end
    return picker:action("confirm")
  end,

  explorer_dive = function(picker)
    picker:set_cwd(picker:dir())
    picker.input:set("", "")
    picker:find()
  end,

  toggle_maximize = function(picker)
    picker.layout:maximize()
    -- picker:toggle("preview", { enable = picker.layout.opts.fullscreen == true })
    explorer_preview = picker.layout.opts.fullscreen == true
    picker:toggle("preview", { enable = explorer_preview })
  end,

  select_files = function(picker)
    local files = {}
    for item in picker:iter() do
      if not item.dir then
        files[#files + 1] = item
      end
    end
    picker.list:set_selected(#picker.list.selected == #files and {} or files)
  end,

  list_file_down = function(picker) file_step(picker, 1) end,
  list_file_up = function(picker) file_step(picker, -1) end,

  input_esc = function(picker)
    picker.input:set("", "")
    picker:find()
    vim.cmd("wincmd p")
  end,
}

local explorer_tick = -1

local function explorer_on_match(matcher, item)
  explorer_tick = matcher.tick
  local score, parent = item.score, item.parent
  while parent do
    if parent.best_tick ~= matcher.tick then
      parent.best_tick, parent.best = matcher.tick, 0
    end
    if score <= parent.best then break end
    parent.best = score
    parent = parent.parent
  end
end

local function explorer_rank(item)
  local score = item.score or 0
  if item.best_tick == explorer_tick and item.best > score then return item.best end
  return score
end

local function explorer_chain(item)
  local chain, n = {}, 0
  while item do
    n = n + 1
    chain[n] = item
    item = item.parent
  end
  return chain, n
end

local function explorer_sort(a, b)
  local ca, na = explorer_chain(a)
  local cb, nb = explorer_chain(b)
  local i = 1
  while i <= na and i <= nb and ca[na - i + 1] == cb[nb - i + 1] do
    i = i + 1
  end
  local x, y = ca[na - i + 1], cb[nb - i + 1]
  if x == y then return false end
  if not x then return true end
  if not y then return false end
  local rx, ry = explorer_rank(x), explorer_rank(y)
  if rx ~= ry then return rx > ry end
  if x.dir ~= y.dir then return x.dir == true end
  return (x.sort or "") < (y.sort or "")
end


local explorer_layout = {
  layout = {
    backdrop = false,
    width = explorer_width,
    min_width = 25,
    position = "left",
    border = "none",
    box = "horizontal",
    [1] = {
      box = "vertical",
      -- width = function() return explorer_preview and explorer_box_width or 0 end,
      width = function() return explorer_preview and (1-explorer_preview_width) or 0 end,
      [1] = { win = "input", height = 1, border = "none" },
      [2] = { win = "list", border = "none" },
    },
    [2] = { win = "preview", width = 0, border = "left" },
  },
}

local explorer_win = {
  list = {
    keys = {
      -- ["l"]  = false,
    },
    wo = {
      scrolloff = 0,
      cursorline = true,
    }
  },
  input = {
    keys = {
      ["<CR>"]   = { "explorer_pick",   mode = { "i", "n" } },
      ["<S-CR>"] = { "explorer_dive",   mode = { "i", "n" } },
      ["<C-n>"]  = { "list_file_down",  mode = { "i", "n" } },
      ["<C-p>"]  = { "list_file_up",    mode = { "i", "n" } },
      ["<Esc>"]  = { "input_esc",       mode = { "i" } },
      ["<C-c>"]  = { "input_esc",       mode = { "i" } },
      ["<C-x>"]  = { "select_files",    mode = { "i", "n" } },
      ["<Tab>"]  = { "toggle_maximize", mode = { "i" } },
      ["<M-j>"]  = { "preview_scroll_down", mode = { "i", "n" } },
      ["<M-k>"]  = { "preview_scroll_up", mode = { "i", "n" } },
    },
  },
}

return function(opts)
  local defaults = {
    git_status = false,
    diagnostics = false,
    -- matcher = { fuzzy = false },
    matcher = { fuzzy = true, on_match = explorer_on_match },
    sort = explorer_sort,

    format = function(item, picker)
      local ret = Snacks.picker.format.file(item, picker)
      if item.dir then
        for i = #ret, 1, -1 do
          if ret[i].field == "file" then
            ret[i][1] = ret[i][1] .. "/"
            break
          end
        end
      end
      return ret
    end,

    layout  = explorer_layout,
    actions = explorer_actions,
    on_show = explorer_on_show,
    win     = explorer_win,
  }

  opts = vim.tbl_deep_extend("force", defaults, opts or {})
  snacks.explorer(opts)
end
