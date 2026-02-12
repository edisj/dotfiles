
local _border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }

local function argpoon_add(i)
    local ok, argpoon = pcall(require, "argpoon")
    if not ok then return end
    return {
        action = function(picker, item)
            local file = item.file
            if file and vim.uv.fs_stat(file).type ~= "file" then return end
            argpoon.arglist[i] = file
            picker:close()
            vim.cmd.edit(file)
        end,
        desc = "Argpoon add " .. i,
    }
end

return {
    "folke/snacks.nvim",
    priority = 1000,
    lazy = false,
    keys = {
        { "<leader>e", function() Snacks.explorer() end, desc = "Explorer"},
        { "<leader>E", function() Snacks.explorer.reveal() end, desc = "Explorer"},
        { "<leader>/", function() Snacks.picker.grep() end, desc = "Grep" },
        { "<leader>n", function() Snacks.picker.notifications() end, desc = "Notification History" },
        {
            "<leader>fp",
            function()
                local dir = vim.fn.stdpath("data") .. "/lazy"
                Snacks.picker.files({
                    dirs = { dir },
                    -- patterns = { "lua/*", "*.lua" },
                    ft = "lua",
                    show_empty = true,
                    supports_live = true,
                    hidden = true,
                    recent = true,
                })
            end,
            desc = "Find Plugins"
        },
        { "<leader>fc", function() Snacks.picker.files({ cwd = vim.fn.stdpath("config") }) end, desc = "Find Config File" },
        { "<leader>hi", function() Snacks.picker.highlights() end, desc = "Highlights" },
        -- LSP
        { "gd", function() Snacks.picker.lsp_definitions() end, desc = "Goto Definition" },
        { "gD", function() Snacks.picker.lsp_declarations() end, desc = "Goto Declaration" },
        { "gr", function() Snacks.picker.lsp_references() end, nowait = true, desc = "References" },
        { "gI", function() Snacks.picker.lsp_implementations() end, desc = "Goto Implementation" },
        { "gy", function() Snacks.picker.lsp_type_definitions() end, desc = "Goto T[y]pe Definition" },
        { "<leader>ss", function() Snacks.picker.lsp_symbols() end, desc = "LSP Symbols" },
        { "<leader>sS", function() Snacks.picker.lsp_workspace_symbols() end, desc = "LSP Workspace Symbols" },
        { "<leader>.",  function() Snacks.scratch() end, desc = "Toggle Scratch Buffer" },
        { "<leader>S",  function() Snacks.scratch.select() end, desc = "Select Scratch Buffer" },
    },
    opts = {
        styles = {
            dashboard = {
                wo = {
                    fillchars = "eob: ",
                },
            },
        },
        dashboard = {
            header = "",
            preset = {
                -- Used by the `keys` section to show keymaps.
                -- Set your custom keymaps here.
                -- When using a function, the `items` argument are the default keymaps.
                ---@type snacks.dashboard.Item[]
                keys = {
                    { icon = " ", key = "f", desc = "Find File",    action = ":Pick files" },
                    -- { icon = " ", key = "n", desc = "New File",     action = ":ene | startinsert" },
                    -- { icon = " ", key = "g", desc = "Find Text",    action = ":lua Snacks.dashboard.pick('live_grep')" },
                    -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                    -- { icon = " ", key = "c", desc = "Config",       action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                    { icon = " ", key = "s", desc = "Last Session", action = ":lua Session.last()" },
                    { icon = "󰒲 ", key = "L", desc = "Lazy",         action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                    { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
                },
            },
            sections = {
                -- { section = "header" },
                { section = "keys", gap = 1, padding = 1 },
                { section = "startup" },
            },
        },

        picker = {
            enabled = false,
            sources = {
                explorer = {
                    auto_close = false,
                    layout = {
                        layout = { width = 30 },
                    },
                },
            },
            -- prompt = " > ",
            layout = {
                -- default settings for all pickers
                preset = "smnatale",
                cycle = false,
            },
            actions = {
                argpoon_add_1 = argpoon_add(1),
                argpoon_add_2 = argpoon_add(2),
                argpoon_add_3 = argpoon_add(3),
                argpoon_add_4 = argpoon_add(4),
                argpoon_add_5 = argpoon_add(5),
                argpoon_add_6 = argpoon_add(6),
            },
            win = {
                input = {
                    keys = {
                        ["<C-f>"] = { "cancel", mode = { "n", "i" } },
                        ["<C-b>"] = { "cancel", mode = { "n", "i" } },
                        ["<C-c>"] = { "cancel", mode = { "n", "i" } },
                        ["<C-s>"] = { "cancel", mode = { "n", "i" } },
                        ["<M-S-q>"] = { "argpoon_add_1", mode = { "n", "i" } },
                        ["<M-S-w>"] = { "argpoon_add_2", mode = { "n", "i" } },
                        ["<M-S-e>"] = { "argpoon_add_3", mode = { "n", "i" } },
                        ["<M-S-u>"] = { "argpoon_add_4", mode = { "n", "i" } },
                        ["<M-S-i>"] = { "argpoon_add_5", mode = { "n", "i" } },
                        ["<M-S-o>"] = { "argpoon_add_6", mode = { "n", "i" } },
                    },
                },
            },
            layouts = {
                smnatale = {
                    layout = {
                        box = "vertical",
                        backdrop = false,
                        row = -1, -- anchors to bottom of page
                        width = 0, -- full screen width
                        height = 0.40,
                        border = "none",
                        title = "{title} {live} {flags}",
                        title_pos = "left",
                        {
                            box = "horizontal",
                            -- wo = {
                            --     winhl = "SnacksPickerBordre:String,Normal:SnacksNormal",
                            -- },
                            { win = "list", border = "bold", title = "{title}" },
                            { win = "preview", border = "bold", title = "{preview}", width = 0.55}
                        },
                        {
                            win = "input",
                            height = 1,
                            border = "bold",
                            keys = {
                                ["<C-f>"] = { "cancel", mode = "i" },
                            } ,
                        },
                    }
                }
            },
        },

        indent = {
            indent = {
                enabled = false,
                only_scope = false,
                only_current = true,
                -- hl = "Normal",
                char = "│",
            },
            chunk = {
                -- when enabled, scopes will be rendered as chunks, except for the
                -- top-level scope which will be rendered as a scope.
                enabled = true,
                -- only show chunk scopes in the current window
                only_current = true,
                priority = 200,
                chunkwidth = 1,
                char = {
                    corner_top = "┌",
                    corner_bottom = "└",
                    -- corner_top = "╭",
                    -- corner_bottom = "╰",
                    horizontal = "─",
                    -- vertical = "│",
                    -- arrow = ">",
                    arrow = "─",
                    -- arrow = "",
                },
            },
            scope = {
                enabled = false,
                priority = 200,
                char = "│",
                underline = false,
                only_current = true,
            },
            animate = { enabled = false, },
        },

        scroll = {
            enabled = true,
            animate = {
                easing = "outQuart",
                -- easing = "inOutQuart",
            },
        },
        statuscolumn = {
            left = { "sign" },
            right = { "fold", "git" },
        },
        animate = {
            fps = 144,
        },
        explorer = { enabled = true },
        bigfile = { enabled = true },
        -- debug = { enabled = true },
        image = { enabled = true },
        lazygit = { enabled = false },
        notifier = { enabled = true },
        quickfile = { enabled = false },
    },

}
