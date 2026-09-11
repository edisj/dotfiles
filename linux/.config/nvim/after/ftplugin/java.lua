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

local mason_packs = fs.joinpath(fn.stdpath("data"), "mason", "packages")
local bundles = fn.glob(mason_packs .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true, true)

--- @type vim.lsp.Config
local config = {
  name = "jdtls",
  root_dir = root_dir,
  cmd = {
    "jdtls",
    "-data", workspace_dir,
  },

  -- eclipse.jdt.ls specific settings
  -- https://github.com/eclipse/eclipse.jdt.ls/wiki/Running-the-JAVA-LS-server-from-the-command-line#initialize-request
  settings = {
    java = {
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
  end,
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
