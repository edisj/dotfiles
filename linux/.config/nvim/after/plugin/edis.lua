local api, fs, fn = vim.api, vim.fs, vim.fn

local M = {}
local ROOT_MARKERS = { ".edis.json", ".edis.toml" }

local find_project_root = function()
  local cwd = fn.getcwd(-1, -1, -1)
  for _, marker in ipairs(ROOT_MARKERS) do
    local root = fs.root(cwd, marker)
    if root then return root, marker end
  end
  local msg = ("no { %s } file detected"):format(table.concat(ROOT_MARKERS, ", "))
  local chunks = {
    { "(", "@punctuation.bracket" },
    { "error", "DiagnosticError" },
    { ") ", "@punctuation.bracket" },
    { msg, "MsgArea" }
  }
  api.nvim_echo(chunks, false, {})
end

local function parse_marker_and_get_context()
  -- local project_root = fs.root(0, ROOT_MARKER)
  local project_root, marker = find_project_root()
  if not project_root then return end

  local marker_file  = fs.joinpath(project_root, marker)
  local data = function()
    if fs.ext(marker) == "toml" then
      local popen_prog = ("yq -p toml -o json %s"):format(marker_file)
      return io.popen(popen_prog):read("*a")
    else
      return table.concat(fn.readfile(marker_file), "\n")
    end
  end
  local ctx = vim.json.decode(data())
  -- ctx.__project_root = project_root
  return ctx
end

local sys = require("quicksys.system").system

function M.build()
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.build) then return end
  -- ctx.__source = ctx.compiler
  -- vim.fn.setqflist({}, " ")
  return require("quicksys").system(ctx.build)
end

function M.run()
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.run) then return end
  ctx.__source = ctx.compiler
  return require("quicksys").system(ctx.run)
end

function M.build_and_run()
  local ctx = parse_marker_and_get_context()
  if not (ctx and ctx.build and ctx.run) then return end
  ctx.__source = ctx.compiler
  return require("quicksys").system(ctx.build, ctx.run)
end

map("<Leader>ee", function()
  local project_root, marker = find_project_root()
  if not project_root then return end
  local marker_file  = vim.fs.joinpath(project_root, marker)
  vim.cmd.edit(marker_file)
end, { desc = ".edis* marker" })

map("<M-m>", function()
  vim.cmd.stopinsert()
  vim.cmd("update")
  M.build()
end, { desc = "edis build", mode = { "n", "i" } })

map("<M-S-m>", function()
  vim.cmd.stopinsert()
  vim.cmd("update")
  M.build_and_run()
end, { desc = "edis build and run", mode = { "n", "i" }})

map("<C-Enter>", function()
  vim.cmd.stopinsert()
  M.run()
end, { desc = "edis run", mode = { "n", "i" } })

return M
