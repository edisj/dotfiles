local M = {}
M.__index = M

M.new = function(opts)
    local self = setmetatable({}, M)
    self.opts = opts

    return self
end

function M:source_enabled() return vim.bo.filetype == "helpout" end


local help_files = vim.api.nvim_get_runtime_file('doc/tags', true)

local items = {}

for _, filename in ipairs(help_files) do
    local file = io.open(filename)
    for line in file:lines() do
        local tag = line and line:match("^([^\t]+)")
        table.insert(items, {
            label = tag,
            -- filterText = tag,
            -- sortText = tag:lower():gsub("^([!-@\\[-`])", "~%1"),
            insertText = tag,
            insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
            kind = require("blink.cmp.types").CompletionItemKind.Reference,

        })
    end
end

function M:get_completions(ctx, callback)
    -- ctx (context) contains the current keyword, cursor position, bufnr, etc.

    -- local items = {}
    --
    -- for _, filename in ipairs(help_files) do
    --     local file = io.open(filename)
    --     for line in file:lines() do
    --         local tag = line and line:match("^([^\t]+)")
    --         table.insert(items, {
    --             label = tag,
    --             -- filterText = tag,
    --             -- sortText = tag:lower():gsub("^([!-@\\[-`])", "~%1"),
    --             insertText = tag,
    --             insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    --             kind = require("blink.cmp.types").CompletionItemKind.Reference,
    --
    --         })
    --     end
    -- end

    -- items = vim.tbl_filter(function(item) return vim.startswith(item.label, ctx.line) end, items)

    -- local itemz = {}
    --
    -- for _, item in ipairs(vim.fn.getcompletion(ctx.line, "help")) do
    --     table.insert(itemz, {
    --         label = item,
    --         insertText = item,
    --         insertTextFormat = vim.lsp.protocol.InsertTextFormat.PlainText,
    --         kind = require("blink.cmp.types").CompletionItemKind.Reference,
    --     })
    -- end

    callback({
        items = items,
        is_incomplete_forward = false,
        is_incomplete_backward = false,
    })

    return function() end
end

return M
