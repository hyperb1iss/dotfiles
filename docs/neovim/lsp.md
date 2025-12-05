# LSP & Completion

_Language intelligence that just works_

This configuration provides full Language Server Protocol (LSP) support for 11+ languages, making Neovim feel like a
modern IDE. Everything is automatically installed and configured through Mason, so you can focus on writing code instead
of managing tools.

## Configured Language Servers

All servers are installed automatically via Mason when you open a file of that type:

| Server        | Languages              | Features                           |
| ------------- | ---------------------- | ---------------------------------- |
| `lua_ls`      | Lua                    | Neovim API completion via lazydev  |
| `ts_ls`       | TypeScript, JavaScript | Full IntelliSense, refactoring     |
| `eslint`      | JS/TS                  | Linting with auto-fix              |
| `biome`       | JS/TS                  | Fast formatting and linting        |
| `volar`       | Vue.js                 | Vue 3 component intelligence       |
| `html`        | HTML                   | Tag completion, validation         |
| `cssls`       | CSS, SCSS, LESS        | Property completion, color preview |
| `jsonls`      | JSON                   | Schema validation, IntelliSense    |
| `yamlls`      | YAML                   | Schema validation                  |
| `tailwindcss` | Tailwind CSS           | Class completion in JSX/HTML       |
| `graphql`     | GraphQL                | Query completion, validation       |

**Rust users:** The `pack.rust` from AstroCommunity includes `rustaceanvim`, which provides enhanced rust-analyzer
integration beyond basic LSP.

**TypeScript users:** The `pack.typescript` provides `vtsls`, an optimized fork of ts_ls with better performance.

## LSP Features

### Code Actions

**Trigger:** `Space l a`

Code actions provide quick fixes and refactoring options based on context:

- **Quick fixes** - Automatically fix linting errors
- **Refactoring** - Extract function/variable, inline variable
- **Source actions** - Organize imports, remove unused imports
- **Import management** - Add missing imports automatically

**Example workflows:**

```
1. Cursor on an error → Space l a → Select fix
2. Select a block of code → Space l a → Extract to function
3. On an import → Space l a → Organize imports
```

### Go To Actions

Navigate your codebase like a pro:

| Keybinding | Action                | Description                         |
| ---------- | --------------------- | ----------------------------------- |
| `g d`      | Go to definition      | Jump to where symbol is defined     |
| `g D`      | Go to declaration     | Jump to declaration (for C/C++)     |
| `g i`      | Go to implementation  | Jump to implementation of interface |
| `g r`      | Go to references      | Show all usages of symbol           |
| `g y`      | Go to type definition | Jump to type definition             |

**Pro tip:** Use `Ctrl-o` to jump back to where you came from, `Ctrl-i` to jump forward.

### Hover Documentation

**Trigger:** `K` in normal mode

Shows documentation for the symbol under cursor:

- Function signatures
- Type information
- Documentation comments
- Source code snippets

Press `K` twice to jump into the hover window for scrolling through long documentation.

### Signature Help

**Trigger:** `g K` in normal mode, or automatic in insert mode

As you type function calls, signature help shows:

- Parameter names and types
- Current parameter highlighted
- Multiple overload signatures
- Parameter documentation

The `lsp_signature` plugin provides real-time signature hints as you type.

### Diagnostics

Inline diagnostics with multiple severity levels:

- **Error** - Red, code won't compile/run
- **Warning** - Yellow, potential issues
- **Info** - Blue, suggestions
- **Hint** - Gray, optional improvements

**Display options:**

- Sign column indicators (left gutter)
- Virtual text at end of line
- Underlines in code
- Floating windows with details (`gl`)

**Navigation:**

- `]d` - Next diagnostic
- `[d` - Previous diagnostic
- `gl` - Show line diagnostic in float
- `Space l d` - All buffer diagnostics (Trouble)
- `Space l D` - All project diagnostics (Trouble)

**Toggle diagnostics:**

- `Space u d` - Cycle between modes (all / no virtual text / off)

### Symbol Renaming

**Trigger:** `Space l r`

Rename a symbol across your entire project:

1. Place cursor on symbol
2. Press `Space l r`
3. Type new name
4. Press Enter

LSP will:

- Find all references across files
- Update all usages
- Handle imports/exports
- Preserve code formatting

Works across:

- Variables and functions
- Classes and interfaces
- Component props
- Import paths

### Document Symbols

**Trigger:** `Space l s`

Shows a searchable list of all symbols in the current file:

- Functions and methods
- Classes and interfaces
- Variables and constants
- Types and enums

**Workspace symbols:** Use `Space l S` to search symbols across all project files.

### Formatting

**Trigger:** `Space l f`

Format the current buffer using the configured formatter.

**Configured formatters** (via none-ls):

- **prettier** - JavaScript, TypeScript, JSON, YAML, Markdown, HTML, CSS
- **stylua** - Lua
- **biome** - JavaScript/TypeScript (faster alternative to prettier)

**Format on save:**

