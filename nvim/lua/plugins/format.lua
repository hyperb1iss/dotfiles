-- conform formats, nvim-lint lints. Language packs register their own
-- entries (ruff, shfmt, stylua); this covers the web and docs filetypes.

---@type LazySpec
return {
  {
    "stevearc/conform.nvim",
    opts = function(_, opts)
      local prettier = { "prettierd", "prettier", stop_after_first = true }
      opts.formatters_by_ft = vim.tbl_extend("force", opts.formatters_by_ft or {}, {
        javascript = prettier,
        javascriptreact = prettier,
        typescript = prettier,
        typescriptreact = prettier,
        json = prettier,
        jsonc = prettier,
        css = prettier,
        scss = prettier,
        html = prettier,
        yaml = prettier,
        markdown = prettier,
      })
    end,
  },
  {
    "mfussenegger/nvim-lint",
    opts = {
      linters_by_ft = {
        markdown = { "markdownlint-cli2" },
        yaml = { "yamllint" },
      },
    },
  },
}
