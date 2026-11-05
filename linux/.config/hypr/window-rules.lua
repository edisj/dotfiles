local state = require "state"

hl.window_rule {
  -- Ignore maximize requests from all apps. You'll probably like this.
  name  = "suppress-maximize-events",
  match = { class = ".*" },
  suppress_event = "maximize",
}

hl.window_rule {
  -- Fix some dragging issues with XWayland
  name  = "fix-xwayland-drags",
  match = {
    class      = "^$",
    title      = "^$",
    xwayland   = true,
    float      = true,
    fullscreen = false,
    pin        = false,
  },
  no_focus = true,
}

hl.window_rule {
  name  = "move-hyprland-run",
  match = { class = "hyprland-run" },
  move  = "20 monitor_h-120",
  float = true,
}

local open_w = "monitor_w*0.98"
local open_h = "monitor_h*0.93"
hl.window_rule({
  name = "floating-window-max-size",
  match = { float = true },
  max_size = open_w .. " " .. open_h,
  -- persistent_size = true,
})

hl.window_rule {
  name  = "fullscreen-remove-borders",
  match = { float = false, workspace = "f[1]s[false]" },
  border_size = 0,
  rounding = 0
}

-- ws with single tiled window has larger gaps
hl.workspace_rule {
  workspace = "w[tv1]s[false]",
  gaps_out = 24,
  gaps_in = 24,
}

-- remove fullscreen gaps
hl.workspace_rule {
  workspace = "f[1]s[false]",
  gaps_out = 0,
  gaps_in = 0,
}
