M = {}


local function is_empty(str)
    return str == nil or str == ""
end


local function find_bin(filetype)
    local obj = vim.system({"which", filetype}):wait()
    return obj.stdout:match("[^\n]+")
end

local defaults = {

    win_opts = {
        relative = "editor", -- sets window layout to "floating"
        style = "minimal",
        -- border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        border = { "▁", "▁", "▁", "▕", "▔", "▔", "▔", "▏" },
        anchor = "SE",
        row = -1,
        col = -1,
        wo = {
            wrap = true,
            linebreak = true,
        }
    },

    bins = {
        python = not is_empty(find_bin("python")) and find_bin("python") or find_bin("python3"),
        lua = find_bin("lua"),
        java = find_bin("java"),
    }

}

local win = require("ui.lib.win").new(defaults.win_opts)

local function send_cmd_to_float(cmd)
    local out = vim.fn.systemlist(cmd)
    win:set_lines(out)
end

function M.popout_open()
    win:open()
end

function M.popout_close()
    win:close()
end

function M.popout_toggle()
    win:toggle()
end

function M.popout_cmd(cmd)
    send_cmd_to_float(cmd)
    M.popout_open()
end

function M.setup(opts)
    opts = opts or {}

    vim.api.nvim_create_user_command("Popout", function()

        local buf = vim.api.nvim_get_current_buf()
        local filename = vim.api.nvim_buf_get_name(buf)
        local filetype = vim.bo.filetype
        local bin = defaults.bins[filetype]
        local cmd = { bin, filename }

        M.popout_cmd(cmd)

    end, {})

    vim.api.nvim_create_user_command("PopoutAttach", function()
        local buf = vim.api.nvim_get_current_buf()

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("popout_attach", { clear = true }),
            callback = function()
                vim.cmd("Popout")
            end,
            buffer = buf,
        })
        M.popout_open()
        vim.cmd("Popout")
    end, {})

    vim.api.nvim_create_user_command("PopoutDetach", function()
        local buf = vim.api.nvim_get_current_buf()

        vim.api.nvim_create_autocmd("BufWritePost", {
            group = vim.api.nvim_create_augroup("popout_attach", { clear = true }),
            callback = function()
                return true
            end,
            buffer = buf,
        })
        M.popout_close()
    end, {})

    vim.keymap.set({"n", "i", "v"}, "<c-p>", ":lua require('popout').popout_toggle()<CR>", { desc = "Popout toggle" })
    vim.keymap.set({"n", "i", "v"}, "<c-=>", ":Popout<CR>", {})
    vim.keymap.set("n", "<leader>pa", ":PopoutAttach<CR>", { desc = "Popout Attach"})
    vim.keymap.set("n", "<leader>pd", ":PopoutDetach<CR>", { desc = "Popout Detach"})

end


return M
