-- AstroNvim core plugins this setup replaces.

---@type LazySpec
return {
  { "nvimtools/none-ls.nvim", enabled = false }, -- conform + nvim-lint
  { "jay-babu/mason-null-ls.nvim", enabled = false },
  { "akinsho/toggleterm.nvim", enabled = false }, -- snacks terminal and lazygit
}
