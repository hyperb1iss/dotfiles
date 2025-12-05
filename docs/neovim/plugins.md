# Plugins

_Your complete arsenal of Neovim superpowers_

This configuration includes a carefully selected set of plugins that work together to create a cohesive, powerful
development environment. Every plugin has been chosen for a specific purpose and configured to integrate seamlessly with
the SilkCircuit aesthetic.

## Core Framework

The foundation that makes everything else possible:

| Plugin        | Purpose                                                |
| ------------- | ------------------------------------------------------ |
| **AstroNvim** | Distribution providing sensible defaults and structure |
| **lazy.nvim** | Ultra-fast plugin manager with lazy loading            |
| **astrocore** | Core options, mappings, and autocommands               |
| **astroui**   | UI configuration and statusline                        |
| **astrolsp**  | LSP configuration and server management                |

## Theme & Visual Polish

Make your editor a joy to look at:

| Plugin                 | Purpose                                        |
| ---------------------- | ---------------------------------------------- |
| **silkcircuit**        | Custom neon colorscheme matching terminal      |
| **nvim-web-devicons**  | File type icons with custom SilkCircuit colors |
| **rainbow-delimiters** | Color-coded bracket pairs for visual clarity   |
| **indent-blankline**   | Visual indent guides (via snacks.nvim)         |

The rainbow delimiter colors are specifically tuned to the SilkCircuit palette:

- Electric purple, neon cyan, coral pink, electric yellow
- Each nesting level gets a distinct, vibrant color

## UI Components

Modern interface elements that stay out of your way:

| Plugin             | Purpose                                        |
| ------------------ | ---------------------------------------------- |
| **snacks.nvim**    | All-in-one: dashboard, picker, terminal, more  |
| **neo-tree.nvim**  | File explorer with git integration             |
| **trouble.nvim**   | Beautiful diagnostics and symbol navigation    |
| **which-key.nvim** | Popup showing available keybindings            |
| **nvim-notify**    | Fancy notification system                      |
| **dressing.nvim**  | Improved UI for vim.ui.input and vim.ui.select |

**Snacks.nvim** is the star here - it provides:

- Startup dashboard with ASCII art and quick actions
- Fuzzy file picker (replaces Telescope for most tasks)
- Integrated terminal with proper window management
- Smart indent guides and word highlighting
- Notification system with smooth animations

## Editing Experience

Make typing feel like magic:

| Plugin              | Purpose                                    |
| ------------------- | ------------------------------------------ |
| **nvim-cmp**        | Completion engine with multiple sources    |
| **LuaSnip**         | Snippet engine with custom snippet support |
| **nvim-autopairs**  | Auto-close brackets, quotes, and tags      |
| **Comment.nvim**    | Toggle comments with `gc` motions          |
| **nvim-treesitter** | Syntax highlighting and code understanding |
| **nvim-ts-autotag** | Auto-close HTML/JSX tags                   |

**Pro tip:** Treesitter provides accurate syntax highlighting by actually parsing your code. It's like having a
compiler-level understanding of every language.

## LSP & Code Intelligence

Transform Neovim into a full IDE:

| Plugin                 | Purpose                                    |
| ---------------------- | ------------------------------------------ |
| **mason.nvim**         | One-stop shop for LSP servers and tools    |
| **nvim-lspconfig**     | LSP client configuration                   |
| **none-ls.nvim**       | Bridge for formatters/linters without LSP  |
| **lsp_signature.nvim** | Function signature hints as you type       |
| **lazydev.nvim**       | Neovim Lua API completion for config files |

**Mason** automatically installs and manages:

- Language servers (ts_ls, lua_ls, rust-analyzer, etc.)
- Formatters (prettier, stylua, biome)
- Linters (eslint)
- Debug adapters

## Git Integration

Work with git without leaving Neovim:

| Plugin            | Purpose                                  |
| ----------------- | ---------------------------------------- |
| **gitsigns.nvim** | Git change indicators in sign column     |
| **octo.nvim**     | Manage GitHub issues and PRs from Neovim |

**Gitsigns** shows you:

- Added, changed, and removed lines
- Inline blame information
- Quick git hunk operations (stage, reset, preview)

## AI Superpowers

Your intelligent pair programming partners:

| Plugin               | Purpose                                  |
| -------------------- | ---------------------------------------- |
| **avante.nvim**      | Claude AI assistant with beautiful UI    |
| **claude-code.nvim** | Terminal integration for Claude Code CLI |

**Avante** brings Claude directly into your editor with:

- Side panel for AI conversations
- Inline code suggestions
- Diff view for proposed changes
- Context-aware assistance based on your selection

**Claude Code** integration provides:

