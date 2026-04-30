local M = {}
function M.load(name)
  package.loaded['colorschemes.palettes'] = nil
  if vim.g.colors_name then vim.cmd("highlight clear") end
  if vim.fn.exists("syntax_on") then vim.cmd("syntax reset") end
  vim.o.termguicolors = true
  vim.g.colors_name = name

  local colors = require("colorscheme.palettes")[name]
  require("colorscheme.groups").set_hls(colors)
end
return M
