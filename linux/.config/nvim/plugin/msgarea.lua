local dev = true
local add = dev and pack.add_local or pack.add
local src = dev and "~/dev/msgarea.nvim" or "https://github.com/edisj/msgarea.nvim"
add({
  {
    src = src,
    data = {
      enable = true,
      loader = function()
        require("msgarea").setup({
          msgarea_targets = {
            "wmsg",
            "emsg",
            "echoerr",
            "echo",
            "list_cmd",
            "lua_error",
            "lua_print",
            "echoerr",
            "shell_out",
            "shell_cmd",
            "shell_err",
          },
          message_title = function(kind)
            return ({ lua_print = " Lua Print ", lua_error = " Lua Error " })[kind]
          end,
          view = {
            style = "msgarea",
            -- style = "split",
            max_height = 0.50,
            winbar_min_tabs = 1,
          },
          cmdline = {
            enable = true,
            cmp_provider = vim.g.cmp or "native",
            dynamic_height = false,
            resize_throttle_ms = 250,
          },
        })

        map("<C-w>m", require("msgarea").close_all, { desc = "Close msgarea" })

        local CTRL_M = "<F13>"
        local m_map = function(k, rhs)
          local lhs = CTRL_M .. "<C-" .. k .. ">"
          map(lhs, rhs)
          map(CTRL_M .. k, lhs, { remap = true })
        end
        m_map("l", function() require("msgarea").close_all() end)
        m_map("c", function()
          if vim.bo.filetype == "pager" then vim.api.nvim_win_close(0, true) end
          vim.cmd("messages clear")
        end)
        m_map(CTRL_M, function()
          if vim.bo.filetype == "pager" then return vim.api.nvim_win_close(0, true) end
          if vim.fn.execute("messages"):match("%S") == nil then return end
          local cmd = vim.v.count == 0 and "messages" or ("%smessages"):format(vim.v.count)
          vim.cmd(cmd)
          -- NOTE: need to schedule this otherwise it goes to bottom of original window
          vim.schedule(function() vim.cmd("normal! G") end)
        end)

        local pumheight = vim.o.pumheight
        on({ "CmdlineEnter", "CmdlineLeave" }, nil, function(ev)
          if ev.event == "CmdlineEnter" then
            vim.o.pumheight = 7
          elseif ev.event == "CmdlineLeave" then
            vim.o.pumheight = pumheight
          end
        end)

        on("BufRead", nil, function(ev)
          if vim.bo[ev.buf].buftype ~= "quickfix" then return end
          vim.schedule(function()
            local winid = vim.fn.bufwinid(ev.buf)
            local wintype = vim.fn.win_gettype(winid)
            local title, height
            if wintype == "loclist" then
              title = " Loclist "
              height = math.min(#vim.fn.getloclist(0), 10)
            else
              title = " Quickfix "
              height = math.min(#vim.fn.getqflist(), 10)
            end
            local win_cfg = { title = title, relative = "msgarea", height = height, style = "minimal" }
            vim.api.nvim_win_set_config(winid, win_cfg)
          end)
        end
        )

      end,
    },
  }
})