Currently disabled by default. To enable, add to `nvim/lua/plugins/astrolsp.lua`:

```lua
formatting = {
  format_on_save = {
    enabled = true,
    allow_filetypes = {
      "lua",
      "javascript",
      "typescript",
      -- Add more filetypes
    },
  },
},
```

**Pro tip:** Use `Space l a` for source actions like "Organize Imports" before formatting.

### Codelens

Shows inline actionable information above functions/classes:

- Test runner actions
- Reference counts
- Implementation counts
- Debug options

Auto-refreshes on:

- `InsertLeave` - When you exit insert mode
- `BufEnter` - When you enter a buffer

**Note:** Codelens support depends on the language server. Works great with rust-analyzer and gopls.

### Semantic Tokens

Enhanced syntax highlighting based on semantic information from LSP:

- Distinguish between different variable types
- Highlight mutable vs immutable
- Show unused variables differently
- Color based on scope and context

**Toggle:** `Space u Y` (buffer-local toggle)

## Completion Engine

Powered by **nvim-cmp** with multiple intelligent sources.

### Completion Sources

Sources are prioritized in this order:

1. **LSP** - Language server completions (highest priority)
2. **LuaSnip** - Snippet expansions
3. **Buffer** - Words from current buffer
4. **Path** - File and directory paths

### Completion Keybindings

| Key       | Action             | Mode | Description                     |
| --------- | ------------------ | ---- | ------------------------------- |
| `C-Space` | Trigger completion | i    | Manually show completion menu   |
| `Tab`     | Next item          | i    | Select next completion          |
| `S-Tab`   | Previous item      | i    | Select previous completion      |
| `Enter`   | Confirm selection  | i    | Accept completion               |
| `C-e`     | Close menu         | i    | Dismiss completion menu         |
| `C-d`     | Scroll docs down   | i    | Scroll completion documentation |
| `C-u`     | Scroll docs up     | i    | Scroll completion documentation |

### Completion Behavior

**Auto-trigger:**

- Appears after typing 1 character
- Filters as you type
- Shows documentation preview
- Ghost text for current selection

**Smart completion:**

- Context-aware suggestions
- Snippet expansion
- Auto-import insertion
- Parameter hints

### Snippets

Powered by **LuaSnip** with extensive snippet libraries.

**Navigation:**

- `Tab` - Jump to next placeholder
- `S-Tab` - Jump to previous placeholder
- Type to replace placeholder

**Extended snippets:**

- JavaScript snippets work in React files
- TypeScript snippets in `.tsx` files
- Custom snippets in `~/.config/nvim/snippets/`

**Example workflow:**

```
1. Type 'log' in JavaScript
2. See 'console.log()' in completion
3. Press Tab to expand
4. Type your message
5. Press Tab to jump out
```

## Treesitter Integration

**Treesitter** complements LSP by providing:

### Accurate Syntax Highlighting

Unlike regex-based highlighting, Treesitter:

- Parses your code into an AST
- Understands code structure
- Highlights based on grammar rules
- Never gets confused by complex syntax

**Enabled parsers** (25+):

```
Web:      html, css, javascript, typescript, tsx, vue
Data:     json, yaml, toml
Systems:  c, cpp, rust, go, python, java
Shell:    bash, fish, zsh
DevOps:   dockerfile, terraform
Markup:   markdown, markdown_inline
Git:      git_config, git_rebase, gitcommit
Other:    lua, vim, vimdoc, regex, query
```

### Smart Indentation

Treesitter provides context-aware indentation:

- Understands nesting levels
- Handles multi-line expressions
- Works across languages consistently

**Special handling:**

- YAML: Fixed to use simple autoindent (avoids smart indent issues)
- HTML/JSX: Auto-close tags via nvim-ts-autotag

### Incremental Selection

Select increasingly larger syntax nodes:

- `Ctrl-Space` - Start selection
- Keep pressing to expand selection
- Selects: variable → expression → statement → function → class

**Use case:** Quickly select a function body or entire class for refactoring.

### Text Objects

Navigate and operate on syntax nodes:

- `vaf` - Select around function
- `vif` - Select inside function
- `vac` - Select around class
- Similar to built-in text objects like `viw` (inside word)

## LSP Performance

### Efficient Server Management

**On-demand startup:**

- Servers start only for opened filetypes
- Multiple buffers share one server
- Auto-restart on crash

**Resource limits:**

- Large files (>256KB) disable Treesitter
- Smart throttling of diagnostics
- Debounced completion triggers

### Diagnostic Performance

**Update triggers:**

- On text change (debounced 300ms)
- On save
- On mode change

**Display optimization:**

- Virtual text only in normal mode
- Floating windows on demand
- Trouble panel for bulk review

## Adding Language Support

### Install New LSP Server

