-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local snacks = require("snacks.picker")

vim.keymap.set("n", "<leader>fh", snacks.git_status, { desc = "Git Changed Files (Snacks picker)" })
