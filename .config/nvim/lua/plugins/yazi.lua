return {
  {
    "mikavilpas/yazi.nvim",
    event = "VeryLazy",
    keys = {
      { "<leader>fy", "<cmd>Yazi<cr>", desc = "Open Yazi File Manager" },
    },
    opts = {
      open_for_directories = false,
      keymaps = {
        show_help = "<F1>",
      },
    },
    init = function()
      vim.g.loaded_netrw = 1
      vim.g.loaded_netrwPlugin = 1
    end,
  },
}
