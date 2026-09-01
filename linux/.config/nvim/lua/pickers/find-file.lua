local fn, fs, api = vim.fn, vim.fs, vim.api
local pick = require("mini.pick")
local dl = require("dirlist")
local ns = vim.api.nvim_create_namespace("")

-- path helpers --------------------------------------------------------------
local query_to_path = function(query)
  local path = table.concat(query)
  if vim.trim(path) == "" then return false end
  return fs.abspath(path)
end
local query_to_dirname = function(query)
  local path = table.concat(query)
  if vim.trim(path) == "" then return false end
  local dirname = path == "~" and fs.dirname(fn.expand(path)) or fs.dirname(path)
  return dl.normalize(dirname)
end
local query_tail = function(query)
  local path = query_to_path(query)
  local tail = path and fs.basename(path) or ""
  return vim.split(tail, "")
end


-- picker implementation -----------------------------------------------------
local CACHE_STUB = { items = {}, text_col_width = 0 }

local get_items = function(dirname, sort)
  local items = dl.get_dirlist_items(dirname)
  local text_col_width = vim.iter(items)
      :fold({}, function(acc, item)
        acc.max = math.max(#item.text, acc.max or #item.text)
        return acc
      end).max or 0
  if sort then table.sort(items, sort) end
  return { items = items, text_col_width = text_col_width }
end

local find_file = function(local_opts, opts)
  local default_local_opts = { dir = fn.getcwd(), sort = dl.default_sort, selected = nil }
  local_opts = vim.tbl_extend("force", default_local_opts, local_opts or {})
  local initial_dir = dl.normalize(local_opts.dir)
  vim.schedule(function()
    pick.set_picker_query(vim.split(fn.fnamemodify(initial_dir, ":~").. "/", ""))
  end)

  -- `items_cache` is a table keyed by normalized directory paths
  -- NOTE: using `[false]` as a special key to stub empty lookups,
  -- which happens when query is empty
  local items_cache = { [false] = CACHE_STUB }
  items_cache[initial_dir] = get_items(initial_dir, local_opts.sort)
  local items = items_cache[initial_dir].items

  -- stack helpers -----------------------------------------------------------
  -- This is just a tiny "stack" implementation to help with implementing the
  -- "presssing ~ or / resets query to list home or root directory" feature.
  -- The idea is pressing a "~" or "/" trigger with the right conditions will
  -- push the current query to a "history" stack and reset the query, and then
  -- reaching an empty query (by typing backspace or however) will restore
  -- a saved query from the top of the stack if it exists.
  local query_history_stack = {}
  local stack_pop = function()
    return table.remove(query_history_stack)
  end
  local stack_push = function(query)
    local top = query_history_stack[#query_history_stack]
    if top and table.concat(top) == table.concat(query) then return end
    table.insert(query_history_stack, query)
    return query
  end
  local push_to_stack_and_reset_query = function(query)
    local trigger_char = query[#query]
    query[#query] = nil -- don't want to save the trigger char to saved query in history
    stack_push(query)
    pick.set_picker_query({ trigger_char })
  end
  ----------------------------------------------------------------------------

  local last_dir = initial_dir
  local match = function(stritems, inds, query)

    -- restore query on top of stack if we hit empty query
    if #query == 0 then
      local last_query = stack_pop()
      if last_query then
        pick.set_picker_query(last_query)
        return
      end
    end

    -- pressing "~" anywhere during a query should immediatlely bring you home
    -- NOTE: excluding cases with repetition like `query == { "~", "~", "~" }`
    if #query > 1 and query[#query] == "~" and query[#query - 1] ~= "~" then
      push_to_stack_and_reset_query(query)
      return
    end

    -- pressing "/" only when last query char is "/" should bring you to root
    -- meaning the last to chars of the query should be "//"
    if #query > 1 and query[#query] == "/" and query[#query - 1] == "/" then
      if table.concat(query) ~= "//" then
        push_to_stack_and_reset_query(query)
      else
        -- NOTE: I'm excluding the case where you type "/" when `query == { "/" }`
        -- i.e. repeating consecutive "/" chars does not add an empty "/" to the query
        -- stack. This differs from Emacs behavior, but I think it's a lot better.
        pick.set_picker_query({ "/" })
      end
      return
    end

    local current_dir = query_to_dirname(query)
    if current_dir ~= last_dir then
      last_dir = current_dir
      -- if `current_dir == false`, we hit our items_cache[false] stub,
      -- which is {} (truthy), so items will become {}, otherwise compute and cache new items
      if not items_cache[current_dir] then items_cache[current_dir] = get_items(current_dir, local_opts.sort) end
      pick.set_picker_items(items_cache[current_dir].items, { do_match = true })
      return
    end

    if local_opts.selected then
      local selected = local_opts.selected
      local_opts.selected = nil
      local matches = pick.default_match(stritems, inds, query_tail(query), { preserve_order = false, sync = true })
      if matches then
        pick.set_picker_match_inds(matches, "all")
        if not vim.tbl_isempty(matches) then
          pick.set_picker_match_inds({ selected }, "current")
        end
      end
      return
    end

    return pick.default_match(stritems, inds, query_tail(query), { preserve_order = false })
  end

  local show = function(buf_id, items_to_show, query)
    local text_col_width = items_cache[query_to_dirname(query)].text_col_width
    pick.default_show(buf_id, items_to_show, query_tail(query), { show_icons = false })
    dl.default_decorate(buf_id, items_to_show, { text_col_width = text_col_width })

    api.nvim_buf_clear_namespace(buf_id, ns, 0, -1)
    local selected, matches = nil, pick.get_picker_matches()
    if matches and matches.current_ind then
      for i, shown_ind in ipairs(matches.shown_inds) do
        if shown_ind == matches.current_ind then
          selected = i
          break
        end
      end
    end
    if selected then
      api.nvim_buf_set_extmark(buf_id, ns, selected-1, 0, { line_hl_group = "MiniPickMatchCurrent"})
    end
  end

  local custom_choose = function()
    local current = pick.get_picker_matches().current
    if current then
      pick.default_choose(current)
      return true
    end
    local query = pick.get_picker_query()
    local path = query_to_path(query)
    -- NOTE: needs to be scheduled so picker returns to target window and THEN calls :edit
    vim.schedule(function() vim.cmd("edit " .. path) end)
    return true
  end

  local custom_tab_complete = function()
    local current = pick.get_picker_matches().current
    if not current then return end

    local path = fn.fnamemodify(current.path, ":p:~")
    local query = vim.split(path, "")
    pick.set_picker_query(query)
  end

  -- default opts
  opts = vim.tbl_deep_extend("keep", opts or {}, {
    delay = { busy = 250 }, -- prevent some flickering on first match for large dirs
    window = { prompt_prefix = " Explore: " },
    source = { name = "Explorer Live" },
    mappings = {
      choose = "", -- to suppress overwrite <CR> warning
      custom_choose = { char = "<CR>", func = custom_choose },
      custom_tab_complete = { char = "<Tab>", func = custom_tab_complete },
    },
  })
  -- mandatory opts
  opts = vim.tbl_deep_extend("force", opts, {
    options = { use_cache = false },
    source = { items = items, match = match, show = show },
  })

  return pick.start(opts)
end

return find_file
