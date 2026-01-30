local Float = require("window.float")
local Split = require("window.split")

local function hello(str)
    str = str or "world"
    print("hello, " .. str)
end

hello()

hello("world")

hello("mom")

