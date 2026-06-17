local nmap_leader = Config.nmap_leader
local nmap = Config.nmap

-- local _win_config = function()
--   local state = require("mini.pick").get_picker_state()
--   local is_preview = state ~= nil and state.buffers.preview == vim.api.nvim_win_get_buf(state.windows.main)
--   local is_info = state ~= nil and state.buffers.info == vim.api.nvim_win_get_buf(state.windows.main)
--   local preview_height = math.floor(0.80 * vim.o.lines)
--   local preview_width = math.floor(0.50 * vim.o.columns)
--   local main_height = math.floor(0.45 * vim.o.lines)
--   local main_width = math.floor(0.40 * vim.o.columns)
--   main_height = 20
--   main_width = 50
--   local width = is_preview and preview_width or main_width
--   local height = (is_preview or is_info) and preview_height or main_height
--   return {
--     relative = "laststatus",
--     anchor = "SW",
--     row = 0,
--     col = 2,
--     width = width,
--     height = height,
--     -- border = "bold",
--   }
-- end
-- local refresh_picker = vim.schedule_wrap(function()
--   if not require("mini.pick").is_picker_active() then return end
--   require("mini.pick").refresh()
-- end)
-- vim.api.nvim_create_autocmd("BufWinEnter", { callback = refresh_picker })

local ns_digit_prefix = vim.api.nvim_create_namespace("cur-buf-pick-show")
local function show_buf_lines(buf_id, items, query, opts)
  if items == nil or #items == 0 then return end

  -- Show as usual
  MiniPick.default_show(buf_id, items, query, opts)

  -- Move prefix line numbers into inline extmarks
  local lines = vim.api.nvim_buf_get_lines(buf_id, 0, -1, false)
  local digit_prefixes = {}
  for i, l in ipairs(lines) do
    local _, prefix_end, prefix = l:find("^(%s*%d+│)")
    if prefix_end ~= nil then
      digit_prefixes[i], lines[i] = prefix, l:sub(prefix_end + 1)
    end
  end

  vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
  for i, pref in pairs(digit_prefixes) do
    local opts = { virt_text = { { pref, "MiniPickNormal" } }, virt_text_pos = "inline" }
    vim.api.nvim_buf_set_extmark(buf_id, ns_digit_prefix, i - 1, 0, opts)
  end

  -- Set highlighting based on the curent filetype
  local ft = vim.bo[items[1].bufnr].filetype
  local has_lang, lang = pcall(vim.treesitter.language.get_lang, ft)
  local has_ts, _ = pcall(vim.treesitter.start, buf_id, has_lang and lang or ft)
  if not has_ts and ft then vim.bo[buf_id].syntax = ft end
end

