local root_markers = { ".edis", ".git" }
local root_dir = vim.fs.root(0, root_markers)
local project_name = root_dir and vim.fn.fnamemodify(root_dir, ":t") or vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath("cache") .. "/jdtls/" .. project_name

local config = {
    name = "jdtls",
    root_dir = root_dir,
    root_markers = root_markers,
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
    -- If you plan on using additional eclipse.jdt.ls plugins like java-debug
    -- you'll need to set the `bundles`
    --
    -- See https://codeberg.org/mfussenegger/nvim-jdtls#java-debug-installation
    --
    -- If you don't plan on any eclipse.jdt.ls plugins you can remove this
    init_options = {
        bundles = {}
    },

    -- handlers = {
    --     ["language/status"] = function(err, result, ctx, config)
    --         -- vim.print(result.message)
    --         -- vim.v.jdtls_status = result.message or "test"
    --         -- _G.jdtls_status = result.message or "test"
    --         -- vim.cmd.redrawstatus()
    --     end,
    -- },

}
require('jdtls').start_or_attach(config)
