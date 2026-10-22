-- Breadcrumbs (dropbar: package > class > method via LSP) and toasts
-- (fidget: LSP progress such as jdtls indexing, plus vim.notify messages).
vim.pack.add({
  { src = "https://github.com/Bekaboo/dropbar.nvim" },
  { src = "https://github.com/j-hui/fidget.nvim" },
})

require("fidget").setup({
  notification = {
    override_vim_notify = true,
    window = { winblend = 0 },
  },
})

require("ui.explorer")

-- Jump into the breadcrumb bar to pick a symbol or sibling.
vim.keymap.set("n", "<leader>;", function()
  require("dropbar.api").pick()
end, { desc = "Pick breadcrumb" })
