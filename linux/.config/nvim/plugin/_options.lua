local o, opt = vim.o, vim.opt

o.autoindent     = true
o.autoread       = true
o.clipboard      = "unnamedplus"
o.cmdheight      = 1
o.cmdwinheight   = 8
o.completeopt    = "menuone,noselect,fuzzy"
o.confirm        = true
o.cursorline     = false
o.cursorlineopt  = "both"
o.equalalways    = true
o.expandtab      = true
opt.fillchars = {
  eob = "~",
  -- msgsep = "█",
  -- msgsep = "🮅",
  -- fold = "╌",
  fold = " ",
  foldopen = "▾",
  foldclose = "▸",
  foldsep = " ",
  horiz     = '━',
  -- horiz = "▁",
  -- horiz = "▬",
  -- horiz     = '▔',
  horizup   = '┻',
  horizdown = '┳',
  -- vert      = '┃',
  vert = "▕",
  -- vert = "▎",
  vertleft  = '┫',
  vertright = '┣',
  verthoriz = '╋',
  -- stl = "▬",
  -- stlnc = "▬",
  msgsep = "▔",
  -- stl = "━",
  -- stlnc = "━",
  -- stl = "▔",
  -- stlnc = "▔",
  -- stl = "▁",
  -- stlnc = "▁",
}
o.foldlevel      = 99
o.foldlevelstart = 99
o.foldtext       = ""
o.guicursor = table.concat({
  "n-v-sm:block-Cursor",
  "i-c-ci-ve:ver20-Cursor",
  "r-cr-o:hor25-Cursor",
  "t:ver50-blinkon500-blinkoff500-TermCursor"
}, ",")
o.hlsearch       = false
o.ignorecase     = true
o.inccommand     = "split"
o.incsearch      = true
o.jumpoptions    = "clean,view"
o.laststatus     = 2
-- o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '
-- o.list           = true
-- opt.listchars      = { space = "⋅", nbsp = "⋅", trail = "⋅", tab = "  " }
o.matchtime      = 1
o.mouse          = "a"
o.mousemoveevent = true
o.mousescroll    = "ver:1"
o.number         = false
o.numberwidth    = 3
o.pumblend       = 10
o.pumborder      = "none"
o.pumheight      = 15
o.relativenumber = false
o.ruler          = false
o.scrolloff      = 2
opt.sessionoptions = {
  "blank",
  -- "buffers",
  "curdir",
  "folds",
  "globals",
  "help",
  -- "tabpages",
  "winsize",
  "terminal"
}
o.shiftwidth     = 2
opt.shortmess:append("cCSu")
o.showcmd        = false
o.showmatch      = true
o.showmode       = false
o.signcolumn     = "no"
o.sidescrolloff  = 2
o.smartindent    = true
o.softtabstop    = 2
o.splitbelow     = true
o.splitkeep      = "topline"
o.splitright     = true
o.smartcase      = true
o.smoothscroll   = true
o.swapfile       = false
o.tabstop        = 2
o.termguicolors  = true
-- vim.schedule(function()
--   local name = (require("mux").get_state() or {}).name
--   name = name and " " .. name or " nvim"
--   o.title          = true
--   o.titlestring    = name
-- end)
o.undofile       = true
o.updatetime     = 0
opt.virtualedit:append("block")
o.wildmode       = "noselect,full"
o.wildoptions    = "pum,fuzzy"
opt.winborder    = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
o.wrap           = false
