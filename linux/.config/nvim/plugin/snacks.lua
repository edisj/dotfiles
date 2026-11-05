local skip = { j = true, k = true, ["<M-j>"] = true, ["<M-k>"] = true, ["<Down>"] = true, ["<Up>"] = true }
local last = ""
local scroll = false
if scroll then
  vim.on_key(function(key, typed)
    last = vim.fn.keytrans(typed ~= "" and typed or key)
  end)
end

pack.add({{
  src = "https://github.com/folke/snacks.nvim",
  data = {
    enable = true,
    defer = true,
    loader = function()
      require("snacks").setup({
        input = { enabled = false },
        bigfile = { enabled = false },
        image = { enabled = false },
        indent = {
          indent = { enabled = false, char = "▏" },
          scope = { enabled = false, only_current = false, char = "│" },
          animate = { enabled = false },
          chunk = {
            enabled = true,
            only_current = true,
            chunkwidth = 1,
            char = {
              corner_top = "┌",
              corner_bottom = "└",
              -- corner_top = "╭",
              -- corner_bottom = "╰",
              horizontal = "─",
              vertical = "│",
              arrow = "─",
            },
          },
        },
        animate = {
          enabled = true,
          duration = { total = 200 }, ---@type snacks.animate.Duration|number
          easing = "inQuad",
          fps = 180,
        },
        scroll = {
          enabled = scroll and vim.g.neovide == nil,
          animate = {
            duration = { step = 10, total = 100 },
            easing = "inQuad",
          },
          filter = function(buf)
            return vim.g.snacks_scroll ~= false
              and vim.b[buf].snacks_scroll ~= false
              and vim.bo[buf].buftype ~= "terminal"
              and not skip[last]
          end,
        },
        ---@type snacks.picker.config
        picker = {
          enabled = false,
          ui_select = true,
        },
      })

      Snacks.input = function(opts, on_confirm)
        vim.ui.input({ prompt = opts.prompt .. ": ", default = opts.default, completion = opts.completion }, on_confirm)
      end
      Snacks.picker.select = function(items, opts, on_choice)
        vim.ui.select(items, opts, on_choice)
      end

      local explorer = require("pickers.explorer")

      map("<C-`>", function()
        explorer { enter = false, focus = "list" }
      end, { desc = "Explorer" })

      map("<C-f><C-/>", function()
        local open_picker = Snacks.picker.get({ source = "explorer" })[1]
        if open_picker then
          open_picker.input.win:focus()
        else
          explorer { focus = "input", auto_close = true, jump = { close = true } }
        end
      end, { desc = "Find file" })
      map("<Leader><Leader>", "<C-f><C-/>", { remap = true, desc = "Find file" })

      local function explorer_at(dir)
        return function()
          local open_picker = Snacks.picker.get({ source = "explorer" })[1]
          if open_picker then
            open_picker.opts.auto_close = true
            open_picker.opts.jump.close = true
            open_picker:set_cwd(dir)
            open_picker:find({ on_done = function() open_picker.input.win:focus() end })
          else
            explorer {
              cwd = dir,
              focus = "input",
              auto_close = true,
              jump = { close = true },
            }
          end
        end
      end
      map("<C-f><C-n>", explorer_at(vim.fn.stdpath("config")), { desc = "config" })
      map("<C-f><C-r>", explorer_at(vim.env.VIMRUNTIME .. "/lua"), { desc = "runtime" })
      map("<C-f><C-o>", explorer_at(vim.fn.stdpath("data") .. "/site/pack/core/opt"), { desc = "packs" })

      map("<Leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
      map("<Leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })

      on("OptionSet", nil, { pattern = "cmdheight" }, function()
        for _, picker in ipairs(Snacks.picker.get()) do
          picker.layout:update()
        end
      end)

      on("FileType", nil, { pattern = { "snacks_picker_input", "snacks_input" } }, function()
        vim.b.minicompletion_disable = true
      end)

    end,
  },
}})
