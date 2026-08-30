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
5. Runs the full installation via `make macos`, an alias for `make install`
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
make install
```

`make install` composes `base.yaml`, `os/macos.yaml`, and `role/desktop.yaml`, which together install:

- Homebrew packages via `macos/brew.sh`
- Modern CLI tools (lsd, bat, fd, ripgrep, delta, zoxide)
- Starship prompt
- FZF (built from source via Go)
- Symlinks for configs (zsh, nvim, tmux, git, starship)

`make macos` is kept as an alias and does the same thing.

## Linux

### Full Desktop Environment

For workstations with a full desktop:

```bash
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
git submodule update --init --recursive
make full
```

`make full` runs the sudo tier first, then the composed install:

- System-level configurations (requires sudo)
- Desktop environment integrations
- GUI tools and fonts
- All shell utilities and CLI tools

::: warning Sudo Required The sudo tier runs as root. Review `dotbot.d/os/linux-system.yaml` first if you're cautious,
or run `make install` on its own to skip it entirely. :::

### Minimal Server Setup

For headless servers or containers:

```bash
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles
cd ~/dev/dotfiles
git submodule update --init --recursive
make server
```

The `server` role includes:

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

## Installation Targets

| Command        | Layers composed                                       | Use Case                          | Sudo Required |
| -------------- | ----------------------------------------------------- | --------------------------------- | ------------- |
| `make install` | `base` + `os/<uname>` + `role/desktop` + host/private | Any desktop, macOS or Linux       | No            |
| `make server`  | `base` + `role/server` + host/private                 | Servers, containers, lightweight  | Yes, packages |
| `make full`    | The sudo tier, then `make install`                    | Full Linux/WSL desktop            | Yes           |
| `make system`  | `os/linux-system` only                                | System files, no home changes     | Yes           |
| `make private` | `private` only                                        | Refresh the dotfiles-private bits | No            |

`make macos` and `make minimal` still work; they are aliases for `make install` and `make server`.

::: tip Layers Compose Profiles no longer collide, so there is no state guard to fight: run `make server` on a box you
installed as a desktop and it succeeds instead of erroring. Dotbot only adds links, so the desktop links that role no
longer installs are left in place; remove them by hand if you want the box genuinely lean. `make install` records the
role it used in `.dotfiles_role`, which is what the shell reads to decide whether to load the heavier modules. :::

Override the detection when you need to, for example `make install ROLE=server` or `make install HOST=hyperia`.

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
make install  # re-run the composed install
```

This is safe to run multiple times—it won't reinstall packages, just update symlinks and configurations.

## Smoke Tests

The install runs against fresh machines in CI so a broken layer shows up on a pull request instead of the next time you
set up a box.

```bash
make smoke
```

That runs the same scripts CI does, from `.github/smoke/`. First it checks that `make -n install` composes the layers
this OS expects, then it does a link-only pass over them: the layers go through Dotbot with `--only clean create link`
against a temporary `HOME`, so nothing is downloaded and your real home directory is never touched. Then the container
jobs run, if `docker` or `podman` is installed and its daemon answers. Without that it says what it skipped and still
reports the rest.

Which layers each lane composes lives in one place, `.github/smoke/layers.sh`, so the workflow and `make smoke` cannot
disagree about what they are testing.

The container jobs each build a machine from nothing. A bare `ubuntu:24.04` or `archlinux:latest` image gets the handful
of packages an install needs to start, an unprivileged user with passwordless sudo, and a copy of the checkout at
`~/dev/dotfiles`, which is where the shell configs expect to find it. Then:

| Job                    | What it proves                                                                                     |
| ---------------------- | -------------------------------------------------------------------------------------------------- |
| `ubuntu-server`        | `make server` completes on Ubuntu, every link resolves, `zsh -i` and `bash -i` load their rc files |
| `arch-server`          | The same on Arch, through pacman instead of apt                                                    |
| `ubuntu-desktop-links` | The desktop layers plus `host/hyperia.yaml` parse and link, without installing a graphical stack   |

The expected links are read out of the layer yaml as the test runs, so adding a link to `dotbot.d/` needs no bookkeeping
anywhere else.

What the matrix does not cover: the sudo tier (`make system`), Homebrew and the macOS defaults in `os/macos.yaml`, the
private overlay, and the graphical Linux stack. The macOS job composes the layers and links them against a temporary
`HOME` rather than installing, since a real macOS install means Homebrew and a long list of casks. Arch runs on an amd64
image, so `make smoke` emulates it on Apple Silicon and takes noticeably longer there than the Ubuntu jobs do.

`make smoke` stops at the first container job that fails. To rerun one on its own:

```bash
./.github/smoke/run-container.sh arch-server
```

Set `SMOKE_INTERACTIVE=0` to skip the interactive shell check, which is the one step that reaches the network after the
packages land (Zinit clones its plugins on first run).

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
