hl.config({
  plugin = {
    hyprbars = {
      enabled = true,
      bar_height = 18,
      bar_blur = false,

      -- bar_color = "#5384b4",
      bar_color = "#81a1c1",
      -- # bar_color = rgba(111318ff),
      col = { text = "#10131a" },

      bar_precedence_over_border = true,
      bar_part_of_window = true,
      bar_text_align = "center",
      bar_text_size = 18,
      -- bar_text_font = "JetBrainsMono Nerd Font Mono Bold",
      bar_text_font = "JetBrainsMono Nerd Font",
      -- bar_text_weight = 750,

      bar_buttons_alignment = "right",
      --     hyprbars-button = rgb(ff5d62), 20, , hyprctl dispatch killactive,
      --   hyprbars-button = rgb(ffd43b), 20, , hyprctl dispatch fullscreen 1,
      -- # hyprbars-button = $color4, 20, , hyprctl dispatch togglefloating,

      icon_on_hover = false,
      on_double_click = "hyprctl dispatch 'hl.dsp.window.float()'",
    }
  }
})

local button_size = 20
hl.plugin.hyprbars.add_button({
  bg_color = "#ff5d62",
  fg_color = "#000000",
  size = button_size,
  icon = "",
  action = "hyprctl dispatch 'hl.dsp.window.kill()'",
})

hl.plugin.hyprbars.add_button({
  bg_color = "#ffd43b",
  fg_color = "#000000",
  size = button_size,
  icon = "",
  action = "hyprctl dispatch 'hl.dsp.window.fullscreen({ mode = \"maximized\" })'",
})

hl.window_rule({
  name = "hyprbars-blacklist",
  match = {
    float = true,
    class = "(org.mozilla.firefox|steam|discord|zotero)"
  },
  ["hyprbars:no_bar"] = true,
})

hl.window_rule({
  name = "hyprbars-disable-on-tiling",
  match = { float = false },
  ["hyprbars:no_bar"] = true,
})
