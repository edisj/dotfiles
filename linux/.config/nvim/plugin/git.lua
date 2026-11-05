vim.g.diffs = {
  integrations = {
    neogit = true,
    gitsigns = true,
  },
  extra_filetypes = { "diff" },
}
pack.add({
  {
    src = "https://github.com/tpope/vim-fugitive",
    data = { enable = false, defer = true }
  },
  {
    src = "https://forge.barrettruth.com/barrettruth/diffs.nvim",
    data = { enable = true, defer = true },
  },
  {
    src = "https://github.com/lewis6991/gitsigns.nvim",
    data = {
      enable = true,
      defer = true,
      -- event = { "BufReadPre", "BufReadPost" },
      loader = function()
        require("gitsigns").setup({
          signcolumn = vim.g.Gitsigns == 1,
          signs = {
            change       = { text = "▏" },
            add          = { text = "▏" },
            delete       = { text = "▏" },
            topdelete    = { text = "▏" },
            changedelete = { text = "▏" },
            untracked    = { text = "?" },
          },
          signs_staged = {
            change       = { text = "▏" },
            add          = { text = "▏" },
            delete       = { text = "▏" },
            topdelete    = { text = "▏" },
            changedelete = { text = "▏" },
            untracked    = { text = "?" },
          },
        })
      end,
    },
  },
  {
    src = "https://github.com/dlyongemallo/diffview-plus.nvim",
    data = { enable = true },
  },
})

local local_neogit = false
local add = local_neogit and pack.add_local or pack.add
local src = local_neogit and "~/dev/neogit" or "https://github.com/NeogitOrg/neogit"

-- local function guh_popup()
--     require("neogit.lib.popup").builder()
--       :name("NeogitGuhPopup")
--       :group_heading("Guh")
--       :action("g", "open view", function()
--         require("neogit.buffers.guh").new("Guh"):open()
--       end)
--       :build()
--       :show()
-- end

add({
{
    src = src,
    data = {
      enable = true,
      defer = true,
      loader = function()
        local neogit = require("neogit")
        neogit.setup({
          disable_hint = true,
          graph_style = "kitty",
          integrations = { mini_pick = true, diffview = true },
          disable_context_highlighting = true,

          signs = {
            item = { "›", "⌄" },
            section = { "›", "⌄" },
            hunk = { "", "" },
          },
          kind = "tab",

          popup = { kind = "floating", show_title = true },
          floating = {
            -- relative = package.loaded["msgrea"] and require("msgarea.config").get().enable and "msgarea" or nil,
            relative = "msgarea",
            height = 0.20,
            -- width = 1,
            -- anchor = "SW",
            -- row = 1000,
            -- border = "solid",
            border = { "", "", "", " ", "", "", "", " " },
          },

          status = {
            show_head_commit_hash = true,
            recent_commit_count = 20,
            HEAD_padding = 10,
            HEAD_folded = false,
            mode_padding = 3,
            mode_text = {
              M = "modified",
              N = "new file",
              A = "added",
              D = "deleted",
              C = "copied",
              U = "updated",
              R = "renamed",
              T = "changed",
              DD = "unmerged",
              AU = "unmerged",
              UD = "unmerged",
              UA = "unmerged",
              DU = "unmerged",
              AA = "unmerged",
              UU = "unmerged",
              ["?"] = "",
            },
          },

          commit_editor = {
            kind = "tab",
            show_staged_diff = true,
            staged_diff_split_kind = "vsplit",
            spell_check = true,
          },

          guh = {
            kind = "tab",
          },

          mappings = {
            status = {
              ["G"] = require("neogit.popups").open("guh-repo", function(p) p {} end),
            },
          },

        })

        local map_g = function(key, kind, desc)
          map("<C-g>".."<C-"..key..">", "<C-g>"..key, { remap = true })
          map("<C-g>" .. key, ("<Cmd>Neogit kind=%s<CR>"):format(kind), { desc = desc } )
        end
        map_g(".", "tab", "Neogit tab")
        map_g("j", "split_below_all", "Neogit below all")
        map_g("k", "split_above_all", "Neogit above all")
        map_g("l", "vsplit", "Neogit vsplit")
        map_g("h", "vsplit_left", "Neogit vsplit left")

        local augroup = vim.api.nvim_create_augroup("config.neogit", { clear = true })
        on("BufWinEnter", augroup, { pattern = "*Neogit*" }, function(ev)
          if not vim.w.neogit_hunk_match then
             vim.w.neogit_hunk_match = vim.fn.matchadd("NeogitHunkHeader", "^@@.*$", 20)
          end
          local win = vim.api.nvim_get_current_win()
          vim.schedule(function()
            -- if vim.bo.filetype == "NeogitStatus" then vim.wo[win].winfixbuf = true end
            if not vim.api.nvim_win_is_valid(win) then return end
            vim.api.nvim_win_call(win, function()
              vim.opt_local.fillchars:append("eob: ")
            end)
          end)
        end)

        on("FileType", augroup, { pattern = "NeogitPopup" }, function(ev)
          local ns = vim.api.nvim_create_namespace("neogit-buffer-" .. ev.buf .. "-Highlights")
          vim.api.nvim_set_hl(ns, "WinBar", { link = "MsgAreaWinBar" })
          vim.api.nvim_set_hl(ns, "WinBarNC", { link = "MsgAreaWinBar" })
        end)

        -- on("FileType", augroup, { pattern = "NeogitCommitView" }, function(ev)
        --   vim.schedule(function() vim.b[ev.buf].neogit_disable_hunk_highlight = false end)
        -- end)

      end
    }
  }
})

