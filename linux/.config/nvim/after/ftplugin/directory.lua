local dir_cache = {}
vim.b.stl = {
  {
    chunks = {
      function()
        local dir = vim.api.nvim_buf_get_name(0):gsub("/$", "")
        if dir_cache[dir] then return dir_cache[dir] end
        local dirlist = require("dirlist")
        -- local path = fn.pathshorten(fn.fnamemodify(dir, ":~"))
        -- path = path == "/" and path or path .. "/"
        local head, tail = vim.fn.fnamemodify(vim.fs.dirname(dir), ":~"), vim.fs.basename(dir)
        local item = dirlist.path_to_item(dir)
        -- local permissions = with_hl(dirlist.default_format_permissions(item), "Number")
        -- local modified = with_hl(dirlist.default_format_modified(item), "LineNr")
        local out = {
          { string.format("%4s ", dirlist.default_format_size(item)), "String" },
          { " ", "Folder" },
          { head .. (head == "/" and "" or "/"), "Comment" },
          { tail .. (tail == "" and "" or "/"), "Directory" }
        }
        dir_cache[dir] = out
        return out
      end
    },
    padding = 1,
  }
}
