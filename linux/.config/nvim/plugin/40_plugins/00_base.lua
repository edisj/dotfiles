local autocmd = vim.api.nvim_create_autocmd
local packadd = vim.cmd.packadd
local map = Config.map
local nmap = function(...) map("n", ...) end

autocmd("PackChanged", {
  group = vim.api.nvim_create_augroup("rebuild-packs", {}),
  callback = function(ev)
    local name = ev.data.spec.name
    local kind = ev.data.kind

    if name == "nvim-treesitter" and kind == "update" then
      if not ev.data.active then
        packadd("nvim-treesitter")
      end
      vim.cmd("TSUpdate")
    end

    if name == "blink.cmp" and (kind == "update" or kind == "install") then
        vim.notify('Building blink.cmp', vim.log.levels.INFO)
        local obj = vim.system({ 'cargo', 'build', '--release' }, { cwd = ev.data.path }):wait()
        if obj.code == 0 then
            vim.notify('Building blink.cmp done', vim.log.levels.INFO)
        else
            vim.notify('Building blink.cmp failed', vim.log.levels.ERROR)
        end

    end
  end
})

Config.add({

  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
      enabled = true,
      loader = function(name)
        packadd(name)

        local install_these_PLEASE = {
          "asm",
          "bash",
          "c",
          "cpp",
          "css",
          "diff",
          "html",
          "java",
          "javascript",
          "json",
          "lua",
          "python",
          "toml",
          "vimdoc",
          "zsh",
        }
        require("nvim-treesitter").install(install_these_PLEASE)

        local function enable_ts_features(ev)
          local buf = ev.buf
          local ft = ev.match

          -- you need some mechanism to avoid running on buffers that do not
          -- correspond to a language (like oil.nvim buffers), this implementation
          -- checks if a parser exists for the current language
          local language = vim.treesitter.language.get_lang(ft) or ft
          if not vim.treesitter.language.add(language) then
            return
          end

          vim.wo.foldmethod = 'expr'
          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.treesitter.start()
        end

        autocmd("FileType", {
          desc = "Enable treesitter features on valid filetype",
          group = vim.api.nvim_create_augroup("treesitter.setup", {}),
          callback = enable_ts_features,
        })
      end
    },
  },

  {
    src = "https://github.com/folke/lazydev.nvim",
    data = {
      enabled = true,
      loader = function(name)
        Config.add({ "https://github.com/Bilal2453/luvit-meta", "https://github.com/DrKJeff16/wezterm-types" })
        vim.cmd.packadd(name)
        require("lazydev").setup({
          library = {
            { path = "${3rd}/luv/library", words = { "vim%.uv" } },
            { path = "wezterm-types", mods = { "wezterm" } },
            },
          })
      end
    },
  },

  {
    src = "https://github.com/folke/flash.nvim",
    data = {
      enabled = true,
      loader = Config.on_event("BufReadPost", function(name)
        packadd(name)
        require("flash").setup({
          labels = "asdfghjklqwertyuiopzxcvbnm",
          label = {
            after = false,
            before = true,
            style = "overlay", -- eol | overlay | right_align | inline
          },
          modes = {
            search = { mode = "fuzzy" },
            char = {
              enabled = true,
              keys = { "f", "F", "t", "T", ";", "," },
              char_actions = function(motion)
                return {
                  [";"] = "right", -- set to `right` to always go right
                  [","] = "left", -- set to `left` to always go left

                  -- clever-f style
                  [motion:lower()] = "next",
                  [motion:upper()] = "prev",

                  -- jump2d style: same case goes next, opposite case goes prev
                  -- [motion] = "next",
                  -- [motion:match("%l") and motion:upper() or motion:lower()] = "prev",
                }
              end,
            },
          },
        })

        map("nix", "<C-space>", function() require("flash").jump() end)
        map("o", "<C-space>", function() require("flash").remote() end)
        map("o", "<space>", function() require("flash").remote() end)
        map("c", "<C-space>", function() require("flash").toggle() end)
        map("c", "<C-s>", function() require("flash").toggle() end)
        nmap("<C-y>", "y<Cmd>lua require('flash').remote()<CR>")

      end),
    }
  },

  { src = "https://github.com/tpope/vim-fugitive", data = { enabled = true } },
  {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    data = {
      enabled = true,
      loader = Config.on_event({ "BufReadPre", "BufReadPost" }, function(name)
        packadd(name)
        require("gitsigns").setup({
          signs = {
            add = { text = "+" },
            change = { text = "·" },
            -- change = { text = "~" },
            delete = { text = "-" },
            topdelete = { text = "-" },
            changedelete = { text = "·" },
            untracked = { text = "?" },
          },
        })
      end),
    },
  },

})
