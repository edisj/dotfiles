local hsluv = require "colorscheme.hsluv"

local M = {}

local _black = "#000000"
local _white = "#FFFFFF"


---@alias HexColor string a hex color in the format "#RRGGBB"

---@param c? HexColor
---@return [integer, integer, integer]?
M.hex_to_rgb = function(c)
  if not c then return end
  -- start at 2 because first char is '#'
  local r = c:sub(2, 3)
  local g = c:sub(4, 5)
  local b = c:sub(6, 7)
  local rgb = { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }

  return rgb
end

M.rgb_to_hex = function(c)
  return c and type(c) == "number" and string.format("#%06x", c)
end

M.get_fg = function(hl_name)
  local fg = vim.api.nvim_get_hl(0, { name = hl_name, link = false }).fg
  return fg and M.rgb_to_hex(fg) or nil
end

M.get_bg = function(hl_name)
  local bg = vim.api.nvim_get_hl(0, { name = hl_name, link = false }).bg
  return bg and M.rgb_to_hex(bg) or nil
end

---@param s string
---@return boolean
M.is_hex_color = function(s)
  if type(s) ~= "string" then return false end
  local pattern = "^#%x%x%x%x%x%x$"
  return s:match(pattern) and true or false
end

local function clamp(val, min, max)
  val = math.max(min, val)
  val = math.min(max, val)
  return val
end

---@param c1? HexColor
---@param alpha number between 0 and 1
---@param c2? HexColor
---@return HexColor?
M.blend = function(c1, alpha, c2)
  if not (c1 and c2) then return end
  local r2, g2, b2 = unpack(M.hex_to_rgb(c2))
  local r1, g1, b1 = unpack(M.hex_to_rgb(c1))

  local weighted_sum = function(x1, x2)
    local fraction_x1 = (1 - alpha) * x1
    local fraction_x2 = alpha * x2
    local sum = fraction_x1 + fraction_x2

    sum = clamp(sum, 0, 255)
    sum = math.floor(sum + 0.5) -- round to nearest whole
    -- cannot be less than 0
    -- sum = math.max(0, sum)
    -- cannot be greater than 255
    -- sum = math.min(sum, 255)
    -- round to nearest whole
    -- sum = math.floor(sum + 0.5)

    return sum
  end

  local blended_hex = string.format(
    "#%02x%02x%02x",
    weighted_sum(r1, r2),
    weighted_sum(g1, g2),
    weighted_sum(b1, b2)
  )

  return blended_hex
end

---@param c HexColor
---@param alpha? number between 0 and 1
---@return HexColor?
M.lighten = function(c, alpha)
  if not c then return end
  alpha = alpha or 0.10
  return M.blend(c, alpha, _white)
end

---@param c HexColor
---@param alpha? number between 0 and 1
---@return HexColor?
M.darken = function(c, alpha)
  if not c then return end
  alpha = alpha or 0.10
  return M.blend(c, alpha, _black)
end

---@param c HexColor?
---@param alpha_s? number between 0 and 1, percentage of saturation to add
---@param alpha_l? number between 0 and 1, percentage of lightness to add
---@return HexColor?
M.brighten = function(c, alpha_s, alpha_l)
  if not c then return end
  alpha_s = alpha_s or 0.20
  alpha_l = alpha_l or 0.05

  local hsl = hsluv.hex_to_hsluv(c)
  hsl[2] = math.min(math.max(hsl[2] + alpha_s * 100, 0), 100)
  hsl[3] = math.min(math.max(hsl[3] + alpha_l * 100, 0), 100)

  return hsluv.hsluv_to_hex(hsl)
end


M.export_kitty = function (palette, path)
  vim.validate("palette", palette, "string")
  vim.validate("path", path, "string")
  local colors = require("colorscheme.palettes")[palette]

end

return M
