vim.opt.cmdheight = 0
vim.opt.wildoptions = "fuzzy"
require("vim._core.ui2").enable({
    msg = {
        target = "msg",
        timeout = 4000,
    }
})
