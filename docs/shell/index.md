# Shell Environment

_27 modular scripts. 100+ aliases. Infinite power._

## Architecture

The shell environment is built on a modular architecture where each domain (git, docker, kubernetes, etc.) has its own
script. This keeps things organized and allows conditional loading based on what's actually installed on your system.

```
sh/
├── shell-common.sh     # Core utilities & platform detection
├── env.sh              # Environment & PATH management
├── terminal.sh         # Terminal title magic
├── git.sh              # Git aliases & worktree manager
├── docker.sh           # Docker utilities
├── kubernetes.sh       # K8s shortcuts
├── typescript.sh       # Turbo, pnpm, TypeScript tooling
├── nvm.sh              # Node version management
├── python.sh           # Python & Django workflows
├── rust.sh             # Rust & Cargo shortcuts
├── java.sh             # Java version switching
├── fzf.sh              # Fuzzy finder integration
├── directory.sh        # Navigation & bookmarks
├── process.sh          # Process management
├── network.sh          # Network utilities
├── system.sh           # System info & health checks
├── macos.sh            # macOS-specific utilities
├── wsl.sh              # WSL2 integration
└── ...                 # And more
```

## Loading Flow

Everything starts in your `zshrc` and flows through a carefully orchestrated loading sequence:

```
zshrc
  │
  ├─ shell-common.sh   ← Helper functions, platform detection
  ├─ env.sh            ← PATH, environment variables
  ├─ terminal.sh       ← Terminal title setup
  │
  └─ [zinit loads remaining sh/*.sh files asynchronously]
      ├─ git.sh
      ├─ docker.sh
      ├─ typescript.sh
      └─ ...
```

Scripts are smart about their environment:

```bash
is_minimal && return 0  # Skip on minimal installs
is_macos && alias ...   # macOS-only aliases
has_command docker && ... # Load only if Docker exists
```

## Platform Detection

Your scripts know where they're running:

```bash
is_macos    # Returns true on macOS
is_linux    # Returns true on Linux (not WSL)
is_wsl      # Returns true on WSL2
is_zsh      # Returns true in Zsh
is_bash     # Returns true in Bash
has_command # Check if command exists
```

These detection functions let scripts adapt gracefully to different environments.

## Color Palette

All scripts use the **SilkCircuit** color scheme for consistent, electric aesthetics:

```bash
# ANSI RGB codes used throughout
ELECTRIC_PURPLE='\033[38;2;225;53;255m'   # Keywords, markers
NEON_CYAN='\033[38;2;128;255;234m'        # Functions, paths
CORAL='\033[38;2;255;106;193m'            # Hashes, numbers
ELECTRIC_YELLOW='\033[38;2;241;250;140m'  # Warnings, timestamps
SUCCESS_GREEN='\033[38;2;80;250;123m'     # Success states
ERROR_RED='\033[38;2;255;99;99m'          # Errors, danger
RESET='\033[0m'
```

This isn't just pretty—it makes terminal output scannable at a glance. Green = good, yellow = caution, red = problem.

## FZF Integration

Most interactive functions leverage [fzf](https://github.com/junegunn/fzf) for fuzzy finding:

- `gadd` — Interactive git add with diff preview
- `gco` — Interactive branch checkout
- `glog` — Interactive commit history browser
- `gwt switch` — Worktree selection
- `fcd` — Directory navigation
- `fkill` — Process killing
- `dexec` — Docker container selection
- `mono` — Monorepo package navigation

The pattern is consistent: fuzzy search with rich previews. Tab to multi-select, Enter to execute.

## Script Categories

### [Git Utilities](./git)

The crown jewel. Comprehensive aliases, an advanced worktree manager, and interactive functions for everything from
staging to rebasing.

### [Directory Navigation](./directory)

Enhanced navigation with bookmarks, zoxide integration, and fzf-powered jumping. Never `cd ../../..` again.

### [Docker](./docker)

Container management made simple. Interactive selection for exec, logs, stats. Everything you need without remembering
container IDs.

### [Kubernetes](./kubernetes)

kubectl shortcuts, context switching, and k9s integration. Because typing `kubectl` 100 times a day is tedious.

### [TypeScript & Turbo](./typescript)

Monorepo development tools. Turborepo shortcuts, pnpm aliases, quick package navigation, and AI-powered commit messages.

### [Language Support](./nvm)

Version managers for Node, Python, Rust, and Java. Switch environments effortlessly.

### [System Utilities](./system)

System info, health checks, resource monitoring. Know your machine inside and out.

### [macOS](./macos)

Platform-specific utilities for Finder integration, clipboard management, and Homebrew services.

### [Network](./network)

Port investigation, connectivity testing, bandwidth monitoring. Debug network issues like a pro.

### [Process Management](./process)

Find, monitor, and control processes with modern tools and interactive selection.

## Pro Tips

**Lazy Loading for Speed**: Scripts load asynchronously via zinit, so your shell starts fast even with 100+ aliases.

**Conditional Loading**: No Docker installed? The docker.sh script gracefully skips. Same for all tools.

**Extensibility**: Drop a new `.sh` file in the `sh/` directory and it's automatically loaded on next shell start.

**Private Overrides**: Create `~/.rc.local` for machine-specific settings that won't be committed to your dotfiles.

## What's Next?

Explore the individual script docs to discover all the shortcuts and functions available. Start with [Git](./git) if you
work with code, or [System](./system) if you want to monitor your machine like a mission control center.
