vim.api.nvim_create_user_command("Banner", function(opts)
  local cs = vim.bo.commentstring:match("^(.*)%%s") or "//"
  cs = vim.trim(cs)
  local width = 79

  for lnum = opts.line1, opts.line2 do
    local line = vim.fn.getline(lnum)
    local indent, text = line:match("^(%s*)(.-)%s*$")

    local existing = text:match("%[(.-)%]")
    if existing then
      text = existing
    else
      local cs_escaped = vim.pesc(cs)
      text = text:gsub("^" .. cs_escaped .. "%s*%s-*%s*", "")
      text = text:gsub("%s*%s-+%s*$", "")
    end

    local sep = (cs == "--") and "" or " --"
    local prefix = indent .. cs .. sep .. " [" .. text .. "] "
    local banner = prefix .. string.rep("-", math.max(0, width - #prefix))
    vim.fn.setline(lnum, banner)
  end
end, { range = true, nargs = 0 })

map("<C-g>", "<Cmd>Banner<CR>", { mode = { "n", "x" } })
map("<C-g>", "<Esc><Cmd>Banner<CR>i", { mode = { "i" } })
