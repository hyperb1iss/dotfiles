-- AstroLSP: language server behavior. `:h astrolsp`
-- Formatting is conform's job (the community recipe disables LSP formatting).

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    features = {
      codelens = true,
      inlay_hints = false,
      semantic_tokens = true,
    },
    mappings = {
      n = {
        gD = {
          function() vim.lsp.buf.declaration() end,
          desc = "Declaration of current symbol",
          cond = "textDocument/declaration",
        },
        ["<Leader>uH"] = {
          function() vim.lsp.inlay_hint.enable(not vim.lsp.inlay_hint.is_enabled { bufnr = 0 }, { bufnr = 0 }) end,
          desc = "Toggle inlay hints (buffer)",
          cond = "textDocument/inlayHint",
        },
      },
    },
  },
}
