-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local snacks = require("snacks.picker")

-- H/L → start/end of line (replacing default top/bottom of screen behavior)
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "End of line" })

vim.keymap.set("n", "<leader>fh", snacks.git_status, { desc = "Git Changed Files" })
