-- local function get_lsp_configs()
--     local path = vim.fn.stdpath("config") .. "/lsp"
--     local lsp_configs = vim.fn.readdir(path)
--     return vim.tbl_map(function(filename)
--         return filename:match("(.+)%.%a+$")
--     end, lsp_configs)
-- end

return {
    "mason-org/mason.nvim",
    enabled = true,
    cmd = "Mason",
    build = ":MasonUpdate",
    event = "VeryLazy",
    keys = { { "<leader>M", "<Cmd>Mason<CR>", desc = "Open Mason" } },
    opts = {
        ui = {
            width = 0.85,
            height = 0.80,
            border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        },
    },
    config = function(_, opts)
        require("mason").setup(opts)

        -- see https://www.reddit.com/r/neovim/comments/1p1y73n/automatically_downloading_and_installing_lsps/
        local ensure_installed = {
            "lua-language-server",
            "stylua",
            "basedpyright",
            "black",
            "debugpy",
            "jdtls",
            "bash-language-server",
            "hyprls",
        }

        local already_installed = require("mason-registry").get_installed_package_names()

        for _, pack in ipairs(ensure_installed) do
            if not vim.tbl_contains(already_installed, pack) then
                vim.cmd("MasonInstall " .. pack)
            end
        end

        local auto_enable = {
            "lua_ls",
            "basedpyright",
            "hyprls",
        }
        vim.lsp.enable(auto_enable)
    end,
}
