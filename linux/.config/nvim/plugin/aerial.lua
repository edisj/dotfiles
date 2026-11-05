pack.add({
  {
    src = "https://github.com/stevearc/aerial.nvim",
    data = {
      enable = true,
      defer = false,
      loader = function()
        require("aerial").setup({
          manage_folds = true,
          link_tree_to_folds = true,
          link_folds_to_tree = true,

          layout = {
            -- These control the width of the aerial window.
            -- They can be integers or a float between 0 and 1 (e.g. 0.4 for 40%)
            -- min_width and max_width can be a list of mixed types.
            -- max_width = {40, 0.2} means "the lesser of 40 columns or 20% of total"
            max_width = { 40, 0.3 },
            width = nil,
            min_width = { 15, 0.10 },

            -- key-value pairs of window-local options for aerial window (e.g. winhl)
            win_opts = {},

            -- Determines the default direction to open the aerial window. The 'prefer'
            -- options will open the window in the other direction *if* there is a
            -- different buffer in the way of the preferred direction
            -- Enum: prefer_right, prefer_left, right, left, float
            default_direction = "left",

            -- Determines where the aerial window will be opened
            --   edge   - open aerial at the far right/left of the editor
            --   window - open aerial to the right/left of the current window
            placement = "edge",

            -- When the symbols change, resize the aerial window (within min/max constraints) to fit
            resize_to_content = true,

            -- Preserve window size equality with (:help CTRL-W_=)
            preserve_equality = false,
          },


          keymaps = { ["<C-Tab>"] = "actions.tree_toggle" },
          on_attach = function(bufnr)
            local function nav(fn, dir)
              return function()
                local pos = vim.api.nvim_win_get_cursor(0)
                require("aerial")[fn](vim.v.count1)
                if (vim.api.nvim_win_get_cursor(0)[1] - pos[1]) * dir < 0 then
                  vim.api.nvim_win_set_cursor(0, pos)
                end
              end
            end
            vim.keymap.set("n", "<C-n>", nav("next", 1), { buf = bufnr })
            vim.keymap.set("n", "<C-p>", nav("prev", -1), { buf = bufnr })

            -- vim.keymap.set("n", "<Tab>", function()
            --   if #require("aerial").get_location(true) == 0 then return end
            --   vim.cmd("normal za")
            -- end, { buffer = bufnr })

            -- vim.keymap.set("n", "<Tab>", function()
            --   local loc = require("aerial").get_location(false)
            --   local item = loc[#loc]
            --   if not item or item.lnum > vim.fn.line(".") then return end
            --   vim.cmd("normal za")
            --   local start = vim.fn.foldclosed(item.lnum)
            --   if start ~= -1 then
            --     vim.api.nvim_win_set_cursor(0, { start, 0 })
            --     vim.cmd("normal! ^")
            --   end
            -- end, { buffer = bufnr })

            vim.keymap.set("n", "<Tab>", function()
              if #require("aerial").get_location(true) == 0 then return end
              vim.cmd("normal za")
            end, { buffer = bufnr })

            on("CursorMoved", nil, { buf = bufnr }, function()
              -- local lnum = vim.fn.line(".")
              -- local prev = lnum > 1 and vim.fn.foldlevel(lnum - 1) or 0
              -- if vim.fn.foldclosed(lnum) ~= -1 or vim.fn.foldlevel(lnum) <= prev then return end
              -- require("aerial").tree_open({ fold = false, bubble = false })

              if vim.fn.foldclosed(vim.fn.line(".")) ~= -1 then return end
              if #require("aerial").get_location(true) == 0 then return end
              require("aerial").tree_open({ fold = false })
            end)

          end,
          -- post_add_all_symbols = function(bufnr, items, ctx)
          --   for _, item in ipairs(items) do
          --     item.children = nil
          --   end
          --   return items
          -- end,
        })
      end
    }
  }
})
