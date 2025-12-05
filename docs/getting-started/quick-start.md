# Quick Start

Hit the ground running with your new development environment.

## Essential Aliases

### Git (The Greatest Hits)

These are muscle memory material:

```bash
g       # git
gst     # git status
ga      # git add
gaa     # git add --all
gcom    # git commit -v
gcomm   # git commit -m "message"
gd      # git diff
gdca    # git diff --cached
gl      # git pull
gp      # git push
gpf     # git push --force-with-lease
gsw     # git switch
gswc    # git switch -c (create new branch)
gig     # git iris gen -a --no-verify --preset conventional
```

### Navigation

Modern filesystem navigation:

```bash
ll      # ls -l (using lsd with icons)
la      # ls -la (show hidden files)
lt      # ls --tree (tree view)
mkcd    # mkdir + cd in one command
up 3    # go up 3 directories
z foo   # zoxide jump to "foo" (learns your habits)
zi      # interactive zoxide selection
```

### Development

For modern JavaScript/TypeScript development:

```bash
# Turbo (monorepo management)
t       # turbo
td      # turbo dev
tb      # turbo build
tl      # turbo lint:fix
tdf pkg # turbo dev --filter=pkg

# pnpm
p       # pnpm
pi      # pnpm install
pa      # pnpm add
pad     # pnpm add -D

# TypeScript
ts file.ts   # run with tsx
tcheck       # tsc --noEmit (type check only)
```

## Interactive Functions (FZF-Powered)

These use fuzzy finding for maximum efficiency:

### File & Directory Operations

```bash
fcd     # Fuzzy-find and cd into directory (with tree preview)
fopen   # Fuzzy-find and open file in $EDITOR (with bat preview)
```

### Git Operations

```bash
gadd    # Interactive git add with diff preview
        # Tab to select multiple files
        # Preview shows actual changes

gco     # Interactive branch checkout
        # Shows local + remote branches
        # Preview displays commit log

glog    # Interactive git log browser
        # Beautiful graph visualization
        # Enter to view full commit

gstash  # Interactive stash management
        # Select stash with preview
        # Choose action: apply/pop/drop/show/branch
```

### System Operations

```bash
fkill   # Interactive process killer
        # Multi-select with Tab
        # Shows full process info

fh      # Fuzzy history search
        # Search through your command history
        # Enter to execute

fenv    # Search environment variables
        # Quick lookup of env vars

frg pattern
        # Interactive ripgrep search
        # Jump to file:line in editor
```

## Git Worktree Manager

The `gwt` command is your new best friend for managing multiple branches:

### Basic Usage

```bash
gwt             # Interactive action picker (requires fzf)
gwt list        # Show all worktrees with context
gwt list -d     # Sort by date (most recent first)
```

### Creating Worktrees

```bash
gwt new feat/amazing
# Creates worktree at ~/dev/worktrees/repo-name/feat/amazing
# Automatically creates branch from origin/main
# Switches you into the new worktree

gwt new bugfix --from main
# Create from a specific base branch

gwt new hotfix --path ~/custom/path
# Create at a custom location
```

### Switching & Removing

```bash
gwt switch      # Fuzzy-select and cd into worktree
gwt switch feat # Direct switch if pattern matches

gwt remove      # Interactive removal (multi-select)
gwt remove --force  # Force remove with uncommitted changes

gwt clean       # Prune stale worktrees
```

### Configuration

```bash
# Customize in ~/.rc.local
export GWT_ROOT=~/worktrees
export GWT_DEFAULT_BASE=origin/develop
```

## Neovim

Launch your editor:

```bash
nvim            # Open Neovim
nvim .          # Open current directory
nvim file.ts    # Open specific file
```

### Essential Key Mappings

| Key         | Action                     |
| ----------- | -------------------------- |
| `Space`     | Leader key                 |
| `,`         | Local leader               |
| `Space f f` | Find files (Telescope)     |
| `Space f w` | Find word/grep (Telescope) |
| `Space f r` | Recent files               |
| `Space e`   | File explorer (neo-tree)   |
| `Space l d` | Show diagnostics           |
| `Space l a` | Code actions               |
| `g d`       | Go to definition           |
| `g r`       | Go to references           |
| `K`         | Hover documentation        |
| `Ctrl-,`    | Toggle Claude Code         |
| `Space g g` | Git status (lazygit)       |

### Plugin Highlights

