-- This checks if Neovim was started with "-c DiffviewOpen" in which case we
-- generally want to quit neovim when exiting DiffView.
local function opened_on_boot()
  for i = 1, #vim.v.argv do
    if vim.v.argv[i] == "-c" and vim.v.argv[i + 1] and vim.v.argv[i + 1]:match("^Diffview") then
      return true
    end
  end
  return false
end

local function close_diffview()
  if opened_on_boot() then
    vim.cmd("qa")
    return
  end

  vim.cmd.DiffviewClose()
end

return {
  { "avm99963/vim-jjdescription" },
  { "rafikdraoui/jj-diffconflicts" },

  {
    "julienvincent/hunk.nvim",
    cmd = { "DiffEditor" },
    config = function()
      local hunk = require("hunk")
      hunk.setup({
        keys = {
          diff = {
            prev_hunk = { "<S-Left>" },
            next_hunk = { "<S-Right>" },

            toggle_line = { "s" },
            toggle_line_pair = { "a" },
          },
        },
      })
    end,
  },

  {
    "lewis6991/gitsigns.nvim",
    event = { "BufReadPost" },
    opts = {
      signs = {
        add = { text = "❙" },
        change = { text = "❙" },
        delete = { text = "" },
        topdelete = { text = "" },
        changedelete = { text = "❙" },
        untracked = { text = "❙" },
      },
      attach_to_untracked = true,
      on_attach = function(buffer)
        local gs = require("gitsigns")

        local function map(mode, l, r, desc)
          vim.keymap.set(mode, l, r, { buffer = buffer, desc = desc })
        end

        -- stylua: ignore start
        map("n", "]h", function ()
          gs.nav_hunk("next")
        end, "Next Hunk")
        map("n", "[h", function ()
          gs.nav_hunk("prev")
        end, "Prev Hunk")

        map({ "n", "v" }, "<leader>ghr", ":Gitsigns reset_hunk<CR>", "Reset Hunk")
        map("n", "<leader>ghR", gs.reset_buffer, "Reset Buffer")
        map("n", "<leader>ghp", gs.preview_hunk, "Diff Hunk")

        map("n", "<leader>gbl", gs.blame_line, "Blame Line")
        map("n", "<leader>gbb", gs.blame , "Toggle line blame")
      end,
    },
  },

  {
    "sindrets/diffview.nvim",
    keys = {
      { "<leader>gd", "<cmd>DiffviewOpen<cr>", desc = "Diff view" },
      { "<leader>gf", "<cmd>DiffviewFileHistory %<cr>", desc = "File history" },
      { "<leader>gl", "<cmd>DiffviewFileHistory<cr>", desc = "Git log" },
    },
    cmd = { "DiffviewOpen", "DiffviewFileHistory" },
    config = function()
      local actions = require("diffview.actions")
      local lib = require("diffview.lib")

      local function notify_diffview(message)
        vim.notify(message, vim.log.levels.WARN, { title = "diffview.nvim" })
      end

      local function infer_entry(view)
        local ok, entry = pcall(function()
          return view:infer_cur_file(false)
        end)

        if ok and entry then
          return entry
        end

        local ok_fallback, fallback_entry = pcall(function()
          return view:infer_cur_file()
        end)

        if ok_fallback then
          return fallback_entry
        end
      end

      local function build_entry_diff(entry)
        local view = lib.get_current_view()
        if not view then
          return nil, "No active Diffview tab."
        end

        if not entry or not entry.path or not entry.revs then
          return nil, "No diff entry selected."
        end

        local adapter = view.adapter
        local args = {
          "diff",
          "--no-ext-diff",
          "--color=never",
        }

        vim.list_extend(args, adapter:rev_to_args(entry.revs.a, entry.revs.b))
        table.insert(args, "--")
        table.insert(args, entry.path)

        if entry.oldpath and entry.oldpath ~= entry.path then
          table.insert(args, entry.oldpath)
        end

        local stdout, code, stderr = adapter:exec_sync(args, { cwd = adapter.ctx.toplevel })
        if code ~= 0 then
          return nil, table.concat(stderr, "\n")
        end

        if not stdout or #stdout == 0 then
          return nil, "Diff is empty."
        end

        return stdout
      end

      local function open_opencode(diff_lines, title)
        if not diff_lines or #diff_lines == 0 then
          notify_diffview("Diff is empty.")
          return
        end

        vim.cmd("tabnew")
        local job_id = vim.fn.termopen({ "opencode", "--prompt", title })

        if job_id <= 0 then
          notify_diffview("Failed to launch opencode.")
          vim.cmd("tabclose")
          return
        end

        local diff_text = table.concat({ "```diff", table.concat(diff_lines, "\n"), "```" }, "\n")
        vim.schedule(function()
          vim.fn.chansend(job_id, diff_text)
        end)
      end

      local function open_entry_diff()
        local view = lib.get_current_view()
        if not view then
          notify_diffview("No active Diffview tab.")
          return
        end

        local entry = infer_entry(view)
        local diff_lines, err = build_entry_diff(entry)
        if not diff_lines then
          notify_diffview(err or "Unable to build diff.")
          return
        end

        open_opencode(diff_lines, ("Review diff: %s"):format(entry.path))
      end

      local function open_focused_diff()
        local view = lib.get_current_view()
        if not view then
          notify_diffview("No active Diffview tab.")
          return
        end

        local entry = view.cur_entry or infer_entry(view)
        local diff_lines, err = build_entry_diff(entry)
        if not diff_lines then
          notify_diffview(err or "Unable to build diff.")
          return
        end

        open_opencode(diff_lines, ("Review focused diff: %s"):format(entry.path))
      end

      require("diffview").setup({
        enhanced_diff_hl = true,

        keymaps = {
          view = {
            ["q"] = close_diffview,
            {
              "n",
              "<leader>gF",
              open_focused_diff,
              { desc = "Open focused diff in opencode" },
            },
          },
          file_panel = {
            ["q"] = close_diffview,
            {
              "n",
              "<leader>gA",
              open_entry_diff,
              { desc = "Open entry diff in opencode" },
            },
            {
              "n",
              "<Right>",
              actions.select_entry,
              { desc = "Open the diff for the selected entry" },
            },
            {
              "n",
              "<cr>",
              actions.focus_entry,
              { desc = "Focus the diff entry" },
            },
          },
          file_history_panel = {
            ["q"] = close_diffview,

            {
              "n",
              "<leader>gA",
              open_entry_diff,
              { desc = "Open entry diff in opencode" },
            },

            {
              "n",
              "<Left>",
              actions.select_entry,
              { desc = "Open the diff for the selected entry" },
            },
            {
              "n",
              "<Right>",
              actions.select_entry,
              { desc = "Open the diff for the selected entry" },
            },
            {
              "n",
              "<cr>",
              actions.focus_entry,
              { desc = "Focus the diff entry" },
            },
          },
        },

        hooks = {
          diff_buf_win_enter = function()
            -- vim.opt_local.foldenable = false
          end,
        },
      })
    end,
  },
}
