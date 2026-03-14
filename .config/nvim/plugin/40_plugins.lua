local autocmd = vim.api.nvim_create_autocmd
local packadd = vim.cmd.packadd

autocmd("PackChanged", {
    callback = function(ev)
        local name = ev.data.spec.name
        local kind = ev.data.kind

        if name == "nvim-treesitter" and kind == "update" then
            if not ev.data.active then
                packadd("nvim-treesitter")
            end
            vim.cmd("TSUpdate")
        end
    end
})

---wraps vim.pack.add with a custom loader
---@param specs (string | vim.pack.Spec)[]
local function add(specs)
    vim.pack.add(specs, {
        load = function(plug_data)
            local name = plug_data.spec.name
            if (plug_data.spec.data or {}).loader then
                return plug_data.spec.data.loader(name)
            end
            packadd(name)
        end,
    })
end

local function load_on(event, pattern, cb)
    autocmd(event, {
        once = true,
        pattern = pattern or "*",
        callback = cb,
    })
end

add({

    {
        src = "https://github.com/nvim-treesitter/nvim-treesitter",
        version = "main",
        data = {
            loader = function(name)

                packadd(name)
                local install_these_PLEASE = {
                    "asm",
                    "bash",
                    "c",
                    "cpp",
                    "css",
                    "diff",
                    "html",
                    "java",
                    "javascript",
                    "json",
                    "lua",
                    "python",
                    "toml",
                    "vimdoc",
                    "zsh",
                }
                require("nvim-treesitter").install(install_these_PLEASE)

                local function enable_ts_features(ev)
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

                autocmd("FileType", {
                    desc = "Enable treesitter features on valid filetype",
                    group = vim.api.nvim_create_augroup("treesitter.setup", {}),
                    callback = enable_ts_features,
                })
            end
        },
    },

    {
        src = "https://github.com/windwp/nvim-autopairs",
        data = {
            loader = function(name)
                load_on("InsertEnter", "*", function()
                    packadd(name)
                    local autopairs = require("nvim-autopairs")

                    autopairs.setup({
                        disable_filetype = { "helpout_search" },
                        map_cr = true,
                        map_bs = true,
                        -- map_c_w = true,
                        check_ts = true,
                        -- ts_config = { lua = { 'string' } },
                        fast_wrap = {
                            map = '<C-e>',
                            chars = { '{', '[', '(', '"', "'" },
                            pattern = [=[[%'%"%>%]%)%}%,]]=],
                            end_key = '$',
                            before_key = 'h',
                            after_key = 'l',
                            cursor_pos_before = true,
                            keys = 'qwertyuiopzxcvbnmasdfghjkl',
                            manual_position = true,
                            highlight = 'Search',
                            highlight_grey='Comment'
                        }
                    })

                    autopairs.remove_rule("`")
                    autopairs.add_rules(require("nvim-autopairs.rules.endwise-lua"))
                end)
            end,
        },
    },

    {
        src = "https://github.com/mason-org/mason.nvim",
        data = {
            loader = function(name)
                load_on("UIEnter", "*", function()
                    packadd(name)
                    require("mason").setup({
                        ui = {
                            width = 0.85,
                            height = 0.80,
                            border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
                        },
                    })

                    -- https://www.reddit.com/r/neovim/comments/1p1y73n/automatically_downloading_and_installing_lsps/
                    local ensure_installed = {
                        "lua-language-server",
                        "stylua",
                        "basedpyright",
                        "black",
                        "debugpy",
                        "java-debug-adapter",
                        "jdtls",
                        "bash-language-server",
                        "hyprls",
                        "codelldb",
                        "clangd",
                    }

                    local already_installed = require("mason-registry").get_installed_package_names()

                    for _, pack in ipairs(ensure_installed) do
                        if not vim.tbl_contains(already_installed, pack) then
                            vim.cmd("MasonInstall " .. pack)
                        end
                    end

                    local auto_enable = {
                        "lua_ls",
                        "bashls",
                        "basedpyright",
                        "hyprls",
                        "clangd",
                    }
                    vim.lsp.enable(auto_enable)

                    vim.keymap.set("n", "<leader>M", "<Cmd>Mason<CR>", { desc = "Open Mason" })
                end)
            end,
        }
    },

    {
        src = "https://github.com/folke/lazydev.nvim",
        data = {
            loader = function(name)
                load_on("Filetype", "lua", function()
                    add({
                        "https://github.com/Bilal2453/luvit-meta",
                        "https://github.com/DrKJeff16/wezterm-types",
                    })
                    packadd(name)
                    require("lazydev").setup({
                        library = {
                            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
                            { path = "wezterm-types", mods = { "wezterm" } },
                        },
                    })
                end)
            end
        },
    },

    {
        src = "https://github.com/lewis6991/gitsigns.nvim",
        data = {
            loader = function(name)
                load_on({ "BufReadPost", "BufNewFile" }, "*", function()
                    packadd(name)
                    require("gitsigns").setup({
                        signs = {
                            add = { text = "▎" },
                            change = { text = "▎" },
                            delete = { text = "-" },
                            topdelete = { text = "-" },
                            changedelete = { text = "▎" },
                            untracked = { text = "▎" },
                        },
                    })
                end)
            end
        },
    },

    {
        src = "https://github.com/folke/flash.nvim",
        data = {
            loader = function(name)
                load_on({ "BufReadPost", "BufNewFile" }, "*", function()
                    packadd(name)
                    require("flash").setup({
                        labels = "asdfghjklqwertyuiopzxcvbnm",
                        modes = {
                            char = {
                                enabled = true,
                                keys = { "f", "F", "t", "T", ";", "," },
                                char_actions = function(motion)
                                    return {
                                        [";"] = "right", -- set to `right` to always go right
                                        [","] = "left", -- set to `left` to always go left
                                        -- clever-f style
                                        [motion:lower()] = "next",
                                        [motion:upper()] = "prev",
                                        -- jump2d style: same case goes next, opposite case goes prev
                                        -- [motion] = "next",
                                        -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
                                    }
                                end,
                            },
                        },
                    })

                    vim.keymap.set({"n", "x", "o"}, "b", function() require("flash").jump() end)
                    vim.keymap.set({"n", "x", "o"}, "<leader>s", function() require("flash").jump() end)
                    vim.keymap.set({"o"}, "B", function() require("flash").remote() end)
                    vim.keymap.set({"c"}, "<C-s>", function() require("flash").jump() end)
                    vim.keymap.set({"n"}, "<C-y>", "y<Cmd>lua require('flash').remote()<CR>")
                end)
            end,
        }
    },

})

-- mini.nvim =============================================================================
add({
    {
        src = "https://github.com/nvim-mini/mini.nvim",
        data = {
            loader = function(name)
                packadd(name)

                require("mini.extra").setup()
                require("mini.splitjoin").setup()
                require("mini.align").setup()
                require("mini.trailspace").setup()
                require("mini.icons").setup()

                require("mini.ai").setup({
                    mappings = {
                        inside      = "i",
                        inside_next = "in",
                        inside_last = "il",
                        around      = "o",
                        around_next = "on",
                        around_last = "ol",
                        -- Move cursor to corresponding edge of `o` textobject
                        goto_left  = "g[",
                        goto_right = "g]",
                    },
                    n_lines = 50,
                    -- custom_textobjects = {
                    --     F = require("mini.ai").gen_spec.treesitter({ a = "@function.outer", i = "@function.inner" }),
                    --     C = require("mini.ai").gen_spec.treesitter({ a = "@class.outer", i = "@class.inner" }),
                    --     B = require('mini.extra').gen_ai_spec.buffer(),
                    --     D = require('mini.extra').gen_ai_spec.diagnostic(),
                    --     I = require('mini.extra').gen_ai_spec.indent(),
                    --     L = require('mini.extra').gen_ai_spec.line(),
                    --     N = require('mini.extra').gen_ai_spec.number(),
                    -- },
                })

                require("mini.surround").setup({
                    mappings = {
                        add       = "sp",
                        delete    = "sd",
                        replace   = "sr",
                        find      = "sf",
                        find_left = "sF",
                        highlight = "sh",

                        suffix_next = "n",
                        suffix_last = "l",
                    },
                    highlight_duration = 1500,
                })

                require("mini.clue").setup({
                    triggers = {
                        { mode = { "n", "x" }, keys =  "<leader>" },
                        { mode = { "n", "x" }, keys =  "[" },
                        { mode = { "n", "x" }, keys =  "]" },
                        { mode = { "n", "x" }, keys =  "g" },
                        { mode = { "n", "x" }, keys =  "'" },
                        { mode = { "n", "x" }, keys =  "`" },
                    }
                })

                local function arglist_add(i)
                    local ok, arglist = pcall(require, "arglist")
                    if not ok then return end

                    local current = MiniPick.get_picker_matches().current
                    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end

                    arglist.arglist[i] = vim.fn.fnamemodify(current, ":p")

                    MiniPick.default_choose(current)
                    MiniPick.stop()
                end
                require("mini.pick").setup({
                    -- See `:h MiniPick-actions`.
                    mappings = {
                        move_down  = "<C-j>",
                        move_start = "<C-g>",
                        move_up    = "<C-k>",

                        refine        = "<C-Space>",
                        refine_marked = "<C-M-Space>",

                        scroll_down  = "<C-M-j>",
                        scroll_left  = "<C-M-h>",
                        scroll_right = "<C-M-l>",
                        scroll_up    = "<C-M-k>",

                        arglist_add_1 = { char = "<M-S-q>", func = function() arglist_add(1) end },
                        arglist_add_2 = { char = "<M-S-w>", func = function() arglist_add(2) end },
                        arglist_add_3 = { char = "<M-S-e>", func = function() arglist_add(3) end },
                        arglist_add_4 = { char = "<M-S-u>", func = function() arglist_add(4) end },
                        arglist_add_5 = { char = "<M-S-i>", func = function() arglist_add(5) end },
                        arglist_add_6 = { char = "<M-S-o>", func = function() arglist_add(6) end },
                    },
                    options = {
                        content_from_bottom = false,
                        use_cache = true,
                        hidden = true,
                    },
                    window = {
                        config = {
                            width = 50,
                            height = 20,
                            border = "solid",
                        },
                        -- prompt_caret = "▏",
                        prompt_caret = "▎",
                        prompt_prefix = "▶ ",
                    },
                })

                require("mini.pick").registry.registry = function()
                    local picker = require("mini.pick")
                    local selected = picker.start({
                        source = { items = vim.tbl_keys(picker.registry), name = "Registry" }
                    })
                    if selected == nil then return end
                    return picker.registry[selected]()
                end

                require("mini.files").setup({
                    mappings = {
                        mark_goto = "<leader>",
                        -- go_in = "<CR>",
                        -- go_in_plus = "L",
                        -- go_out = "",
                        -- go_out_plus = "H",
                    },
                    windows = {
                        width_nofocus = 10,
                        width_focus = 40,
                    },
                })

                autocmd("User", {
                    pattern = "MiniFilesBufferCreate",
                    callback = function(ev)
                        vim.keymap.set({"n", "i", "x"}, "<C-s>", function()
                            vim.cmd.stopinsert()
                            require("mini.files").synchronize()
                        end, { desc = "MiniFiles synchronize", buffer = ev.data.buf_id })
                    end,
                })

                local set_mark = function(id, path, desc) MiniFiles.set_bookmark(id, path, { desc = desc }) end
                autocmd("User", {
                    pattern = "MiniFilesExplorerOpen",
                    callback = function()
                        set_mark("c", vim.fn.stdpath("config") .. "/lua", "Config") -- path
                        set_mark("w", vim.fn.getcwd, "Working directory") -- callable
                        set_mark("~", "~", "Home directory")
                    end,
                })

                autocmd('User', {
                    pattern = 'MiniFilesWindowOpen',
                    callback = function(ev)
                        local win_id = ev.data.win_id
                        -- vim.wo[win_id].winblend = 50
                        local config = vim.api.nvim_win_get_config(win_id)
                        config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
                        -- config.border = "rounded"
                        vim.api.nvim_win_set_config(win_id, config)
                        vim.wo[win_id].scrolloff = 2
                        vim.wo[win_id].sidescrolloff = 0
                    end,
                })

                local ensure_center_layout = function(ev)
                    local state = MiniFiles.get_explorer_state()
                    if state == nil then return end

                    -- Compute "depth offset" - how many windows are between this and focused
                    local path_this = vim.api.nvim_buf_get_name(ev.data.buf_id):match('^minifiles://%d+/(.*)$')
                    local depth_this
                    for i, path in ipairs(state.branch) do
                        if path == path_this then depth_this = i end
                    end
                    if depth_this == nil then return end
                    local depth_offset = depth_this - state.depth_focus

                    local widths = { 55, 20, 10 }
                    -- Adjust config of this event's window
                    local i = math.abs(depth_offset) + 1
                    local win_config = vim.api.nvim_win_get_config(ev.data.win_id)
                    win_config.width = i <= #widths and widths[i] or widths[#widths]

                    win_config.zindex = 99
                    win_config.col = math.floor(0.5 * (vim.o.columns - widths[1]))
                    local sign = depth_offset == 0 and 0 or (depth_offset > 0 and 1 or -1)
                    for j = 1, math.abs(depth_offset) do
                        -- widths[j+1] for the negative case because we don't want to add the center window's width
                        local prev_win_width = (sign == -1 and widths[j+1]) or widths[j] or widths[#widths]
                        -- Add an extra +2 each step to account for the border width
                        local new_col = win_config.col + sign * (prev_win_width + 2)
                        if (new_col < 0) or (new_col + win_config.width > vim.o.columns) then
                            win_config.zindex = win_config.zindex - 1
                            break
                        end
                        win_config.col = new_col
                    end

                    win_config.height = depth_offset == 0 and 20 or 16
                    win_config.row = math.floor(0.5 * (vim.o.lines - win_config.height))
                    -- win_config.border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
                    -- win_config.footer = { { tostring(depth_offset), "Normal" } }
                    vim.api.nvim_win_set_config(ev.data.win_id, win_config)
                end

                autocmd("User", { pattern = "MiniFilesWindowUpdate", callback = ensure_center_layout })

                load_on("InsertEnter", "*", function()
                    require("mini.completion").setup({

                        delay = { completion = 100, info = 100, signature = 50 },
                        -- `height` and `width` are maximum dimensions.
                        window = {
                            info = { height = 25, width = 130, border = "rounded" },
                            signature = { height = 25, width = 130, border = "rounded" },
                        },

                        lsp_completion = {
                            source_func = 'completefunc',
                            -- source_func = 'omnifunc',

                            -- `auto_setup` should be boolean indicating if LSP completion is set up
                            -- on every `BufEnter` event.
                            auto_setup = true,

                            -- A function which takes LSP 'textDocument/completion' response items
                            -- (each with `client_id` field for item's server) and word to complete.
                            -- Output should be a table of the same nature as input. Common use case
                            -- is custom filter/sort. Default: `default_process_items`
                            process_items = nil,

                            -- A function which takes a snippet as string and inserts it at cursor.
                            -- Default: `default_snippet_insert` which tries to use 'mini.snippets'
                            -- and falls back to `vim.snippet.expand` (on Neovim>=0.10).
                            snippet_insert = nil,
                        },

                        -- Fallback action as function/string. Executed in Insert mode.
                        -- To use built-in completion (`:h ins-completion`), set its mapping as
                        -- string. Example: set '<C-x><C-l>' for 'whole lines' completion.
                        fallback_action = '<C-n>',

                        -- Module mappings. Use `''` (empty string) to disable one. Some of them
                        -- might conflict with system mappings.
                        mappings = {
                            -- Force two-step/fallback completions
                            force_twostep = "<C-Space>",
                            force_fallback = "<C-A-Space>",

                            -- Scroll info/signature window down/up. When overriding, check for
                            -- conflicts with built-in keys for popup menu (like `<C-u>`/`<C-o>`
                            -- for 'completefunc'/'omnifunc' source function; or `<C-n>`/`<C-p>`).
                            scroll_down = "<M-j>",
                            scroll_up = "<M-k>",
                        },
                    })
                    autocmd("FileType", {
                        pattern = { "snacks_picker_input", "minifiles" },
                        callback = function(_)
                            vim.b.minicompletion_disable = true
                        end,
                    })
                end)

                load_on("CmdlineEnter", "*", function() require("mini.cmdline").setup() end)

                vim.keymap.set("n", "<C-f>", function()
                    require("mini.pick").builtin.files({ hidden = true })
                end, { desc = "MiniPick files" })

                vim.keymap.set("n", "<C-e>", function()
                    if not require("mini.files").close() then
                        require("mini.files").open(vim.api.nvim_buf_get_name(0), false)
                    end
                end, { desc = "MiniFiles toggle" })
            end,
        },
    },

})

-- snacks.nvim ===========================================================================
add({
    {
        src = "https://github.com/folke/snacks.nvim",
        data = {
            loader = function(name)
                packadd(name)

                -- local function arglist_add(i)
                --     local ok, arglist = pcall(require, "arglist")
                --     if not ok then return end
                --     return {
                --         action = function(picker, item)
                --             local file = item.file
                --             if file and vim.uv.fs_stat(file).type ~= "file" then return end
                --             arglist.arglist[i] = file
                --             picker:close()
                --             vim.cmd.edit(file)
                --         end,
                --         desc = "Argpoon add " .. i,
                --     }
                -- end
                require("snacks").setup({
                    styles = {
                        dashboard = {
                            wo = {
                                fillchars = "eob: ",
                            },
                        },
                    },
                    dashboard = {
                        -- header = "",
                        row = nil,
                        col = nil,
                        preset = {
                            keys = {
                                { icon = " ", key = "f", desc = "Find File",    action = ":Pick files" },
                                -- { icon = " ", key = "n", desc = "New File",     action = ":ene | startinsert" },
                                -- { icon = " ", key = "g", desc = "Find Text",    action = ":lua Snacks.dashboard.pick('live_grep')" },
                                -- { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.dashboard.pick('oldfiles')" },
                                -- { icon = " ", key = "c", desc = "Config",       action = ":lua Snacks.dashboard.pick('files', {cwd = vim.fn.stdpath('config')})" },
                                { icon = " ", key = "s", desc = "Last Session", action = ":lua Session.last()" },
                                -- { icon = "󰒲 ", key = "L", desc = "Lazy",         action = ":Lazy", enabled = package.loaded.lazy ~= nil },
                                { icon = " ", key = "q", desc = "Quit",         action = ":qa" },
                            },
                        },
                        sections = {
                            { section = "header" },
                            {
                                pane = 2,
                                section = "terminal",
                                cmd = "colorscript -e square",
                                height = 5,
                                padding = 1,
                            },
                            { section = "keys", gap = 1, padding = 1 },
                            -- { pane = 2, icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                            { pane = 2, title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
                            { pane = 2, icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
                            {
                                pane = 2,
                                icon = " ",
                                title = "Git Status",
                                section = "terminal",
                                enabled = function() return Snacks.git.get_root() ~= nil end,
                                padding = 1,
                                ttl = 5 * 60,
                                indent = 3,
                                cmd = "git --no-pager diff --stat -B -M -C",
                                -- cmd = "git status --short --branch --renames",
                                height = 10,
                            },
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
                        -- actions = {
                        --     arglist_add_1 = arglist_add(1),
                        --     arglist_add_2 = arglist_add(2),
                        --     arglist_add_3 = arglist_add(3),
                        --     arglist_add_4 = arglist_add(4),
                        --     arglist_add_5 = arglist_add(5),
                        --     arglist_add_6 = arglist_add(6),
                        -- },
                        win = {
                            input = {
                                keys = {
                                    ["<C-f>"] = { "cancel", mode = { "n", "i" } },
                                    ["<C-b>"] = { "cancel", mode = { "n", "i" } },
                                    ["<C-c>"] = { "cancel", mode = { "n", "i" } },
                                    ["<C-s>"] = { "cancel", mode = { "n", "i" } },
                                    -- ["<M-S-q>"] = { "arglist_add_1", mode = { "n", "i" } },
                                    -- ["<M-S-w>"] = { "arglist_add_2", mode = { "n", "i" } },
                                    -- ["<M-S-e>"] = { "arglist_add_3", mode = { "n", "i" } },
                                    -- ["<M-S-u>"] = { "arglist_add_4", mode = { "n", "i" } },
                                    -- ["<M-S-i>"] = { "arglist_add_5", mode = { "n", "i" } },
                                    -- ["<M-S-o>"] = { "arglist_add_6", mode = { "n", "i" } },
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
                        left = { "git", "sign" },
                        right = { },
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
                })

                vim.keymap.set("n", "<C-`>", function() Snacks.explorer() end, { desc = "Explorer" })
                vim.keymap.set("n", "<leader>.", function() Snacks.scratch() end, { desc = "Toggle Scratch Buffer" })
                vim.keymap.set("n", "<leader>S", function() Snacks.scratch.select() end, { desc = "Select Scratch Buffer" })
            end,
        },
    },

})

-- debug =================================================================================
add({
    "https://codeberg.org/mfussenegger/nvim-jdtls",

    {
        src = "https://codeberg.org/mfussenegger/nvim-dap",
        data = {
            loader = function(name)
                packadd(name)
                local dap = require("dap")

                dap.configurations.lua = {
                    {
                        type = "nlua",
                        request = "attach",
                        name = "Attach to running Neovim instance",
                    }
                }
                dap.adapters.nlua = function(callback, config)
                    callback({
                        type = "server",
                        host = config.host or "127.0.0.1",
                        port = config.port or 8086
                    })
                end

                dap.adapters.codelldb = {
                    type = "executable",
                    command = "codelldb",
                }
                dap.configurations.c = {
                    name = "launch",
                    type = "lldb",
                    request = "launch",
                    program = function()
                        return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
                    end,
                    cwd = "${workspaceFolder}",
                    stopOnEntery = false,
                    args = {},

                }
                dap.configurations.cpp = dap.configurations.c

                local function map(lhs, rhs, desc)
                    vim.keymap.set("n", lhs, rhs, { silent = true, desc = desc or "" })
                end

                map("<leader>db", function() dap.toggle_breakpoint() end, "Dap: Toggle Breakpoint")

                map("<F1>", function() dap.continue() end,  "Debug continue")
                map("<F2>", function() dap.restart() end,   "Debug retstart")
                map("<F3>", function() dap.step_out() end,  "Debug step out")
                map("<F4>", function() dap.step_into() end, "Debug step into")
                map("<F5>", function() dap.step_back() end, "Debug step back")
                map("<F6>", function() dap.step_over() end, "Debug step over")
            end,
        },
    },

    {
        src = "https://github.com/igorlfs/nvim-dap-view",
        data = {
            loader = function(name)
                packadd(name)
                require("dap-view").setup({
                    winbar = {
                        -- sections = { "scopes", "breakpoints", "threads", "exceptions", "repl", "console" },
                        sections = { "watches", "scopes", "breakpoints", "threads", "exceptions", "repl" },
                        default_section = "scopes",
                    },
                    switchbuf = "usetab,uselast",
                })

                local dap = require("dap")
                local dv = require("dap-view")
                dap.listeners.before.attach["dap-view-config"] = function() dv.open() end
                dap.listeners.before.launch["dap-view-config"] = function() dv.open() end
                dap.listeners.before.event_terminated["dap-view-config"] = function() dv.close() end
                dap.listeners.before.event_exited["dap-view-config"] = function() dv.close() end

                vim.keymap.set("n", "<leader>dv", "<Cmd>DapViewToggle<CR>")
            end,
        },
    },

})

-- do
--
--     local _win_config = function()
--         local state = MiniPick.get_picker_state()
--         local is_preview = state ~= nil and state.buffers.preview == vim.api.nvim_win_get_buf(state.windows.main)
--         local is_info = state ~= nil and state.buffers.info == vim.api.nvim_win_get_buf(state.windows.main)
--         local preview_width = math.floor(0.45 * vim.o.columns)
--         local preview_height = math.floor(0.75 * vim.o.lines)
--
--         local main_height = math.floor(0.40 * vim.o.lines)
--         local main_width = math.floor(0.35 * vim.o.columns)
--
--         local width = is_preview and preview_width or main_width
--         local height = (is_preview or is_info) and preview_height or main_height
--
--         return { anchor = "NW", row = 0, col = 0, width = width, height = height }
--     end
--
--     -- Ensure that window is updated every time a new buffer is shown in it.
--     -- Schedule since state data is not yet updated when the buffer is shown.
--     local refresh_picker = vim.schedule_wrap(function()
--         if not MiniPick.is_picker_active() then return end
--         MiniPick.refresh()
--     end)
--     autocmd("BufWinEnter", { callback = refresh_picker })
-- end

-- vim.pack.add({

-- }, { load = load_plug })
