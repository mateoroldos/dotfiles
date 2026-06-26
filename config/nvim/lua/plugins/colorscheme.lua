return {
	"Aejkatappaja/cendre",
	lazy = false,
	priority = 1000,
	config = function()
		require("cendre").setup({
			background = "soft",
			italic_virtual_text = false,
		})
		vim.cmd.colorscheme("cendre")
	end,
}
