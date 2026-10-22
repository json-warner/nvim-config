local option = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

option.number = true
option.relativenumber = true
option.signcolumn = "yes"
option.cursorline = true
option.scrolloff = 8
option.wrap = false
option.foldlevel = 99

option.expandtab = true
option.shiftwidth = 2
option.tabstop = 2
option.smartindent = true

option.ignorecase = true
option.smartcase = true
option.incsearch = true
option.hlsearch = true

option.splitright = true
option.splitbelow = true
option.termguicolors = true
option.clipboard = "unnamedplus"
option.undofile = true
option.updatetime = 250
option.timeoutlen = 1000
option.completeopt = { "menuone", "noselect", "popup" }
