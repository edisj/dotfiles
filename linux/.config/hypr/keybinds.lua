local cmd = hl.dsp.exec_cmd

hl.bind("SHIFT + ALT + Y", cmd("ghostty"))
hl.bind("SHIFT + ALT + N", cmd("firefox"))

hl.bind("Print",                 cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print",         cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + Print", cmd("hyprshot -m window"))

local function bind_super(key, _cmd)
  hl.bind("SUPER + " .. key, hl.dsp.exec_cmd(_cmd))
end
bind_super("R", "hyprctl reload && hyprctl notify 5 2000 0 'fontsize:16  hyprland reloaded'")
-- bind_super("U", "launch-wiremix")
-- bind_super("I", "launch-bluetui")

local state = require("state")
hl.bind("SUPER + TAB", function() state.ws_cycle_layout() end)

local function noctalia(_cmd)
  return cmd("noctalia msg " .. _cmd)
end
hl.bind("SUPER + Space",         noctalia("panel-toggle launcher"))
hl.bind("SUPER + S",             noctalia("panel-toggle control-center"))
-- hl.bind("ALT + Tab",             noctalia("window-switcher hold"))
-- hl.bind("ALT + SHIFT + Tab",     noctalia("window-switcher hold reverse"))
hl.bind("SUPER + comma",         noctalia("settings-toggle"))
hl.bind("XF86AudioRaiseVolume",  noctalia("volume-up"))
hl.bind("XF86AudioLowerVolume",  noctalia("volume-down"))
hl.bind("XF86AudioMute",         noctalia("volume-mute"))
hl.bind("XF86MonBrightnessUp",   noctalia("brightness-up"))
hl.bind("XF86MonBrightnessDown", noctalia("brightness-down"))
hl.window_rule({
  name = "noctalia-float-settings",
  match = { class = "dev.noctalia.Noctalia" },
  float = true,
  tag = "+keep-size",
  size = { 1080, 1020 },
})

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.bind("SUPER + F", hl.dsp.window.float())

hl.bind("SUPER + BACKSPACE", hl.dsp.window.close())
hl.bind("SUPER + SHIFT + BACKSPACE", hl.dsp.window.kill())

for i = 1, 10 do
  local key = i % 10
  hl.bind("ALT + " .. key, function()
    local ws = hl.get_active_special_workspace()
    if ws then
      local name = (ws.name):gsub("^special:", "")
      hl.dispatch(hl.dsp.workspace.toggle_special(name))
    end
    hl.dispatch(hl.dsp.focus { workspace = i })
  end)
  hl.bind("ALT + SHIFT + " .. key, hl.dsp.window.move({ workspace = i }))
end

for key, direction in pairs { h = "left", j = "down", k = "up", l = "right" } do
  hl.bind("SUPER + " .. key,         hl.dsp.focus({ direction = direction }))
  hl.bind("SUPER + " .. direction,   hl.dsp.focus({ direction = direction }))
  hl.bind("SUPER + SHIFT + " .. key, hl.dsp.window.move({ direction = direction }))
end

hl.bind("ALT + Tab", function()
  hl.dispatch(hl.dsp.window.cycle_next())
  hl.dispatch(hl.dsp.window.bring_to_top())
end)

---------------
---- MOUSE ----
---------------
hl.config({
  binds = { drag_threshold = 0 },
})
hl.bind("SUPER + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("SUPER  + mouse:273", hl.dsp.window.resize(), { mouse = true })
-- hl.bind("ALT + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.float({ action = "toggle", mouse = true }))
