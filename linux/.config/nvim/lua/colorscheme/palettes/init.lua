local M = {}

M.get = function(name)
  local mod = "colorscheme.palettes." .. name
  return require(mod)
end

return M
