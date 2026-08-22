local ok, dap = pcall(require, "dap")
if not ok then return end

dap.adapters.codelldb = {
  type = "executable",
  command = "codelldb",
}
dap.configurations.c = {
  {
    type = "codelldb",
    name = "launch",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    stopOnEntery = false,
    args = {},
  }
}
dap.configurations.cpp = dap.configurations.c
