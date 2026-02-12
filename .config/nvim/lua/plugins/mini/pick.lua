local function arglist_add(i)
    local ok, arglist = pcall(require, "arglist")
    if not ok then return end

    local current = MiniPick.get_picker_matches().current
    if current == nil or vim.uv.fs_stat(current).type ~= "file" then return end

    arglist.arglist[i] = vim.fn.fnamemodify(current, ":p")

    MiniPick.default_choose(current)
    MiniPick.stop()
end

local ui_select_orig = vim.ui.select
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

        argpoon_add_1 = { char = "<M-S-q>", func = function() arglist_add(1) end },
        argpoon_add_2 = { char = "<M-S-w>", func = function() arglist_add(2) end },
        argpoon_add_3 = { char = "<M-S-e>", func = function() arglist_add(3) end },
        argpoon_add_4 = { char = "<M-S-u>", func = function() arglist_add(4) end },
        argpoon_add_5 = { char = "<M-S-i>", func = function() arglist_add(5) end },
        argpoon_add_6 = { char = "<M-S-o>", func = function() arglist_add(6) end },
    },
    options = {
        content_from_bottom = true,
        use_cache = true,
        hidden = true,
    },
    window = {
        config = function()
            local state = MiniPick.get_picker_state()
            local is_preview = state ~= nil and state.buffers.preview == vim.api.nvim_win_get_buf(state.windows.main)
            local is_info = state ~= nil and state.buffers.info == vim.api.nvim_win_get_buf(state.windows.main)
            local preview_width = math.floor(0.45 * vim.o.columns)
            local preview_height = math.floor(0.75 * vim.o.lines)

            local main_height = math.floor(0.40 * vim.o.lines)
            local main_width = math.floor(0.35 * vim.o.columns)

            local width = is_preview and preview_width or main_width
            local height = (is_preview or is_info) and preview_height or main_height

            return { anchor = "NW", row = 0, col = 0, width = width, height = height }
        end,
        -- prompt_caret = "▏",
        prompt_caret = "▎",
        prompt_prefix = "▶ ",
    },
})

local function registry()
    local picker = require("mini.pick")
    local selected = picker.start({
        source = { items = vim.tbl_keys(picker.registry), name = "Registry" }
    })

    if selected == nil then return end

    return picker.registry[selected]()
end
require("mini.pick").registry.registry = registry

-- Ensure that window is updated every time a new buffer is shown in it.
-- Schedule since state data is not yet updated when the buffer is shown.
local refresh_picker = vim.schedule_wrap(function()
    if not MiniPick.is_picker_active() then return end
    MiniPick.refresh()
end)
vim.api.nvim_create_autocmd("BufWinEnter", { callback = refresh_picker })

vim.ui.select = ui_select_orig
