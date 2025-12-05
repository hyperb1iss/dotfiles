# Neovim Configuration

_AstroNvim v4 supercharged with SilkCircuit aesthetics and electric AI power_

## Overview

This is a carefully crafted Neovim setup that transforms your editor into a powerful, beautiful development environment.
Built on [AstroNvim v4](https://astronvim.com/), it combines robust LSP support, cutting-edge AI integration, and the
stunning SilkCircuit color palette into one cohesive experience.

**What you get:**

- **11+ languages** with full LSP support out of the box
- **Claude AI integration** via Avante.nvim for intelligent code assistance
- **SilkCircuit theme** - neon colors that match your terminal aesthetic
- **Modern plugin ecosystem** managed seamlessly by lazy.nvim
- **Optimized workflow** with carefully curated keybindings and UI components

## Project Structure

```
nvim/
├── init.lua              # Entry point - bootstraps AstroNvim
├── lua/
│   ├── lazy_setup.lua    # Plugin manager configuration
│   ├── community.lua     # AstroCommunity language packs
│   ├── polish.lua        # Post-load customization & highlights
│   └── plugins/          # Individual plugin configurations
│       ├── astrocore.lua     # Core options, mappings, autocmds
│       ├── astrolsp.lua      # LSP settings & server configs
│       ├── astroui.lua       # UI elements & statusline
│       ├── avante.lua        # Claude AI assistant
│       ├── mason.lua         # LSP/tool installer
│       ├── neo-tree.lua      # File explorer
│       ├── none-ls.lua       # Formatters & linters
│       ├── silkcircuit.lua   # Custom colorscheme
│       ├── snacks.nvim       # Dashboard, picker, terminal
│       ├── treesitter.lua    # Syntax parsing
│       ├── trouble.lua       # Diagnostics panel
│       └── user.lua          # Additional plugins
```

## Key Features

### Language Intelligence

Full LSP support powered by Mason, with automatic installation and configuration:

- **TypeScript/JavaScript** - ts_ls, ESLint, Biome, Prettier
- **Lua** - lua_ls with lazydev for Neovim API completion
- **Rust** - rustaceanvim with rust-analyzer integration
- **Vue.js** - Volar for Vue 3 component intelligence
- **CSS/HTML** - cssls, html, with Tailwind CSS support
- **JSON/YAML** - Schema validation and formatting
- **GraphQL** - Full language server support
- **Markdown** - Enhanced editing with live preview capabilities

### AI-Powered Development

Two complementary AI tools integrated directly into your workflow:

**[Avante.nvim](https://github.com/yetone/avante.nvim)** - Claude in your editor

- Inline code assistance with context awareness
- Real-time suggestions as you type
- Beautiful markdown rendering in side panel
- Diff-based edits with visual conflict resolution

**Claude Code CLI** - Terminal-based AI pair programming

- Multi-file refactoring and analysis
- Project-wide context understanding
- Seamless integration with git workflows

### Modern, Beautiful UI

Every visual element has been thoughtfully designed:

- **Snacks.nvim** - Sleek dashboard, fuzzy picker, integrated terminal
- **Neo-tree** - File explorer with git status indicators and custom icons
- **Trouble.nvim** - VSCode-like diagnostics panel with symbol navigation
- **Rainbow delimiters** - Color-coded bracket pairs matching SilkCircuit palette
- **Custom statusline** - Essential info without clutter

## Quick Start Guide

### Essential Commands

```bash
# Open Neovim
nvim

# Navigate files
Space f f         # Find files (fuzzy search)
Space f w         # Find word in project (grep)
Space f r         # Recent files
Space f b         # Find buffers

# File explorer
Space e           # Toggle Neo-tree

# AI assistance
Ctrl-,            # Toggle Claude Code terminal
Space a a         # Ask Claude about selection
Space a e         # Edit with Claude suggestions

# Diagnostics
Space l d         # Buffer diagnostics (Trouble)
Space l D         # Project diagnostics (Trouble)
Ctrl-\            # Quick toggle diagnostics panel
```

### Your First Session

1. **Open Neovim** - You'll see the SilkCircuit dashboard with quick actions
2. **Find a file** - Press `Space f f` and start typing
3. **Explore the tree** - Press `Space e` to toggle the file explorer
4. **Get AI help** - Select some code and press `Space a a` to ask Claude
5. **Check diagnostics** - Press `Space l d` to see any issues in your code

## Documentation Sections

Dive deeper into specific areas:

- **[Plugins](./plugins)** - Complete plugin list with descriptions
- **[Keybindings](./keybindings)** - All keyboard shortcuts organized by category
- **[LSP & Completion](./lsp)** - Language server setup and completion config
- **[AI Integration](./ai)** - Claude and Avante configuration details

## Customization Tips

### Adding Your Own Plugins

Create a new file in `nvim/lua/plugins/`:

```lua
-- nvim/lua/plugins/my-plugin.lua
return {
  "username/plugin-name",
  event = "VeryLazy",  -- Lazy load for fast startup
  opts = {
    -- Plugin configuration here
  },
  keys = {
    { "<leader>mp", "<cmd>MyPlugin<cr>", desc = "My Plugin Action" },
  },
}
```

### Modifying Keybindings

Edit `nvim/lua/plugins/astrocore.lua`:

```lua
mappings = {
  n = {  -- normal mode
    ["<leader>custom"] = { "<cmd>MyCommand<cr>", desc = "My custom action" },
  },
  v = {  -- visual mode
    ["<leader>cv"] = { ":CustomVisual<cr>", desc = "Visual mode action" },
  },
}
```

### Adjusting Colors

The SilkCircuit theme is defined in `nvim/lua/plugins/silkcircuit.lua`. You can override specific highlight groups in
`nvim/lua/polish.lua`:

```lua
vim.api.nvim_set_hl(0, "Normal", { fg = "#f8f8f2", bg = "#1a1826" })
vim.api.nvim_set_hl(0, "Comment", { fg = "#6272a4", italic = true })
```

## Performance

This configuration is designed to be fast:

- **Lazy loading** - Plugins load only when needed
- **Optimized startup** - Dashboard appears in < 50ms
- **Smart treesitter** - Disabled for large files (> 256KB)
- **Efficient LSP** - Servers start on-demand per filetype

## Philosophy

This Neovim config follows three core principles:

1. **Aesthetics matter** - Beautiful tools inspire better work
2. **Intelligence at your fingertips** - AI and LSP should feel natural, not intrusive
3. **Keyboard-driven flow** - Everything important is just a few keystrokes away

The goal is to create an environment where you can stay in flow state, where the editor anticipates your needs, and
where every visual element reinforces focus rather than breaking it.

Welcome to your new editing experience.
