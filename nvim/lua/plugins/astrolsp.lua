-- AstroLSP: language server behavior. `:h astrolsp`
-- The defaults fit; formatting is conform's job (the community recipe
-- disables LSP formatting). Server-specific config goes in `opts.config`.

---@type LazySpec
return {
  "AstroNvim/astrolsp",
  ---@type AstroLSPOpts
  opts = {
    config = {},
  },
}