1. Find the server name at
   [LSP Server Configurations](https://github.com/neovim/nvim-lspconfig/blob/master/doc/server_configurations.md)

2. Add to `nvim/lua/plugins/mason.lua`:

```lua
ensure_installed = {
  "lua_ls",
  "ts_ls",
  "your_server_here",  -- Add this
},
```

3. Install via Mason:

```vim
:Mason
```

or restart Neovim (auto-installs on next open).

4. Server auto-configures on first use.

### Add Custom Server Settings

Edit `nvim/lua/plugins/astrolsp.lua`:

```lua
config = {
  your_server_name = {
    settings = {
      -- Server-specific settings here
    },
  },
},
```

**Example for TypeScript:**

```lua
config = {
  ts_ls = {
    settings = {
      typescript = {
        inlayHints = {
          includeInlayParameterNameHints = "all",
        },
      },
    },
  },
},
```

### Add Formatters/Linters

1. Find tool at [Mason Registry](https://mason-registry.dev/)

2. Install via Mason:

```vim
:MasonInstall prettier
:MasonInstall stylua
```

3. Configure in `nvim/lua/plugins/none-ls.lua`:

```lua
local null_ls = require("null-ls")
local formatting = null_ls.builtins.formatting
local diagnostics = null_ls.builtins.diagnostics

return {
  sources = {
    formatting.prettier,
    formatting.stylua,
    -- Add your tools:
    formatting.your_formatter,
    diagnostics.your_linter,
  },
}
```

### Add Treesitter Parser

Edit `nvim/lua/plugins/treesitter.lua`:

```lua
ensure_installed = {
  "lua", "vim", "javascript",
  "your_language",  -- Add here
},
```

Or install on-demand:

```vim
:TSInstall your_language
```

## Troubleshooting

### LSP Not Working

**Check server status:**

```vim
:LspInfo
```

Shows:

- Active servers
- Server status
- Attached buffers
- Configuration issues

**Restart LSP:**

```vim
:LspRestart
```

**Check Mason installation:**

```vim
:Mason
```

Verify server is installed (green checkmark).

### Completion Not Showing

**Check sources:**

```vim
:CmpStatus
```

**Manually trigger:** Press `Ctrl-Space` in insert mode.

**Check if disabled:**

```vim
:lua vim.print(vim.g.cmp_enabled)
```

Should return `true`. Toggle with `Space u c`.

### Diagnostics Too Noisy

**Toggle virtual text:**

```vim
Space u d
```

Cycles through:

1. All diagnostics
2. Signs only (no virtual text)
3. Diagnostics off

**Hide specific severity:**

Edit diagnostic config in `nvim/lua/plugins/astrolsp.lua`.

### Formatting Issues

**Check formatter availability:**

```vim
:Mason
```

**Format manually:**

```vim
Space l f
```

**Check which formatter is used:**

```vim
:lua print(vim.inspect(vim.lsp.buf_get_clients()))
```

## Best Practices

### Workflow Tips

1. **Use Trouble for diagnostics** - Better than jumping error-to-error
2. **Learn go-to-definition** - `gd` is your most-used keybinding
3. **Master code actions** - `Space l a` fixes most issues
4. **Hover for docs** - `K` saves trips to documentation
5. **Rename safely** - `Space l r` updates everywhere

### Performance Optimization

1. **Disable for large files** - Auto-disabled at 256KB
2. **Use format on save sparingly** - Can cause lag on huge files
3. **Close unused buffers** - Each buffer keeps its LSP connection
4. **Restart LSP if sluggish** - `:LspRestart` clears state

### Language-Specific Tips

**TypeScript:**

- Use `Space l a` to add missing imports
- Enable inlay hints for parameter names
- Use `gd` on imports to jump to definitions

**Lua:**

- Lazydev provides Neovim API completion
- Hover on Neovim functions for docs
- Use `stylua` for consistent formatting

**Rust:**

- rustaceanvim provides enhanced features
- Hover shows detailed type information
- Use code actions for derive macros

**Vue:**

- Volar understands both script and template
- Separate TypeScript server for `<script>` blocks
- CSS language server for `<style>` blocks

## Advanced Configuration

### Disable LSP for Specific Filetype

In `nvim/lua/plugins/astrolsp.lua`:

```lua
on_attach = function(client, bufnr)
  if vim.bo[bufnr].filetype == "markdown" then
    vim.lsp.buf_detach_client(bufnr, client.id)
  end
end
```

### Custom LSP Handlers

Override how LSP responses are displayed:

```lua
vim.lsp.handlers["textDocument/hover"] = vim.lsp.with(
  vim.lsp.handlers.hover, {
    border = "rounded",
    max_width = 80,
  }
)
```

### Inlay Hints

Show inline type annotations (experimental):

```lua
vim.lsp.inlay_hint.enable(true)
```

Toggle with custom keybinding.

## Conclusion

This LSP configuration provides IDE-level features while maintaining Neovim's speed and flexibility. The combination of
LSP, Treesitter, and intelligent completion creates a powerful development environment that works across 11+ languages
with zero manual setup.

**Key takeaway:** Everything auto-installs and auto-configures. Just open a file and start coding.
