local M = {}

function M.map(lhs, rhs, opts)
  opts = vim.tbl_extend("force", { silent = true, remap = false }, opts or {})
  local mode = opts.mode or { "n" }
  opts.mode = nil
  vim.keymap.set(mode, lhs, rhs, opts)
end

---See require("vim._core.util").nvim_on
---@param events vim.api.keyset.events|vim.api.keyset.events[] Event(s) to watch. See |autocmd-events|.
---@param group string|integer? Group name or id, or `nil`.
---@param opts_or_fn vim.api.keyset.create_autocmd Options.
---@param fn string|fun(ev: vim.api.keyset.create_autocmd.callback_args): boolean? Event handler.
---@return integer # Autocmd id (see |nvim_create_autocmd()|).
---@overload fun(events: vim.api.keyset.events|vim.api.keyset.events[], group: string|integer?, fn: fun(ev: vim.api.keyset.create_autocmd.callback_args): boolean?): integer
function M.on(events, group, opts_or_fn, fn)
  local opts ---@type vim.api.keyset.create_autocmd
  if type(opts_or_fn) == "table"  then
    opts = opts_or_fn
  else
    fn, opts = opts_or_fn, {}
  end
  if type(group) == "string" then
    opts.group = vim.api.nvim_create_augroup(group --[[@as string]], { clear = false })
  else
    opts.group = group
  end
  opts[type(fn) == "function" and "callback" or "command"] = fn
  return vim.api.nvim_create_autocmd(events, opts)
end

return M
