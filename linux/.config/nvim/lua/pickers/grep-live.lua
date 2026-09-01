local pick = require("mini.pick")
local show_grouped = require("pickers._shared").show_grouped

return function(local_opts, opts)
  local default_local_opts = { show_header = true, group_by = "fname" }
  local_opts = vim.tbl_deep_extend("force", default_local_opts, local_opts or {})

  local showopts = {
    show_header = local_opts.show_header,
    group_by = local_opts.group_by,
    extmark_cache = {},
    parse_item = local_opts.parse_item or function(item)
      local fname, lnum, _, text = unpack(vim.split(item, "\0"))
      local prefix = tostring(lnum) .. ":"
      return { fname = fname, lnum = lnum, text = text, prefix = prefix }
    end,
  }
  local show = function(bufnr, items, query)
    show_grouped(bufnr, items, query, showopts)
  end

  opts = vim.tbl_deep_extend("keep", { source = { show = show } }, opts or {})
  local cwd_text = opts.source.cwd and opts.source.cwd .. " " or "./ "
  opts = vim.tbl_deep_extend("keep", opts, {
    window = {
      prompt_prefix = " rg ",
      prompt_caret = "🯏" .. tostring(cwd_text)
    }
  })
  pick.builtin.grep_live(local_opts, opts)
end
