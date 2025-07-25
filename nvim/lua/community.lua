-- AstroCommunity: import any community modules here
-- We import this file in `lazy_setup.lua` before the `plugins/` folder.
-- This guarantees that the specs are processed before any user plugins.

---@type LazySpec
return {
  "AstroNvim/astrocommunity",
  { import = "astrocommunity.colorscheme.catppuccin" },
  { import = "astrocommunity.pack.lua" },
  { import = "astrocommunity.pack.rust" },
  { import = "astrocommunity.pack.typescript" }, -- TypeScript/JavaScript support
  { import = "astrocommunity.pack.tailwindcss" }, -- TailwindCSS support
  { import = "astrocommunity.pack.html-css" }, -- HTML/CSS support
  { import = "astrocommunity.pack.json" }, -- JSON support
  { import = "astrocommunity.pack.yaml" }, -- YAML support
  { import = "astrocommunity.pack.markdown" }, -- Markdown support

  -- import/override with your plugins folder
}