local function setup_mini_pick()

  local function arglist_add(k)
    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end
    MiniPick.default_choose(current)
    Arglist.set_key(k, current)
    MiniPick.stop()
  end

  require("mini.pick").setup({
    -- See `:h MiniPick-actions`.
    mappings = {
      move_down  = "<C-j>",
      move_start = "<C-g>",
      move_up    = "<C-k>",

      refine        = "<C-Space>",
      refine_marked = "<C-M-Space>",

      mark              = "<C-e>",
      mark_all          = "<C-a>",
      choose_marked     = "<C-q>",
      choose_in_split   = "<M-S-j>",
      choose_in_tabpage = "<C-t>",
      choose_in_vsplit  = "<M-S-l>",

      delete_left       = '',

      scroll_down  = "<C-d>",
      scroll_left  = "<C-h>",
      scroll_right = "<C-l>",
      scroll_up    = "<C-u>",

      close_ = { char = "<C-f>", func = function() return true end },
      arglist_add_q = { char = "<M-S-q>", func = function() arglist_add("q") end },
      arglist_add_w = { char = "<M-S-w>", func = function() arglist_add("w") end },
      arglist_add_e = { char = "<M-S-e>", func = function() arglist_add("e") end },
      arglist_add_r = { char = "<M-S-r>", func = function() arglist_add("r") end },
      arglist_add_s = { char = "<M-S-s>", func = function() arglist_add("s") end },
      arglist_add_d = { char = "<M-S-d>", func = function() arglist_add("d") end },
      arglist_add_f = { char = "<M-S-f>", func = function() arglist_add("f") end },
    },
    options = {
      content_from_bottom = false,
      use_cache = true,
      hidden = true,
    },
    window = {
      config = function()
        return {
          relative = "msgarea",
          border = { "▔", "▔", "▔", " ", " ", " ", " ", " " },
          height = 20,
        }
    end,
      prompt_prefix = ">>> ",
      -- prompt_caret = "▎",
      prompt_caret = "🯏",
      -- prompt_caret = "▌",
    },
  })
  require("mini.pick").registry.registry = function()
    local picker = require("mini.pick")
    local selected = picker.start({
      source = { items = vim.tbl_keys(picker.registry), name = "Registry" }
    })
    if selected == nil then return end
    return picker.registry[selected]()
  end

  MiniPick.registry.buffer_lines_current = function()
    -- local local_opts = { scope = "current", preserve_order = true } -- use preserve_order
    local local_opts = { scope = "current" }
    MiniExtra.pickers.buf_lines(local_opts, { source = { show = show_buf_lines } })
  end

  nmap("<C-f>", function()
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(cwd, ":~")
    MiniPick.builtin.files({}, {
      source = {
        show = function(buf_id, items_arr, query)
          require("mini.pick").default_show(buf_id, items_arr, query, { show_icons = true } )
          -- local lines = vim.tbl_map(function(x) return 'Item: ' .. x end, items_arr)
          -- vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
        end
      },
      window = { prompt_prefix = " Find: " .. path .. "/" }
    }) end, { desc = "Pick files" })
  nmap_leader("ff", function() MiniPick.registry.registry() end,   { desc = "registry" })
  nmap_leader("fh", function() MiniPick.builtin.help() end,        { desc = "helptags" })
  nmap_leader("fb", function() MiniPick.builtin.buffers() end,     { desc = "buffers" })
  nmap_leader("fr", function() MiniPick.builtin.resume() end,      { desc = "resume" })
  nmap_leader("/",  function() MiniPick.builtin.grep_live() end,   { desc = "grep live" })
  nmap_leader("fd", function() MiniExtra.pickers.diagnostic({scope="current"}) end, { desc = "diagnostics %" })
  nmap_leader("fD", function() MiniExtra.pickers.diagnostic() end, { desc = "diagnostics" })
  nmap_leader("fk", function() MiniExtra.pickers.keymaps() end,    { desc = "keymaps" })
  nmap_leader("fH", function() MiniExtra.pickers.hl_groups() end,  { desc = "highlights" })

  nmap("<M-/>", function() MiniExtra.pickers.buf_lines({ scope = "current" }, {
    { source = { show = show_buf_lines }}
  }) end)
  nmap("<M-S-/>", function()
    MiniExtra.pickers.buf_lines({}, {
      source = {
        show = function(buf_id, items_arr, query)
          require("mini.pick").default_show(buf_id, items_arr, query, { show_icons = false } )
        end,
      },
    })
  end)

  nmap("<leader><leader>", function() MiniPick.builtin.resume() end)

  nmap_leader("fc", function()
    local cwd = vim.fn.stdpath("config")
    local prefix = " " .. vim.fn.fnamemodify(cwd, ":~") .. "/"
    local opts = {
      source = { cwd = cwd },
      window = { prompt_prefix = prefix },
    }
    MiniPick.builtin.files(nil, opts)
  end, { desc = "config" })

  nmap_leader("fv", function()
    local opts = { source = { cwd = vim.fn.expand("$VIMRUNTIME").."/lua" } }
    MiniPick.builtin.files(nil, opts)
  end, { desc = "runtime" })

  local function pp(picker)
    local packroot = vim.fn.stdpath("data") .. "/site/pack/core/opt"
    local prefix = " opt/**/lua/"
    local opts = {
      source = {
        cwd = packroot,
        name = "Pack",
        command = "fd",
        args = { "-e", "lua", "-p", ".*/lua/" }
      },
      window = { prompt_prefix = prefix },
    }
    MiniPick.builtin[picker](nil, opts)
  end
  nmap_leader("fp", function() pp("files") end, { desc = "find pack" })
  nmap_leader("fP", function() pp("grep_live") end, { desc = "grep packs" })
end

Pack.load_on_loop(setup_mini_pick)("mini.pick")
