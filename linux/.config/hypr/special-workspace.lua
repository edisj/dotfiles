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
    name  = ("dropdown-%s"):format(name),
    match = { class = name },
    workspace = ws_name,
    tile = true,
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
    name = "term.dropdown",
    key = "SUPER + grave",
    cmd = "focus-app --app-id=term.dropdown ghostty --class=term.dropdown",
    height = 0.60,
  },
  -- {
  --   name = "edis.tui.bluetui",
  --   key = "SUPER + U",
  --   cmd = "launch-bluetui edis.tui.bluetui",
  --   height = 0.50,
  -- },
  -- {
  --   name = "wiremix-dropdown",
  --   key = "SUPER + I",
  --   cmd = "launch-wiremix wiremix-dropdown",
  --   height = 0.35,
  -- },
  -- {
  --   name = "lf-dropdown",
  --   key = "SUPER + Tab",
  --   cmd = "focus-app --app-id=lf-dropdown kitty --class lf-dropdown -e lf",
  --   height = 0.50,
  -- },
  {
    name = "spotify",
    key = "SUPER + m",
    cmd = "focus-app --app-id=spotify flatpak run com.spotify.Client",
    height = 0.75,
  },
  {
    name = "thunar",
    key = "SUPER + E",
    cmd = "focus-app --app-id=thunar thunar",
    height = 0.60,
  },
  {
    name = "discord",
    key = "SUPER + O",
    cmd = "focus-app Discord",
    height = 0.75,
  },
} do
  register_special_app(app.key, app.name, app.cmd, app.height)
end
