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

hl.workspace_rule { workspace = "w[tv1]s[false]", gaps_out = 0, gaps_in = 0 }
hl.workspace_rule { workspace = "f[1]s[false]", gaps_out = 0, gaps_in = 0 }
hl.window_rule {
  match = { float = false, workspace = "w[tv1]s[false]" },
  border_size = 0,
  rounding = 0,
}
hl.window_rule {
  match = { float = false, workspace = "f[1]s[false]" },
  border_size = 0,
  rounding = 0
}

hl.layer_rule { match = { namespace = "waybar" }, blur = true }
