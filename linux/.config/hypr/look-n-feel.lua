local general = {
  gaps_in = 6,
  gaps_out = 12,

  border_size = 3,
  col = {
    inactive_border = "#1a1d25",
    -- active_border = "#5384b4",
    active_border = "#81a1c1",
  },

  allow_tearing = false,

  -- layout = dwindle
  layout = "master",
  resize_on_border = true,
  no_focus_fallback = true,
}

local decoration = {
  rounding = 0,
  rounding_power = 3,
  dim_inactive = false,
  dim_strength = 0.2,
  blur = {
    enabled = true,
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
