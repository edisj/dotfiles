on("PackChanged", "config.treesitter.rebuild", function(ev)
  local name = ev.data.spec.name
  local kind = ev.data.kind
  if name == "nvim-treesitter" and kind == "update" then
    if not ev.data.active then
      vim.cmd.packadd("nvim-treesitter")
    end
    vim.cmd("TSUpdate")
  end
end)

pack.add({
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter-textobjects",
    version = "main",
    data = {
      enable = true,
      -- loader = function()
      --   local ts_repeat_move = require("nvim-treesitter-textobjects.repeatable_move")
      --   map(";", ts_repeat_move.repeat_last_move_next,     { mode = "n", "x", "o" })
      --   map(",", ts_repeat_move.repeat_last_move_previous, { mode = "n", "x", "o" })
      -- end
    }
  },
  {
    src = "https://github.com/nvim-treesitter/nvim-treesitter",
    version = "main",
    data = {
      enable = true,
      loader = function()
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
          "latex",
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

          vim.wo.foldexpr = 'v:lua.vim.treesitter.foldexpr()'
          vim.wo.foldmethod = 'expr'
          vim.bo.indentexpr = "v:lua.require'nvim-treesitter'.indentexpr()"
          vim.treesitter.start()
        end

        on("FileType", "config.treesitter", enable_ts_features)
      end
    },
  },
})
