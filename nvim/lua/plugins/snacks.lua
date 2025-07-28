return {
  "folke/snacks.nvim",
  priority = 1000,
  lazy = false,
  ---@type snacks.Config
  opts = {
    -- Enable the features you want
    bigfile = { enabled = true },
    dashboard = {
      enabled = true,
      preset = {
        header = [[
███████╗██╗██╗     ██╗  ██╗ ██████╗██╗██████╗  ██████╗██╗   ██╗██╗████████╗
██╔════╝██║██║     ██║ ██╔╝██╔════╝██║██╔══██╗██╔════╝██║   ██║██║╚══██╔══╝
███████╗██║██║     █████╔╝ ██║     ██║██████╔╝██║     ██║   ██║██║   ██║   
╚════██║██║██║     ██╔═██╗ ██║     ██║██╔══██╗██║     ██║   ██║██║   ██║   
███████║██║███████╗██║  ██╗╚██████╗██║██║  ██║╚██████╗╚██████╔╝██║   ██║   
╚══════╝╚═╝╚══════╝╚═╝  ╚═╝ ╚═════╝╚═╝╚═╝  ╚═╝ ╚═════╝ ╚═════╝ ╚═╝   ╚═╝   
        ]],
        keys = {
          { icon = " ", key = "f", desc = "Find File", action = ":lua Snacks.picker.files()" },
          { icon = " ", key = "n", desc = "New File", action = ":ene | startinsert" },
          { icon = " ", key = "g", desc = "Find Text", action = ":lua Snacks.picker.grep()" },
          { icon = " ", key = "r", desc = "Recent Files", action = ":lua Snacks.picker.recent()" },
          {
            icon = " ",
            key = "c",
            desc = "Config",
            action = ":lua Snacks.picker.files({ cwd = vim.fn.stdpath('config') })",
          },
          { icon = " ", key = "s", desc = "Restore Session", action = [[<cmd>lua require("persistence").load()<cr>]] },
          { icon = "󰒲 ", key = "l", desc = "Lazy", action = ":Lazy" },
          { icon = " ", key = "q", desc = "Quit", action = ":qa" },
        },
      },
    },
    indent = {
      enabled = true,
      scope = {
        enabled = true,
        char = "│",
        hl = "SnacksIndentScope",
      },
    },
    input = { enabled = true },
    notifier = {
      enabled = true,
      timeout = 3000,
    },
    picker = {
      enabled = true,
      -- Use telescope-style mappings
      mappings = {
        i = {
          ["<C-j>"] = "move_down",
          ["<C-k>"] = "move_up",
        },
      },
    },
    profiler = { enabled = true },
    quickfile = { enabled = true },
    scope = { enabled = true },
    scroll = {
      enabled = false,
    },
    statuscolumn = { enabled = false }, -- Keep AstroNvim's statuscolumn
    terminal = {
      enabled = true,
      win = {
        position = "bottom",
        height = 0.3,
      },
    },
    words = {
      enabled = true,
      debounce = 200,
    },
  },
  keys = {
    { "<leader>un", function() Snacks.notifier.hide() end, desc = "Dismiss All Notifications" },
    { "<leader>bd", function() Snacks.bufdelete() end, desc = "Delete Buffer" },
    { "<leader>gg", function() Snacks.gitbrowse() end, desc = "Git Browse" },
    { "<leader>gb", function() Snacks.git.blame_line() end, desc = "Git Blame Line" },
    {
      "<leader>gB",
      function()
        Snacks.gitbrowse { open = function(url) vim.fn.system { "open", url } end }
      end,
      desc = "Git Browse (open)",
    },
    { "<leader>gf", function() Snacks.lazygit.log_file() end, desc = "Lazygit Current File History" },
    { "<leader>gl", function() Snacks.lazygit() end, desc = "Lazygit" },
    { "<leader>gL", function() Snacks.lazygit.log() end, desc = "Lazygit Log (cwd)" },
    { "<leader>pd", function() Snacks.profiler.scratch() end, desc = "Profiler Scratch Buffer" },
    { "<leader>ps", function() Snacks.profiler.start() end, desc = "Profiler Start" },
    { "<leader>ph", function() Snacks.profiler.stop() end, desc = "Profiler Stop" },
    { "<C-t>", function() Snacks.terminal.toggle() end, desc = "Toggle Terminal", mode = { "n", "t" } },
    { "]]", function() Snacks.words.jump(vim.v.count1) end, desc = "Next Reference" },
    { "[[", function() Snacks.words.jump(-vim.v.count1) end, desc = "Prev Reference" },
  },
  init = function()
    vim.api.nvim_create_autocmd("User", {
      pattern = "VeryLazy",
      callback = function()
        -- Setup some globals for debugging (lazy-loaded)
        _G.dd = function(...) Snacks.debug.inspect(...) end
        _G.bt = function() Snacks.debug.backtrace() end
        vim.print = _G.dd
      end,
    })
  end,
}
