
local _defaults = {
    homepage = "nvim",
    cabbrev_help = true,
    use_cache = true,
    close_search_on_bs = true,
    search_cmp_provider = "none",
    search_icon = ">",
    preview_search = true,
    preview_toc = true,
    hl_search_preview = "word",
    hl_toc_preview = "word",
    auto_open_toc = true,
    auto_close_toc = false,
    window_style = "float",
    keymaps = {
        close = "q",
        search = "s",
        open_toc = "t",
        scroll_toc_down = "<C-j>",
        scroll_toc_up = "<C-k>",

        search_accept = "<CR>",
        search_cancel = { "<C-c>", "<Esc>" },

        toc_close = "q",
        toc_jump = "<CR>",
        toc_expand = "l",
        toc_expand_all = "L",
        toc_collapse = "h",
        toc_collapse_all = "H",
    },
    main_window = {
        auto_position = "right",
        auto_resize = true,
        xoffset = -5,
        width = 0.45,
        height = 0.85,
        -- style = "minimal",
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        zindex = 75,
        title = function(win)
            local filename = string.format(" %s (%s)",  vim.fn.fnamemodify(vim.api.nvim_buf_get_name(win.bufnr), ":t"), win.bufnr)
            return filename
        end,
        title_pos = "center",
        footer = {
            { " s search ", "HelpoutFloatFooter" },
            { " ", "HelpoutFloatBorder" },
            { " t table of contents ", "HelpoutFloatFooter" },
            { " ", "HelpoutFloatBorder" },
            { " q close ", "HelpoutFloatFooter" },
        },
        footer_pos = "center",
        bo = {
            buflisted = false,
            bufhidden = "hide",
        },
        wo = {
            number = true,
            -- statuscolumn = " ",
            conceallevel = 1,
            colorcolumn = "",
            cursorline = true,
            signcolumn = "no",
            winbar = "",
        },
    },
    search_window = {
        auto_position = "bot",
        auto_resize = true,
        width = 0.8,
        height = 1,
        yoffset = 3,
        style = "minimal",
        title = "Search",
        title_pos = "center",
        bo = {
            bufhidden = "hide",
            buflisted = false,
        },
        wo = {
            cursorline = false,
        },
    },
    toc_window = {
        auto_position = "topleft",
        anchor = "NW",
        auto_resize = true,
        height = 0.5,
        width = 0.25,
        xoffset = function(win)
            return -(win.win_config.width + 3)
        end,
        yoffset = 1,
        border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
        title = " Table of Contents ",
        title_pos = "center",
        style = "minimal",
        bo = {
            bufhidden = "hide",
            buflisted = false,
        },
        wo = {
            -- wrap = true,
            linebreak = true,
            cursorline = true,
        },
    },
}

local _cmp_providers = {
    ["blink.cmp"] = function()
        local ok, blink = pcall(require, "blink.cmp")
        if ok then
            local source_id = "helpout"
            local source_config = {
                name = "Helpout",
                module = "helpout.integrations.blink",
                opts = {},
            }
            local per_filetype = {
                helpout_search = { "helpout" },
            }

            blink.add_source_provider(source_id, source_config)
            local blink_config = require("blink.cmp.config")
            blink_config.sources.per_filetype = vim.tbl_deep_extend(
                "force", blink_config.sources.per_filetype, per_filetype
            )
        end
    end,
    ["none"] = function()
        -- see `:h complete-functions`
        function HelpoutCompletion(findstart, base, win)
            if findstart == 1 then
                return 0
            end
            local ok, completions = pcall(vim.fn.getcompletion, base, "help")
            return ok and completions or {}
        end
        _G.HelpoutCompletion = HelpoutCompletion
        require("helpout.config").search_window.bo.completefunc = "v:lua.HelpoutCompletion"
        require("helpout.config").search_window.bo.omnifunc = "v:lua.HelpoutCompletion"
        -- local merge = {
        --     search_window = {
        --         bo = {
        --             completefunc = "v:lua.HelpoutCompletion",
        --             omnifunc = "v:lua.HelpoutCompletion",
        --         },
        --     },
        -- }
        -- _defaults = vim.tbl_deep_extend("force", _defaults, merge)
    end
}

local _config = {}
local M = setmetatable({}, {
    __index = function(_, k)
        return _config[k]
    end,
})

-- local M = {}

-- M.config = {}

M.setup = function(opts)
    _config = vim.tbl_deep_extend("force", _defaults, opts or {})

   local provider = _config.search_cmp_provider

   _cmp_providers[provider]()
end

return M