- **LSP** — Full language server support
- **Treesitter** — Advanced syntax highlighting
- **Telescope** — Fuzzy finder for everything
- **Neo-tree** — Modern file explorer
- **Which-key** — Keybinding hints
- **Avante** — AI-powered coding assistance

## Starship Prompt

Your prompt automatically shows:

- **Current directory** (3-level truncation with `…/`)
- **Git branch** and status (modified, staged, ahead/behind)
- **Language versions** when in a project:
  - Node.js, Python, Rust, Go, Java, Kotlin
- **Command duration** (if >500ms)
- **Docker context** (when active)
- **Kubernetes context** (when set)

The prompt uses the SilkCircuit gradient theme with deep purple to hot pink segments.

## System Information

Beautiful, colorized system info commands:

```bash
sys         # Full system overview
            # OS, kernel, uptime, load, CPU, memory, disk

sysinfo     # Quick system info
            # Host, OS, kernel, uptime

meminfo     # Memory usage with visual bar
            # Shows used/free/cached/buffers

diskinfo    # Disk usage per partition
            # Mounted filesystems with usage bars

battery     # Battery status (laptops)
            # Charge level, status, time remaining

health      # Quick system health check
            # Load, memory, disk, temps
```

All system commands use the SilkCircuit color palette for consistent, beautiful output.

## Docker

Container management made easy:

```bash
d           # docker
dc          # docker compose
dps         # docker ps (prettier output)

# Interactive functions
dexec       # Fuzzy-select container, exec shell
dlf         # Fuzzy-select container, follow logs
dstop       # Fuzzy-select container(s), stop
drm         # Fuzzy-select container(s), remove

# Cleanup
dclean      # Full cleanup (containers, images, volumes)
dprune      # Prune unused images/containers
```

## macOS Specific

macOS-only utilities:

```bash
finder .           # Open Finder at current directory
ql file.pdf        # Quick Look preview
clip "text"        # Copy to clipboard
pbpaste            # Paste from clipboard

showfiles          # Show hidden files in Finder
hidefiles          # Hide hidden files in Finder

# Homebrew services
brew-services      # Interactive service manager
                   # Start/stop/restart services via fzf
```

## Modern CLI Tools Showcase

These replace classic Unix commands:

```bash
# Instead of ls
ll                 # lsd with colors and icons
lt                 # tree view with lsd

# Instead of cat
bat file.ts        # Syntax highlighted file viewing

# Instead of find
fd pattern         # Faster, smarter file finding
fd -e ts           # Find all TypeScript files

# Instead of grep
rg pattern         # Blazingly fast code search
rg -t ts pattern   # Search only TypeScript files

# Instead of cd
z project          # Jump to frequently used directory
zi                 # Interactive directory selection

# Git diffs
git diff           # Automatically uses delta for beautiful output
```

## Keyboard Shortcuts (Zsh)

Default Zsh keybindings with FZF integration:

| Key       | Action                              |
| --------- | ----------------------------------- |
| `Ctrl-R`  | Fuzzy command history search        |
| `Ctrl-T`  | Fuzzy file search (insert path)     |
| `Alt-C`   | Fuzzy directory search (cd into it) |
| `Tab`     | Completion with suggestions         |
| `Up/Down` | Navigate history                    |

## Configuration Tips

### Private Settings

Create `~/.rc.local` for machine-specific settings that won't be committed:

```bash
# ~/.rc.local
export ANTHROPIC_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
alias work="cd ~/work/projects"
alias personal="cd ~/personal"
```

This file is automatically sourced if it exists.

### Custom Aliases

Add your own aliases to `~/.rc.local` or create a new file in `~/dev/dotfiles/sh/`:

```bash
# ~/dev/dotfiles/sh/custom.sh
alias myalias='echo "Hello!"'

function myfunction() {
  echo "Custom function"
}
```

New `.sh` files in `sh/` are automatically loaded by Zinit.

## Pro Tips

1. **Use Tab completion everywhere** — Most commands have smart completion
2. **Try `gwt` without arguments** — Interactive menu for git worktrees
3. **Use `gadd` instead of `git add`** — Preview changes before staging
4. **Let `zoxide` learn your paths** — After a few days, `z` becomes magic
5. **Explore with `which-key` in Neovim** — Press `Space` and wait to see options
6. **Check `type` to find functions** — `type gwt` shows you what a command does

## Next Steps

- [Configuration Guide](./configuration) — Customize everything
- [Shell Utilities](/shell/) — Deep dive into shell scripts
- [Neovim Setup](/neovim/) — Editor configuration details
- [CLI Tools](/tools/) — Modern tool replacements
