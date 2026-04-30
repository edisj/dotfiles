local o, opt = vim.o, vim.opt

o.autoindent     = true
o.autoread       = true
o.clipboard      = "unnamedplus"
-- o.colorcolumn    = "90"
o.cmdheight      = 1
o.cmdwinheight   = 8
o.completeopt    = "menuone,noselect,fuzzy"
o.confirm        = true
o.cursorline     = true
o.equalalways    = false
o.expandtab      = true
opt.fillchars = {
  eob = "~",
  msgsep = "▔",
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
o.guicursor      = "n-v-sm:block,i-c-ci-ve:ver20,r-cr-o:hor50,t:ver50-blinkon500-blinkoff500-TermCursor"
o.hlsearch       = true
o.ignorecase     = true
o.inccommand     = "split"
o.incsearch      = true
o.laststatus     = 3
-- o.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '
-- o.list           = true
-- opt.listchars      = { space = "⋅", nbsp = "⋅", trail = "⋅", tab = "  " }
o.matchtime      = 1
o.mouse          = "a"
o.mousescroll    = "ver:3"
o.number         = true
o.numberwidth    = 3
o.pumborder      = "single"
o.pumheight      = 10
o.relativenumber = false
o.scrolloff      = 5
opt.sessionoptions = {
  -- "blank",
  -- "buffers",
  "curdir",
  "folds",
  "globals",
  "help",
  "tabpages",
  "winsize",
  "terminal"
}
o.shiftwidth     = 4
o.showcmd        = false
o.showmatch      = true
o.showmode       = false
o.signcolumn     = "no"
o.sidescrolloff  = 8
o.smartindent    = true
o.softtabstop    = 4
o.splitbelow     = true
o.splitright     = true
o.smartcase      = true
o.swapfile       = false
o.tabstop        = 4
o.termguicolors  = true
o.title          = true
o.titlestring    = " neovim"
o.undofile       = true
o.virtualedit    = "block"
o.wildmode       = "noselect,full"
o.wildoptions    = "pum,fuzzy"
opt.winborder    = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" }
o.wrap           = false

if vim.g.neovide then
  o.linespace = 0
  o.title = true
  -- o.titlestring = "eovide"
  o.titlestring = " neovide"

  vim.o.guifont = "JetBrainsMono NF:h15"
  vim.g.neovide_scale_factor = 1
  vim.g.neovide_text_gamma = 0.8
  vim.g.neovide_text_contrast = 0.5
  vim.g.neovide_opacity = 0.97
  vim.g.neovide_underline_stroke_scale = 1.5

  vim.g.neovide_padding_top = 10
  vim.g.neovide_padding_bottom = 0
  vim.g.neovide_padding_right = 5
  vim.g.neovide_padding_left = 5

  vim.g.neovide_scroll_animation_length = 0.15
  vim.g.neovide_scroll_animation_far_lines = 0

  vim.g.neovide_progress_bar_enabled = true
  vim.g.neovide_progress_bar_height = 8.0
  vim.g.neovide_progress_bar_animation_speed = 150.0
  vim.g.neovide_progress_bar_hide_delay = 0.5

  vim.g.neovide_floating_shadow = false
  vim.g.neovide_show_border = false

  vim.g.neovide_refresh_rate = 120
  vim.g.neovide_confirm_quit = true

  vim.g.neovide_position_animation_length = 0.20

  vim.g.neovide_cursor_animation_length = 0.15
  vim.g.neovide_cursor_short_animation_length = 0.03
  vim.g.neovide_cursor_trail_size = 0.5
  vim.g.neovide_cursor_antialiasing = true
  vim.g.neovide_cursor_smooth_blink = false
end
