local colors = require("noctalia").colors

hl.plugin.load("/var/cache/hyprpm/edis/hyprland-plugins/hyprbars.so")

hl.config({
  plugin = {
    hyprbars = {
      enabled = true,
      bar_height = 24,
      bar_blur = false,
      bar_color = colors.primary,
      col = { text = colors.on_secondary },

      bar_precedence_over_border = true,
      bar_part_of_window = true,
      bar_text_align = "left",
      bar_text_size = 18,
      bar_text_font = "JetBrainsMono Nerd Font",
      -- bar_text_weight = "bold",

      bar_buttons_alignment = "right",
      icon_on_hover = false,
      on_double_click = "hyprctl dispatch 'hl.dsp.window.float()'",
    }
  }
})

local button_size = 20
hl.plugin.hyprbars.add_button({
  bg_color = colors.error,
  fg_color = colors.on_error,
  size = button_size,
  icon = "",
  action = "hyprctl dispatch 'hl.dsp.window.close()'",
})
hl.plugin.hyprbars.add_button({
  bg_color = colors.secondary,
  fg_color = colors.surface,
  size = button_size,
  icon = "",
  action = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'",
})

hl.window_rule({
  name = "hyprbars-blacklist",
  match = {
    float = true,
    class = "(steam|discord|zotero)"
  },
  ["hyprbars:no_bar"] = true,
})

hl.window_rule({
  name = "hyprbars-disable-on-tiling",
  match = { float = false },
  ["hyprbars:no_bar"] = true,
})
