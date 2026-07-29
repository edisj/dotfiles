local o, opt = vim.o, vim.opt

o.autoindent     = true
o.autoread       = true
o.clipboard      = "unnamedplus"
o.cmdheight      = 0
o.cmdwinheight   = 8
o.completeopt    = "menuone,noselect,fuzzy"
o.confirm        = true
o.cursorline     = false
o.cursorlineopt  = "both"
o.equalalways    = false
o.expandtab      = true
opt.fillchars = {
  eob = "~",
  -- msgsep = "▔",
  msgsep = " ",
  fold = "╌",
  horiz     = '━',
  horizup   = '┻',
  horizdown = '┳',
  vert      = '┃',
  vertleft  = '┫',
  vertright = '┣',
  verthoriz = '╋',
}
o.foldlevel      = 99
o.foldlevelstart = 99
o.guicursor = table.concat({
  "n-v-sm:block",
  "i-c-ci-ve:ver15",
  "r-cr-o:hor25",
  "t:ver50-blinkon500-blinkoff500-TermCursor"
}, ",")
o.hlsearch       = true
o.ignorecase     = true
o.inccommand     = "split"
o.incsearch      = true
o.laststatus     = 2
-- o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '
-- o.list           = true
-- opt.listchars      = { space = "⋅", nbsp = "⋅", trail = "⋅", tab = "  " }
o.matchtime      = 1
o.mouse          = "a"
o.mousescroll    = "ver:5"
o.number         = false
o.numberwidth    = 3
o.pumblend       = 15
o.pumborder      = "none"
o.pumheight      = 12
o.relativenumber = false
o.scrolloff      = 2
opt.sessionoptions = {
  -- "blank",
  -- "buffers",
  "curdir",
  "folds",
  "globals",
  -- "help",
  "tabpages",
  -- "winsize",
  "terminal"
}
o.shiftwidth     = 2
o.showcmd        = false
o.showmatch      = true
o.showmode       = false
o.signcolumn     = "no"
o.sidescrolloff  = 8
o.smartindent    = true
o.softtabstop    = 2
o.splitbelow     = true
o.splitkeep      = "topline"
o.splitright     = true
o.smartcase      = true
o.swapfile       = false
o.tabstop        = 2
o.termguicolors  = true
-- o.title          = true
-- o.titlestring    = " neovim"
o.undofile       = true
o.virtualedit    = "block"
o.wildmode       = "noselect,full"
o.wildoptions    = "pum,fuzzy"
opt.winborder    = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
o.wrap           = false
