-- Claude Code IDE bridge. Claude itself runs in a herdr pane; this only
-- hosts the WebSocket server that `/ide` attaches to, so selections, open
-- files and diagnostics flow to Claude and its diffs open here for review.

---@type LazySpec
return {
  "coder/claudecode.nvim",
  dependencies = { "folke/snacks.nvim" },
  event = "VeryLazy",
  opts = {
    terminal = { provider = "none" },
    diff_opts = {
      layout = "vertical",
      open_in_new_tab = true,
    },
  },
  keys = {
    { "<Leader>as", "<Cmd>ClaudeCodeSend<CR>", mode = "v", desc = "Send selection to Claude" },
    { "<Leader>ab", "<Cmd>ClaudeCodeAdd %<CR>", desc = "Add buffer to Claude" },
    { "<Leader>as", "<Cmd>ClaudeCodeTreeAdd<CR>", desc = "Add file to Claude", ft = { "neo-tree" } },
    { "<Leader>aa", "<Cmd>ClaudeCodeDiffAccept<CR>", desc = "Accept Claude diff" },
    { "<Leader>ad", "<Cmd>ClaudeCodeDiffDeny<CR>", desc = "Deny Claude diff" },
    { "<Leader>ai", "<Cmd>ClaudeCodeStatus<CR>", desc = "Claude connection status" },
  },
}
