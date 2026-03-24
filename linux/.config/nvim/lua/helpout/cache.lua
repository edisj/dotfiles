local M = {}
M.loclists = {}
M.helptags = {}

M.get = function(key)
    return
        M.loclists[key] ~= nil and M.loclists[key]
        or M.helptags[key] ~= nil and M.helptags[key]
        or vim.notify(string.format("cache entry: `%s` not found", key), vim.log.levels.ERROR, { title = "helpout.cache" })
end

return M
