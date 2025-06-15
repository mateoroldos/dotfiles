return {
  "vimwiki/vimwiki",
  event = "BufEnter *.md", -- Lazy-load Vimwiki when entering markdown files
  keys = { "<leader>ww", "<leader>wt" }, -- Optional key bindings to trigger Vimwiki commands
  init = function()
    vim.g.vimwiki_list = {
      {
        path = "~/vimwiki/", -- Path to your wiki directory
        syntax = "markdown",
        ext = "md",
      },
    }
  end,
}
