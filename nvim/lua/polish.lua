-- Runs last. Plain Lua for anything that doesn't fit a plugin spec.

vim.opt.guifont = "PragmataPro Mono Liga:h14"
vim.opt.linespace = 1

if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0
  vim.g.neovide_cursor_trail_size = 0
end
