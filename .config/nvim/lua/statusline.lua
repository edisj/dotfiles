local api = vim.api
local fn = vim.fn

local M = {}

M.restart = function()
    package.loaded["statusline"] = nil
    vim.go.statusline = "%!v:lua.require('statusline').render()"
end

M.restart()

-- grabbed this table from https://github.com/nvim-mini/mini.nvim/blob/main/lua/mini/statusline.lua#L553
local CTRL_S = api.nvim_replace_termcodes("<C-S>", true, true, true)
local CTRL_V = api.nvim_replace_termcodes("<C-V>", true, true, true)
local modes = setmetatable({
    ["n"]    = { long = "Normal",   short = "N",   hl = "StatuslineNormal" },
    ["v"]    = { long = "Visual",   short = "V",   hl = "StatuslineVisual" },
    ["V"]    = { long = "V-Line",   short = "V-L", hl = "StatuslineVisual" },
    [CTRL_V] = { long = "V-Block",  short = "V-B", hl = "StatuslineVisual" },
    ["s"]    = { long = "Select",   short = "S",   hl = "StatuslineVisual" },
    ["S"]    = { long = "S-Line",   short = "S-L", hl = "StatuslineVisual" },
    [CTRL_S] = { long = "S-Block",  short = "S-B", hl = "StatuslineVisual" },
    ["i"]    = { long = "Insert",   short = "I",   hl = "StatuslineInsert" },
    ["R"]    = { long = "Replace",  short = "R" ,  hl = "StatuslineVisual" },
    ["c"]    = { long = "Command",  short = "C",   hl = "StatuslineCommand" },
    ["r"]    = { long = "Prompt",   short = "P",   hl = "StatuslineCommand" },
    ["!"]    = { long = "Shell",    short = "Sh",  hl = "StatuslineCommand" },
    ["t"]    = { long = "Terminal", short = "T",   hl = "StatuslineCommand" },
}, {
    -- By default return 'Unknown' but this shouldn't be needed
    __index = function()
        return   { long = "Unknown",  short = "U" }
    end,
})

local lsps = {
    lua_ls = { name = "LuaLS", icon = "" }
}

local function with_hl(text, hl)
    return "%#" .. hl .. "#" .. text
end

local function wrap(out, n)
    n = n or 1
    local pad = string.rep(" ", n)
    return with_hl(pad, "Statusline") .. out .. with_hl(pad, "Statusline")
end

--         ▊
M.border = function(left_or_right)
    local hl = modes[fn.mode()].hl
    local left = with_hl("▊", hl)
    local right =  with_hl("▊", hl)
    local out = left_or_right == "left" and left or right
    return out
end

M.sep = function()
    local hl = modes[fn.mode()].hl
    local out = with_hl("", hl)
    return wrap(out)
end

M.location = function()
    -- local line = fn.line(".")
    -- local line_count = fn.line("$")
    -- local col = fn.virtcol(".")
    -- local col_count = fn.virtcol("$")

    local out = '%l|%L │ %2v|%-2{virtcol("$") - 1}'
    return wrap(out)
end

M.mode = function()
    local m = fn.mode()
    local icon = ""
    -- local icon = ""
    -- local mode = " " .. icon .. " "  .. modes[m].long:upper() .. " "
    -- local hl = modes[m].hl .. "Inverted"
    local mode = " " .. icon .. " "  .. modes[m].long:upper()
    local hl = modes[m].hl
    local out = with_hl(mode, hl)
    return wrap(out, 0)
end

M.lsp = function()
    local clients = vim.lsp.get_clients({ bufnr = 0 })
    if #clients == 0 then return "" end
    local names = vim.iter(ipairs(clients))
        :map(function(_, client)
            if client.server_capabilities.completionProvider ~= nil then
                return string.format("%s (%d)", client.name, client.id)
            end
        end)
        :totable()
    -- local out = table.concat(names, " ┃ ")
    local out = table.concat(names, "｜")
    return wrap(out)
end

M.buf = function()
    local bufnr = api.nvim_get_current_buf()
    local out = with_hl(string.format("(%d)", bufnr), "Statusline")
    return out .. " "
end

M.file = function()
    local fname = fn.expand("%")
    local ft = vim.bo.filetype
    if fname == "" then return ft end
    local icon, hl = require("mini.icons").get("filetype", ft)
    fname = fname:match("^(%w+://).+") and fname or fn.fnamemodify(fname, ":t")
    local out = with_hl(icon, hl) .. " " .. with_hl(fname, "Statusline")
    out = not vim.bo.modifiable and out .. " " or out
    -- out = vim.bo.modified and out .. " [•]" or out
    out = vim.bo.modified and out .. " [+]" or out
    return wrap(out, 1)
end
 -- { Error = "󰅙", Info = "󰋼", Hint = "󰌵", Warn = "" }
 --  ❌
local diagnostics = {
    { icon = "󰅙", hl = "DiagnosticError" },
    { icon = "", hl = "DiagnosticWarn" },
    { icon = " ", hl = "DiagnosticInfo" },
    { icon = "", hl = "DiagnosticHint" },
}

M.diagnostics = function()
    local count = vim.diagnostic.count(0)
    local out = {}
    for i, c in pairs(count) do
        out[#out + 1] = with_hl(tostring(c) .. diagnostics[i].icon, diagnostics[i].hl)
    end
    return table.concat(out, "  ")
end

M.session = function()
    local out = require("session").this_session()
    return out and wrap(out) or ""
end

M.render = function()
    local components = {
        M.border("left"),
        M.mode(),
        -- M.sep(),
        M.buf(),
        M.file(),
        -- M.sep(),
        M.diagnostics(),
        "%=",
        M.lsp(),
        M.session(),
        M.location(),
        M.border("right"),
    }
    -- local spacer = with_hl(" ", "Normal")
    local spacer = ""

    return table.concat(components, spacer)
end

return M
