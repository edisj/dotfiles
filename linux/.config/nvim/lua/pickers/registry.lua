return function()
  local items = vim.tbl_keys(MiniPick.registry)
  table.sort(items)
  local source = {items = items, name = 'Registry', choose = function() end}
  local chosen_picker_name = MiniPick.start({ source = source })
  if chosen_picker_name == nil then return end
  return MiniPick.registry[chosen_picker_name]()
end
