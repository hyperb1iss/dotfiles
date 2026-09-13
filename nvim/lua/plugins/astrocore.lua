-- AstroCore: options, mappings, autocmds, treesitter. `:h astrocore`

---@type LazySpec
return {
  "AstroNvim/astrocore",
  ---@type AstroCoreOpts
  opts = {
    features = {
      large_buf = { size = 1024 * 256, lines = 10000 },
      diagnostics = { virtual_text = true, virtual_lines = false },
    },
    options = {
      opt = {
        scrolloff = 6,
        sidescrolloff = 8,
      },
      g = {
        -- conform's format-on-save honors this; <Leader>uF flips it live
        autoformat = false,
      },
    },
    treesitter = {
      ensure_installed = {
        "vim",
        "vimdoc",
        "query",
        "regex",
        "diff",
        "gitcommit",
        "git_rebase",
        "git_config",
        "gitignore",
        "ini",
        "ssh_config",
        "powershell",
      },
    },
    mappings = {
      n = {
        ["<Leader>a"] = { desc = "󰚩 Claude" },
        ["<Leader>O"] = { desc = " Octo" },
        ["<Leader>t"] = { desc = " Terminal" },
      },
    },
    autocmds = {
      yaml_indent = {
        {
          event = "FileType",
          pattern = { "yaml", "yml" },
          desc = "Plain autoindent for YAML, smartindent fights the nesting",
          callback = function()
            vim.opt_local.smartindent = false
            vim.opt_local.indentexpr = ""
            vim.opt_local.shiftwidth = 2
            vim.opt_local.tabstop = 2
            vim.opt_local.softtabstop = 2
            vim.opt_local.expandtab = true
          end,
        },
      },
    },
  },
}
