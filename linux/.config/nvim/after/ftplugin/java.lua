local fs = vim.fs
local fn = vim.fn
local uv = vim.uv

local root_markers = { ".edis.toml", ".git" }
local root_dir = fs.root(0, root_markers)
local project_name = root_dir and fn.fnamemodify(root_dir, ":t") or fn.fnamemodify(fn.getcwd(), ":p:h:t")
local workspace_dir = fs.joinpath(fn.stdpath("cache"), "jdtls", project_name)

local mason_packs = fs.joinpath(fn.stdpath("data"), "mason", "packages")
local osname = uv.os_uname().sysname
local os_config = fs.joinpath(mason_packs, "jdtls", "config_linux")
local bundles = {
  fn.glob(mason_packs .. "/java-debug-adapter/extension/server/com.microsoft.java.debug.plugin-*.jar", true),
}

--- @type vim.lsp.Config
local config = {
  name = "jdtls",
  root_dir = root_dir,
  root_markers = root_markers,
  cmd = {
    "jdtls",
    "-configuration", os_config,
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
  init_options = { bundles = bundles },

  on_init = function(client)
    client.server_capabilities.semanticTokensProvider = nil
  end,

  on_attach = function(client, bufnr)
    require("jdtls.dap").setup_dap_main_class_configs()
  end,

  handlers = {
    ["language/status"] = function(_, result)
      if result and result.message == "" then return end
      local chunks = { { result.message } }
      vim.api.nvim_echo(chunks, false, {
        kind = "progress",
        status = result.type == "ServiceReady" and "success" or "running",
        source = "jdtls",
        title = "jdtls",
      })
    end,

  },

}

---@type jdtls.start.opts
local opts = {
  dap = {
    config_overrides = {},
    hotcodereplace = "auto",
  }
}
require('jdtls').start_or_attach(config, opts)
