-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local snacks = require("snacks.picker")

vim.keymap.set("n", "<leader>fh", snacks.git_status, { desc = "Git Changed Files" })
vim.keymap.set("n", "<leader>h", snacks.git_status, { desc = "Git Changed Files)" })
vim.keymap.set("n", "<c-h>", snacks.git_status, { desc = "Git Changed Files)" })

vim.keymap.set("n", "<c-p>", snacks.buffers, { desc = "Recent Files" })

vim.keymap.set("n", "<c-j>", function()
  Snacks.picker.lsp_symbols({ layout = { preset = "vscode", preview = "main" } })
end, { desc = "LSP Symbols" })

vim.keymap.set("n", "<c-l>", snacks.grep, { desc = "Grep" })
