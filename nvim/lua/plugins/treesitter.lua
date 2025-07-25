-- Customize Treesitter

---@type LazySpec
return {
  "nvim-treesitter/nvim-treesitter",
  opts = {
    ensure_installed = {
      -- Core
      "lua",
      "vim",
      "vimdoc",
      "query",
      "regex",

      -- Web
      "html",
      "css",
      "javascript",
      "typescript",
      "tsx",
      "json",
      "yaml",
      "toml",

      -- Systems
      "c",
      "cpp",
      "rust",
      "go",
      "python",
      "java",

      -- DevOps
      "bash",
      "dockerfile",
      "terraform",

      -- Markup
      "markdown",
      "markdown_inline",

      -- Git
      "git_config",
      "git_rebase",
      "gitattributes",
      "gitcommit",
      "gitignore",
    },

    -- Enable syntax highlighting
    highlight = {
      enable = true,
      additional_vim_regex_highlighting = false,
    },

    -- Enable indentation
    indent = {
      enable = true,
    },

    -- Enable incremental selection
    incremental_selection = {
      enable = true,
    },
  },
}
