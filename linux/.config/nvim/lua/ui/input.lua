local fn = vim.fn
local api = vim.api

local function make_winopts(opts, on_confirm)

  local prompt = opts.prompt or "Input"
  local function spawn_prompt_buf(win)
    local bufnr = api.nvim_create_buf(false, true)
    local name = ("input://%s"):format(bufnr)
    vim.bo[bufnr].buftype = "prompt"
    fn.prompt_setprompt(bufnr, "")
    fn.prompt_setcallback(bufnr, function(input)
      on_confirm(input)
      win:close()
    end)

    -- FIXME: need to sort out autocmds for winapi
    win:create_autocmd("BufLeave", function(self, ev)
      on_confirm(nil)
      self:close()
    end, { once = true, buffer = bufnr })
    win:create_autocmd("BufEnter", function(self, ev)
      vim.cmd.startinsert()
    end, { buffer = bufnr })

    return bufnr
  end

  local function abort(win)
    win:close()
    on_confirm(nil)
  end

  return {
    enter = true,
    style = "minimal",
    position = "top",
    yoffset = -0.20,
    bufnr = spawn_prompt_buf,
    width = 0.15 * vim.o.columns,
    height = 1,
    row = 1,
    relative = "win",
    -- TODO: this should be automatic
    win = api.nvim_get_current_win(),
    keymaps = {
      { "n", "o", "<Nop>" },
      { "n", "o", "<Nop>" },
      { "i", "<C-j>", "<Nop>" },
      { "i", "<C-w>", "<C-S-w>" },
      { "n", "q", function(self) abort(self) end },
      { "i", "<Esc>", function(self) abort(self) end },
      { "i", "<C-c>", function(self) abort(self) end },
    },
    title = prompt,
    title_pos = "left",
    border = "bold",
    bo = { bufhidden = "wipe" },
    wo = {
      cursorline = false,
      winhl = "NormalFloat:Normal,FloatBorder:FloatBorder2",
    },
  }
end

local M = {}

function M.input(opts, on_confirm)
  opts = opts or {}
  on_confirm = on_confirm or function(input) return input and vim.print(input) end
  vim.validate("opts", opts, "table", true)
  vim.validate("on_confirm", on_confirm, "function")

  if opts.winopts then opts.winopts.bufnr = nil end
  local winopts = vim.tbl_deep_extend("keep", opts.winopts or {}, make_winopts(opts, on_confirm))

  local win = Win.float(winopts)

  win:open()
end

local _input = vim.ui.input
function M.enable() vim.ui.input = M.input end
function M.disable() vim.ui.input = _input end

return M
