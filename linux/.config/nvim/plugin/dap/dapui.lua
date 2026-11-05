local ok, dap = pcall(require, "dap")
if not ok then return end

local api = vim.api

local msgarea_element = { nlua = "repl" }
local msgarea_wins = {}

local function close_msgarea_win(id)
  local win = msgarea_wins[id]
  if win and api.nvim_win_is_valid(win) then
    api.nvim_win_close(win, true)
  end
  msgarea_wins[id] = nil
end

local function open_in_msgarea(id)
  close_msgarea_win(id)
  local bufnr = require("dapui").elements[id].buffer()
  local win_cfg = {
    relative = "msgarea",
    title = (" DAP %s "):format(id:sub(1, 1):upper() .. id:sub(2)),
    height = math.floor(0.15 * vim.o.lines),
  }
  msgarea_wins[id] = api.nvim_open_win(bufnr, false, win_cfg)
end

local function dapui_open()
  require("dapui").open({ layout = 1 })
  open_in_msgarea("stacks")
  open_in_msgarea("watches")
  open_in_msgarea("console")
end

local hover_buf, hover_win
local hover_ns = api.nvim_create_namespace("")

local function get_cexpr_and_hl()
  local expr = vim.fn.expand("<cexpr>")
  if expr == "" then return end
  local row, col = unpack(api.nvim_win_get_cursor(0))
  local s = api.nvim_get_current_line():find(expr, math.max(1, col + 2 - #expr), true)
  if not s then return expr end
  hover_buf = api.nvim_get_current_buf()
  vim.hl.range(hover_buf, hover_ns, "LspReferenceTarget",
    { row - 1, s - 1 }, { row - 1, s - 1 + #expr },
    { priority = vim.hl.priorities.user })
  return expr
end

local function eval_in_msgarea(expr)
  if not dap.session() then
    return api.nvim_echo({{ "No active debug session" }}, false, {})
  end
  if hover_win and api.nvim_win_is_valid(hover_win) then
    return api.nvim_set_current_win(hover_win)
  end
  local cexpr = get_cexpr_and_hl()
  local elem = require("dapui").elements.hover
  elem.set_expression(expr or cexpr)
  local bufnr = elem.buffer()
  local win_cfg = {
    relative = "msgarea",
    title = (" %s "):format(cexpr),
    height = math.min(math.max(1, api.nvim_buf_line_count(bufnr), math.floor(0.25 * vim.o.lines)))
  }
  hover_win = api.nvim_open_win(bufnr, false, win_cfg)
  vim.wo[hover_win].winfixbuf = true
end

pack.add({
  { src = "https://github.com/nvim-neotest/nvim-nio" },
  {
    src = "https://github.com/theHamsta/nvim-dap-virtual-text",
    data = {
      enable = true,
      defer = true,
      loader = function()
        require("nvim-dap-virtual-text").setup({
          highlight_changed_variables = false,
          highlight_new_as_changed = false,
          virt_text_pos = "eol",
        })
      end,
    }
  },
  {
    src =  "https://github.com/LiadOz/nvim-dap-repl-highlights",
    data = {
      enable = true,
      defer = true,
      loader = function()
        require("nvim-dap-repl-highlights").setup()
        require("nvim-treesitter").install({ "dap_repl" })
      end
    },
  },
  {
    src = "https://github.com/rcarriga/nvim-dap-ui",
    data = {
      enable = true,
      defer = true,
      loader = function()
        local dapui = require("dapui")
        ---@diagnostic disable-next-line: missing-fields
        dapui.setup({
          render = { indent = 2 },
          expand_lines = false,
          icons = { expanded = "⌄", collapsed = "›", current_frame = "›" },
          layouts = {
            {
              position = "right",
              size = 0.25,
              elements = { { id = "console", size = 1.0 } }
            },
          },
          controls = { enabled = false },
        })

        map("<Leader>do", function() dapui_open() end)

        local dapbp = require("dap.breakpoints")
        dap.listeners.after.event_initialized["dapui_config"] = function(session)
          if next(dapbp.get()) then dapui.open({ layout = 1 }) end
          open_in_msgarea("stacks")
          open_in_msgarea("watches")
          open_in_msgarea(msgarea_element[session.config.type] or "console")
        end

        local console_to_bottom = vim.schedule_wrap(function(buf)
          local winid = vim.fn.bufwinid(buf)
          if winid == -1 then return end
          vim.api.nvim_win_set_cursor(winid, { vim.api.nvim_buf_line_count(buf), 0 })
        end)

        local augroup = api.nvim_create_augroup("config.dapui", {})

        on("TermOpen", augroup, function(ev)
          if ev.buf == dapui.elements.console.buffer() then
            console_to_bottom(ev.buf)
          end
        end)

        on("BufWinEnter", augroup, function(ev)
          local ft = vim.bo[ev.buf].filetype
          if not (ft:match("^dapui_") or ft == "dap-repl") then return end
          local winid = vim.fn.bufwinid(ev.buf)
          if winid == -1 then return end
          vim.wo[winid][0].cursorline = false
          vim.wo[winid][0].statuscolumn = ""
          vim.wo[winid][0].number = false
          vim.api.nvim_win_call(winid, function()
            vim.opt_local.fillchars:append("eob: ")
          end)
          if ft == "dapui_console" then console_to_bottom(ev.buf) end
        end)

        on("CursorMoved", augroup, { nested = true }, function()
          if api.nvim_get_current_win() ~= hover_win then
            if hover_buf and api.nvim_buf_is_valid(hover_buf) then
              api.nvim_buf_clear_namespace(hover_buf, hover_ns, 0, -1)
              pcall(api.nvim_win_close, hover_win, true)
            end
          end
        end)

        -- map("K", function()
        --   local session = dap.session()
        --   if session and vim.bo.buftype == "" and vim.bo.filetype == session.filetype then
        --     eval_in_msgarea()
        --   elseif next(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })) then
        --     vim.notify"???"
        --      vim.lsp.buf.hover({ wrap = false, width = 200, max_width=999, border = "rounded" })
        --   else
        --     vim.api.nvim_feedkeys(vim.keycode("K"), "n", false)
        --   end
        -- end, { desc = "hover / dap eval" })

      end,
    }
  },
  {
    src = "https://codeberg.org/Jorenar/nvim-dap-disasm.git",
    data = {
      enable = false,
      -- defer = true,
      loader = function()
        require("dap-disasm").setup({})
      end,
    },
  },
})

map("K", function()
  local session = dap.session()
  if session and vim.bo.buftype == "" and vim.bo.filetype == session.filetype then
    eval_in_msgarea()
  elseif next(vim.lsp.get_clients({ bufnr = 0, method = "textDocument/hover" })) then
    vim.lsp.buf.hover({ wrap = false,  border = "rounded" })
  else
    vim.api.nvim_feedkeys(vim.keycode("K"), "n", false)
  end
end, { desc = "hover / dap eval" })
