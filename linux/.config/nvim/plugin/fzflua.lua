local function make_botleft_winopts(title)
  return function()
    local height = 25
    return {
      backdrop = 100,
      anchor = "SW",
      title = title and " ".. title .. " " or "",
      title_pos = "right",
      border = "solid",
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
    arglist[i] = file
    vim.cmd("edit " .. file)
  end
end

pack.add({{
  src = "https://github.com/ibhagwan/fzf-lua",
  data = {
    enable = false,
    defer = true,
    loader = function()
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
          winopts = make_botleft_winopts("files"),
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

    end,
  }
}})
