# Helix

Helix 25.07, painted in SilkCircuit glow, with the Space leader laid out the way AstroNvim taught your hands

## Overview

[Helix](https://helix-editor.com) is a modal editor with no plugin system: tree-sitter, LSP, pickers, multiple cursors
and a file explorer are built in, and the whole setup is two TOML files. It is Kakoune-shaped rather than Vim-shaped, so
you select first and act second. That model is the reason to try it, and the config here leaves it alone. What it does
carry over from the [Neovim setup](../neovim/) is the muscle memory that has nothing to do with motions: the Space
groups, `Ctrl-s`, `]b` and `[b`, and `Esc` clearing your selection.

What you get:

- The same language servers and formatters as Neovim: Rust, Python (ruff and ty), TypeScript (vtsls), HTML, CSS,
  Tailwind, JSON, YAML, TOML, Markdown, Bash, Lua and Docker, with prettier, stylua and shfmt for formatting
- One master switch for format-on-save, off by default like the Neovim config, toggled with `Space u F`
- Inlay hints, inline diagnostics on the cursor line, a bufferline when more than one file is open, a statusline that
  shows the git branch
- lazygit in a tmux popup, one-line git blame, and a `Space a y` that copies a `file:line` reference for pasting at an
  agent

## Structure

```
helix/
├── config.toml      # Editor options and keymap (→ ~/.config/helix/config.toml)
├── languages.toml   # Language servers and formatters (→ ~/.config/helix/languages.toml)
└── README.md
sh/helix.sh          # Puts Mason's binaries on PATH so Helix finds the servers
```

The SilkCircuit installer drops its five Helix themes into `~/.config/helix/themes/`, which is why the two files are
linked individually rather than the directory. Pick another variant any time with `:theme silkcircuit-neon` (also
`vibrant`, `soft` and `dawn`); the tracked default is `glow`.

## Quick start

```
hx .                # File explorer at the project root
hx file.py          # Open a file

Space f f           # Find files
Space f w           # Grep the project
Space f c           # Grep the word under the cursor
Space e             # File explorer
Space x x           # Diagnostics for this buffer
Space l f           # Format buffer
Space g g           # lazygit (tmux popup)
Space ?             # Command palette, searchable by description
:config-reload      # After editing config.toml
hx --health python  # What a language resolved to
```

## Coming from Neovim

The unlearning is smaller than it looks. Everything that is not in this table works the way you expect.

| Habit                  | Helix                                                                                              |
| ---------------------- | -------------------------------------------------------------------------------------------------- |
| `dw`, `ciw`, `yap`     | Select first, then act: `wd`, `miwc`, `mapy`. `w`, `e`, `b` and friends leave a selection behind   |
| `v` then move          | You are always selecting. `v` toggles select mode, where motions extend instead of replace         |
| `x`                    | Selects the whole line (repeat to grow). `d` deletes what is selected                              |
| `%`                    | Selects the whole file. `mm` jumps to the matching bracket                                         |
| `Ctrl-r`               | `U` redoes, and `Ctrl-r` is mapped to it too                                                       |
| `K` for hover          | `Space k` (or `Space l h`). `K` keeps selections matching a regex, which you will want             |
| `.` repeat             | Repeats the last insert. Multiple cursors cover most of what `.` did: `s` splits a selection       |
|                        | into one cursor per regex match, `C` copies the cursor down, `,` collapses back to one             |
| `:%s/a/b/g`            | `%` to select all, `s` to pick the matches, then `c` and type. Live, with every match visible      |
| `f`, `t`               | Not confined to the line                                                                           |
| `:terminal`, lazygit   | No terminal. `Space g g` opens lazygit in a tmux popup; anywhere else `Ctrl-z` drops you to the    |
|                        | shell and `fg` brings Helix back                                                                   |
| `:Mason`, `:Lazy`      | Nothing to manage. `hx --health` reports what each language found on PATH                          |
| which-key              | Press `Space` and wait; the infobox lists the group. Same for `g`, `m`, `z`, `Ctrl-w`              |
| `q:`, `:help`          | `Space ?` searches every command by description                                                    |
| `gd`, `gr`, `gi`, `gy` | Same keys. `gd` definition, `gr` references, `gi` implementation, `gy` type definition             |
| `]d`, `[d`, `]g`, `[g` | Same keys: diagnostics and git hunks. Also `]f` function, `]t` type, `]a` argument, `]p` paragraph |

## Keybindings

Notation: `Space` is the leader, `C-x` is Ctrl. Mode is normal unless a table says otherwise. Mappings marked (ours)
come from `helix/config.toml`; the rest are Helix defaults kept because they already matched.

### Files and windows

| Key                     | Action                                                          |
| ----------------------- | --------------------------------------------------------------- |
| `Space w`               | Save (ours)                                                     |
| `Space q` / `Space Q`   | Close view / close all views (ours)                             |
| `Space n`               | New scratch buffer (ours)                                       |
| `Space c` / `Space C`   | Close buffer / force close (ours)                               |
| `Space e` / `Space E`   | File explorer at workspace root / at this file's directory      |
| `Space \|` / `Space \\` | Vertical / horizontal split (ours)                              |
| `C-h` `C-j` `C-k` `C-l` | Move between splits (ours)                                      |
| `C-w`                   | Window mode: `v` `s` split, `q` close, `o` only, `H J K L` swap |
| `C-s`                   | Save, in normal and insert mode (ours)                          |
| `C-q`                   | Quit everything, discarding changes (ours, same as AstroNvim)   |
| `]b` / `[b`             | Next / previous buffer (ours)                                   |
| `Esc`                   | Collapse to one cursor, drop extra selections (ours)            |

### Find (`Space f`)

| Key         | Action                            |
| ----------- | --------------------------------- |
| `Space f f` | Files in the workspace            |
| `Space f F` | Files under the current directory |
| `Space f w` | Grep the workspace, live          |
| `Space f c` | Grep the word under the cursor    |
| `Space f b` | Buffers                           |
| `Space f s` | Symbols in this file              |
| `Space f S` | Symbols in the workspace          |
| `Space f j` | Jumplist                          |
| `Space f g` | Files changed in git              |
| `Space '`   | Reopen the last picker            |

### Buffers (`Space b`)

| Key                       | Action                   |
| ------------------------- | ------------------------ |
| `Space b b`               | Buffer picker            |
| `Space b n` / `Space b p` | Next / previous buffer   |
| `Space b d`               | Close this buffer        |
| `Space b c`               | Close every other buffer |
| `Space b C`               | Close all buffers        |

### Language tools (`Space l`)

| Key                       | Action                                 |
| ------------------------- | -------------------------------------- |
| `Space l a`               | Code action                            |
| `Space l r` / `Space r`   | Rename symbol                          |
| `Space l h` / `Space k`   | Hover documentation                    |
| `Space l f`               | Format buffer                          |
| `Space l s` / `Space l G` | Document / workspace symbols           |
| `Space l d` / `Space l D` | Document / workspace diagnostics       |
| `Space l R`               | References                             |
| `Space l i` / `Space l y` | Implementation / type definition       |
| `Space l l`               | Restart the language servers           |
| `Space l L`               | Open the Helix log                     |
| `Space x x` / `Space x X` | Diagnostics picker, buffer / workspace |

### Git (`Space g`)

| Key         | Action                                                  |
| ----------- | ------------------------------------------------------- |
| `Space g g` | lazygit in a tmux popup                                 |
| `Space g f` | lazygit filtered to this file's history                 |
| `Space g s` | Picker of files changed in the working tree             |
| `Space g b` | Blame the current line: commit, author, age and subject |
| `]g` / `[g` | Next / previous hunk                                    |

Outside tmux, `Space g g` prints a reminder instead of failing quietly: `Ctrl-z`, run lazygit, `fg`.

### Agents (`Space a`)

| Key         | Action                                                                                                   |
| ----------- | -------------------------------------------------------------------------------------------------------- |
| `Space a y` | Copy `path:line` for the cursor, or `path:start-end` for a multi-line selection, to the system clipboard |

Works in normal and select mode. It uses `pbcopy`, `wl-copy` or `xclip`, whichever the box has.

### Toggles (`Space u`)

| Key         | Toggles                                    |
| ----------- | ------------------------------------------ |
| `Space u n` | Relative / absolute line numbers           |
| `Space u w` | Soft wrap                                  |
| `Space u i` | Inlay hints                                |
| `Space u g` | Indent guides                              |
| `Space u h` | Visible whitespace                         |
| `Space u c` | Cursor line highlight                      |
| `Space u b` | Bufferline                                 |
| `Space u m` | Mouse                                      |
| `Space u d` | Inline and end-of-line diagnostics         |
| `Space u F` | Format on save, for every language at once |

### Kept from Helix

`Space y`, `Space p`, `Space P` and `Space R` move text through the system clipboard. `Space j` is the jumplist,
`Space h` selects every reference to the symbol under the cursor, `Space G` is the debugger, `Space /` comments the
selection (matching AstroNvim, and replacing Helix's `Space c`). Two defaults moved: `Space a` is the agents group, so
code actions are `Space l a`, and `Space w` saves, so window mode is `Ctrl-w`.

## Language servers

Everything below resolves to the binaries Mason installed for Neovim under `~/.local/share/nvim/mason/bin`, which
`sh/helix.sh` appends to PATH. Nothing gets installed twice, and a box that has never run Neovim shows the gaps in
`hx --health`.

| Language               | Server(s)                                                   | Formatter                       |
| ---------------------- | ----------------------------------------------------------- | ------------------------------- |
| Rust                   | rust-analyzer, with clippy as the check command             | LSP                             |
| Python                 | ty, ruff                                                    | LSP                             |
| TypeScript, JavaScript | vtsls (tsx and jsx also get tailwindcss-ls)                 | prettier                        |
| HTML, CSS, SCSS        | vscode html and css servers, tailwindcss-ls                 | prettier                        |
| JSON, YAML, Markdown   | vscode-json-language-server, yaml-language-server, marksman | prettier                        |
| TOML                   | taplo                                                       | LSP                             |
| Lua                    | lua-language-server                                         | stylua                          |
| Bash                   | bash-language-server                                        | shfmt, honoring `.editorconfig` |
| Dockerfile, Compose    | docker-language-server (compose adds yaml-language-server)  | none                            |

Formatting is off on save until you flip `Space u F`, matching the Neovim config. `Space l f` formats on demand. Helix
has no separate linter hook, so the markdownlint and yamllint passes that nvim-lint runs in Neovim stay in `make lint`.

## Gotchas

- `hx --health` warns that `~/.config/helix/runtime` does not exist. That is where a source build keeps grammars; the
  Homebrew install ships them elsewhere and the warning is noise.
- Helix expands the first word of a `:sh` command only when the whole word is an expansion, so `s=%{cursor_line}` stays
  literal there. `Space a y` goes through `set --` for exactly that reason.
- `git blame -l` prefixes boundary commits with `^`; `Space g b` uses `--porcelain` to get a clean hash.
- `Space f c` deliberately does not press Enter: global search runs as you type, and Enter would jump to the first match
  instead of leaving the picker open.
- Run `make install` after pulling: it links the two files and lets the SilkCircuit installer lay down the themes.
