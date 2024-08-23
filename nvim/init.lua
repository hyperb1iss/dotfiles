-- Neovim Configuration

-- Run PackerSync to install/update plugins!

-- Basic Settings
vim.o.number = true
vim.o.relativenumber = true
vim.o.wrap = false
vim.o.expandtab = true
vim.o.tabstop = 4
vim.o.shiftwidth = 4
vim.o.smartindent = true
vim.o.termguicolors = true
vim.o.mouse = 'a'
vim.o.clipboard = 'unnamedplus'
vim.o.ignorecase = true
vim.o.smartcase = true
vim.o.undofile = true
vim.o.updatetime = 250
vim.o.signcolumn = 'no'
vim.o.cursorline = false
-- vim.wo.colorcolumn = '80'

-- WSL2 Clipboard Support
if vim.fn.has('wsl') == 1 then
    vim.g.clipboard = {
        name = 'WslClipboard',
        copy = {
            ['+'] = 'clip.exe',
            ['*'] = 'clip.exe',
        },
        paste = {
            ['+'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
            ['*'] = 'powershell.exe -c [Console]::Out.Write($(Get-Clipboard -Raw).tostring().replace("`r", ""))',
        },
        cache_enabled = 0,
    }
else
    vim.o.clipboard = 'unnamedplus'  -- Use system clipboard if not in WSL
end

-- Install packer
local install_path = vim.fn.stdpath 'data' .. '/site/pack/packer/start/packer.nvim'
if vim.fn.empty(vim.fn.glob(install_path)) > 0 then
  vim.fn.execute('!git clone https://github.com/wbthomason/packer.nvim ' .. install_path)
end

-- Plugin setup
require('packer').startup(function(use)
  use 'wbthomason/packer.nvim'
  use 'Mofiqul/dracula.nvim'
  use {
    'nvim-lualine/lualine.nvim',
    requires = { 'kyazdani42/nvim-web-devicons', opt = true }
  }
  use {
    'nvim-treesitter/nvim-treesitter',
    run = ':TSUpdate'
  }
  use {
    'nvim-telescope/telescope.nvim',
    requires = {
      {'nvim-lua/plenary.nvim'},
      {'nvim-telescope/telescope-fzf-native.nvim', run = 'make' }
    }
  }
  use 'neovim/nvim-lspconfig'
  use 'hrsh7th/nvim-cmp'
  use 'hrsh7th/cmp-nvim-lsp'
  use 'hrsh7th/cmp-buffer'
  use 'hrsh7th/cmp-path'
  use 'hrsh7th/cmp-cmdline'
  use 'L3MON4D3/LuaSnip'
  use 'saadparwaiz1/cmp_luasnip'
  use {
    'lewis6991/gitsigns.nvim',
    requires = { 'nvim-lua/plenary.nvim' }
  }
  use 'windwp/nvim-autopairs'
  use 'numToStr/Comment.nvim'
  use 'preservim/vim-markdown'
  use({
    "iamcco/markdown-preview.nvim",
    run = function() vim.fn["mkdp#util#install"]() end,
  })
  use 'onsails/lspkind-nvim'
  use 'ray-x/lsp_signature.help'
  use 'simrat39/rust-tools.nvim'
  use 'mfussenegger/nvim-jdtls'  -- For Java/Kotlin
  use 'lukas-reineke/indent-blankline.nvim'
  use 'norcalli/nvim-colorizer.lua'
  use 'folke/which-key.nvim'
  use 'akinsho/bufferline.nvim'
  use 'kyazdani42/nvim-tree.lua'
  use 'folke/zen-mode.nvim'
  use 'folke/twilight.nvim'
  use 'github/copilot.vim'
  use 'hrsh7th/cmp-copilot'
end)

-- Theme setup
require('dracula').setup {
  transparent_bg = true,
  italic_comment = true,
}

-- Copilot setup
vim.g.copilot_no_tab_map = true
vim.g.copilot_assume_mapped = true
vim.g.copilot_tab_fallback = ""

-- Keybindings
local keymap = vim.api.nvim_set_keymap
local opts = { noremap = true, silent = true }
local expr_opts = { noremap = true, silent = true, expr = true }

keymap('n', '<leader>ff', '<cmd>Telescope find_files<cr>', opts)
keymap('n', '<leader>fg', '<cmd>Telescope live_grep<cr>', opts)
keymap('n', '<leader>fb', '<cmd>Telescope buffers<cr>', opts)
keymap('n', '<leader>fh', '<cmd>Telescope help_tags<cr>', opts)
keymap('n', '<C-n>', ':NvimTreeToggle<CR>', opts)
keymap('n', '<leader>z', ':ZenMode<CR>', opts)
keymap('n', '<leader>w', ':w<CR>', opts)
keymap('n', '<leader>q', ':q<CR>', opts)
keymap('n', '<C-h>', '<C-w>h', opts)
keymap('n', '<C-j>', '<C-w>j', opts)
keymap('n', '<C-k>', '<C-w>k', opts)
keymap('n', '<C-l>', '<C-w>l', opts)
keymap('n', '<leader>mp', '<Plug>MarkdownPreviewToggle', opts)

-- Copilot keybindings
keymap("i", "<C-J>", 'copilot#Accept("<CR>")', expr_opts)
keymap("i", "<C-H>", 'copilot#Previous()', expr_opts)
keymap("i", "<C-K>", 'copilot#Next()', expr_opts)

-- LSP setup
local lspconfig = require('lspconfig')
local servers = { 'pyright', 'rust_analyzer', 'kotlin_language_server' }
for _, lsp in ipairs(servers) do
  lspconfig[lsp].setup {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client, bufnr)
      require "lsp_signature".on_attach({
        bind = true,
        handler_opts = {
          border = "rounded"
        }
      }, bufnr)

      local bufopts = { noremap=true, silent=true, buffer=bufnr }
      vim.keymap.set('n', 'gD', vim.lsp.buf.declaration, bufopts)
      vim.keymap.set('n', 'gd', vim.lsp.buf.definition, bufopts)
      vim.keymap.set('n', 'K', vim.lsp.buf.hover, bufopts)
      vim.keymap.set('n', 'gi', vim.lsp.buf.implementation, bufopts)
      vim.keymap.set('n', '<C-k>', vim.lsp.buf.signature_help, bufopts)
      vim.keymap.set('n', '<space>wa', vim.lsp.buf.add_workspace_folder, bufopts)
      vim.keymap.set('n', '<space>wr', vim.lsp.buf.remove_workspace_folder, bufopts)
      vim.keymap.set('n', '<space>wl', function()
        print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
      end, bufopts)
      vim.keymap.set('n', '<space>D', vim.lsp.buf.type_definition, bufopts)
      vim.keymap.set('n', '<space>rn', vim.lsp.buf.rename, bufopts)
      vim.keymap.set('n', '<space>ca', vim.lsp.buf.code_action, bufopts)
      vim.keymap.set('n', 'gr', vim.lsp.buf.references, bufopts)
      vim.keymap.set('n', '<space>f', function() vim.lsp.buf.format { async = true } end, bufopts)
    end
  }
