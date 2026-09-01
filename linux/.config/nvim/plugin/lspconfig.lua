local lsp = vim.lsp

pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
  {
    src = "https://github.com/mason-org/mason.nvim",
    data = {
      enable = true,
      loader = function()
        require("mason").setup({
          ui = {
            width = 0.80,
            height = 0.80,
            border = { "🭽", "▔", "🭾", "▕", "🭿", "▁", "🭼", "▏" },
          },
        })

        -- https://www.reddit.com/r/neovim/comments/1p1y73n/automatically_downloading_and_installing_lsps/
        local ensure_installed = {
          "bash-language-server",
          "basedpyright",
          "black",
          "clangd",
          "codelldb",
          "debugpy",
          "hyprls",
          "java-debug-adapter",
          "jdtls",
          "lua-language-server",
          "stylua",
        }

        local already_installed = require("mason-registry").get_installed_package_names()
        for _, pack in ipairs(ensure_installed) do
          if not vim.tbl_contains(already_installed, pack) then
            vim.cmd("MasonInstall " .. pack)
          end
        end

        map("<Leader>M", "<Cmd>Mason<CR>", { desc = "Open Mason" })
      end
    }
  }
})

-- Config.on("LspProgress", function(ev)
--   local value = ev.data.params.value
--   local name = lsp.get_client_by_id(ev.data.client_id).name
--   if name == "jdtls" then return end
--   local msg = value.message or "done"
--   local chunks = value.title .. ": " .. msg
--   vim.api.nvim_echo({ { chunks } }, false, {
--     id = "lsp." .. ev.data.params.token,
--     kind = "progress",
--     source = "vim.lsp",
--     title = name,
--     status = value.kind ~= "end" and "running" or "success",
--     percent = value.percentage,
--   })
-- end)

-- --- @param client vim.lsp.Client
-- local on_init = function(client)
--   client.server_capabilities.semanticTokensProvider = nil
-- end
-- lsp.config("*", {
--   on_init = on_init,
-- })
on("LspAttach", nil, function(ev)
  local client = lsp.get_client_by_id(ev.data.client_id)
  if client then
    client.server_capabilities.semanticTokensProvider = nil
  end
end)

-- lsp.config("lua_ls", {
--   on_init = function(client)
--     -- on_init(client)
--     if client.workspace_folders then
--       local path = client.workspace_folders[1].name
--       if
--         path ~= vim.fn.stdpath("config")
--         and (vim.uv.fs_stat(path .. "/.luarc.json") or vim.uv.fs_stat(path .. "/.luarc.jsonc"))
--       then
--         return
--       end
--     end
--
--     client.config.settings.Lua = vim.tbl_deep_extend("force", client.config.settings.Lua, {
--       runtime = {
--         -- Tell the language server which version of Lua you're using (most
--         -- likely LuaJIT in the case of Neovim)
--         version = 'LuaJIT',
--         -- Tell the language server how to find Lua modules same way as Neovim
--         -- (see `:h lua-module-load`)
--         path = {
--           "lua/?.lua",
--           -- "lua/?/init.lua",
--         },
--       },
--       -- Make the server aware of Neovim runtime files
--       workspace = {
--         checkThirdParty = false,
--         library = {
--           vim.env.VIMRUNTIME,
--           -- Depending on the usage, you might want to add additional paths
--           -- here.
--           "${3rd}/luv/library",
--           -- "${3rd}/busted/library",
--         },
--         -- Or pull in all of "runtimepath".
--         -- NOTE: this is a lot slower and will cause issues when working on
--         -- your own configuration.
--         -- See https://github.com/neovim/nvim-lspconfig/issues/3189
--         -- library = vim.api.nvim_get_runtime_file("", true),
--       },
--     })
--   end,
--   settings = {
--     Lua = {},
--   },
-- })
lsp.enable("lua_ls")


---@type vim.lsp.Config
lsp.config("bashls", {
  filetypes = { "zsh", "bash", "sh" },
})
lsp.enable("bashls")

---@type vim.lsp.Config
lsp.config("asm_lsp", {
  cmd = { "asm-lsp" },
  filetypes = { "asm", "vmasm", "mips" },
  root_markers = { ".edis.toml", ".asm-lsp.toml", ".git" },
})
lsp.enable("asm_lsp")

lsp.enable("clangd")
lsp.enable("hyprls")
lsp.enable("basedpyright")
