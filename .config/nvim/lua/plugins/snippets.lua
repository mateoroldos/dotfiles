return {
  "L3MON4D3/LuaSnip",
  dependencies = {
    "rafamadriz/friendly-snippets",
  },
  config = function()
    -- Load friendly-snippets
    require("luasnip.loaders.from_vscode").lazy_load()
    --
    -- Load your custom snippets (if you have any)
    require("luasnip.loaders.from_lua").load({ paths = "./lua/snippets" })
  end,
}
