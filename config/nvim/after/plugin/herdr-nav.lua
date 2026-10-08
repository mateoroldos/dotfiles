-- vim-herdr-navigation: seamless C-h/j/k/l across nvim splits and herdr panes.
-- Loaded via after/plugin so it runs after all plugins and its mappings always win.

local function nav(wincmd, dir)
	local prev = vim.api.nvim_get_current_win()
	vim.cmd("wincmd " .. wincmd)
	if vim.api.nvim_get_current_win() ~= prev then
		return
	end
	if vim.env.HERDR_PANE_ID and vim.env.HERDR_PANE_ID ~= "" then
		local herdr = vim.env.HERDR_BIN_PATH or "herdr"
		vim.fn.system({ herdr, "pane", "focus", "--direction", dir, "--current" })
	end
end

local function map(lhs, wincmd, dir, desc)
	pcall(vim.keymap.del, "n", lhs)
	vim.keymap.set("n", lhs, function()
		nav(wincmd, dir)
	end, { silent = true, noremap = true, desc = desc })
end

map("<C-h>", "h", "left", "Navigate left")
map("<C-j>", "j", "down", "Navigate down")
map("<C-k>", "k", "up", "Navigate up")
map("<C-l>", "l", "right", "Navigate right")
