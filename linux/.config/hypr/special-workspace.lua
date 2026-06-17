hl.animation {
  enabled = true,
  leaf = "specialWorkspace",
  speed = 2,
  -- spring = "easy",
  bezier = "linear",
  style = "slidefadevert -75%",
}

local function register_special_app(key, name, cmd, height)
  local ws_name = "special:" .. name
  height = height or 0.5
  hl.window_rule {
    match = { class = name },
    workspace = ws_name,
    tile = true
  }
  local m = hl.get_active_monitor()
  local gap = m and math.floor(m.height * (1 - height)) or 500
  hl.workspace_rule {
    workspace = ws_name,
    gaps_out = { top = 0, right = 0, bottom = gap, left = 0 },
    border_size = 0,
    animation = "slidefadevert",
  }
  hl.bind(key, function()
    local _ws = hl.get_active_special_workspace()
    if _ws and _ws.name == ws_name then
      hl.dispatch(hl.dsp.workspace.toggle_special(name))
    else
      hl.exec_cmd(cmd)
    end
  end)
end

for _, app in ipairs {
  {
    name = "kitty-dropdown",
    key = "SUPER + RETURN",
    cmd = "focus-app --app-id=kitty-dropdown kitty --class kitty-dropdown",
    height = 0.60,
  },
  {
    name = "btop-dropdown",
    key = "SUPER + grave",
    cmd = "launch-btop btop-dropdown",
  },
  {
    name = "bluetui-dropdown",
    key = "SUPER + U",
    cmd = "launch-bluetui bluetui-dropdown",
    height = 0.50,
  },
  {
    name = "wiremix-dropdown",
    key = "SUPER + I",
    cmd = "launch-wiremix wiremix-dropdown",
    height = 0.35,
  },
  {
    name = "lf-dropdown",
    key = "SUPER + Tab",
    cmd = "focus-app --app-id=lf-dropdown kitty --class lf-dropdown -e lf",
    height = 0.50,
  },
  {
    name = "discord",
    key = "F1",
    cmd = "focus-app Discord",
    height = 0.75,
  },
  {
    name = "steam",
    key = "F2",
    cmd = "focus-app steam",
    height = 0.50,
  },
  {
    name = "Spotify",
    key = "F3",
    cmd = "focus-app --app-id=Spotify flatpak run com.spotify.Client",
    height = 0.75,
  },
} do
  register_special_app(app.key, app.name, app.cmd, app.height)
end
