-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    -- kb_options = "caps:escape_shifted_capslock",
    kb_options = "caps:super",
    kb_rules = "",

    repeat_rate = 45,
    repeat_delay = 175,

    follow_mouse = 2,
    sensitivity = -0.5,

    touchpad = {
        disable_while_typing = true,
        natural_scroll = true,
    }
  },
})

hl.config({
  cursor = {
    inactive_timeout = 5.0,
    no_warps = true,
  }
})

-- https://wiki.hypr.land/Configuring/Gestures
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

