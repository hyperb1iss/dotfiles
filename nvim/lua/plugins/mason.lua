-- Customize Mason plugins

---@type LazySpec
return {
  -- use mason-lspconfig to configure LSP installations
  {
    "williamboman/mason-lspconfig.nvim",
    -- overrides `require("mason-lspconfig").setup(...)`
    opts = {
      ensure_installed = {
        "lua_ls",
        -- TypeScript/JavaScript language servers
        "ts_ls", -- TypeScript Language Server (previously typescript-language-server)
        "eslint", -- ESLint language server
        "biome", -- Biome - Fast formatter and linter for JS/TS
        "volar", -- Vue language server (if you work with Vue)
        -- Other useful language servers
        "html",
        "cssls",
        "jsonls",
        "tailwindcss",
        "graphql",
      },
    },
  },
  -- use mason-null-ls to configure Formatters/Linter installation for null-ls sources
  {
    "jay-babu/mason-null-ls.nvim",
    -- overrides `require("mason-null-ls").setup(...)`
    opts = {
      ensure_installed = {
        "stylua",
        -- TypeScript/JavaScript formatters and linters
        "biome", -- Biome for formatting and linting
        "prettier", -- Code formatter for JS/TS/CSS/HTML/JSON/etc
        "prettierd", -- Faster prettier daemon
        -- Additional tools
        "markdownlint",
        "yamllint",
      },
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
