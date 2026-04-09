-- Treesitter — nvim-treesitter is archived; Neovim 0.12 has treesitter built-in.
-- Parsers are now managed via `vim.treesitter.install` or `:TSInstall`.

---@type LazySpec
return {
  { "nvim-treesitter/nvim-treesitter", enabled = false },
  { "nvim-treesitter/nvim-treesitter-textobjects", enabled = false },
  { "stevearc/aerial.nvim", enabled = false },
}
