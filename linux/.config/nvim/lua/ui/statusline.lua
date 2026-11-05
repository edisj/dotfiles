local api = vim.api
local fn = vim.fn
local fs = vim.fs

local shared = require("ui.shared")
local icons = require("icons")
local M = {}


-- M.searchcount = function()
--   if not vim.o.hlsearch or (MiniPick and MiniPick.is_picker_active()) then return "" end
--   local out = (" [%s/%s]"):format(fn.searchcount().current, fn.searchcount().total)
--   return with_pad(out)
-- end
--
-- M.git = function()
--   local g_head = vim.g.gitsigns_head
--   local b_head = vim.b.gitsigns_head
--   if not (b_head and g_head) then return "" end
--   if g_head == b_head then return "" end
--   local branch = with_hl(" ", "DiagnosticError") .. b_head
--   -- local changes = {}
--   -- changes[#changes + 1] = gitsigns.added and gitsigns.added ~= 0 and "+" .. gitsigns.added or nil
--   -- changes[#changes + 1] = gitsigns.removed and gitsigns.removed ~= 0 and "-" .. gitsigns.removed or nil
--   -- changes[#changes + 1] = gitsigns.changed and gitsigns.changed ~= 0 and "~" .. gitsigns.changed or nil
--   -- local text = table.concat(changes, " ")
--   -- if not_nil(text) then text = "(" .. text .. ")" end
--   return with_pad(branch)
-- end

local name_cache = {}
M.name = {
  chunks = {
    function()
      local name = api.nvim_buf_get_name(0)
      if name_cache[name] then return name_cache[name] end
      local bt = vim.bo.buftype

      -- handle empty buffers
      if name == "" then
        local out
        if bt == "nofile" then out = { "[Scratch]" } end
        if bt == "" or bt == "nowrite" then out = { "[No Name]" } end
        if out then
          name_cache[name] = out
          return out
        end
      end

      -- handle uri's
      if name:match("^term://") then
        local tail = name:match(".*//(.*)$")
        local out = { { " ", "String" }, { tail } }
        name_cache[name] = out
        return out
      elseif name:match("^(%w+://)") then -- just grab tail of uri
        local decoded = vim.uri_decode(name)
        local out = { (decoded:match("<(.*)$") or decoded):gsub("%(", ".") }
        name_cache[name] = out
        return out
      end

      local cwd = fn.getcwd()
      local root, rel = "", fn.fnamemodify(name, ":~")
      if vim.startswith(name, cwd .. "/") then
        root = fs.basename(cwd) .. "/"
        rel = name:sub(#cwd + 2)
      end

      local short = fn.pathshorten(rel, 1)
      local head, tail = short:match("^(.*/)([^/]*)$")
      if not head then head, tail = "", short end

      local out = {
        { root, { "DiagnosticOkB", "DiagnosticOk", "Bold" } },
        { head, { "FunctionB", "Function", "Bold" } },
        { tail }
      }
      name_cache[name] = out
      return out
    end,
  },
  padding = 1
}

local diagnostic_before_entering_insert = { "" }
local diag_map = {
  { icon = icons.diagnostic2.error, hl = "DiagnosticError" },
  { icon = icons.diagnostic2.warn, hl = "DiagnosticWarn" },
  { icon = icons.diagnostic2.info, hl = "DiagnosticInfo" },
  { icon = icons.diagnostic2.hint, hl = "DiagnosticHint" },
}
M.diagnostics = {
  chunks = {
    function()
      if #vim.lsp.get_clients({ bufnr = 0 }) == 0 then return { "" } end
      if fn.mode() == "i" then return diagnostic_before_entering_insert end

      local counts = vim.diagnostic.count(0)
      local chunks = {}
      for i = 1,4 do
        local icon = diag_map[i].icon
        local count = counts[i] == nil and 0 or counts[i]
        local hl = count == 0 and "LineNr" or diag_map[i].hl
        chunks[#chunks + 1] = { "" .. icon .. "" .. count, hl }
        if i < 4 then chunks[#chunks +1] = { ' ' } end
      end
      diagnostic_before_entering_insert = chunks
      return chunks
    end,
  },
  padding = 1,
}

M.loc = {
  chunks = { "%2l:%-2v" },
  padding = 2,
}

-- function M.loc2()
--   local rw = #tostring(api.nvim_buf_line_count(0))
--   -- local cw = #tostring(#api.nvim_get_current_line())
--   return with_pad(
--     with_hl("Row:"  .. " %-" .. rw .. "l ", "LineNr") ..
--     with_hl("Col:" .. " %-3c", "LineNr")
--   )
-- end

local default_stl = { "name", "loc", { "%=" }, "diagnostics", { chunks = { ' ' } } }

function M.render()
  return shared.render(vim.b.stl or default_stl, M)
end

return M
