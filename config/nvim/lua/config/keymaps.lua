-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here
local snacks = require("snacks.picker")

-- H/L → start/end of line (replacing default top/bottom of screen behavior)
vim.keymap.set({ "n", "v" }, "H", "^", { desc = "Start of line" })
vim.keymap.set({ "n", "v" }, "L", "$", { desc = "End of line" })

vim.keymap.set("n", "<leader>fh", snacks.git_status, { desc = "Git Changed Files" })

-- C-h/j/k/l move across nvim splits, then across herdr-app panes at an edge (its terminals set HC_TERMINAL_ID).
-- Set here, not in after/plugin, because LazyVim maps C-h/j/k/l to plain window moves on VeryLazy.
local function nav(wincmd, dir)
	local prev = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. wincmd)
	if vim.api.nvim_get_current_win() ~= prev then
		return
	end

	if vim.env.HC_TERMINAL_ID and vim.env.HC_TERMINAL_ID ~= "" then
		vim.fn.system({ "herdr-app", "do", "pane.go:" .. dir })
	end
end

local function map(lhs, wincmd, dir, desc)
	vim.keymap.set("n", lhs, function()
		nav(wincmd, dir)
	end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left")
map("<C-j>", "j", "down", "Navigate down")
map("<C-k>", "k", "up", "Navigate up")
map("<C-l>", "l", "right", "Navigate right")
