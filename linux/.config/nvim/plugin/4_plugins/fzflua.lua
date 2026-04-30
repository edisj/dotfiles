local nmap = function(...) Config.map("n", ...) end
local nmap_leader = function(lhs, ...) Config.map("n", "<leader>"..lhs, ...) end

local function make_botleft_winopts(title)
  return function()
    local height = 25
    return {
      backdrop = 100,
      anchor = "SW",
      title = title and " ".. title .. " " or "",
      title_pos = "right",
      border = { "🭽", "▔", "🭾", "🮈", "🮈", " ", "▍", "▍" },
      height = height,
      width = 50,
      row = vim.o.lines - height - (vim.bo.filetype == "snacks_dashboard" and 0 or (1 + vim.o.cmdheight)),
      col = 2,
      spinner = { enabled = true },
      preview = {
        hidden = true,
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
      },
      on_create = function(ev)
        -- vim.api.nvim_create_autocmd({ "BufLeave", "CmdlineEnter" }, {
        vim.api.nvim_create_autocmd("BufLeave", {
          once = true,
          buffer = ev.bufnr,
          callback = function()
            local win = FzfLua.utils.fzf_winobj()
            if win then win:close() end
          end })

        vim.keymap.set("t", "<C-space>", function()
          local win = FzfLua.utils.fzf_winobj()
          if win then
            win:toggle_fullscreen()
            win:toggle_preview()
          end
        end, { buffer = ev.bufnr })

        vim.keymap.set("t", "<C-f>", function()
          local win = FzfLua.utils.fzf_winobj()
          if win then win:close() end
        end, { buffer = ev.bufnr })
      end,
    }
  end
end


local _cmdheight_saved = vim.o.cmdheight
local function make_minibuffer_winopts(title)
  return function()

    vim.o.cmdheight = vim.g.minibuffer_height
    local cmd_win = require("vim._core.ui2").wins.cmd
    local cmd_win_config = vim.api.nvim_win_get_config(cmd_win)
    return {
      backdrop = 100,
      anchor = "NW",
      title = title and (" %s "):format(title) or "",
      title_pos = "left",
      border = { "▔", "▔", "▔", "", "", "", "", "" },
      height = vim.o.cmdheight,
      width = cmd_win_config.width + 100,
      relative = "laststatus",
      -- win = cmd_win,
      row = 1,
      col = 0,
      zindex = cmd_win_config.zindex,
      spinner = { enabled = true },
      preview = {
        hidden = true,
        horizontal     = "right:55%",
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        -- border = "none",
      },
      on_create = function(ev)
        vim.cmd("mode")
        local winid = vim.api.nvim_get_current_win()
        vim.wo[winid].winhl = "NormalFloat:MsgArea,FloatBorder:MiniBufferBorder"
        vim.api.nvim_create_autocmd({ "BufLeave", "CmdlineEnter" }, {
          buffer = ev.bufnr,
          callback = function()
            if not vim.api.nvim_buf_is_valid(ev.bufnr) then return true end
            local win = FzfLua.utils.fzf_winobj()
            if win then win:close() end
            vim.schedule(function()
              vim.o.cmdheight = 1
              -- vim.cmd("redraw!")
            end)
          end })
        vim.api.nvim_create_autocmd({ "WinClosed" }, {
          callback = function()
            vim.schedule(function()
              vim.o.cmdheight = _cmdheight_saved
              -- vim.cmd.redraw()
            end)
          end,
          buf = ev.bufnr,
        })

        vim.keymap.set("t", "<C-space>", function()
          local win = FzfLua.utils.fzf_winobj()
          if win then
            win:toggle_fullscreen()
            win:toggle_preview()
          end
        end, { buffer = ev.bufnr })

        vim.keymap.set("t", "<C-f>", function()
          local win = FzfLua.utils.fzf_winobj()
          if win then win:close() end
        end, { buffer = ev.bufnr })
      end,
    }
  end
end

local function split(split_direction)
  return function(selected)
    local file = require("fzf-lua").path.entry_to_file(selected[1]).stripped
    vim.cmd(split_direction .. " " .. file)
  end
end

local function arglist(i)
  return function(selected)
    local file = require("fzf-lua").path.entry_to_file(selected[1]).stripped
    if not (file and vim.uv.fs_stat(file)) then return end
    Arglist.arglist[i] = file
    vim.cmd("edit " .. file)
  end
end

Pack.add({{
  src = "https://github.com/ibhagwan/fzf-lua",
  data = {
    enabled = true,
    loader = Pack.load_on_loop(function(name)
      vim.cmd.packadd(name)
      require("fzf-lua").setup({
        defaults = {
          -- header = false,
        },
        keymap = {
          fzf = {
            ["ctrl-d"] = "half-page-down",
            ["ctrl-u"] = "half-page-up",
            ["ctrl-a"] = "select-all"
          },
        },
        fzf_opts = { ["--gutter"] = " " },

        builtin = {
          cwd_prompt = false,
          winopts = make_botleft_winopts("builtin"),
        },

        files = {
          cwd_prompt = true,
          cwd_prompt_shorten_len =10,
          cwd_prompt_shorten_val = 1,
          -- prompt = vim.fn.fnamemodify(vim.fn.getcwd(), ":~:t") .."/",
          -- winopts = make_botleft_winopts("files"),
          winopts = make_minibuffer_winopts("files"),
        },

        lsp = { symbols = { locate = true } },

        actions = {
          files = {
            -- Pickers inheriting these actions:
            --   files, git_files, git_status, grep, lsp, oldfiles, quickfix, loclist,
            --   tags, btags, args, buffers, tabs, lines, blines
            -- `file_edit_or_qf` opens a single selection or sends multiple selection to quickfix
            -- replace `enter` with `file_edit` to open all files/bufs whether single or multiple
            -- replace `enter` with `file_switch_or_edit` to attempt a switch in current tab first
            ["enter"]  = FzfLua.actions.file_edit_or_qf,
            ["ctrl-t"] = FzfLua.actions.file_tabedit,
            ["ctrl-q"] = FzfLua.actions.file_sel_to_qf,
            ["ctrl-l"] = FzfLua.actions.file_sel_to_ll,
            ["alt-h"] = FzfLua.actions.toggle_hidden,
            ["alt-i"] = FzfLua.actions.toggle_ignore,
            ["alt-f"] = FzfLua.actions.toggle_follow,
            ["alt-L"] = split("vsplit"),
            ["alt-H"] = split("leftabove vsplit"),
            ["alt-J"] = split("belowright split"),
            ["alt-K"] = split("leftabove split"),
            ["alt-Q"] = arglist(1),
            ["alt-W"] = arglist(2),
            ["alt-E"] = arglist(3),
            -- ["alt-U"] = arglist(4),
            -- ["alt-I"] = arglist(5),
            -- ["alt-O"] = arglist(6),
          },
        },
      })

      -- nmap("<C-f>", function() FzfLua.files() end)
      -- nmap_leader("/",  function() FzfLua.live_grep() end,  { desc = "live grep" })
      -- nmap_leader("ff", function() FzfLua.builtin() end,    { desc = "builtin" })
      -- nmap_leader("fb", function() FzfLua.buffers() end,    { desc = "buffers" })
      -- nmap_leader("ft", function() FzfLua.filetypes() end,  { desc = "filetypes" })
      -- nmap_leader("fa", function() FzfLua.args() end,       { desc = "arglist" })
      -- nmap_leader("fA", function() FzfLua.autocmds() end,   { desc = "autocmds" })
      -- nmap_leader("fk", function() FzfLua.keymaps() end,    { desc = "keymaps" })
      -- nmap_leader("fh", function() FzfLua.helptags() end,   { desc = "helptags" })
      -- nmap_leader("fH", function() FzfLua.highlights() end, { desc = "highlights" })

      -- nmap_leader("fc", function()
      --   local opts = { prompt = false, cwd = vim.fn.stdpath("config") }
      --   FzfLua.files(opts)
      -- end, { desc = "config" })
      --
      -- nmap_leader("fv", function()
      --   local opts = { prompt = false, cwd = vim.fn.expand("$VIMRUNTIME").."/lua" }
      --   FzfLua.files(opts)
      -- end, { desc = "runtime" })

      nmap_leader("fG", function()
        FzfLua.live_grep({ cwd = require("fzf-lua.path").git_root({}) })
      end, { desc = "grep ." })

      -- local function pp(picker)
      --   local packroot = vim.fn.stdpath("data") .. "/site/pack/core/opt"
      --   FzfLua[picker]({
      --     prompt = "opt/**/lua/",
      --     cwd = packroot,
      --     cwd_prompt_shorten_len = 5,
      --     fd_opts = [[-e lua -p '.*/lua/']],
      --   })
      -- end
      --
      -- nmap_leader("fp", function() pp("files") end)
      -- nmap_leader("fP", function() pp("live_grep") end)
    end),
  }
}})
