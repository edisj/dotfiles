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

local function setup_mini_pick()

  local function arglist_add(k)
    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end
    MiniPick.default_choose(current)
    arglist.set_key(k, current)
    MiniPick.stop()
  end

  require("mini.pick").setup({
    -- See `:h MiniPick-actions`.
    mappings = {
      move_down  = "<C-n>",
      move_up    = "<C-p>",
      move_start = "<C-g>",

      refine        = "<S-CR>",
      refine_marked = "<M-CR>",

      mark              = "<C-x>",
      mark_all          = "<C-a>",
      choose_marked     = "<C-q>",
      choose_in_split   = "<M-S-j>",
      choose_in_vsplit  = "<M-S-l>",
      choose_in_tabpage = "<C-t>",

      delete_left       = "<C-u>",

      toggle_info    = "<C-h>",
      toggle_preview = "<C-Tab>",

      scroll_left  = "<M-h>",
      scroll_down  = "<C-j>",
      scroll_up    = "<C-k>",
      scroll_right = "<M-l>",

      test3 = { char = "<C-\\>", func = function()
        require("vim._core.ui2.messages").show_msg("msgarea", "", {{0, "a\nb\nc", 0 }})
      end},
      test2 = { char = "<C-o>", func = function() vim.print(require("vim._core.ui2").wins) end },
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
          relative = package.loaded["msgarea"] and "msgarea" or nil,
          border = { " ", " ", " ", "", " ", " ", " ", "" },
          height = 10,
        }
      end,
      prompt_prefix = ">>> ",
      -- prompt_caret = "▎",
      prompt_caret = "🯏",
      -- prompt_caret = "▌",
    },
  })

  MiniPick.registry["registry"] = require("pickers.registry")
  MiniPick.registry["find_file"] = require("pickers.find-file")

  local fmap = function(key, desc, rhs)
    map("<C-f>" .. key, rhs, { desc = desc })
  end

  map("<C-e><C-/>", function() MiniPick.registry.find_file({ dir = vim.fn.expand("%:p:h") }) end)
  fmap("<C-o>", "files (cwd)", function() MiniPick.registry.find_file() end)
  fmap("<C-.>", "files (%)", function() MiniPick.registry.find_file({ dir = vim.fn.expand("%:p:h") }) end)
  fmap("~", "files (~)", function() MiniPick.registry.find_file({ dir = vim.fn.expand("~") }) end)
  fmap("<C-f>", "registry", function() MiniPick.registry.registry() end)
  fmap("<C-h>", "helptags", function() MiniPick.builtin.help() end)
  fmap("<C-b>", "buffers", function() MiniPick.builtin.buffers() end)
  fmap("<C-g>", "grep live", function() MiniPick.builtin.grep_live() end)
  map("<Leader>fd", function() MiniExtra.pickers.diagnostic({scope="current"}) end, { desc = "diagnostics %" })
  map("<Leader>fD", function() MiniExtra.pickers.diagnostic() end, { desc = "diagnostics" })
  map("<Leader>fk", function() MiniExtra.pickers.keymaps() end,    { desc = "keymaps" })
  map("<Leader>fH", function() MiniExtra.pickers.hl_groups() end,  { desc = "highlights" })

  map("<C-space>", "<Cmd>Pick files<CR>")
  map("<M-space>", function()
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(cwd, ":~")
    MiniPick.builtin.files({}, {

      mappings = {
        close_ = { char = "<M-space>", func = function() return true end },
      },
      source = {
        show = function(buf_id, items_arr, query)
          require("mini.pick").default_show(buf_id, items_arr, query, { show_icons = true } )
          -- local lines = vim.tbl_map(function(x) return 'Item: ' .. x end, items_arr)
          -- vim.api.nvim_buf_set_lines(buf_id, 0, -1, false, lines)
        end
      },
      window = { prompt_prefix = " Find: " .. path .. "/" }
    }) end, { desc = "Pick files" })
  map("<leader><leader>", function() MiniPick.builtin.resume() end)

  fmap("<C-n>", "config", function()
    local cwd = vim.fn.stdpath("config")
    local prefix = " " .. vim.fn.fnamemodify(cwd, ":~") .. "/"
    local opts = {
      source = { cwd = cwd },
      window = { prompt_prefix = prefix },
    }
    MiniPick.builtin.files(nil, opts)
  end)

  fmap("<C-r>", "runtime", function()
    local opts = { source = { cwd = vim.fn.expand("$VIMRUNTIME").."/lua" } }
    MiniPick.builtin.files(nil, opts)
  end)

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
  fmap("<C-p>", "packages", function() pp("files") end)
  map("<Leader>fP", function() pp("grep_live") end, { desc = "grep packs" })
end

pack.gen_loop_loader(setup_mini_pick)("mini.pick")
