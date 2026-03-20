return {
  "ghillb/cybu.nvim",
  branch = "main",
  dependencies = { "nvim-tree/nvim-web-devicons", "nvim-lua/plenary.nvim" },
  keys = {
    { "<C-S-p>", "<Plug>(CybuLastusedPrev)", mode = { "n", "v" }, desc = "Cybu Prev" },
    { "<C-p>", "<Plug>(CybuLastusedNext)", mode = { "n", "v" }, desc = "Cybu Next" },
  },
  opts = {},
}
