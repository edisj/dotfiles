local ui_select = vim.ui.select
local function setup_mini_pick()

  local expanded = false
  local win_cfg = function()
    local base = math.floor(0.30 * vim.o.lines)
    local h = base
    if expanded then
      local matches = MiniPick.get_picker_matches()
      local n = matches and matches.all and #matches.all + 2 or 0
      h = math.max(base, math.min(n, math.floor(0.66 * vim.o.lines)))
    end
    local relative = package.loaded["msgarea"] and require("msgarea.config").get().enable and "msgarea" or nil
    return { relative = relative, height = h, border = "solid" }
  end
  vim.api.nvim_create_autocmd("User", {
    pattern = "MiniPickStart",
    callback = function() expanded = false end,
  })

  local msgarea_opts = { window = { config = win_cfg } }

  local mappings = {
    move_down  = "<C-n>",
    move_up    = "<C-p>",
    move_start = "<C-g>",

    refine        = "<M-CR>",
    refine_marked = "<C-CR>",

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

    test2 = { char = "<C-o>", func = function() vim.print(require("vim._core.ui2").wins) end },
    expand = { char = "<C-space>", func = function()
      expanded = not expanded
      MiniPick.refresh()
    end},
  }

  local function arglist_add(k)
    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end
    MiniPick.default_choose(current)
    arglist.add(k, current)
    MiniPick.stop()
  end
  for _, k in ipairs(arglist.keys()) do
    local lhs = "<M-S-" .. k .. ">"
    mappings["arglist_add_" .. k] = { char = lhs, func = function() arglist_add(k) end }
  end

  local centered = function()
    local h = math.floor(0.5*vim.o.lines)
    local w = math.floor(0.6*vim.o.columns)
    return {
      relative = "editor", anchor = "NW",
      border = "bold",
      height = h, width = w,
      row = 0.5 * ( vim.o.lines - h -2 ),
      col = 0.5 * ( vim.o.columns - w-2 ),
    }
  end

  require("mini.pick").setup({
    -- See `:h MiniPick-actions`.
    mappings = mappings,
    options = {
      content_from_bottom = false,
      use_cache = true,
      hidden = true,
    },
    window = {
      config = centered,
      prompt_prefix = ">>> ",
      -- prompt_caret = "▎",
      prompt_caret = "🯏",
      -- prompt_caret = "▌",
    },
  })
  vim.ui.select = ui_select

  local _default_show = require("mini.pick").default_show
  ---@diagnostic disable-next-line: duplicate-set-field
  require("mini.pick").default_show = function(bufnr, items, query, opts)
    _default_show(bufnr, items, query, opts)
    local mpns = vim.api.nvim_create_namespace("MiniPickRanges")
    for _, m in ipairs(vim.api.nvim_buf_get_extmarks(bufnr, mpns, 0, -1, { details = true })) do
      local id, row, col, d = m[1], m[2], m[3], m[4]
      d.ns_id, d.id = nil, id
      d.priority = 202
      vim.api.nvim_buf_set_extmark(bufnr, mpns, row, col, d)
    end
  end

  MiniPick.registry["registry"] = require("pickers.registry")
  MiniPick.registry["find_file"] = require("pickers.find-file")
  MiniPick.registry["grep_live"] = require("pickers.grep-live")
  MiniPick.registry["buf_lines"] = require("pickers.buf-lines")
  MiniPick.registry["mux"] = require("pickers.mux")

  local fmap = function(key, desc, rhs)
    map("<C-f>" .. key, rhs, { desc = desc })
  end

  map("<C-e><C-/>", function() MiniPick.registry.find_file({ dir = vim.fn.expand("%:p:h") }, msgarea_opts) end)
  fmap("<C-o>", "files (cwd)", function() MiniPick.registry.find_file() end)
  fmap("<C-f>", "registry", function() MiniPick.registry.registry() end)
  fmap("<C-h>", "helptags", function() MiniPick.builtin.help(nil, msgarea_opts) end)
  fmap("<C-b>", "buffers", function() MiniPick.builtin.buffers(nil, msgarea_opts) end)
  map("<Leader>fd", function() MiniExtra.pickers.diagnostic({scope="current"}) end, { desc = "diagnostics %" })
  map("<Leader>fD", function() MiniExtra.pickers.diagnostic() end, { desc = "diagnostics" })
  map("<Leader>fk", function() MiniExtra.pickers.keymaps() end,    { desc = "keymaps" })
  map("<Leader>fH", function() MiniExtra.pickers.hl_groups() end,  { desc = "highlights" })

  map("<C-/>", function() MiniPick.registry.grep_live({ show_header = true, group_by = "fname" }, msgarea_opts) end)
  -- map("<C-_>", function() MiniPick.registry.grep_live({ show_header = true, group_by = "fname" }, msgarea_opts) end)
  map("<M-/>", function() MiniPick.registry.buf_lines({ scope = "current", show_header = false }, msgarea_opts) end)
  map("<C-M-/>", function() MiniPick.registry.buf_lines({ show_header = true }, msgarea_opts) end)

  fmap("<C-.>", "files", function()
    local cwd = vim.fn.getcwd(-1, -1, -1)
    local cwd = vim.fn.getcwd()
    local path = vim.fn.fnamemodify(cwd, ":~")
    local prompt_prefix = " Find (file): " .. path .. "/"
    MiniPick.builtin.files({}, {
      source = { cwd = cwd },
      window = { prompt_prefix = prompt_prefix, config = win_cfg },
    })
  end)

  -- map("<C-space>", "<Cmd>Pick files<CR>")
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
      window = { prompt_prefix = " Find: " .. path .. "/", config = win_cfg }
    }) end, { desc = "Pick files" })

  -- map("<leader><leader>", function() MiniPick.builtin.resume() end)

  -- fmap("<C-n>", "config", function()
  --   local cwd = vim.fn.stdpath("config")
  --   local prefix = " " .. vim.fn.fnamemodify(cwd, ":~") .. "/"
  --   local opts = {
  --     source = { cwd = cwd },
  --     window = { prompt_prefix = prefix, config = win_cfg },
  --   }
  --   MiniPick.builtin.files(nil, opts)
  -- end)

  fmap("<C-p>", "projects", function()
    local opts = {
      window = { prompt_prefix = " Select Project: ", config = win_cfg },
    }
    MiniPick.registry.mux(nil, opts)
  end)

  -- fmap("<C-r>", "runtime", function()
  --   local opts = { source = { cwd = vim.fn.expand("$VIMRUNTIME").."/lua" }, window = { config = win_cfg } }
  --   MiniPick.builtin.files(nil, opts)
  -- end)
  --
  -- local function pp(picker)
  --   local packroot = vim.fn.stdpath("data") .. "/site/pack/core/opt"
  --   local prefix = " opt/**/lua/"
  --   local opts = {
  --     source = {
  --       cwd = packroot,
  --       name = "Pack",
  --       command = "fd",
  --       args = { "-e", "lua", "-p", ".*/lua/" }
  --     },
  --     window = { prompt_prefix = prefix, config = win_cfg },
  --   }
  --   MiniPick.builtin[picker](nil, opts)
  -- end
  -- fmap("<C-o>", "packages", function() pp("files") end)
end

pack.gen_loop_loader(setup_mini_pick)("mini.pick")
