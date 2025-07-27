-- You can also add or configure plugins by creating files in this `plugins/` folder
-- Here are some examples:

---@type LazySpec
return {

  -- == Examples of Adding Plugins ==

  -- Claude Code AI assistant plugin
  {
    "greggh/claude-code.nvim",
    dependencies = {
      "nvim-lua/plenary.nvim", -- Required for git operations
    },
    event = "VeryLazy",
    config = function()
      require("claude-code").setup {
        -- Terminal window settings
        window = {
          split_ratio = 0.4, -- 40% of screen for the terminal window
          position = "botright", -- Bottom right position
          enter_insert = true, -- Enter insert mode when opening Claude Code
          hide_numbers = true, -- Hide line numbers in the terminal window
          hide_signcolumn = true, -- Hide the sign column in the terminal window
        },
        -- File refresh settings
        refresh = {
          enable = true, -- Enable file change detection
          updatetime = 100, -- updatetime when Claude Code is active (milliseconds)
          timer_interval = 1000, -- How often to check for file changes (milliseconds)
          show_notifications = true, -- Show notification when files are reloaded
        },
        -- Git project settings
        git = {
          use_git_root = true, -- Set CWD to git root when opening Claude Code (if in git project)
        },
        -- Command settings
        command = "claude", -- Command used to launch Claude Code
        -- Command variants
        command_variants = {
          continue = "--continue", -- Resume the most recent conversation
          resume = "--resume", -- Display an interactive conversation picker
          verbose = "--verbose", -- Enable verbose logging with full turn-by-turn output
        },
        -- Keymaps
        keymaps = {
          toggle = {
            normal = "<C-,>", -- Normal mode keymap for toggling Claude Code
            terminal = "<C-,>", -- Terminal mode keymap for toggling Claude Code
            variants = {
              continue = "<leader>cC", -- Normal mode keymap for Claude Code with continue flag
              verbose = "<leader>cV", -- Normal mode keymap for Claude Code with verbose flag
            },
          },
          window_navigation = true, -- Enable window navigation keymaps (<C-h/j/k/l>)
          scrolling = true, -- Enable scrolling keymaps (<C-f/b>) for page up/down
        },
      }
    end,
    cmd = { "ClaudeCode", "ClaudeCodeContinue", "ClaudeCodeResume", "ClaudeCodeVerbose" },
    keys = {
      { "<leader>ac", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<C-,>", "<cmd>ClaudeCode<cr>", desc = "Toggle Claude Code" },
      { "<leader>cC", "<cmd>ClaudeCodeContinue<cr>", desc = "Claude Code Continue" },
      { "<leader>cV", "<cmd>ClaudeCodeVerbose<cr>", desc = "Claude Code Verbose" },
    },
  },

  "andweeb/presence.nvim",
  {
    "ray-x/lsp_signature.nvim",
    event = "BufRead",
    config = function() require("lsp_signature").setup() end,
  },

  -- Rainbow brackets/delimiters
  {
    "HiPhish/rainbow-delimiters.nvim",
    dependencies = "nvim-treesitter/nvim-treesitter",
    event = "User AstroFile",
    config = function()
      local rainbow_delimiters = require "rainbow-delimiters"

      -- SilkCircuit rainbow colors
      vim.api.nvim_set_hl(0, "RainbowDelimiterRed", { fg = "#ff79c6" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterYellow", { fg = "#f1fa8c" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterBlue", { fg = "#80ffea" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterOrange", { fg = "#ffb86c" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterGreen", { fg = "#50fa7b" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterViolet", { fg = "#bd93f9" })
      vim.api.nvim_set_hl(0, "RainbowDelimiterCyan", { fg = "#8be9fd" })

      vim.g.rainbow_delimiters = {
        strategy = {
          [""] = rainbow_delimiters.strategy["global"],
          vim = rainbow_delimiters.strategy["local"],
        },
        query = {
          [""] = "rainbow-delimiters",
          lua = "rainbow-blocks",
        },
        highlight = {
          "RainbowDelimiterRed",
          "RainbowDelimiterYellow",
          "RainbowDelimiterBlue",
          "RainbowDelimiterOrange",
          "RainbowDelimiterGreen",
          "RainbowDelimiterViolet",
          "RainbowDelimiterCyan",
        },
      }
    end,
  },

  -- == Examples of Overriding Plugins ==

  -- customize alpha options
  {
    "goolord/alpha-nvim",
    opts = function(_, opts)
      -- customize the dashboard header
      opts.section.header.val = {
        " █████  ███████ ████████ ██████   ██████",
        "██   ██ ██         ██    ██   ██ ██    ██",
        "███████ ███████    ██    ██████  ██    ██",
        "██   ██      ██    ██    ██   ██ ██    ██",
        "██   ██ ███████    ██    ██   ██  ██████",
        " ",
        "    ███    ██ ██    ██ ██ ███    ███",
        "    ████   ██ ██    ██ ██ ████  ████",
        "    ██ ██  ██ ██    ██ ██ ██ ████ ██",
        "    ██  ██ ██  ██  ██  ██ ██  ██  ██",
        "    ██   ████   ████   ██ ██      ██",
      }
      -- Apply SilkCircuit highlight groups
      opts.section.header.opts.hl = "AlphaHeader"
      -- For button shortcuts (like [f] for find file)
      for _, button in ipairs(opts.section.buttons.val) do
        button.opts.hl_shortcut = "AlphaButtonShortcut"
      end
      opts.section.footer.opts.hl = "AlphaFooter"
      return opts
    end,
  },

  -- You can disable default plugins as follows:
  { "max397574/better-escape.nvim", enabled = false },

  -- You can also easily customize additional setup of plugins that is outside of the plugin's setup call
  {
    "L3MON4D3/LuaSnip",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.luasnip"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom luasnip configuration such as filetype extend or custom snippets
      local luasnip = require "luasnip"
      luasnip.filetype_extend("javascript", { "javascriptreact" })
    end,
  },

  {
    "windwp/nvim-autopairs",
    config = function(plugin, opts)
      require "astronvim.plugins.configs.nvim-autopairs"(plugin, opts) -- include the default astronvim config that calls the setup call
      -- add more custom autopairs configuration such as custom rules
      local npairs = require "nvim-autopairs"
      local Rule = require "nvim-autopairs.rule"
      local cond = require "nvim-autopairs.conds"
      npairs.add_rules(
        {
          Rule("$", "$", { "tex", "latex" })
            -- don't add a pair if the next character is %
            :with_pair(cond.not_after_regex "%%")
            -- don't add a pair if  the previous character is xxx
            :with_pair(
              cond.not_before_regex("xxx", 3)
            )
            -- don't move right when repeat character
            :with_move(cond.none())
            -- don't delete if the next character is xx
            :with_del(cond.not_after_regex "xx")
            -- disable adding a newline when you press <cr>
            :with_cr(cond.none()),
        },
        -- disable for .vim files, but it work for another filetypes
        Rule("a", "a", "-vim")
      )
    end,
  },
}
