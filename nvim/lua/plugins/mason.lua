-- Customize Mason plugins

---@type LazySpec
return {
  -- mason.nvim v2 handles ensure_installed natively
  {
    "williamboman/mason.nvim",
    opts = {
      ensure_installed = {
        -- LSP servers
        "lua-language-server",
        "typescript-language-server",
        "eslint-lsp",
        "biome",
        "vue-language-server",
        "html-lsp",
        "css-lsp",
        "json-lsp",
        "tailwindcss-language-server",
        "graphql-language-service-cli",
        -- Formatters and linters
        "stylua",
        "prettier",
        "prettierd",
        "markdownlint",
        "yamllint",
      },
    },
  },
  -- use mason-lspconfig to auto-install LSP servers when configured
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      automatic_installation = true,
    },
  },
  -- use mason-null-ls for automatic null-ls source installation
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      automatic_installation = true,
    },
  },
  {
    "jay-babu/mason-nvim-dap.nvim",
    -- overrides `require("mason-nvim-dap").setup(...)`
    opts = {
      ensure_installed = {
        "python",
        -- TypeScript/JavaScript debugger
        "js", -- Node.js debugger (works for TypeScript too)
      },
    },
  },
}
