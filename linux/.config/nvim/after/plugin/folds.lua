vim.o.foldcolumn = "1"

local ns = vim.api.nvim_create_namespace("folded_text")

vim.api.nvim_set_decoration_provider(ns, {
  on_line = function(_, _, buf, row)
    if vim.bo[buf].buftype ~= "" then return end
    if vim.fn.foldclosed(row + 1) ~= row + 1 then return end
    local line = vim.api.nvim_buf_get_lines(buf, row, row + 1, true)[1]
    vim.api.nvim_buf_set_extmark(buf, ns, row, 0, {
      end_col = #line,
      hl_group = "FoldedText",
      ephemeral = true,
      priority = 1,
    })
    vim.api.nvim_buf_set_extmark(buf, ns, row, #line, {
      virt_text = { { " … ", "FoldedText" } },
      virt_text_pos = "overlay",
      ephemeral = true,
      priority = 1,
    })
  end,
})
