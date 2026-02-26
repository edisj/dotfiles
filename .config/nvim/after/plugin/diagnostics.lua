vim.diagnostic.config({
    severity_sort = true,
    virtual_text = {
        severity = { min = vim.diagnostic.severity.ERROR },
    },
    -- virtual_lines = {
    --     severity = { min = vim.diagnostic.severity.ERROR },
    -- },
    signs = {
        text = {
            [vim.diagnostic.severity.ERROR] = "●",
            [vim.diagnostic.severity.WARN] = "●",
            [vim.diagnostic.severity.HINT] = "●",
            [vim.diagnostic.severity.INFO] = "●",
        },
    },
    update_in_insert = false,
})

for level, icon in pairs{
    Error = "●",
    Warn = "●",
    Hint = "●",
    Info = "●"
} do
    local hl = "DiagnosticSign" .. level
    vim.fn.sign_define(hl, { text = icon, texthl = hl, numhl = hl })
end

vim.keymap.set("n", "<leader>vd", function()
    if vim.diagnostic.is_enabled() then
        return vim.diagnostic.enable(false)
    end
    return vim.diagnostic.enable(true)
end, { desc = "vim diagnostic toggle" })
