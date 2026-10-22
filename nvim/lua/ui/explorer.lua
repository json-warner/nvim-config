-- Project explorer (neo-tree). Empty intermediate folders are collapsed so
-- Java packages read as com.example.service instead of nested directories.
vim.pack.add({
  { src = "https://github.com/nvim-lua/plenary.nvim" },
  { src = "https://github.com/MunifTanjim/nui.nvim" },
  { src = "https://github.com/nvim-tree/nvim-web-devicons" },
  { src = "https://github.com/nvim-neo-tree/neo-tree.nvim", version = "v3.x" },
})

require("neo-tree").setup({
  close_if_last_window = true,
  filesystem = {
    group_empty_dirs = true,
    follow_current_file = { enabled = true },
    filtered_items = {
      hide_dotfiles = false,
      hide_by_name = { ".git", ".gradle", ".idea", "build", "target", "bin" },
    },
  },
  window = { width = 40 },
})

vim.keymap.set("n", "<leader>t", "<cmd>Neotree toggle reveal<CR>", { desc = "Toggle project explorer" })