end

-- Rust-tools setup
require('rust-tools').setup({
  server = {
    capabilities = require('cmp_nvim_lsp').default_capabilities(),
    on_attach = function(client, bufnr)
      require "lsp_signature".on_attach({
        bind = true,
        handler_opts = {
          border = "rounded"
        }
      }, bufnr)
    end
  }
})

-- Copilot status function for lualine
local function copilot_status()
  return vim.fn['copilot#Enabled']() == 1 and " Copilot" or ""
end

-- nvim-cmp setup
local cmp = require 'cmp'
local lspkind = require('lspkind')

cmp.setup {
  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },
  mapping = cmp.mapping.preset.insert({
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },
    ['<Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
    ['<S-Tab>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      else
        fallback()
      end
    end, { 'i', 's' }),
  }),
  sources = cmp.config.sources({
    { name = 'copilot' },
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
  }, {
    { name = 'buffer' },
    { name = 'path' },
  }),
  formatting = {
    format = lspkind.cmp_format({
      mode = 'symbol_text',
      maxwidth = 50,
      symbol_map = {
        Copilot = "",
      },
    })
  }
}

cmp.setup.cmdline('/', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = {
    { name = 'buffer' }
  }
})

cmp.setup.cmdline(':', {
  mapping = cmp.mapping.preset.cmdline(),
  sources = cmp.config.sources({
    { name = 'path' }
  }, {
    { name = 'cmdline' }
  })
})

