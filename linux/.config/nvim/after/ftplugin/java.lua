local api, fn, fs, uv = vim.api, vim.fn, vim.fs, vim.uv

local root_markers = {
  { ".edis.toml" },
  { "gradelw", "settings.gradle", "settings.gradle.kts", "mvnw", "pom.xml"},
  { ".git", ".classpath", ".project" }
}
local root_dir = fs.root(0, root_markers)

if not root_dir then
  local msg = "jdtls: could not find root dir; aborting lsp setup..."
  local chunks = {
    { "(", "@punctuation.bracket" },
    { "error", "DiagnosticError" },
    { ") ", "@punctuation.bracket" },
    { msg, "MsgArea" }
  }
  api.nvim_echo(chunks, true, {})
  return
end

local project_name =
  root_dir and fn.fnamemodify(root_dir, ":t")
  or fn.fnamemodify(fn.getcwd(), ":p:h:t")
local workspace_dir = fs.joinpath(fn.stdpath("cache"), "jdtls", project_name)
-- vim.print("ROOT DIR: " .. tostring(root_dir))
-- vim.print("PROJECT NAME: " .. tostring(project_name))
-- vim.print("WORKSPACE DIR: " .. tostring(workspace_dir))

-- local osname = uv.os_uname().sysname
-- local os_config = fs.joinpath(mason_packs, "jdtls", "config_linux")
local mason_packs = fs.joinpath(fn.stdpath("data"), "mason", "packages")
local bundles = fn.glob(mason_packs .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)

local jars, sources
-- NOTE: perhaps use this block for projects with no build system
-- local lib = root_dir .. "/lib"
-- if uv.fs_stat(lib) then
--   jars = fn.glob(lib .. "/**/*.jar", true, true)
--   vim.print("JARS")
--   for _, jar in ipairs(jars) do
--     -- vim.print(fs.basename(jar))
--     vim.print(jar)
--     sources[jar] = src
--   end
-- end

--- @type vim.lsp.Config
local config = {
  name = "jdtls",
  root_dir = root_dir,
  -- root_markers = root_markers,
  cmd = {
    "jdtls",
    -- "-configuration", os_config,
    "-data", workspace_dir,
  },

  -- eclipse.jdt.ls specific settings
  -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  settings = {
    java = {
      project = {
        -- sourcePaths = { "src" },
        referencedLibraries = {
          include = jars,
          sources = sources
        },
      },
      signagureHelp = {
        enabled = true,
        description = { enabled = true },
      },
    },
  },

  -- This sets the `initializationOptions` sent to the language server
  -- https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
  init_options = { bundles =  bundles },

  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,

  on_attach = function(client, bufnr)
    -- TODO: why is this needed?
    require("jdtls.dap").setup_dap_main_class_configs()

    -- local dap = require('dap')
    -- dap.listeners.after.event_stopped["jdtls-"..client.id] = function(session, _)
    --   local frame = session.current_frame
    --   local path = frame and frame.source and frame.source.path
    --   if not (path and path:match("^jdt://")) then return end
    --
    --   local buf = vim.uri_to_bufnr(path)
    -- end

  end,

  handlers = {
    -- ["language/status"] = function(_, result)
    --   if result and result.message == "" then return end
    --   local chunks = { { result.message } }
    --   vim.api.nvim_echo(chunks, false, {
    --     kind = "progress",
    --     status = result.type == "ServiceReady" and "success" or "running",
    --     source = "jdtls",
    --     title = "jdtls",
    --   })
    -- end,
  },
}

---@type jdtls.start.opts
local jdtls_opts = {
  dap = {
    config_overrides = {},
    hotcodereplace = "auto",
  }
}

vim.opt_local.tabstop = 4
vim.opt_local.softtabstop = 4
vim.opt_local.shiftwidth = 4
vim.opt_local.expandtab = true
require("jdtls").start_or_attach(config, jdtls_opts)
