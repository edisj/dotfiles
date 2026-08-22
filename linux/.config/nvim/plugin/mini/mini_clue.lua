local function setup_mini_clue()
  vim.keymap.set({"n"}, "<C-f>", "<Nop>")

  local clue = require("mini.clue")
  clue.setup({
    triggers = {
      { mode = { "n", "x" }, keys =  "<leader>" },
      { mode = { "n" },      keys =  "<C-f>" },
      { mode = { "n" },      keys =  "<F13>" },
      { mode = { "n", "x" }, keys =  "[" },
      { mode = { "n", "x" }, keys =  "]" },
      { mode =   'i',        keys = '<C-x>' },
      { mode = { "n", "x" }, keys =  "g" },
      { mode = { "n", "x" }, keys =  "'" },
      { mode = { "n", "x" }, keys =  "`" },
      { mode = { "n", "x" }, keys =  '"' },
      { mode = { 'i', 'c' }, keys = '<C-r>' },
      { mode =   'n',        keys = '<C-w>' },
      { mode = { 'n', 'x' }, keys = 's' },
      { mode = { 'n', 'x' }, keys = 'd' },
      { mode = { 'n', 'x' }, keys = 'z' },
    },
    clues = {
      { mode = 'n', keys = '<Leader>e', desc = '+Edit' },
      { mode = 'n', keys = '<Leader>d', desc = '+Dap' },
      { mode = 'n', keys = '<Leader>f', desc = '+Find' },
      { mode = 'n', keys = '<C-F>', desc = '+Find' },
      { mode = 'n', keys = '<F13>', desc = '+msgarea' },
      { mode = 'n', keys = '<Leader>g', desc = '+Git' },
      { mode = 'n', keys = '<Leader>l', desc = '+Lsp' },
      { mode = 'n', keys = '<Leader>m', desc = '+Messages' },
      { mode = 'n', keys = '<Leader>s', desc = '+Session' },
      { mode = 'n', keys = '<Leader>t', desc = '+Toggle' },
      clue.gen_clues.g(),
      clue.gen_clues.z(),
      clue.gen_clues.marks(),
      clue.gen_clues.square_brackets(),
      clue.gen_clues.builtin_completion(),
      -- This creates a submode for window resize mappings. Try the following:
      -- - Press `<C-w>s` to make a window split.
      -- - Press `<C-w>+` to increase height. Clue window still shows clues as if
      --   `<C-w>` is pressed again. Keep pressing just `+` to increase height.
      --   Try pressing `-` to decrease height.
      -- - Stop submode either by `<Esc>` or by any key that is not in submode.
      clue.gen_clues.windows({ submode_resize = true }),
    },
    window = {
      scroll_down = '<M-j>',
      scroll_up = '<M-k>',
      config = function()
        return {
          anchor = "SE",
          height = 1000,
          -- col = 0.75 * vim.o.columns,
          -- width = 30,
          width = "auto",
          -- width = 0.3 * vim.o.columns,
          -- border = { "🭽", "▔", "🭾", "▕", " ", " ", " ", "▏" },
          border = "solid",
        }
      end,
    },
  })
end

pack.gen_loop_loader(function() setup_mini_clue() end)("mini.clue")
