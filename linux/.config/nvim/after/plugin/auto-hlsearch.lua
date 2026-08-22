-- copied/modified from https://github.com/CKolkey/config/blob/master/nvim/after/plugin/toggle_hlsearch.lua
if vim.g.loaded_toggle_hlsearch then return end
vim.g.loaded_toggle_hlsearch = true

local fn = vim.fn
local o = vim.o
local function toggle_hlsearch(char, typed)
  if
    fn.mode() ~= "n"
    or not typed
    or typed == ""
    or (MiniPick and MiniPick.is_picker_active())
  then
    return
  end
  local keys = { "n", "N", "*", "#", "?", "/" }
  local new_hlsearch = vim.tbl_contains(keys, vim.fn.keytrans(char))
  if (o.hlsearch ~= new_hlsearch) then o.hlsearch = new_hlsearch end
end

vim.on_key(toggle_hlsearch, vim.api.nvim_create_namespace("toggle_hlsearch"))
