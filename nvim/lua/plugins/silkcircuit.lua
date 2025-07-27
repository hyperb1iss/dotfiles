-- SilkCircuit theme configuration
return {
  {
    dir = "~/dev/silkcircuit-nvim",
    name = "silkcircuit",
    lazy = false,
    priority = 1000,
    config = function()
      require("silkcircuit").setup {
        -- Enable all features
        terminal_colors = true,
        compile = false, -- Disable compilation for development

        -- Enable all integrations
        integrations = {
          aerial = true,
          alpha = true,
          cmp = true,
          dap = true,
          dap_ui = true,
          gitsigns = true,
          illuminate = true,
          indent_blankline = true,
          markdown = true,
          mason = true,
          native_lsp = { enabled = true },
          neotree = true,
          notify = true,
          semantic_tokens = true,
          symbols_outline = true,
          telescope = true,
          treesitter = true,
          rainbow_delimiters = true,
          ufo = true,
          which_key = true,
          window_picker = true,
        },

        -- Style customizations
        styles = {
          comments = { italic = true },
          keywords = { bold = true },
          functions = { bold = true, italic = true },
          strings = { italic = true },
          variables = {},
        },
      }
    end,
  },
}
