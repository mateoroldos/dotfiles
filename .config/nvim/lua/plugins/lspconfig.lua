return {
  {
    "neovim/nvim-lspconfig",
    opts = {
      servers = {
        vtsls = {
          settings = {
            typescript = {
              referencesCodeLens = { enabled = true },
              implementationsCodeLens = { enabled = true },
            },
            javascript = {
              referencesCodeLens = { enabled = true },
              implementationsCodeLens = { enabled = true },
            },
          },
        },
      },
    },
    keys = {
      {
        "<leader>cL",
        function()
          if vim.g.codelens_enabled == false then
            vim.g.codelens_enabled = true
            vim.lsp.codelens.refresh()
          else
            vim.g.codelens_enabled = false
            vim.lsp.codelens.clear()
          end
        end,
        desc = "Toggle CodeLens",
      },
    },
  },
}
