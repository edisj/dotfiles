
---@class NodeData
---@field bufnr integer
---@field id string
---@field text string
---@field type string
---@field start_row integer
---@field start_col integer
---@field end_row integer
---@field end_col integer
---@field children? TSNode[]
---@field depth? integer
---@field child_count? integer

---@class TreeData
---@field data NodeData
---@field children TreeData[]

---@class LoclistItem
---@field bufnr integer
---@field idx integer
---@field lnum integer
---@field end_lnum integer
---@field col integer
---@field end_col integer
---@field text string
---@field type string
---@field depth integer
---@field show boolean
---@field expanded boolean | nil

---@class Loclist
---@field last_cursor_position? integer
---@field [integer] LoclistItem
