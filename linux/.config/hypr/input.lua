-- https://wiki.hypr.land/Configuring/Basics/Variables/#input
hl.config({
  input = {
    kb_layout = "us",
    kb_variant = "",
    kb_model = "",
    kb_options = "caps:escape_shifted_capslock",
    kb_rules = "",

    repeat_rate = 40,
    repeat_delay = 200,

    follow_mouse = 2,
    sensitivity = -0.2,

    touchpad = {
        disable_while_typing = true,
        natural_scroll = true,
    }
  },
})

hl.config({
  cursor = {
    inactive_timeout = 5.0,
  }
})

-- https://wiki.hypr.land/Configuring/Gestures
hl.gesture({
  fingers = 3,
  direction = "horizontal",
  action = "workspace",
})