pack.add_local({
  -- { src = "https://github.com/justinmk/guh.nvim", data = { enable = true } },
  { src = "~/dev/guh.nvim", data = { enable = true } },
})

pack.add_local({ "~/dev/neoguh.nvim" })

pack.add({
  { src = "https://github.com/emrearmagan/atlas.nvim",
    data = {
      enable = false,
      loader = function()
          require("atlas").setup({
            providers = {
              ---@type AtlasGitHubConfig
              github = {
                -- hostname = "github.company.com", -- Defaults to GH_HOST, then github.com.
                cache_ttl = 300, -- Seconds; 0 disables caching.
                -- CI options: https://github.com/emrearmagan/atlas.nvim#pipeline-configuration
              },
            },
            pulls = {
              ---@type AtlasGitHubPullsConfig
              github = {
                views = {
                  {
                    name = "Assigned",
                    key = "1",
                    layout = "compact", -- "compact" | "grouped" | "plain"
                    -- current_repo = true, -- Restrict the search to the current Git repository.
                    search = "is:pr assignee:@me archived:false",
                  },
                  { name = "Authored",  key = "2", search = "is:pr author:@me archived:false" },
                  { name = "Reviewing", key = "3", search = "is:pr review-requested:@me archived:false" },
                  { name = "Reviewed",  key = "4", search = "is:pr reviewed-by:@me archived:false" },
                  { name = "Mention",   key = "5", search = "is:pr mentions:@me archived:false" },
                },
                bookmarks = {
                  -- key   = "S",      -- default
                  -- label = "Search", -- default
                  items = {
                    ["Drafts"] = {
                      layout = "compact",
                      search = "is:pr is:draft author:@me",
                    },
                    ["Recently merged"] = "is:pr is:merged author:@me sort:updated-desc",
                  },
                },
              },
            },
          issues = {
            ---@type AtlasGitHubIssuesConfig
            github = {
              views = {
                {
                  name = "Assigned",
                  key = "1",
                  layout = "plain", -- "plain" | "compact"
                  -- current_repo = true, -- Restrict the search to the current Git repository.
                  search = "assignee:@me is:open",
                },
                { name = "Created",  key = "2", search = "author:@me is:open" },
                { name = "Mention",  key = "3", search = "mentions:@me is:open" },
                { name = "Updated",  key = "4", search = "involves:@me sort:updated-desc" },
              },
              bookmarks = {
                -- key   = "S",      -- default
                -- label = "Search", -- default
                items = {
                  ["Bugs"] = {
                    layout = "compact",
                    search = "is:issue is:open label:bug",
                  },
                  ["Recently closed"] = "is:issue is:closed author:@me sort:updated-desc",
                },
              },
            },
          }
          })
      end
    }
  },
})

