-- Tools the language packs don't already pull in. AstroNvim installs this
-- list through mason-tool-installer; mason.nvim itself has no ensure_installed.

---@type LazySpec
return {
  {
    "WhoIsSethDaniel/mason-tool-installer.nvim",
    opts = function(_, opts)
      opts.ensure_installed = require("astrocore").list_insert_unique(opts.ensure_installed, {
        "prettierd",
        "markdownlint-cli2",
        "yamllint",
      })
    end,
  },
}
