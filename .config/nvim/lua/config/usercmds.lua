local create_usercmd = vim.api.nvim_create_user_command

create_usercmd("SayHello", "lua print('hello!!')", {})

local function toggle_fold()
    if vim.opt.foldcolumn:get() == "0" then
        vim.opt.foldcolumn = "1"
        return
    end
    if vim.opt.foldcolumn:get() == "1" then
        vim.opt.foldcolumn = "0"
        return
    end
end
create_usercmd("ToggleFoldColumn", toggle_fold, {})
