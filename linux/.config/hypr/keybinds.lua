local cmd = hl.dsp.exec_cmd

hl.bind("SHIFT + ALT + Y", cmd("kitty"))
hl.bind("SHIFT + ALT + N", cmd("firefox"))

hl.bind("Print",                 cmd("hyprshot -m region --clipboard-only"))
hl.bind("SHIFT + Print",         cmd("hyprshot -m region"))
hl.bind("SUPER + SHIFT + Print", cmd("hyprshot -m window"))

local function bind_super(key, cmd)
  hl.bind("SUPER + " .. key, hl.dsp.exec_cmd(cmd))
end
bind_super("R", "hyprctl reload && hyprctl notify 5 2000 0 'fontsize:16  hyprland reloaded'")
bind_super("W", "reload-waybar.sh")
-- bind_super("U", "launch-wiremix")
-- bind_super("I", "launch-bluetui")

bind_super("Space", "launch-walker")
bind_super("SHIFT + Space", "launch-walker -m runner")
bind_super("slash", "launch-walker -m files --width 1600 --height 800")
hl.layer_rule({
  match = { namespace = "^(walker)$" },
  no_anim = true,
})

hl.bind("CTRL + ALT + E", hl.dsp.exec_cmd("launch-fzf-edis", { float = true, center = true, size = { 1200, 1000 } }))
hl.bind("SUPER + O", hl.dsp.exec_cmd("launch-fzf-nvim", { float = true, center = true, size = { 1200, 1200 } }))

--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------
hl.bind("ALT + SHIFT + Space", hl.dsp.window.float())

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
hl.bind("ALT + mouse:272", hl.dsp.window.drag(), { mouse = true })
hl.bind("ALT + SHIFT + mouse:272", hl.dsp.window.resize(), { mouse = true })
hl.bind("ALT + mouse:273", hl.dsp.window.float({ action = "toggle", mouse = true }))
