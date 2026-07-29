Pack.add({
  {
    src = "https://github.com/stevearc/aerial.nvim",
    data = {
      enabled = true,
      loader = Pack.load_on_loop(function(name)
        vim.cmd.packadd(name)
        require("aerial").setup()
      end)
    }
  }
})
