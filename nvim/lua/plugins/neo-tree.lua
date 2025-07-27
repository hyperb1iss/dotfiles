return {
  "nvim-neo-tree/neo-tree.nvim",
  opts = {
    filesystem = {
      filtered_items = {
        visible = false, -- This needs to be false to actually hide items
        hide_dotfiles = false, -- Show dotfiles
        hide_gitignored = true, -- Hide gitignored files
        hide_by_name = {
          "node_modules",
          ".git",
        },
      },
      follow_current_file = {
        enabled = true,
      },
    },
  },
}