-- Common plugins only. Language/database plugins are added by their own
-- modules (lsp/*, database/*) when first needed.
vim.pack.add({
  { src = "https://github.com/neovim/nvim-lspconfig" },
})

vim.cmd.colorscheme("devstyle")
