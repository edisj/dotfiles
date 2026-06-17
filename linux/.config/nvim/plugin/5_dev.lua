local fn = vim.fn
local uv = vim.uv

local nmap = Config.nmap
local imap = Config.imap

local PACKPATH = fn.stdpath("data") .. "/site/pack/dev/opt/"
fn.mkdir(PACKPATH, "p")

local function e(msg)
  vim.api.nvim_echo({{msg}}, true, {
    err = true,
  })
end

local function add_local(specs)
  local enabled_plugs = vim
    .iter(specs)
    :map(function(spec)
      return (spec.data or {}).enabled ~= false and spec or nil
    end)
    :totable()

  local try_link_src = function(src_path)
    if not uv.fs_stat(src_path) then
      e(src_path .. " not found")
      return false
    end
    local name = fn.fnamemodify(src_path, ":t")
    local symlink = PACKPATH .. name
    local ret = uv.fs_symlink(src_path, symlink)
    -- NOTE: ret is (only?) nil when symlink already exists
    return ret or ret == nil
  end
  for _, plug in ipairs(enabled_plugs) do
    local data = plug.data or {}
    local src_path = fn.expand(plug.src)
    if try_link_src(src_path) then
      local name = fn.fnamemodify(src_path, ":t")
      if data.loader then
        data.loader(name)
      else
        vim.cmd.packadd(name)
      end
    end
  end

end

add_local({
  {
    src = "~/dev/win.nvim",
    data = { enabled = true },
  },
  {
    src = "~/dev/msgarea.nvim",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)
        vim.g.msgarea_min_height = 5
        vim.g.msgarea_max_height = 0.35
        require("msgarea.blink_integration").enable()
        Config.nmap("<M-n>", function()
          require("msgarea").close_all()
        end)
      end
    },
  },
  {
    src = "~/dev/quicksys.nvim",
    data = {
      enabled = true,
      loader = function(name)
        vim.cmd.packadd(name)

      end,
    }
  },
})

local gcc = {
  name = "gcc",
  handler = function(data)
    local lines = vim.split(data, "\n")
    local error_pattern = "^([^:]+):(%d+):(%d+): ([^:]+): (.+)$"
    local line_to_qf_item = function(line)
      local filename, lnum, col, severity, message = line:match(error_pattern)
      if filename == nil then return end
      return {
        filename = filename,
        lnum = lnum,
        col = col,
        text = message,
        type = require("quicksys.constants").SEVERITY_TO_CHAR[severity],
      }
    end
    return vim
      .iter(lines)
      :map(line_to_qf_item)
      :totable()
  end,
  qftf = require("quicksys.builtin.sources.flat").qftf
}

local git_status = {
  name = "git-status",
  handler = function(data)
    if data == nil then return end

    local lines = vim.split(data, "\n")
    local staged, untracked, modified, deleted = {}, {}, {}, {}
    for _, line in ipairs(lines) do
      local item = {
        type = line:sub(1, 2),
        filename = vim.trim(line:sub(3)),
        staged = line:sub(2, 2) == " ",
      }
      if     item.staged          then staged[#staged + 1] = item
      elseif item.type == "??"    then untracked[#untracked + 1] = item
      elseif item.type:match("M") then modified[#modified + 1] = item
      elseif item.type:match("D") then deleted[#deleted + 1] = item
      else
        error("something went wrong")
      end
    end

    local qf_list = {}
    local git_root = vim.fs.root(vim.fn.getcwd(), ".git")
    local add_to_list = function(group, header)
      if #group == 0 then return end

      qf_list[#qf_list + 1] = {
        text = header,
        valid = false,
        user_data = { header = true, count = #group },
      }
      for _, item in ipairs(group) do
        local fullpath = vim.fs.joinpath(git_root, item.filename)
        local qf_entry = {
          filename = fullpath,
          text = item.filename,
          type = vim.trim(item.type),
          valid = not item.type:match("D"),
          user_data = { staged = item.staged },
        }
        qf_list[#qf_list + 1] = qf_entry
      end
    end
    add_to_list(staged, "Staged")
    add_to_list(modified, "Modified")
    add_to_list(deleted, "Deleted")
    add_to_list(untracked, "Untracked")

    return qf_list
  end,
  qftf = require("quicksys.utils").gen_nested_qftf({
    format_line = function(item) return item.text end,
    decorate_line = function(item, line, extmark)
      if not item.user_data.header then
        extmark({ virt_text = {{ "    " }}, virt_text_pos = "inline" })
        local icon, hl = require("mini.icons").get("file", item.text)
        extmark({ virt_text = {{ icon .. " ", hl }}, virt_text_pos = "inline" })
      else
        extmark({
          virt_text = { { ("(%s)"):format(item.user_data.count), "Comment" } },
          virt_text_pos = "eol",
          hl_mode = "combine",
        })
        if item.text == "Staged" then
          extmark({ hl_group = "DiagnosticOk", end_col = #line })
        elseif item.text == "Modified" then
          extmark({ hl_group = "DiagnosticWarn", end_col = #line })
        end
      end
    end,
  }),
}

local quicksys = require("quicksys")
quicksys.setup({
  sources = {
    default = "flat",
    Diagnostics = "flat",
    References = "nested",
    gcc = gcc,
    ["git-status"] = git_status,
  },
  windows = {
    only_one_open_at_a_time = false,
    quickfix = {
      enabled = true,
      -- kind = "split",
      kind = "float",
      win_opts = {
        win = -1,
        relative = "msgarea",
        wo = {},
      }
    },
    output = {
      enabled = true,
      -- kind = "split",
      kind = "float",
      win_opts = {
        enter = false,
        -- win = -1,
        relative = "msgarea",
      }
    },
  }
})

local nmap = Config.nmap
nmap("g>", function() require("quicksys").quickfix_focus() end)

nmap("<M-x>", function() require("quicksys").output_toggle() end)

nmap("<M-space>", function() require("quicksys").output_toggle() end)

nmap("<C-q>", function() require("quicksys").quickfix_toggle() end, { desc = "quickfix toggle" })

nmap("<C-n>", function() require("quicksys").quickfix_next() end, { desc = "quickfix next" })

nmap("<C-p>", function() require("quicksys").quickfix_prev() end, { desc = "quickfix prev" })

local custom_stdout = function(ctx, _, data)
  if data == nil then return end
  data = data:gsub("\n$", "") -- remove trailing newline
  vim.schedule(function()
    require("quicksys").quickfix_set(ctx, data)
  end)
end
nmap("<C-g>", function()
  require("quicksys").system({ __source = "git-status" }, {
    cmd = "git status --porcelain",
    stderr = false,
    stdout = custom_stdout,
    before = false,
    after = false,
  })
  require("quicksys").quickfix_open()
end)
