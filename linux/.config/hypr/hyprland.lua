hl.on("hyprland.start", function()
  hl.exec_cmd("hypridle")
  hl.exec_cmd("noctalia")

  -- hl.exec_cmd("hyprpm reload -n")
  -- hl.exec_cmd("hyprpaper")
end)

hl.env("XCURSOR_SIZE", 40)
hl.env("HYPRCURSOR_SIZE", 40)
hl.env("GDK_SCALE", 1.2)

hl.monitor {
  output = "",
  mode = "preferred",
  position = "auto",
  -- scale = 1.25,
}
hl.monitor {
  output = "DP-5",
  mode = "2560x1440@180",
  position = "0x0",
  -- scale = 1.07,
}
hl.monitor { -- macbook
  output = "eDP-1",
  mode = "preferred",
  position = "auto",
  scale = 1.5,
}

require "look-n-feel"
require "input"
require "window-rules"
require "animations"
require "special-workspace"
require "nvim"
require "keybinds"
-- require "plugins"

-- For Noctalia Color templates
require("noctalia").apply_theme()
