-- Customize Treesitter

---@type LazySpec
return {
  {
    "nvim-treesitter/nvim-treesitter",
    branch = "main",
    main = "nvim-treesitter",
    dependencies = {
      { "nvim-treesitter/nvim-treesitter-textobjects", branch = "main" },
    },
    config = function(_, opts) require("nvim-treesitter").setup(opts) end,
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
  },
}
