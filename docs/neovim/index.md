# Neovim

AstroNvim v6 on Neovim 0.12, painted in SilkCircuit, wired for a Claude Code workflow

## Overview

The editor is [AstroNvim v6](https://astronvim.com/) with a short list of overrides. AstroNvim supplies the framework
(lazy.nvim, LSP wiring, blink.cmp completion, snacks.nvim pickers, heirline statusline), AstroCommunity supplies the
language packs, and `nvim/lua/plugins/` holds the handful of opinions layered on top. The
[SilkCircuit](https://github.com/hyperb1iss/silkcircuit) colorscheme themes every surface and the terminal around it.

What you get:

- Language servers, formatters and linters for the languages in `~/dev`: Lua, Rust, Python (ruff and ty), TypeScript,
  HTML/CSS/Tailwind, JSON, YAML, TOML, Markdown, Bash, Docker and PowerShell
- Claude Code attached over the IDE protocol, so a Claude running in a herdr pane can read your selection and open its
  diffs in the editor
- snacks.nvim for the dashboard, picker, terminal, lazygit, notifications and input prompts
- Trouble for diagnostics, Octo for GitHub, and treesitter parsers that install themselves

## Structure

```
nvim/
├── init.lua                # Bootstraps lazy.nvim
├── lazy-lock.json          # Pinned plugin commits
├── lua/
│   ├── lazy_setup.lua      # AstroNvim + community + plugins imports
│   ├── community.lua       # Language packs and community recipes
│   ├── polish.lua          # Runs last: GUI font, Neovide tweaks
│   └── plugins/
│       ├── astrocore.lua   # Options, treesitter list, autocmds, which-key groups
│       ├── astrolsp.lua    # LSP features and mappings
│       ├── astroui.lua     # SilkCircuit statusline colors (installer-owned)
│       ├── blink.lua       # Signature help from blink.cmp
│       ├── claudecode.lua  # Claude Code IDE bridge
│       ├── disabled.lua    # Core plugins this setup replaces
│       ├── format.lua      # conform formatters, nvim-lint linters
│       ├── mason.lua       # Extra Mason tools
│       ├── neo-tree.lua    # File explorer (installer-owned)
│       ├── octo.lua        # GitHub issues and PRs
│       ├── silkcircuit.lua # Colorscheme setup (installer-owned)
│       └── snacks.lua      # Dashboard, terminal, lazygit, mappings
└── .styluaignore           # The installer-owned files above
```

The three installer-owned files are copied in by the SilkCircuit installer and must stay byte-identical to
`extras/astronvim/plugins/` in that repo. Edit them there.

## Quick start

```
nvim                # Dashboard: f find file, w find word, o recent, p projects, s last session

Space f f           # Find files
Space f w           # Grep the project
Space e             # Toggle Neo-tree
Space x x           # Trouble: buffer diagnostics
Space l f           # Format buffer (conform)
F7                  # Toggle terminal
Space g g           # Lazygit
Space a s           # Send selection to Claude (visual mode)
```

Leader is `Space`, local leader is `,`. Press `Space` and wait for which-key to show every group.

## Documentation

- [Plugins](./plugins): what is installed and why
- [Keybindings](./keybindings): every mapping, grouped by prefix
- [LSP, formatting and completion](./lsp): servers, tools, conform and nvim-lint
- [AI integration](./ai): the Claude Code bridge and the herdr workflow

## Customizing

Add a plugin by dropping a spec into `nvim/lua/plugins/`:

```lua
return {
  "username/plugin-name",
  event = "VeryLazy",
  opts = {},
  keys = {
    { "<Leader>mp", "<Cmd>MyPlugin<CR>", desc = "My plugin" },
  },
}
```

Mappings go in `nvim/lua/plugins/astrocore.lua` under `opts.mappings`, keyed by mode. Language packs are one line each
in `nvim/lua/community.lua`; browse [AstroCommunity](https://github.com/AstroNvim/astrocommunity) for more.

Switch the SilkCircuit variant at runtime with `:SilkCircuit glow` (or `neon`, `vibrant`, `soft`, `dawn`). The choice
persists in `~/.local/share/nvim/silkcircuit_preferences.json`.

## Sandbox testing

To try config changes without touching the live editor, symlink a worktree's `nvim/` to `~/.config/nvimtest` and run
`NVIM_APPNAME=nvimtest nvim`. The sandbox gets its own data, state and cache directories.

## Performance

Plugins lazy-load on events, commands and keys. A cold start lands on the dashboard in about 80ms with 45 of 59 plugins
loaded. Treesitter, indent guides and scope switch off for buffers over 256KB or 10,000 lines.
