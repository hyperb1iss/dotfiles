# Installation

Get your development environment up and running in minutes.

## macOS (Recommended Path)

### One-Liner Install

The fastest way to get started:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hyperb1iss/dotfiles/main/install_macos.sh)"
```

This script automates everything:

1. Installs Xcode Command Line Tools (if needed)
2. Sets up Homebrew (detects Apple Silicon vs Intel)
3. Installs Git and other dependencies
4. Clones the dotfiles repository to `~/dev/dotfiles`
5. Runs the full installation via `make macos`
6. Configures Zsh as your default shell

::: tip First Run If Command Line Tools aren't installed, the script will initiate the installation and exit. Complete
the GUI installer, then run the script again. :::

### Manual Install

Prefer to see what's happening? Install step by step:

```bash
# 1. Clone the repository
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles

# 2. Initialize submodules (Dotbot, tpm)
git submodule update --init --recursive

# 3. Run installation
make macos
```

The `macos` profile installs:

- Homebrew packages via `macos/brew.sh`
- Modern CLI tools (lsd, bat, fd, ripgrep, delta, zoxide)
- Starship prompt
- FZF (built from source via Go)
- Symlinks for configs (zsh, nvim, tmux, git, starship)

## Linux

### Full Desktop Environment

For workstations with a full desktop:

```bash
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
git submodule update --init --recursive
make full
```

The `full` profile includes:

- System-level configurations (requires sudo)
- Desktop environment integrations
- GUI tools and fonts
- All shell utilities and CLI tools

::: warning Sudo Required The `full` installation runs `sudo` for system-level changes. Review `system.yaml` first if
you're cautious. :::

### Minimal Server Setup

For headless servers or containers:

```bash
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
git submodule update --init --recursive
make minimal
```

The `minimal` profile includes:

- Essential shell utilities only
- No GUI tools or desktop integrations
- Lightweight footprint
- Perfect for SSH environments

## WSL2

Windows Subsystem for Linux works great:

```bash
# In your WSL2 terminal
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
git submodule update --init --recursive
make full
```

WSL-specific features are automatically enabled:

- Path conversion utilities (`wslpath` wrappers)
- Windows integration functions
- Cross-platform clipboard support
- Browser launching from WSL

## Installation Profiles

| Profile   | Command        | Use Case                         | Sudo Required |
| --------- | -------------- | -------------------------------- | ------------- |
| `macos`   | `make macos`   | Full macOS desktop environment   | No            |
| `full`    | `make full`    | Full Linux/WSL desktop           | Yes           |
| `minimal` | `make minimal` | Servers, containers, lightweight | No            |

::: tip Installation State The installation type is saved to `.install_state`. Mixing profiles (e.g., running `minimal`
then `full`) will warn you to prevent conflicts. :::

## What Gets Installed

### Automatically Installed Tools

These are installed by the setup scripts:

**Package Managers**

- **Homebrew** (macOS) — Via official install script
- **cargo** (via rustup) — For Rust-based tools

**Modern CLI Tools**

- **lsd** — Better ls with icons
- **bat** — Better cat with syntax highlighting
- **fd** — Better find that's faster
- **ripgrep** — Better grep that's blazing fast
- **delta** — Beautiful git diffs
- **zoxide** — Smarter cd that learns

**Essential Utilities**

- **Starship** — Cross-shell prompt
- **fzf** — Fuzzy finder (built from Go source)
- **tree** — Directory tree viewer

### Prerequisites (Must Exist)

These should already be on your system:

- **Git** — For cloning and submodules
- **curl** — For downloading installers
- **Make** — For running installation scripts

On macOS, these come with Command Line Tools. On Linux, install via your package manager:

```bash
# Ubuntu/Debian
sudo apt-get install git curl make

# Fedora/RHEL
sudo dnf install git curl make

# Arch
sudo pacman -S git curl make
```

## Post-Installation

### Reload Your Shell

```bash
# Reload your config
source ~/.zshrc

# Or simply open a new terminal
```

### Verify Installation

Check that everything loaded correctly:

```bash
# Test shell utilities
type gwt        # Git worktree manager
type gadd       # Interactive git add

# Check modern tools
lsd --version   # ls replacement
bat --version   # cat replacement
fd --version    # find replacement
rg --version    # grep replacement

# Verify Starship prompt
starship --version

# Check Neovim (if installed)
nvim --version
```

You should see the Starship prompt with the SilkCircuit theme immediately.

## Updating

Keep your dotfiles fresh:

```bash
cd ~/dev/dotfiles

# Pull latest changes
git pull

# Update submodules
git submodule update --remote --recursive

# Or use the convenience command
make update
```

To re-apply configuration after updates:

```bash
make macos  # or your installation profile
```

This is safe to run multiple times—it won't reinstall packages, just update symlinks and configurations.

## Troubleshooting

### Homebrew Not Found (macOS)

If `brew` isn't in your PATH after installation:

```bash
# Apple Silicon (M1/M2/M3)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel Mac
eval "$(/usr/local/bin/brew shellenv)"
```

Then reload your shell or open a new terminal.

### Zinit Errors

If you see Zinit plugin errors:

```bash
# Reinstall Zinit
rm -rf "${HOME}/.local/share/zinit"
source ~/.zshrc  # Zinit will auto-install
```

### Starship Not Showing

If the prompt looks plain:

```bash
# Verify Starship is installed
which starship

# Check config exists
ls -la ~/.config/starship.toml

# Manually initialize (should be automatic)
eval "$(starship init zsh)"
```

### FZF Not Working

If fuzzy finding isn't available:

```bash
# Check if fzf is installed
which fzf

# If missing, install via Go
go install github.com/junegunn/fzf@latest

# Ensure Go bin is in PATH
export PATH="$HOME/go/bin:$PATH"
```

## Uninstallation

The dotfiles use symlinks, so removing them is straightforward:

```bash
# Remove symlinks (configs will revert to defaults)
rm ~/.zshrc
rm ~/.config/starship.toml
rm ~/.tmux.conf
rm ~/.gitconfig
rm -rf ~/.config/nvim

# Remove the repository
rm -rf ~/dev/dotfiles

# Remove Zinit and its plugins
rm -rf "${HOME}/.local/share/zinit"
```

::: warning Homebrew Packages This won't uninstall Homebrew packages or cargo tools. Remove those manually if needed:

```bash
# List installed Homebrew packages
brew list

# Remove specific package
brew uninstall lsd bat fd ripgrep
```

:::

## Next Steps

- [Quick Start Guide](./quick-start) — Learn the essential commands
- [Configuration](./configuration) — Customize to your preferences
- [Tools Overview](../tools/) — Deep dive into the modern CLI tools
