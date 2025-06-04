-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<leader>r", "<cmd>CodeCompanionChat<CR>", { desc = "Open CodeCompanion Chat" })

-- Override default telescope commands to show hidden files but exclude .git
vim.keymap.set("n", "<leader><space>", function()
  require("telescope.builtin").find_files({
    hidden = true,
    file_ignore_patterns = { "%.git/" },
  })
end, { desc = "Find Files (Root Dir)" })

vim.keymap.set("n", "<leader>ff", function()
  require("telescope.builtin").find_files({
    hidden = true,
    file_ignore_patterns = { "%.git/" },
  })
end, { desc = "Find Files (Root Dir)" })

vim.keymap.set("n", "<leader>fF", function()
  require("telescope.builtin").find_files({
    cwd = false,
    hidden = true,
    file_ignore_patterns = { "%.git/" },
  })
end, { desc = "Find Files (cwd)" })

vim.keymap.set("n", "<leader>/", function()
  require("telescope.builtin").live_grep({
    additional_args = function()
      return { "--hidden", "--glob", "!.git/*" }
    end,
  })
end, { desc = "Grep (Root Dir)" })

vim.keymap.set("n", "<leader>sg", function()
  require("telescope.builtin").live_grep({
    additional_args = function()
      return { "--hidden", "--glob", "!.git/*" }
    end,
  })
end, { desc = "Grep (Root Dir)" })

vim.keymap.set("n", "<leader>sG", function()
  require("telescope.builtin").live_grep({
    cwd = false,
    additional_args = function()
      return { "--hidden", "--glob", "!.git/*" }
    end,
  })
end, { desc = "Grep (cwd)" })
