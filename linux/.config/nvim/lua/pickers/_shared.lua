local api, fn, ts = vim.api, vim.fn, vim.treesitter
local pick = require("mini.pick")
local ns = api.nvim_create_namespace("")
local M = {}

M.show_grouped = function(bufnr, items, query, showopts)
  -- if items == nil or #items == 0 then return end
  local lines, extmarks_by_line = M.get_lines_and_extmarks(items, showopts)
  pick.default_show(bufnr, lines, query, showopts)

  api.nvim_buf_clear_namespace(bufnr, ns, 0, -1)
  for i, extmarks in ipairs(extmarks_by_line) do
    for _, extmark in ipairs(extmarks) do
      if type(extmark) == "function" then extmark = extmark() end
      local scol = extmark.start_col
      extmark.start_col = nil
      extmark.priority = 199
      api.nvim_buf_set_extmark(bufnr, ns, i-1, scol, extmark)
    end
  end

  local winid = pick.get_picker_state().windows.main
  api.nvim_win_call(winid, function() vim.cmd('normal! \25') end)  -- <C-y>
end

M.get_lines_and_extmarks = function(items, showopts)
  local state = pick.get_picker_state()
  if not (state and items and #items > 0) then return {}, {} end

  local winid = state.windows.main
  local group = {}
  local lines, extmarks_by_line = {}, {}
  for i, item in ipairs(items) do
    local data = showopts.parse_item(item)
    local bufnr_or_fname = data.bufnr or data.fname
    -- local fname_or_bufnr, lnum, text = item_to_line(item)

    table.insert(lines, data.text)
    extmarks_by_line[i] = {}

    local key = data[showopts.group_by]
    if not group[key] then
      group[key] = {}
      group[key].prefix_width = 0
      if showopts.show_header then
        table.insert(extmarks_by_line[i], {
          start_col = 0,
          virt_lines = { {{""}}, M.construct_header(key, winid) },
          virt_lines_above = true,
        })
      end
    end

    local ts_extmarks = M.extract_ts_highlights(bufnr_or_fname, data.lnum, showopts.extmark_cache)
    if ts_extmarks then
      vim.list_extend(extmarks_by_line[i], ts_extmarks)
    end

    local curr_group = group[key]
    local prefix_width = #tostring(data.prefix)
    if prefix_width > curr_group.prefix_width then curr_group.prefix_width = prefix_width end

    table.insert(extmarks_by_line[i], function()
      local w = group[key].prefix_width
      local prefix_text = ("%" .. w .. "s"):format(data.prefix)
      return {
        start_col = 0,
        virt_text_pos = "inline",
        virt_text = { { prefix_text, "LineNr" } }
      }
    end)
  end
  return lines, extmarks_by_line
end

M.construct_header = function(key, winid)
  local header = ""
  if type(key) == "number" and api.nvim_buf_is_valid(key) then
    header = api.nvim_buf_get_name(key)
    header = " " .. fn.fnamemodify(header, ":~:.") .. " "
  elseif type(key) == "string" then
    if vim.uv.fs_stat(key) then
      header = " " .. fn.fnamemodify(key, ":~:.") .. " "
    else
      header = key
    end
  else
    header = " " ..  tostring(key) .. " "
  end
  -- local name = bufnr_or_fname
  -- if type(name) == "number" then name = api.nvim_buf_get_name(name) end
  local left_bar = "──"
  -- local icon, icon_hl = require("icons").get("file", name)
  -- icon = " " .. vim.trim(icon)
  -- name = " " .. fn.fnamemodify(name, ":~:.") .. " "
  local header_so_far = left_bar ..  header
  local width = api.nvim_win_get_width(winid)
  local right_bar = ("─"):rep(width - fn.strchars(header_so_far))
  -- return { { left_bar, "LineNr" }, { icon, icon_hl }, { name }, { right_bar, "LineNr" } }
  return { { left_bar, "LineNr" }, { header }, { right_bar, "LineNr" } }
end

M.extract_ts_highlights = function(bufnr_or_fname, lnum, cache)
  if cache[bufnr_or_fname] == false then return end

  if cache[bufnr_or_fname] == nil then
    local src, get_parser
    if type(bufnr_or_fname) == "number" then
      src = bufnr_or_fname
      get_parser = ts.get_parser
    else
      src = io.open(bufnr_or_fname):read("*a"):gsub("\t", (" "):rep(vim.o.tabstop))
      get_parser = ts.get_string_parser
    end

    local ft = type(bufnr_or_fname) == "number" and vim.bo[bufnr_or_fname].filetype or vim.filetype.match({ filename = bufnr_or_fname })
    local lang = ft and vim.treesitter.language.get_lang(ft)
    local ok, parser = pcall(get_parser, src, lang)
    if not (lang and ok and parser) then
      cache[bufnr_or_fname] = false
      return
    end

    parser:parse(true)
    cache[bufnr_or_fname] = { parser = parser, src = src }
    if type(bufnr_or_fname) == "string" then
      cache[bufnr_or_fname].lines = vim.split(src, "\n")
    else
      cache[bufnr_or_fname].lines = api.nvim_buf_get_lines(bufnr_or_fname, 0, -1, true)
    end
  end

  local parser = cache[bufnr_or_fname].parser
  local src = cache[bufnr_or_fname].src
  local lines = cache[bufnr_or_fname].lines
  local extmarks = {}
  parser:for_each_tree(function(tree, ltree)
    local lang = ltree:lang()
    local query = vim.treesitter.query.get(lang, "highlights")
    if not query then return end
    local row = lnum - 1
    for id, node, _ in query:iter_captures(tree:root(), src, row, row+1) do
      local capture = query.captures[id]
      local hl_group = "@" .. capture

      local sr, sc, er, ec = node:range()
      local start_col = row == sr and sc or 0
      local end_col = row == er and ec or #lines[row + 1]

      local extmark_opts = { hl_group = hl_group, start_col = start_col, end_col = end_col }
      table.insert(extmarks, extmark_opts)
    end
  end)

  return extmarks
end

return M
