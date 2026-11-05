hl.bind(
  "SUPER + N",
  hl.dsp.exec_cmd(
    "focus-app --app-id=edis.tui.nvim -- xdg-terminal-exec --app-id=edis.tui.nvim -e nvim", {
      workspace = "3",
      tile = true,
      tag = "+keep-tiled",
      size = "monitor_w*0.95 monitor_h*0.90",
    })
)

local nvim = { window = "class:edis.tui.nvim" }
for _, key in ipairs { "q", "w", "e", "r", "y", "u" } do
  hl.bind("ALT + " .. key, function()
    if hl.dispatch(hl.dsp.focus(nvim)).ok then
      hl.dispatch(hl.dsp.pass(nvim))
    else
      return { pass_event = true }
    end
  end, { desc = ("arglist %s in nvim"):format(key) })
end
