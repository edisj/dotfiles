local dev = false
local add = dev and pack.add_local or pack.add
local src = dev and "~/dev/system.nvim" or "https://github.com/edisj/system.nvim"

vim.g.system = {
  win_config = {
    float = function(ctx)
      return {
        relative = "msgarea",
        title = " Output ",
      }
    end
  },
}

add({
  {
    src = src,
    data = {
      enable = true,
      loader = function()
        local input = require("system").input
        for k, pos in pairs {
          h = "left",
          j = "bot",
          k = "top",
          l = "right",
          ["."] = "current",
        } do
          map("<C-q><C-" .. k .. ">", function() input { target = "quickfix", pos = pos, repeat_last = true } end)
          map("<C-q>" .. k, "<C-q><C-" .. k .. ">", { remap = true })
          map("<C-x><C-" .. k .. ">", function() input { target = "buf", pos = pos, repeat_last = true } end)
          map("<C-x>" .. k, "<C-x><C-" .. k .. ">", { remap = true })
        end
        local CTRL_M = vim.g.CTRL_M or "<C-m>"
        map("<C-q>m", function() input { target = "quickfix", pos = "float", repeat_last = true } end)
        map("<C-q>".. CTRL_M, "<C-q>m", { remap = true })
        map("<C-x>m", function() input { target = "buf", pos = "float", repeat_last = true } end)
        map("<C-x>".. CTRL_M, "<C-x>m", { remap = true })
        map("<C-;>", function() input { repeat_last = true } end)
      end,
    }
  }
})
