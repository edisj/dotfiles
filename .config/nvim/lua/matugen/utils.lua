local M = {}

local _black = "#000000"
local _white = "#FFFFFF"

---@param c HexColor
---@return [integer, integer, integer]
M.hex_to_rgb = function(c)
    -- start at 2 because first char is '#'
    local r = c:sub(2, 3)
    local g = c:sub(4, 5)
    local b = c:sub(6, 7)
    local rgb = { tonumber(r, 16), tonumber(g, 16), tonumber(b, 16) }

    return rgb
end

M.rgb_to_hex = function(c)
    return type(c) == "number" and string.format("#%06x", c)
end

---@param s string
---@return boolean
local is_hex_color = function(s)
    if type(s) ~= "string" then return false end

    local pattern = "^#%x%x%x%x%x%x$"
    return s:match(pattern) and true or false
end


---@param c1 HexColor
---@param alpha number between 0 and 1
---@param c2 HexColor
---@return HexColor
M.blend = function(c1, alpha, c2)
    local r2, g2, b2 = unpack(M.hex_to_rgb(c2))
    local r1, g1, b1 = unpack(M.hex_to_rgb(c1))

    local weighted_sum = function(x1, x2)
        local fraction_x1 = (1 - alpha) * x1
        local fraction_x2 = alpha * x2
        local sum = fraction_x1 + fraction_x2

        -- cannot be less than 0
        sum = math.max(0, sum)
        -- cannot be greater than 255
        sum = math.min(sum, 255)
        -- not sure ...
        sum = math.floor(sum + 0.5)

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
---@return HexColor
M.lighten = function(c, alpha)
    alpha = alpha or 0.10
    return M.blend(c, alpha, _white)
end

---@param c HexColor
---@param alpha? number between 0 and 1
---@return HexColor
M.darken = function(c, alpha)
    alpha = alpha or 0.10
    return M.blend(c, alpha, _black)
end

---@param c HexColor
---@param alpha_s? number between 0 and 1, percentage of saturation to add
---@param alpha_l? number between 0 and 1, percentage of lightness to add
---@return HexColor
M.brighten = function(c, alpha_s, alpha_l)
    alpha_s = alpha_s or 0.20
    alpha_l = alpha_l or 0.05
    local hsluv = require("colorscheme.hsluv")

    local hsl = hsluv.hex_to_hsluv(c)
    -- max saturation/lightness value is 100
    hsl[2] = math.min(hsl[2] + alpha_s * 100, 100)
    hsl[3] = math.min(hsl[3] + alpha_l * 100, 100)

    return hsluv.hsluv_to_hex(hsl)
end

return M