- Full terminal window at 40% screen height
- Auto-refresh on file changes
- Git root detection for project context

## Navigation & Window Management

Move around your code effortlessly:

| Plugin                 | Purpose                                      |
| ---------------------- | -------------------------------------------- |
| **telescope.nvim**     | Fuzzy finder for files, grep, and more       |
| **smart-splits.nvim**  | Seamless window navigation                   |
| **nvim-window-picker** | Visual window selection for split operations |
| **toggleterm.nvim**    | Manage multiple terminal windows             |

**Note:** Snacks picker is used for most fuzzy finding, but Telescope is available for advanced use cases.

## Debugging

Full Debug Adapter Protocol support:

| Plugin             | Purpose                       |
| ------------------ | ----------------------------- |
| **nvim-dap**       | Debug Adapter Protocol client |
| **nvim-dap-ui**    | Beautiful debugging UI        |
| **mason-nvim-dap** | Auto-install debug adapters   |

Set breakpoints, step through code, inspect variables - all from Neovim.

## Language Packs

Pre-configured language support from AstroCommunity:

| Pack               | Provides                                |
| ------------------ | --------------------------------------- |
| `pack.lua`         | Lua development (lua_ls, lazydev)       |
| `pack.rust`        | Rust tools (rustaceanvim, crates.io)    |
| `pack.typescript`  | TypeScript/JavaScript (vtsls, tsc.nvim) |
| `pack.tailwindcss` | Tailwind CSS IntelliSense               |
| `pack.html-css`    | HTML/CSS language servers               |
| `pack.json`        | JSON with schema validation             |
| `pack.yaml`        | YAML support with schema validation     |
| `pack.markdown`    | Enhanced markdown editing               |

Each pack includes:

- Language server configuration
- Treesitter parser
- Common tools and utilities
- Sensible defaults

## Treesitter Parsers

Syntax parsing for 25+ languages:

```
Core: lua, vim, vimdoc, query, regex
Web: html, css, javascript, typescript, tsx, vue
Data: json, yaml, toml, xml
Systems: c, cpp, rust, go, python, java
Shell: bash, fish, zsh
DevOps: dockerfile, terraform
Markup: markdown, markdown_inline
Git: git_config, git_rebase, gitcommit, gitignore
```

Treesitter provides:

- Accurate syntax highlighting
- Smart indentation
- Code folding
- Incremental selection

## Additional Plugins

Extra tools that enhance the experience:

| Plugin            | Purpose                          |
| ----------------- | -------------------------------- |
| **presence.nvim** | Discord Rich Presence            |
| **lsp_signature** | Function signatures while typing |

## Managing Plugins

### Adding New Plugins

Create a file in `nvim/lua/plugins/`:

```lua
-- nvim/lua/plugins/my-awesome-plugin.lua
return {
  "author/plugin-name",
  -- Lazy load on event
  event = "VeryLazy",

  -- Or load on specific file types
  ft = { "python", "javascript" },

  -- Or load on command
  cmd = { "MyCommand" },

  -- Or load on keypress
  keys = {
    { "<leader>mp", "<cmd>MyPlugin<cr>", desc = "My Plugin" },
  },

  -- Plugin configuration
  opts = {
    setting = "value",
  },

  -- Or use config function for more control
  config = function()
    require("my-plugin").setup({
      -- settings here
    })
  end,

  -- Dependencies
  dependencies = {
    "required/plugin",
  },
}
```

### Updating Plugins

```vim
:Lazy update    " Update all plugins
:Lazy sync      " Update and clean plugins
```

Or use the dashboard shortcut when you first open Neovim.

### Disabling Plugins

To temporarily disable a plugin, add `enabled = false`:

```lua
return {
  "author/plugin-name",
  enabled = false,
}
```

### Plugin Performance

Check startup time and plugin loading:

```vim
:Lazy profile   " View plugin load times
```

Use the profiler from snacks.nvim:

```vim
:lua Snacks.profiler.start()  " Start profiling
" ... do some actions ...
:lua Snacks.profiler.stop()   " Stop and view results
```

## Plugin Philosophy

This configuration follows these principles:

1. **Lazy loading everywhere** - Plugins load only when needed
2. **One tool, one job** - Avoid plugin overlap
3. **Sensible defaults** - Minimal configuration required
4. **Visual consistency** - Everything matches SilkCircuit theme
5. **Performance first** - Fast startup and responsive editing

Every plugin has earned its place by either:

- Solving a specific problem exceptionally well
- Enhancing the core editing experience
- Integrating seamlessly with other tools
- Looking absolutely beautiful while doing it

The result is a cohesive system where everything works together naturally.
