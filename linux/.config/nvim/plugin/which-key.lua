local function setup_msgarea()
  local Win = require("which-key.win")

  local defaults = Win.defaults
  Win.defaults = function(opts)
    local o = defaults(opts)
    if opts and opts.relative == "msgarea" then
      o.relative = "msgarea"
      o.noautocmd = false
    end
    return o
  end

  local hide = Win.hide
  Win.hide = function(self)
    if self.win and vim.api.nvim_win_is_valid(self.win) then
      vim.api.nvim_exec_autocmds("WinClosed", { pattern = tostring(self.win), modeline = false })
    end
    return hide(self)
  end

  local show = Win.show
  Win.show = function(self, opts)
    show(self, opts)
    if opts and opts.relative == "msgarea" then require("msgarea.view").render({ flush = true }) end
  end

  require("which-key").setup({
    delay = 1500,
    win = {
      no_overlap = true, -- don't allow the popup to overlap with the cursor
      height = { min = 2, max = 15 },
      relative = "msgarea",
      border = "none",
      padding = { 0, 0 }, -- [top/bottom, right/left]
      -- title = true,
      -- title_pos = "center",
    },
    icons = { separator = ":" },
    layout = {
      width = { min = 20, max = 30 },
      spacing = 2,
    },
  })

  vim.api.nvim_set_hl(0, "WhichKeyNormal", { link = "Msgarea"})
end

local use_msgarea = true

pack.add({
  {
    src = "https://github.com/folke/which-key.nvim",
    data = {
      enable = true,
      defer = true,
      loader = function()
        if use_msgarea then setup_msgarea() end
      end
    }}
})
