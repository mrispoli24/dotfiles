-- Load the current Omarchy theme dynamically on each machine.
-- Keep this as a regular Lua file instead of a symlink so the dotfiles repo is
-- portable across hosts and home-directory layouts.
local theme = vim.fn.expand("~/.local/state/omarchy/current/theme/neovim.lua")

if vim.fn.filereadable(theme) == 1 then
  return dofile(theme)
end

-- Safe fallback if Omarchy has not generated a current theme yet.
return {
  { "LazyVim/LazyVim", opts = { colorscheme = "tokyonight" } },
  { "folke/tokyonight.nvim" },
}
