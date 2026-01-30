local languages = {
    "lua",
    "python",
    "vimdoc",
    "bash",
}

return {
    {
        "nvim-treesitter",
        branch = "main",
        version = false,
        build = ":TSUpdate",
        event = "VeryLazy",
        cmd = { "TSUpdate", "TSInstall", "TSLog", "TSUninstall" },
        config = function()
            require("nvim-treesitter").install(languages)

            vim.api.nvim_create_autocmd("Filetype", {
                group = vim.api.nvim_create_augroup("treesitter.setup", {}),
                callback = function(ev)
                    local buf = ev.buf
                    local ft = ev.match

                    -- you need some mechanism to avoid running on buffers that do not
                    -- correspond to a language (like oil.nvim buffers), this implementation
                    -- checks if a parser exists for the current language
                    local language = vim.treesitter.language.get_lang(ft) or ft
                    if not vim.treesitter.language.add(language) then
                        return
                    end

                    -- replicate `fold = { enable = true }`
                    vim.wo.foldmethod = 'expr'
                    vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'

                    -- replicate `highlight = { enable = true }`
                    vim.treesitter.start(buf, language)

                    -- replicate `indent = { enable = true }`
                    vim.bo[buf].indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
                end
            })
        end,
    },
    {
        "nvim-treesitter/nvim-treesitter-textobjects",
        enabled = true,
        branch = "main",
        event = "VeryLazy",
        dependencies = "nvim-treesitter",
        init = function()
            -- Disable entire built-in ftplugin mappings to avoid conflicts.
            -- See https://github.com/neovim/neovim/tree/master/runtime/ftplugin for built-in ftplugins.
            vim.g.no_plugin_maps = true

            -- Or, disable per filetype (add as you like)
            -- vim.g.no_python_maps = true
            -- vim.g.no_ruby_maps = true
            -- vim.g.no_rust_maps = true
            -- vim.g.no_go_maps = true
        end,
        config = function()
            require("nvim-treesitter-textobjects").setup({})
        end,
    },
    {
        "RRethy/nvim-treesitter-endwise",
        enabled = false,
        event = "VeryLazy",
        dependencies = "nvim-treesitter",
    },
}
