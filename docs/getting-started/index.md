# Introduction

_Where electric meets elegant_

Welcome to the **SilkCircuit Dotfiles**—a meticulously crafted development environment that brings together modern
tooling, beautiful aesthetics, and cross-platform compatibility. This isn't just another dotfiles collection; it's a
complete terminal experience designed to make you faster, smarter, and genuinely excited to work in the command line.

## What's Inside

This dotfiles collection provides a complete development environment:

- **24 modular shell scripts** with 100+ aliases and functions
- **AstroNvim configuration** with LSP, AI assistance, and custom plugins
- **SilkCircuit theme** applied consistently across all tools
- **Modern CLI replacements** for classic Unix tools
- **Cross-platform support** for macOS, Linux, and WSL2

## Design Philosophy

### Modular Architecture

Every component is self-contained. Shell scripts are organized by domain (git, docker, kubernetes, system, network,
etc.) and only loaded when relevant. Don't need Kubernetes? It won't pollute your shell. Working on a minimal server?
Skip the GUI tools entirely.

### Sensible Defaults

Everything works out of the box. No tweaking required—but every setting is customizable when you need it. Installation
detects your platform and automatically configures the right tools, paths, and behaviors.

### Platform Intelligence

Automatic detection of your platform (macOS, Linux, WSL2) with appropriate tool selection and path configuration. The
same dotfiles work seamlessly across all your machines.

### Visual Consistency

The SilkCircuit color palette flows through everything—from your prompt to git diffs to system info commands:

| Color           | Hex       | Usage                               |
| --------------- | --------- | ----------------------------------- |
| Electric Purple | `#e135ff` | Keywords, active states, importance |
| Neon Cyan       | `#80ffea` | Paths, functions, interactions      |
| Coral           | `#ff6ac1` | Hashes, numbers, constants          |
| Electric Yellow | `#f1fa8c` | Warnings, timestamps                |
| Success Green   | `#50fa7b` | Confirmations, additions            |
| Error Red       | `#ff6363` | Errors, deletions                   |

## What Makes This Special

### Git Worktree Manager

A modern, beautifully styled git worktree manager with fuzzy finding, automatic branch creation, and intelligent
switching. Managing multiple branches has never been this smooth.

### FZF Integration Everywhere

Fuzzy finding isn't just for files—it's integrated into git operations, docker management, process killing, history
search, and more. If you can select it, you can fuzzy-find it.

### System Information Tools

Beautiful, colorized system info commands that actually make you want to check your system status. From memory usage
bars to disk info to network stats—all styled with the SilkCircuit palette.

### Modern CLI Tools

Classic Unix tools, reimagined. `lsd` for ls, `bat` for cat, `fd` for find, `ripgrep` for grep, `zoxide` for cd, `delta`
for git diffs. All configured and themed.

## Quick Preview

```bash
# One-liner installation (macOS)
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hyperb1iss/dotfiles/main/install_macos.sh)"

# Manual installation
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
make macos  # or: make full, make minimal
```

After installation, you get:

```bash
# Beautiful git worktree management
gwt                      # Interactive action picker
gwt list -d              # Show worktrees sorted by date
gwt new feat/amazing     # Create and switch to new worktree

# Interactive fuzzy finding everywhere
gadd                     # Fuzzy-select files to stage with diff preview
gco                      # Fuzzy-checkout branches with log preview
fcd                      # Fuzzy-navigate directories with tree preview
fkill                    # Fuzzy-kill processes

# Stunning system information
sys                      # Complete system overview
meminfo                  # Memory usage with visual bar
diskinfo                 # Disk usage per partition
health                   # Quick health check
```

## Next Steps

- [Installation Guide](./installation) — Full setup instructions for your platform
- [Quick Start](./quick-start) — Start using your new environment immediately
- [Configuration](./configuration) — Customize to your preferences
