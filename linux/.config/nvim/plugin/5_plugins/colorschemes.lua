Pack.add({
  "https://github.com/folke/tokyonight.nvim",
  "https://github.com/serhez/teide.nvim",
  "https://github.com/rebelot/kanagawa.nvim",
  "https://github.com/ellisonleao/gruvbox.nvim",
  "https://github.com/catppuccin/nvim",
  "https://github.com/AlexvZyl/nordic.nvim",
  "https://github.com/oonamo/ef-themes.nvim",
  "https://github.com/shatur/neovim-ayu",
  "https://github.com/arnauKL/south.nvim",
  "https://github.com/gmr458/cold.nvim",
  "https://github.com/mcauley-penney/techbase.nvim",
  {
    src = "https://github.com/edeneast/nightfox.nvim",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        require("nightfox").setup({
          options = {
            styles = { keywords = "bold", comments = "italic", },
            inverse = { match_paren = true, },
          },
          groups = {
            all = {
              FloatBorder = { fg = "fg3", bg = "bg0" },
              Normal = { fg = "fg2" },
              MiniPickMatchCurrent  = { bg = "sel1" },
              ["@keyword.function"] = { style = "bold" },
              ["@property"] = { link = "Normal" },
              CursorLine = { fg = nil, bg = "bg2" },
            },
            dayfox = {
              MsgArea = { fg = nil, bg = "sel0" },
              PmenuKind = { fg = nil, bg = "sel1" },
              BlinkCmpMenuSelection = { fg = nil, bg = "sel1" },
              BlinkCmpSelection = { fg = nil, bg = "sel1" },
              BlinkCmpDocCursorLine = { fg = nil, bg = "sel1" },
              BlinkCmpKindProperty = { fg = nil, bg = "sel1" },
              BlinkCmpLabelMatch = { style = "bold" },
              CursorLine = { fg = nil, bg = "bg0" },
              StatusLine = { fg = "white", bg = "palette.blue.dim", style = "" },
            }
          },
        })
      end,
    },
 },
})
