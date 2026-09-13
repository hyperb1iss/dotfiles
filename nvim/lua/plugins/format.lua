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
    opts = function(_, opts)
      opts.linters_by_ft = vim.tbl_extend("force", opts.linters_by_ft or {}, {
        markdown = { "markdownlint-cli2" },
        yaml = { "yamllint" },
      })
      -- selene reads stdin and looks for selene.toml in the cwd, which is
      -- rarely the directory that holds it. Hand it the nearest one instead.
      opts.linters = opts.linters or {}
      -- The lua pack's condition already requires a selene.toml above the
      -- file, so the lookup always resolves when this runs.
      opts.linters.selene = vim.tbl_deep_extend("force", opts.linters.selene or {}, {
        args = {
          "--display-style",
          "json",
          "--config",
          function() return vim.fs.find("selene.toml", { path = vim.api.nvim_buf_get_name(0), upward = true })[1] end,
          "-",
        },
      })
    end,
  },
}