-- Lualine setup
require('lualine').setup {
  options = {
    theme = 'dracula',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
  },
  sections = {
    lualine_x = {
      copilot_status,
      'encoding',
      'fileformat',
      'filetype'
    },
  }
}

-- Treesitter setup
require('nvim-treesitter.configs').setup {
  ensure_installed = {"lua", "rust", "python", "kotlin", "java"},
  highlight = { enable = true },
  indent = { enable = true },
}

-- Telescope setup
local telescope = require('telescope')
telescope.setup{
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    }
  }
}
telescope.load_extension('fzf')

-- Gitsigns setup
require('gitsigns').setup()

-- Autopairs setup
require('nvim-autopairs').setup{}

-- Comment.nvim setup
require('Comment').setup()

-- Markdown setup
vim.g.vim_markdown_folding_disabled = 1
vim.g.vim_markdown_conceal = 0
vim.g.tex_conceal = ""
vim.g.vim_markdown_math = 1
vim.g.vim_markdown_frontmatter = 1
vim.g.vim_markdown_strikethrough = 1

-- Markdown Preview setup
vim.g.mkdp_auto_start = 0
vim.g.mkdp_auto_close = 1
vim.g.mkdp_refresh_slow = 0
vim.g.mkdp_command_for_global = 0
vim.g.mkdp_open_to_the_world = 0
vim.g.mkdp_browser = ''
vim.g.mkdp_echo_preview_url = 0
vim.g.mkdp_page_title = '「${name}」'

-- indent-blankline setup
local highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowOrange",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
}

local hooks = require "ibl.hooks"
-- Create the highlight groups in the highlight setup hook, so they are reset
-- every time the colorscheme changes
hooks.register(hooks.type.HIGHLIGHT_SETUP, function()
    vim.api.nvim_set_hl(0, "RainbowRed", { fg = "#E06C75" })
    vim.api.nvim_set_hl(0, "RainbowYellow", { fg = "#E5C07B" })
    vim.api.nvim_set_hl(0, "RainbowBlue", { fg = "#61AFEF" })
    vim.api.nvim_set_hl(0, "RainbowOrange", { fg = "#D19A66" })
    vim.api.nvim_set_hl(0, "RainbowGreen", { fg = "#98C379" })
    vim.api.nvim_set_hl(0, "RainbowViolet", { fg = "#C678DD" })
    vim.api.nvim_set_hl(0, "RainbowCyan", { fg = "#56B6C2" })
end)

require("ibl").setup {
    indent = { highlight = highlight },
    scope = {
        enabled = true,
        show_start = true,
        show_end = true,
        injected_languages = true,
        highlight = highlight,
        priority = 500,
    },
    exclude = {
        filetypes = {
            "help",
            "alpha",
            "dashboard",
            "neo-tree",
            "Trouble",
            "trouble",
            "lazy",
            "mason",
            "notify",
            "toggleterm",
            "lazyterm",
        },
    },
}

-- Use hook to get scope highlighting from treesitter
hooks.register(hooks.type.SCOPE_HIGHLIGHT, hooks.builtin.scope_highlight_from_extmark)

-- nvim-colorizer setup
require('colorizer').setup()

-- which-key setup
local wk = require("which-key")
wk.setup {}
wk.add({
  { "<leader>c", group = "Copilot" },
  { "<leader>cd", "<cmd>Copilot disable<CR>", desc = "Disable Copilot" },
  { "<leader>ce", "<cmd>Copilot enable<CR>", desc = "Enable Copilot" },
  { "<leader>cs", "<cmd>Copilot status<CR>", desc = "Copilot Status" },
})

-- bufferline setup
require("bufferline").setup{}

-- nvim-tree setup
require("nvim-tree").setup{}

-- zen-mode and twilight setup
require("zen-mode").setup {
  plugins = {
    twilight = { enabled = true },
  }
}

-- Set up autocommands
vim.cmd [[
  augroup CustomAutocommands
    autocmd!
    autocmd BufWritePre * :%s/\s\+$//e
  augroup END
]]
