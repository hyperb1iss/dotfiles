-- herdr-nvim: annotate lines or selections and hand the notes to the agent
-- in the neighboring herdr pane. The herdr side of the plugin (sidebar and
-- file picker) is installed with `herdr plugin install ChmaraX/herdr-nvim`.
-- Shares the <Leader>a agents group with claudecode.

---@type LazySpec
return {
  "ChmaraX/herdr-nvim",
  enabled = vim.env.HERDR_ENV == "1",
  event = "VeryLazy",
  cmd = "Herdr",
  opts = {
    prefix = "<Leader>a",
  },
}
