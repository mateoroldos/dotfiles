return {
  "folke/snacks.nvim",
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
