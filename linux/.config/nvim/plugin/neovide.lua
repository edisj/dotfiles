if not vim.g.neovide then return end

local o = vim.o
local g = vim.g

o.title = true
-- o.titlestring = " Neovide"
o.titlestring = "Neovide"
o.linespace = 3
o.mousemoveevent = true

g.neovide_scale_factor = g.neovide_scale_factor or 1.0
local change_scale_factor = function(delta)
  g.neovide_scale_factor = g.neovide_scale_factor * delta
end
vim.keymap.set("n", "<C-=>", function() change_scale_factor(1.1) end)
vim.keymap.set("n", "<C-ScrollWheelUp>", function() change_scale_factor(1.1) end)
vim.keymap.set("n", "<C-->", function() change_scale_factor(1/1.1) end)
vim.keymap.set("n", "<C-ScrollWheelDown>", function() change_scale_factor(1/1.1) end)

-- o.guifont = "Rec Mono Semicasual:h15"
o.guifont = "JetBrainsMono Nerd Font:h14"
g.neovide_text_gamma = 0.8
g.neovide_text_contrast = 0
g.neovide_underline_stroke_scale = 1.1

g.neovide_padding_left = 15
g.neovide_padding_right = 15
g.neovide_padding_bottom = 4
g.neovide_padding_top = 8

g.neovide_opacity = 1
local on = false
local function toggle_opacity()
  g.neovide_opacity = on and 1 or 0.95
  on = not on
end
vim.keymap.set("n", "<leader>to", toggle_opacity, { desc = "neovide opacity" })

g.neovide_floating_shadow = true
g.neovide_floating_z_height = 3
g.neovide_light_radius = 5
g.neovide_light_angle_degrees = 45
g.neovide_floating_corner_radius = 0.15

g.neovide_refresh_rate = 180
g.neovide_confirm_quit = true

-- see
-- https://github.com/neovide/neovide/issues/1771
-- https://github.com/neovide/neovide/issues/2235
local grp = vim.api.nvim_create_augroup("NeovideSnapBufChange", { clear = true })
vim.api.nvim_create_autocmd("BufLeave", {
  group = grp,
  callback = function()
    vim.g.neovide_scroll_animation_length = 0
  end,
})
vim.api.nvim_create_autocmd("BufEnter", {
  group = grp,
  callback = function()
    vim.defer_fn(function()
      vim.g.neovide_scroll_animation_length = 0.30
    end, 20)
  end,
})
g.neovide_scroll_animation_length = 0.20
g.neovide_scroll_animation_far_lines = 0
g.neovide_position_animation_length = 0

g.neovide_cursor_animation_length = 0.05
g.neovide_cursor_short_animation_length = 0.03
-- g.neovide_cursor_trail_size = 0.8
g.neovide_cursor_smooth_blink = true

g.neovide_progress_bar_enabled = true
g.neovide_progress_bar_height = 5
g.neovide_progress_bar_animation_speed = 150.0
g.neovide_progress_bar_hide_delay = 0.5
