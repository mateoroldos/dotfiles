return {
  "folke/snacks.nvim",
  keys = {
    { "<leader>gd", false },
    {
      "<leader>gD",
      function()
        Snacks.picker.git_diff()
      end,
      desc = "Git Diff (hunks)",
    },
  },
  opts = {
    explorer = {
      replace_netrw = false,
    },

    picker = {
      hidden = true, -- Show hidden files by default
      -- exclude = { ".git", "node_modules" },
      sources = {
        files = {
          hidden = true,
          ignored = false,
          -- exclude = {
          -- "**/.git/*",
          --},
        },
      },
    },
  },
}
