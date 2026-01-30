return {
    "saghen/blink.cmp",
    -- optional: provides snippets for the snippet source
    enabled = false,
    dependencies = {
        "rafamadriz/friendly-snippets",
        { "xzbdmw/colorful-menu.nvim", opts = {} },
    },
    event = { "InsertEnter", "CmdlineEnter" },
    version = "1.*",
    opts = {
        -- See :h blink-cmp-config-keymap for defining your own keymap
        keymap = {
            preset = "default",
            ["<C-e>"] = { "show", "hide", "fallback" },
            ["<C-j>"] = { "select_next", "fallback" },
            ["<C-k>"] = { "select_prev", "fallback" },
            -- ["<M-j>"] = { "scroll_documentation_down", "fallback" },
            -- ["<M-k>"] = { "scroll_documentation_up", "fallback" },
            ["<M-j>"] = { function(cmp) cmp.scroll_documentation_down(1) end },
            ["<M-k>"] = { function(cmp) cmp.scroll_documentation_up(1) end },
            ["<C-h>"] = { "show_signature", "hide_signature", "fallback" },
            -- ["<C-u>"] = { "scroll_signature_up", "fallback" },
            -- ["<C-d>"] = { "scroll_signature_down", "fallback" },
            ["<C-n>"] = { "show", "show_documentation", "hide_documentation" },
            -- ["<C-n>"] = {
            --     function(cmp)
            --         if cmp.is_visible() then
            --             if cmp.is_documentation_visible() then
            --                 cmp.hide_documentation()
            --             else
            --                 cmp.show_documentation()
            --             end
            --         else
            --             cmp.show()
            --             vim.schedule(function()
            --             cmp.show_documentation()
            --             end)
            --         end
            --     end,
            -- },
        },
        appearance = {
            nerd_font_variant = "mono",
            use_nvim_cmp_as_default = true,
        },

        completion = {
            keyword = {
                range = "prefix",
                -- range = "full",
            },
            accept = {
                auto_brackets = { enabled = false },
            },
            menu = {
                border = "none",
                -- border = { "", "", "", "🮇", "🭿", "▁", "🭼", "▎" },
                -- border = { "", "", "", "▕", "🭿", "▁", "🭼", "▏" },
                -- winblend = 10,
                winhighlight = "BlinkCmpMenu:Normal,BlinkCmpMenuBorder:FloatBorder,BlinkCmpMenuSelection:CursorLine,Search:None",
                draw = {
                    padding = { 1, 1 },
                    components = {

                        -- kind_icon = {
                        --     text = function(ctx) return ' ' .. ctx.kind_icon .. ctx.icon_gap .. ' ' end
                        -- },

                        kind_icon = {
                            text = function(ctx)
                                local kind_icon, _, _ = require('mini.icons').get('lsp', ctx.kind)
                                return kind_icon
                            end,
                            -- (optional) use highlights from mini.icons
                            highlight = function(ctx)
                                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                return hl
                            end,
                        },

                        kind = {
                            -- (optional) use highlights from mini.icons
                            highlight = function(ctx)
                                local _, hl, _ = require('mini.icons').get('lsp', ctx.kind)
                                return hl
                            end,
                        },

                        label = {
                            text = function(ctx)
                                return require("colorful-menu").blink_components_text(ctx)
                            end,
                            highlight = function(ctx)
                                return require("colorful-menu").blink_components_highlight(ctx)
                            end,
                        },
                    },
                    -- We don't need label_description now because label and
                    -- label_description are already combined together in
                    -- label by colorful-menu.nvim.
                    -- columns = { { "kind_icon", "label", "label_description", "source_name", "kind", gap = 3 } },
                    columns = { { "label", "label_description" }, { "kind_icon", "kind", gap = 2 } },
                    -- columns = { { "label"} , {"label_description" }, { "kind_icon", "kind", gap = 1 } },
                    treesitter = { "lsp" },
                },
            },
            documentation = {
                auto_show = false,
                auto_show_delay_ms = 250,
                window = {
                    border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
                    winblend = 10,
                },
            },
            ghost_text = {
                enabled = true,
                show_with_menu = true,
            },
        },
        sources = {
            default = { "lazydev", "lsp", "path", "cmdline" },
            providers = {
                lsp = {
                    fallbacks = {},
                },
                lazydev = {
                    name = "LazyDev",
                    module = "lazydev.integrations.blink",
                    -- make lazydev completions top priority (see `:h blink.cmp`)
                    score_offset = 100,
                },
            },
        },
        fuzzy = {
            implementation = "prefer_rust_with_warning",
            -- implementation = "lua",
            sorts = {
                "score",
                "exact",
                "sort_text",
            }
        },

        -- Experimental signature help support
        signature = { enabled = true },

        cmdline = {
            enabled = false,
            keymap = { preset = "inherit" },
            completion = {
                menu = {
                    auto_show = true,
                    -- border = { "", "", "", "🮇", "🭿", "▁", "🭼", "▎" },
                }
            },
        },
    },
    opts_extend = { "sources.default" },

    -- {
    --     "saghen/blink.indent",
    --     --- @module "blink.indent"
    --     --- @type blink.indent.Config
    --     opts = {
    --         static = {
    --             highlights = { "BlinkIndent" },
    --         },
    --         scope = {
    --             highlights = { "BlinkIndentScope" }
    --         },
    --     },
    -- }

}
