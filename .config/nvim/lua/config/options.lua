local opt = vim.opt

opt.autoindent     = true
opt.autoread       = true
opt.clipboard      = "unnamedplus"
-- opt.colorcolumn    = "90"
opt.cmdheight      = 0
opt.cmdwinheight   = 10
opt.completeopt    = "menuone,noselect,fuzzy"
opt.confirm        = true
opt.cursorline     = true
opt.equalalways    = false
opt.expandtab      = true
opt.fillchars = {
    eob = "~",
    fold = "╌",
    vert = "┃",
    horiz = "━",
    horizup = "┻",
    horizdown = "┳",
    vertleft = "┫",
    vertright = "┣",
    verthoriz = "╋",
}
opt.foldlevel      = 99
opt.foldlevelstart = 99
opt.guicursor      = "n-v-sm:block,i-c-ci-ve:ver20,r-cr-o:hor50,t:ver50-blinkon500-blinkoff500-TermCursor"
opt.hlsearch       = true
opt.ignorecase     = true
opt.inccommand     = "split"
opt.incsearch      = true
opt.iskeyword      = "@,48-57,_,192-255,-" -- Treat dash as `word` textobject part
-- opt.iskeyword      = "48-57,_,192-255,-" -- Treat dash as `word` textobject part
opt.laststatus     = 3
-- opt.listchars = 'extends:…,nbsp:␣,precedes:…,tab:> '
-- opt.list           = true
-- opt.listchars      = { space = "⋅", nbsp = "⋅", trail = "⋅", tab = "  " }
opt.matchtime      = 1
opt.mouse          = "a"
opt.mousescroll    = "ver:2"
opt.number         = true
opt.numberwidth    = 3
opt.pumheight      = 10
opt.relativenumber = false
opt.scrolloff      = 10
opt.shiftwidth     = 4
opt.showmatch      = true
opt.showmode       = false
opt.signcolumn     = "yes"
opt.sidescrolloff  = 8
opt.smartindent    = true
opt.softtabstop    = 4
opt.splitbelow     = true
opt.splitright     = true
opt.smartcase      = true
opt.swapfile       = false
opt.tabstop        = 4
opt.termguicolors  = true
opt.undofile       = true
opt.virtualedit    = "block"
opt.wildmode       = "noselect,full"
opt.wildoptions    = "pum,fuzzy"
opt.winborder      = "bold"
opt.wrap           = false

-- vim.highlight.priorities.semantic_tokens = 95

-- vim.diagnostic.config({
--     underline = {
--         severity = vim.diagnostic.severity.ERROR,
--     },
--     -- severity_sort = true,
--     virtual_text = true,
--     signs = true,
--     update_in_insert = false,
-- })
