local nmap = Config.nmap

local ensure_center_layout = function(ev)
  local state = MiniFiles.get_explorer_state()
  if state == nil then return end

  -- Compute "depth offset" - how many windows are between this and focused
  local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match('^minifiles://%d+/(.*)$')
  local depth_this
  for i, path in ipairs(state.branch) do
    if path == path_this then depth_this = i end
  end
  if depth_this == nil then return end
  local depth_offset = depth_this - state.depth_focus

  local widths = { 40, 20, 10 }
  -- Adjust config of this event's window
  local i = math.abs(depth_offset) + 1
  local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
  win_config.width = i <= #widths and widths[i] or widths[#widths]

  win_config.zindex = 99
  win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
  local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
  for j = 1, math.abs(depth_offset) do
    -- widths[j+1] for the negative case because we don't want to add the center window's width
    local prev_win_width = (sign == -1 and widths[j+1]) or widths[j] or widths[#widths]
    -- Add an extra +2 each step to account for the border width
    local new_col = win_config.col + sign * (prev_win_width + 2)
    if (new_col < 0) or (new_col + win_config.width > vim.o.columns) then
      win_config.zindex = win_config.zindex - 1
      break
    end
    win_config.col = new_col
  end

  -- local tail = vim.fn.fnamemodify(path_this, ":t") .. " "
  -- win_config.title = tail == " " and "/ " or tail
  win_config.height = depth_offset == 0 and 22 or 18
  win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
  vim.api.nvim_win_set_config(ev.data.win_id, win_config)
end

local function setup_mini_files()
  local mini_files = require("mini.files")

  mini_files.setup({
    mappings = {
      mark_goto = "<leader>",
      go_in_plus = "<CR>",
    },
    windows = {
      width_nofocus = 10,
      width_focus = 40,
      preview = false,
      width_preview = 50,
    },
  })

  local augroup = vim.api.nvim_create_augroup("mini-files-user-events", {})
  local function on(mini_files_event, cb)
    Config.on("User", cb, {
      group = augroup,
      pattern = "MiniFiles" .. mini_files_event })
  end

  on("BufferCreate", function(ev)
    vim.keymap.set({"n", "i", "x"}, "<C-s>", function()
      vim.cmd.stopinsert()
      mini_files.synchronize()
    end, { desc = "MiniFiles synchronize", buffer = ev.data.buf_id })
  end)
  -- asldkfjkl

  on("ExplorerOpen", function(ev)
    MiniFiles.set_bookmark("c", vim.fn.stdpath("config") .. "/lua", { desc = "Config" })
    MiniFiles.set_bookmark("w", vim.fn.getcwd, { desc = "Working directory" })
    MiniFiles.set_bookmark("v", vim.fn.expand("$VIMRUNTIME".."/lua"), { desc = "vim runtime" })
    MiniFiles.set_bookmark("~", "~", { desc = "Home directory" })
  end)

  on("WindowOpen", function(ev)
    local win_id = ev.data.win_id
    local config = vim.api.nvim_win_get_config(win_id)
    config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
    config.title_pos = "left"
    vim.api.nvim_win_set_config(win_id, config)
    vim.wo[win_id].scrolloff = 2
    vim.wo[win_id].sidescrolloff = 0
  end)

  on("WindowUpdate", ensure_center_layout)

  local function go_in_and_arglist(k)
    local path = (mini_files.get_fs_entry() or {}).path
    if path == nil then return vim.notify('Cursor is not on valid entry') end
    if vim.uv.fs_stat(path).type ~= "file" then return end
    Arglist.set_key(k, path)
    mini_files.go_in({ close_on_file = true })
  end

  local map_split = function(buf_id, lhs, direction)
    local rhs = function()
      -- Make new window and set it as target
      local cur_target = MiniFiles.get_explorer_state().target_window
      local new_target = vim.api.nvim_win_call(cur_target, function()
        vim.cmd(direction .. " split")
        return vim.api.nvim_get_current_win()
      end)

      MiniFiles.set_target_window(new_target)

      -- This intentionally doesn't act on file under cursor in favor of
      -- explicit "go in" action (`l` / `L`). To immediately open file,
      -- add appropriate `MiniFiles.go_in()` call instead of this comment.
      MiniFiles.go_in({ close_on_file = true })
    end

    -- Adding `desc` will result into `show_help` entries
    local desc = "Split " .. direction
    nmap(lhs, rhs, { buffer = buf_id, desc = desc })
  end

  on("BufferCreate", function(ev)
    local buf_id = ev.data.buf_id
    for _, k in ipairs(Arglist.keys()) do
      nmap("<M-S-" .. k .. ">", function() go_in_and_arglist(k) end, { buffer = buf_id })
    end
    map_split(buf_id, "<M-S-l>", "belowright vertical")
    map_split(buf_id, "<M-S-j>", "belowright horizontal")
    map_split(buf_id, "<M-S-h>", "topleft vertical")
    map_split(buf_id, "<M-S-k>", "topleft horizontal")
  end)

  nmap("<C-e>", function()
    if not mini_files.close() then
      mini_files.open(vim.api.nvim_buf_get_name(0), false)
    end
  end, { desc = "MiniFiles toggle" })
  nmap("<leader><C-e>", function()
    if not mini_files.close() then
      mini_files.open(nil, true)
    end
  end, { desc = "MiniFiles toggle" })

end

Pack.load_on_loop(function() setup_mini_files() end)("mini.files")
