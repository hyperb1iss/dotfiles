-- GitHub issues and PRs without leaving the editor.

---@type LazySpec
return {
  "pwntester/octo.nvim",
  dependencies = { "nvim-lua/plenary.nvim", "folke/snacks.nvim", "nvim-tree/nvim-web-devicons" },
  cmd = "Octo",
  event = { { event = "BufReadCmd", pattern = "octo://*" } },
  opts = {
    picker = "snacks",
    enable_builtin = true,
    default_to_projects_v2 = true,
    suppress_missing_scope = { projects_v2 = true },
    issues = { order_by = { field = "UPDATED_AT", direction = "DESC" } },
    pull_requests = { order_by = { field = "UPDATED_AT", direction = "DESC" } },
  },
  keys = {
    { "<Leader>Oo", "<Cmd>Octo<CR>", desc = "Octo picker" },
    { "<Leader>Oi", "<Cmd>Octo issue list<CR>", desc = "Issues" },
    { "<Leader>OI", "<Cmd>Octo issue search<CR>", desc = "Search issues" },
    { "<Leader>Op", "<Cmd>Octo pr list<CR>", desc = "Pull requests" },
    { "<Leader>OP", "<Cmd>Octo pr search<CR>", desc = "Search pull requests" },
    { "<Leader>Or", "<Cmd>Octo review start<CR>", desc = "Start review" },
    { "<Leader>Oa", "<Cmd>Octo actions<CR>", desc = "Actions" },
    { "<Leader>On", "<Cmd>Octo notification list<CR>", desc = "Notifications" },
  },
}
