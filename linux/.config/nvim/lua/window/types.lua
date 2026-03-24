---@alias Window window.Base | window.Float | window.Split

---@alias WinCoordinate { row: integer, col: integer }

---@alias WinDimensions { width: integer, height: integer }

---@alias WinPosition
---| "topleft"
---| "top"
---| "topright"
---| "left"
---| "center"
---| "right"
---| "botleft"
---| "bot"
---| "botright"
---| "fixed"

---@class EventOpts: vim.api.keyset.create_autocmd
---@field buf? boolean
---@field win? boolean

---@class KeymapSignature
---@field [1] string|string[] mode
---@field [2] string lhs
---@field [3] string|function rhs
---@field [4]? vim.keymap.set.Opts keymap options

---@class WinOpts: vim.api.keyset.win_config
---@field auto_position? WinPosition
---@field auto_resize? boolean
---@field enter? boolean
---@field parent? Window
---@field file? string
---@field bufnr? integer | fun(win: Window):integer
---@field stickybuf? boolean | string|string[]
---@field height? number | fun(win: Window):number
---@field width? number | fun(win: Window):number
---@field xoffset? number | fun(win: Window):number
---@field yoffset? number | fun(win: Window):number
---@field title? string | [string, string][] | fun(win: Window):string | [string, string][]
---@field footer? string | [string, string][] | fun(win: Window):string | [string, string][]
---@field keymaps? KeymapSignature[]
---@field bo? table<string, any> | {}
---@field wo? table<string, any> | {}

---@alias BorderText
---| string
---| [string, string][]
---| fun(self: window.Float): string
---| fun(self: window.Float): [string, string][]

