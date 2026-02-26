
package.loaded["win"] = nil
local win = require("win")

float = win.float({
    position = "topright",
    border = "rounded",
    relative = "editor",
    split = "below",
    keymaps = {
        { "n", "q", function(self) self:close() end }
    }
})

split = win.split({
    split = "left",
    border = "rounded",
    width = 0.15,
})

-- vim.print(float)
-- vim.print(proxy.width)

vim.keymap.set("n", "<C-u>", function() float:toggle() end)
vim.keymap.set("n", "<C-b>", function() split:toggle() end)

