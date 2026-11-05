local api = vim.api

local M = {}

local hls_cache = {}
on("ColorScheme", nil, function() hls_cache = {} end)

local function create_hl(target, ...)
  if hls_cache[target] then return end

  local merged_hl = {}
  for _, name in ipairs { ... } do
    local hl = type(name) == "string" and api.nvim_get_hl(0, { name = name, link = false }) or name
    merged_hl = vim.tbl_deep_extend("keep", merged_hl, hl)
  end
  api.nvim_set_hl(0, target, merged_hl)
  hls_cache[target] = true
end

function M.with_hl(text, hl)
  if vim.islist(hl) then create_hl(unpack(hl)) end
  return hl and ("%#" .. (hl[1] or hl) .. "#" .. text .. "%*") or text
end


function M.with_pad(text, pad)
  local spaces = string.rep(" ", pad or 1)
  return spaces .. text .. spaces
end

function M.render(components, module)
  -- if vim.v.virtnum ~= 0 then return "" end

  -- local components = vim.b.stc or default_stc
  local rendered = {}
  for _, c in ipairs(components) do
    if type(c) == "string" then c = module[c] end

    local chunks = {}
    if type(c) == "function" then
      chunks = c() or {}
    elseif type(c) == "table" then
      chunks = c.chunks or { c }
    end

    local out = {}
    for _, chunk in ipairs(chunks) do
      if type(chunk) == "function" then
        for _, sub in ipairs(chunk() or {}) do
          out[#out + 1] = type(sub) == "string" and sub or M.with_hl(sub[1], sub[2])
        end
      elseif type(chunk) == "string" then
        out[#out + 1] = chunk
      else
        out[#out + 1] = M.with_hl(chunk[1], chunk[2])
      end
    end

    local text = table.concat(out)
    local pad = type(c) == "table" and c.padding
    if text ~= "" then
      rendered[#rendered + 1] = pad and M.with_pad(text, pad) or text
    end
  end

  return table.concat(rendered)
end

return M
