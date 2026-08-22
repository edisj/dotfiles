pack.add({
  {
    src = "https://github.com/nvim-tree/nvim-tree.lua",
    data = {
      enable = true,
      loader = function()
        require("nvim-tree").setup({
          hijack_netrw = false,
        })
        map("<C-Tab>", "<Cmd>NvimTreeToggle<CR>")
      end,
    }
  },
})
