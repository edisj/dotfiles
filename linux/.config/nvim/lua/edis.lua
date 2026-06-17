local fs = vim.fs
local api = vim.api

local M = {}

local ROOT_MARKER = ".edis.toml"
local function parse_marker_and_get_context()
  -- local project_root = fs.root(0, ROOT_MARKER)
  local project_root = fs.root(vim.fn.getcwd(), ROOT_MARKER)
  if project_root == nil then
    local msg = ("no '%s' file detected"):format(ROOT_MARKER)
    local chunks = {
      { "(", "@punctuation.bracket" },
      { "error", "DiagnosticError" },
      { ") ", "@punctuation.bracket" },
      { msg, "MsgArea" }
    }
    api.nvim_echo(chunks, true, {})
    return
  end
  local marker_file  = fs.joinpath(project_root, ROOT_MARKER)
  local popen_prog = ("yq -p toml -o json %s"):format(marker_file)
  local ctx = vim.json.decode(io.popen(popen_prog):read("*a"))
  ctx.__project_root = project_root
  return ctx
end

function M.build()
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.build) then return end
  ctx.__source = ctx.compiler
  -- vim.fn.setqflist({}, " ")
  return require("quicksys").system(ctx, ctx.build)
end

function M.run()
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.run) then return end
  ctx.__source = ctx.compiler
  return require("quicksys").system(ctx, ctx.run)
end

function M.build_and_run()
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.build and ctx.run) then return end
  ctx.__source = ctx.compiler
  return require("quicksys").system(ctx, ctx.build, ctx.run)
end

vim.keymap.set({ "n", "i" }, "<M-m>", function()
  vim.cmd.stopinsert()
  vim.cmd("update")
  M.build()
end, { desc = "edis build" })

vim.keymap.set({ "n", "i" }, "<M-S-m>", function()
  vim.cmd.stopinsert()
  vim.cmd("update")
  M.build_and_run()
end, { desc = "edis build and run" })

vim.keymap.set({ "n", "i" }, "<C-Enter>", function()
  vim.cmd.stopinsert()
  M.run()
end, { desc = "edis run" })

return M
