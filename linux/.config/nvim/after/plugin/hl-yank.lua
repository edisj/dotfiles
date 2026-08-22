local unpack_rgb = function(rgb)
  local r = math.floor(rgb / 65536) % 256
  local g = math.floor(rgb / 256) % 256
  local b = rgb % 256
  return r, g, b
end

local blend = function(c1, alpha, c2)
  local r1, g1, b1 = unpack_rgb(c1)
  local r2, g2, b2 = unpack_rgb(c2)

  local weighted_sum = function(x1, x2)
    local fraction_x1 = (1 - alpha) * x1
    local fraction_x2 = alpha * x2
    local sum = fraction_x1 + fraction_x2
    sum = math.min(math.max(sum, 0), 255) -- clamp to [0, 255]
    sum = math.floor(sum + 0.5) -- round to nearest whole
    return sum
  end

  return string.format(
    "#%02x%02x%02x",
    weighted_sum(r1, r2),
    weighted_sum(g1, g2),
    weighted_sum(b1, b2)
  )
end

local bg = vim.api.nvim_get_hl(0, { name = "Normal" }).bg
local incsearch = vim.api.nvim_get_hl(0, { name = "IncSearch" }).bg

local durations = {}

local total_time_ms = 200
local start, stop, step = 100, 1, -1
for i = start, stop, step do
  durations[#durations + 1] = (i/10) * total_time_ms

  local j = (i - start) / (stop - start)
  local alpha = 0.20 + 0.80 * j
  local hl = blend(bg, 1-alpha, incsearch)
  local name = "Yank" .. (i - stop + 1)
  vim.api.nvim_set_hl(0, name, { bg = hl, fg = "#000000", bold = true })
end

on("TextYankPost", "highlight-yank", { desc = "Highlight when yanking (copying) text." }, function()
  local ev = vim.v.event

  local priority = 1
  vim.hl.hl_op({ higroup = "Yank1", timeout = durations[1] })

  for i = 2, 100 do
    priority = priority + 1
    local duration = durations[i]
    local delay = (durations[1] - durations[i]) / 2
    local higroup = "Yank" .. i
    vim.defer_fn(function()
      vim.hl.hl_op({ event = ev, higroup = higroup, timeout = duration })
    end, delay)
  end

end)
