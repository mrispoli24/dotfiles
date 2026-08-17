-- Keymaps are automatically loaded on the VeryLazy event
-- Default keymaps that are always set: https://github.com/LazyVim/LazyVim/blob/main/lua/lazyvim/config/keymaps.lua
-- Add any additional keymaps here

vim.keymap.set("n", "<c-k>", ":wincmd k<CR>", { desc = "Move to window above" })
vim.keymap.set("n", "<c-j>", ":wincmd j<CR>", { desc = "Move to window below" })
vim.keymap.set("n", "<c-h>", ":wincmd h<CR>", { desc = "Move to window left" })
vim.keymap.set("n", "<c-l>", ":wincmd l<CR>", { desc = "Move to window right" })
