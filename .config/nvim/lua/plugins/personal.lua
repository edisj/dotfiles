local function help_visual()
    local pos1 = vim.fn.getpos("v")
    local pos2 = vim.fn.getpos(".")
    local selection = vim.fn.getregion(pos1, pos2)
    if #selection ~= 1 then return end

    require("helpout").help(selection[1])
end

local function help_cword()
    local query = vim.fn.expand("<cword>")
    if query == "" then return end

    require("helpout").help(query)
end

return {
    {
        dir = "~/projects/window.nvim",
        lazy = true,
    },
    {
        dir = "~/projects/helpout.nvim",
        lazy = true,
        dependencies = "window.nvim",
        cmd = "Helpout",
        keys = {
            { "<C-n>", function() require("helpout").toggle() end },
            { "<C-n>", help_visual, mode = "v" },
            { "<leader><C-n>", help_cword },
        },
        opts = {},
    },

}
