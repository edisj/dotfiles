local general = {
  gaps_in = 6,
  gaps_out = 10,

  border_size = 2,
  col = {
    -- inactive_border = colors.outline_variant,
    -- active_border = colors.primary,
  },

  allow_tearing = false,
  -- layout = dwindle
  layout = "master",
  resize_on_border = true,
  no_focus_fallback = true,
}
hl.config {
  xwayland = { force_zero_scaling = true },
}

local decoration = {
  active_opacity = 1.0,
  inactive_opacity = 1.0,
  rounding = 2,
  rounding_power = 3,
  dim_inactive = false,
  dim_strength = 0.2,
  blur = {
    enabled = false,
    xray = false,
    size = 4,
    passes = 2,
    -- vibrancy = 0.1696,
    -- vibrancy = 10,
  },
  shadow = {
    enabled = true,
    range = 30,
    render_power = 100,
    -- color = rgba(1a1a1aee)
  }
}
hl.layer_rule({
  name = "noctalia",
  match = {
    namespace = "^noctalia-(bar-.+|notification|dock|panel|attached-panel|osd|window-switcher)$",
  },
  no_anim = true,
  ignore_alpha = 0.75,
  blur = true,
  blur_popups = true,
})

local dwindle = {
  preserve_split = true,
}

local master = {
  new_status = "slave",
}

local misc = {
  disable_hyprland_logo = true,
  disable_splash_rendering = true,
  force_default_wallpaper = false,
}

hl.config {
  general = general,
  decoration = decoration,
  dwindle = dwindle,
  master = master,
  misc = misc,
}
