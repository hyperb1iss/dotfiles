# LSP, formatting and completion

Servers from Mason, formatting from conform, linting from nvim-lint, completion from blink

## Language servers

The language packs in `nvim/lua/community.lua` declare each server; Mason installs it the first time you open a file of
that type, and AstroLSP attaches it with the mappings in [Keybindings](./keybindings#language-tools).

| Server                      | Languages              | Notes                                 |
| --------------------------- | ---------------------- | ------------------------------------- |
| `lua_ls`                    | Lua                    | lazydev adds the Neovim API           |
| `rust_analyzer`             | Rust                   | Through rustaceanvim, not lspconfig   |
| `ruff`                      | Python                 | Lint, fix, format, import sorting     |
| `ty`                        | Python                 | Type checking, the Astral checker     |
| `vtsls`                     | TypeScript, JavaScript | tsc.nvim for project-wide type errors |
| `html`, `cssls`, `emmet_ls` | HTML, CSS, SCSS        |                                       |
| `tailwindcss`               | Tailwind classes       |                                       |
| `jsonls`                    | JSON                   | Schemas from schemastore              |
| `yamlls`                    | YAML                   | Schemas from schemastore              |
| `taplo`                     | TOML                   |                                       |
| `marksman`                  | Markdown               |                                       |
| `bashls`                    | sh, bash, zsh          | Runs shellcheck inline                |
| `docker_language_server`    | Dockerfile, compose    | hadolint for lint                     |
| `powershell_es`             | PowerShell             |                                       |

`Space li` shows what is attached to the current buffer. `:Mason` shows what is installed.

## Features

- Diagnostics show as virtual text by default; `Space ud` toggles them, `Space uv` toggles just the virtual text, `gl`
  or `Space ld` opens the float, `Space xx` opens Trouble.
- Hover with `K`, signature help with `gK`, and blink.cmp pops signature help while you type inside a call.
- Inlay hints start off. `Space uh` turns them on per buffer.
- CodeLens refreshes on `InsertLeave` and `BufEnter`; `Space lL` runs the lens under the cursor.
- Semantic tokens are on. `Space uY` switches them off for a buffer if a server paints too much.

## Formatting (conform)

`Space lf` formats the buffer or the visual selection. Formatters resolve per filetype and fall back to the language
server when nothing else is registered:

| Filetype                                      | Formatter                                    |
| --------------------------------------------- | -------------------------------------------- |
| Lua                                           | stylua                                       |
| Python                                        | ruff fix, ruff organize imports, ruff format |
| Rust                                          | rust-analyzer                                |
| JS, TS, JSON, CSS, SCSS, HTML, YAML, Markdown | prettierd, then prettier                     |
| sh, bash, zsh                                 | shfmt, shellcheck                            |
| TOML                                          | taplo                                        |

Autoformat on save is off. `vim.g.autoformat = false` in `astrocore.lua` sets the default; `Space uF` flips it for the
session and `Space uf` for one buffer. `Space lc` opens `:ConformInfo` when a formatter misbehaves.

## Linting (nvim-lint)

Linters run after you save, when you leave insert mode, and a beat after text changes:

| Filetype   | Linter            |
| ---------- | ----------------- |
| Markdown   | markdownlint-cli2 |
| YAML       | yamllint          |
| sh, zsh    | shellcheck        |
| Dockerfile | hadolint          |

Ruff and ty report through the LSP, so Python needs no separate linter.

## Tools

`mason-tool-installer` owns the `ensure_installed` list. The packs contribute their servers and tools; `mason.lua` adds
prettierd, markdownlint-cli2 and yamllint. `Space pM` or `:MasonToolsUpdate` installs anything missing. `mason.nvim`
itself has no `ensure_installed` option, so lists placed there are ignored.

## Completion (blink.cmp)

Sources: LSP, path, snippets (LuaSnip with friendly-snippets), buffer words. The menu opens as you type, `Enter`
accepts, `C-Space` shows documentation, and `Tab` jumps through snippet fields. `Space uc` turns completion off for a
buffer.

## Treesitter

Parsers install on demand from the main branch of nvim-treesitter. Highlighting, indentation, folding and text objects
are on for every buffer with a parser, and off above 256KB or 10,000 lines. `:TSInstall <lang>` adds one by hand,
`:TSUpdate` rebuilds them all. `:InspectTree` shows the syntax tree under the cursor.

## Adding a language

1. Check [AstroCommunity](https://github.com/AstroNvim/astrocommunity/tree/main/lua/astrocommunity/pack) for a pack and
   add `{ import = "astrocommunity.pack.<name>" }` to `nvim/lua/community.lua`.
2. No pack: add the server to `mason-lspconfig`'s `ensure_installed` through a spec in `nvim/lua/plugins/`, and set any
   options under `astrolsp.opts.config.<server>`.
3. Formatters and linters go in `nvim/lua/plugins/format.lua` under `formatters_by_ft` and `linters_by_ft`, plus the
   tool name in `mason.lua`.
4. Restart, then `Space pa` to install.

## Troubleshooting

- Server not attaching: `Space li`, then `:LspLog`. Most misses are a tool that Mason has not installed yet; run
  `:MasonToolsUpdate`.
- Formatter did nothing: `:ConformInfo` lists the formatters conform found for the buffer and why it skipped any.
- Treesitter error after an update: `:TSUpdate`, and if a parser stays broken, delete it from
  `~/.local/share/nvim/site/parser/` and reopen the file.
