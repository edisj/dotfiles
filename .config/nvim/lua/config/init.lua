require "config.options"
require "config.lazy"
require "config.autocmds"
require "config.keymaps"
require "config.usercmds"

require "arglist"
require "ui.winbar"
require "ui.statusline"
require "ui.wildermenu"
require("floaterminal").setup()
require("helpout").setup()
require("inspector").setup()
require("session").setup()

require("edis")
require("quickfix")
