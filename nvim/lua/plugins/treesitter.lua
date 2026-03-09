-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  main = "nvim-treesitter", -- override AstroNvim's "nvim-treesitter.configs" (removed upstream)
  opts = {
    ensure_installed = {
      "regex",
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "yaml",
      "toml",
      "cpp",
      "rust",
      "go",
      "java",
      "dockerfile",
      "terraform",
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
    },
  },
}
