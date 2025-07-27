-- Customize None-ls sources

---@type LazySpec
return {
  "nvimtools/none-ls.nvim",
  opts = function(_, opts)
    -- opts variable is the default configuration table for the setup function call
    local null_ls = require "null-ls"

    -- Check supported formatters and linters
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/formatting
    -- https://github.com/nvimtools/none-ls.nvim/tree/main/lua/null-ls/builtins/diagnostics

    -- Only insert new sources, do not replace the existing ones
    -- (If you wish to replace, use `opts.sources = {}` instead of the `list_insert_unique` function)
    opts.sources = require("astrocore").list_insert_unique(opts.sources, {
      -- Prettier for YAML formatting (and other files)
      null_ls.builtins.formatting.prettier.with {
        filetypes = { "yaml", "yml", "json", "jsonc", "markdown", "html", "css", "scss", "javascript", "typescript" },
      },
      -- Keep yamllint for structural validation
      null_ls.builtins.diagnostics.yamllint,
      -- Stylua for Lua formatting
      null_ls.builtins.formatting.stylua,
    })
  end,
}
