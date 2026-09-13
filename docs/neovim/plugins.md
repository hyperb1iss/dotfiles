# Plugins

59 plugins, most of them AstroNvim's own

AstroNvim v6 ships the framework. Everything here is either core, a language pack from AstroCommunity, or one of the
overrides in `nvim/lua/plugins/`. Run `:Lazy` to see load state and startup cost per plugin.

## Framework

| Plugin             | Purpose                                                 |
| ------------------ | ------------------------------------------------------- |
| **AstroNvim**      | The distribution: defaults, structure, update channel   |
| **lazy.nvim**      | Plugin manager with lazy loading and the lockfile       |
| **astrocore**      | Options, mappings, autocmds, treesitter install list    |
| **astrolsp**       | LSP attach behavior, features, mappings                 |
| **astroui**        | Icons, statusline components, SilkCircuit status colors |
| **astrocommunity** | Registry of language packs and recipes imported by name |

## Theme and UI

| Plugin                      | Purpose                                                         |
| --------------------------- | --------------------------------------------------------------- |
| **silkcircuit**             | The colorscheme, with integrations for every plugin below       |
| **heirline.nvim**           | Statusline, winbar and buffer tabline (AstroNvim default)       |
| **snacks.nvim**             | Dashboard, picker, terminal, lazygit, notifier, input, indent   |
| **neo-tree.nvim**           | File explorer with git status and diagnostics                   |
| **which-key.nvim**          | Mapping discovery popup                                         |
| **trouble.nvim**            | Diagnostics, quickfix and todo panel on `Space x`               |
| **aerial.nvim**             | Symbols outline on `Space l S`                                  |
| **rainbow-delimiters.nvim** | Bracket pairs colored from the SilkCircuit palette              |
| **nvim-highlight-colors**   | Inline color swatches for hex and CSS colors                    |
| **todo-comments.nvim**      | Highlights and searches TODO, FIX, HACK markers                 |
| **mini.icons**              | Icon provider, with nvim-web-devicons as the compatibility shim |
| **nvim-window-picker**      | Pick a window when opening from Neo-tree                        |
| **smart-splits.nvim**       | Split navigation and resizing that also crosses tmux panes      |

## Editing

| Plugin                 | Purpose                                               |
| ---------------------- | ----------------------------------------------------- |
| **blink.cmp**          | Completion and signature help                         |
| **LuaSnip**            | Snippet engine, with friendly-snippets as the library |
| **nvim-autopairs**     | Bracket and quote pairing                             |
| **nvim-ts-autotag**    | Closes and renames HTML/JSX tags                      |
| **guess-indent.nvim**  | Detects indentation per buffer                        |
| **better-escape.nvim** | `jj` and `jk` leave insert mode                       |
| **nvim-treesitter**    | Parsers install on demand; textobjects come along     |

## LSP, formatting, linting

| Plugin                        | Purpose                                              |
| ----------------------------- | ---------------------------------------------------- |
| **nvim-lspconfig**            | Server definitions                                   |
| **mason.nvim**                | Installs servers, formatters, linters and debuggers  |
| **mason-lspconfig.nvim**      | Bridges Mason packages to lspconfig names            |
| **mason-tool-installer.nvim** | Holds the real `ensure_installed` list               |
| **conform.nvim**              | Formatting on `Space l f`; autoformat off by default |
| **nvim-lint**                 | Linters that run on save and when you stop typing    |
| **lazydev.nvim**              | Neovim API completion for Lua                        |
| **schemastore.nvim**          | JSON and YAML schemas                                |
| **nvim-lsp-file-operations**  | Tells servers about renames made in Neo-tree         |

none-ls and mason-null-ls are disabled in `disabled.lua`; conform and nvim-lint replace them.

## Git and GitHub

| Plugin            | Purpose                                             |
| ----------------- | --------------------------------------------------- |
| **gitsigns.nvim** | Hunk signs, staging, blame, navigation              |
| **octo.nvim**     | Issues, PRs, reviews and notifications on `Space O` |
| **snacks.nvim**   | Lazygit, blame line, git browse (also listed above) |

## AI

| Plugin              | Purpose                                                              |
| ------------------- | -------------------------------------------------------------------- |
| **claudecode.nvim** | WebSocket server for Claude Code's `/ide`; selection and diff bridge |

Claude runs in a herdr pane, not inside Neovim. See [AI integration](./ai).

## Debugging

| Plugin                  | Purpose                                           |
| ----------------------- | ------------------------------------------------- |
| **nvim-dap**            | Debug Adapter Protocol client                     |
| **nvim-dap-ui**         | Scopes, breakpoints, REPL windows                 |
| **mason-nvim-dap.nvim** | Installs adapters (codelldb, debugpy, js, bash)   |
| **nvim-dap-python**     | Python adapter configuration from the python pack |
| **nvim-nio**            | Async runtime for dap-ui                          |

## Sessions and utilities

| Plugin             | Purpose                               |
| ------------------ | ------------------------------------- |
| **resession.nvim** | Sessions on `Space S`                 |
| **plenary.nvim**   | Lua utilities other plugins depend on |
| **nui.nvim**       | UI primitives for Neo-tree            |

## Language packs

Each pack in `nvim/lua/community.lua` brings its treesitter parser, server, formatter and any companion plugins.

| Pack               | Brings                                                      |
| ------------------ | ----------------------------------------------------------- |
| `pack.lua`         | lua_ls, stylua, selene                                      |
| `pack.rust`        | rustaceanvim, crates.nvim, codelldb                         |
| `pack.python.base` | debugpy, nvim-dap-python, venv-selector                     |
| `pack.python.ruff` | ruff server and conform formatters                          |
| `pack.python.ty`   | ty type checker as a language server                        |
| `pack.typescript`  | vtsls, nvim-vtsls, tsc.nvim, package-info, js-debug-adapter |
| `pack.html-css`    | html, cssls, emmet_ls                                       |
| `pack.tailwindcss` | tailwindcss server                                          |
| `pack.json`        | jsonls with schemastore                                     |
| `pack.yaml`        | yamlls with schemastore                                     |
| `pack.toml`        | taplo                                                       |
| `pack.markdown`    | marksman                                                    |
| `pack.bash`        | bashls, shfmt, shellcheck, bash-debug-adapter               |
| `pack.docker`      | docker-language-server, hadolint                            |
| `pack.ps1`         | powershell-editor-services, vim-ps1                         |

Treesitter parsers install automatically when you open a filetype that has one. The base list lives in `astrocore.lua`
under `treesitter.ensure_installed`; everything else arrives on demand.

## Managing plugins

- `:Lazy` shows status, `:Lazy sync` installs and updates against `lazy-lock.json`, `Space p a` updates Lazy and Mason
  together.
- `:Mason` shows installed tools. `:MasonToolsUpdate` installs anything missing from the `ensure_installed` lists.
- To disable a core plugin, add `{ "author/name", enabled = false }` to `nvim/lua/plugins/disabled.lua`.
- Commit `lazy-lock.json` with any plugin change so every machine runs the same commits.
