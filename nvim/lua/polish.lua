-- This will run last in the setup process and is a good place to configure
-- things like custom filetypes. This just pure lua so anything that doesn't
-- fit in the normal config locations above can go here

-- Set GUI font for Neovide, VimR, etc.
vim.opt.guifont = "PragmataPro Mono Liga:h14"
vim.opt.linespace = 1 -- Adds 1 pixel between lines (approximates 1.1 line height)

-- Neovide specific settings
if vim.g.neovide then
  vim.g.neovide_cursor_animation_length = 0 -- Disable cursor animation
  vim.g.neovide_cursor_trail_size = 0 -- Disable cursor trail
end

-- Set up custom filetypes
vim.filetype.add {
  extension = {
    foo = "fooscript",
  },
  filename = {
    ["Foofile"] = "fooscript",
  },
  pattern = {
    ["~/%.config/foo/.*"] = "fooscript",
  },
}
