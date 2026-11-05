local LAYOUTS = { "floating", "master", "scrolling" }
local MAX_W = 0.98
local MAX_H = 0.93

local M = {
  ws_layout = {
    [1] = 0,
    [2] = 0,
    [3] = 0,
    [4] = 0,
    [5] = 0,
    [6] = 0,
    [7] = 0,
    [8] = 0,
    [9] = 0,
    [10] = 0,
  },
  positions = {},
}

function M.ws_get_layout(id)
  local x = M.ws_layout[id]
  return x and LAYOUTS[(x % #LAYOUTS) + 1] or nil
end


function M.ws_cycle_layout(id)
  local ws = id and hl.get_workspace(tostring(id)) or hl.get_active_workspace()
  if not (ws and ws.id and M.ws_layout[ws.id]) then return end

  M.ws_layout[ws.id] = M.ws_layout[ws.id] + 1

  local layout = M.ws_get_layout(ws.id)
  if layout ~= "floating" then
    hl.workspace_rule({ workspace = tostring(ws.id), layout = layout })
  end

  for _, window in ipairs(hl.get_workspace_windows(tostring(ws.id))) do
    hl.dispatch(hl.dsp.window.float({ action = layout == "floating" and "on" or "off", window = window }))
    if layout == "floating" then
      local mon = window.monitor
      local w = math.min(window.size.x, mon.width * MAX_W)
      local h = math.min(window.size.y, mon.height * MAX_H)
      if w < window.size.x or h < window.size.y then
        hl.dispatch(hl.dsp.window.resize { x = w, y = h, window = window })
        hl.dispatch(hl.dsp.window.center { window = window })
      end
    end
  end

  local text = layout == "master" and "tiled" or layout
  hl.notification.create({ text = text, timeout = 2000, font_size = 20 })
end

local function win_has_tag(window, tag)
  local tags = window.tags
  if type(tags) == "string" then
    return tags:find(tag, 1, true) ~= nil
  end
  if type(tags) == "table" then
    for _, t in ipairs(tags) do
      if t == tag or t == tag .. "*" then return true end
    end
  end
  return false
end

local function win_clamp_size(window, max_w, max_h)
  local mon = window.monitor
  local w = math.min(window.size.x, mon.width * max_w)
  local h = math.min(window.size.y, mon.height * max_h)
  if w < window.size.x or h < window.size.y then
    hl.dispatch(hl.dsp.window.resize { x = w, y = h, window = window })
    hl.dispatch(hl.dsp.window.center { window = window })
  end
end

hl.on("window.close", function(window)
  if window.floating and not win_has_tag(window, "keep-size") then
    M.positions[window.class] = {
      x = window.at.x,
      y = window.at.y,
      w = window.size.x,
      h = window.size.y,
    }
  end
end)

hl.on("window.open", function(window)
  local id = window.workspace.id
  local layout = M.ws_get_layout(id)
  if layout and layout == "floating" and not win_has_tag(window, "keep-tiled") then
    hl.dispatch(hl.dsp.window.float({ action = "on", window = window }))
    local pos = M.positions[window.class]
    if pos and not win_has_tag(window, "keep-size") then
      hl.dispatch(hl.dsp.window.resize({ x = pos.w, y = pos.h, window = window }))
      hl.dispatch(hl.dsp.window.move({ x = pos.x, y = pos.y, window = window }))
    end
    win_clamp_size(window, MAX_W, MAX_H)
  end
end)

return M
