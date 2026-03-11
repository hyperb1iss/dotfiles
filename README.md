# 🌠 Stefanie's Dotfiles

<p align="center">
  <img src="https://img.shields.io/badge/OS-macOS%20%7C%20Linux%20%7C%20WSL2-informational?style=for-the-badge&logo=apple&logoColor=white&color=ff00ff">
  <img src="https://img.shields.io/badge/Shell-Zsh%20%7C%20Bash-informational?style=for-the-badge&logo=gnu-bash&logoColor=white&color=b300ff">
  <img src="https://img.shields.io/badge/Editor-AstroNvim%20v5-informational?style=for-the-badge&logo=neovim&logoColor=white&color=9933ff">
  <img src="https://img.shields.io/badge/Theme-SilkCircuit-informational?style=for-the-badge&logo=neovim&logoColor=white&color=e135ff">
  <img src="https://img.shields.io/badge/Terminal-Ghostty%20%7C%20Tmux-informational?style=for-the-badge&logo=ghostty&logoColor=white&color=00ffff">
  <img src="https://img.shields.io/badge/Prompt-Starship-informational?style=for-the-badge&logo=starship&logoColor=white&color=33ffcc">
</p>

Hey there! Welcome to my personal dotfiles repository! I'm **Stefanie Jane**, aka **hyperb1iss**—a creative technologist
based in Seattle. These dotfiles create a powerful, beautiful development environment with a macOS-first focus that also
works seamlessly across Linux and WSL2. Everything is tied together by the
[SilkCircuit](https://github.com/hyperb1iss/silkcircuit-nvim) color theme—a cyberpunk-inspired aesthetic with neon
purples, electric cyans, and blazing pinks that flows through every tool.

<p align="center">
  <img src="images/terminal-bliss.png" alt="Terminal Bliss" width="600" />
</p>

## 🌟 Core Features

| Feature                  | Description                                                                                                                                                                                            |
| ------------------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 🐚 **Shell Environment** | • Zsh with Zinit plugin management & Bash fallback<br>• Atuin-powered shell history with cross-machine sync<br>• 28 modular shell scripts with 100+ aliases<br>• Smart platform detection & adaptation |
| 🖥️ **Terminal Setup**    | • Ghostty terminal with SilkCircuit theme<br>• Tmux multiplexer with custom keybindings<br>• Starship prompt with gradient theme<br>• FZF-powered fuzzy finding everywhere                             |
| 🤖 **AI Integration**    | • Claude Code CLI for terminal AI pair programming<br>• Avante.nvim for in-editor Claude assistance<br>• Custom Claude Code status line & security hooks                                               |
| 🎨 **SilkCircuit Theme** | • [silkcircuit-nvim](https://github.com/hyperb1iss/silkcircuit-nvim) Neovim colorscheme<br>• Consistent theming across Neovim, Git, Starship, Tmux, Ghostty, Bat, Delta, Atuin, FZF, and more          |
| 🛠️ **Development Tools** | • AstroNvim v5 with full LSP for 11+ languages<br>• Proto version manager (Node, Rust, pnpm)<br>• Git workflow enhancements with Delta diffs<br>• Docker & Kubernetes management                       |
| 🌐 **Cross-Platform**    | • macOS-first with Homebrew & DotBot automation<br>• Linux (Ubuntu/Arch) full desktop & minimal server profiles<br>• WSL2 with seamless path conversion<br>• Windows PowerShell via HyperShell modules |

## 🔧 Tool Suite

### 📊 Core Development

| Tool                                                                 | Description          | Features                                                                    |
| -------------------------------------------------------------------- | -------------------- | --------------------------------------------------------------------------- |
| 📝 **[AstroNvim v5](https://astronvim.com/)**                        | Neovim configuration | • IDE-like features<br>• Avante.nvim AI assistant<br>• SilkCircuit theme    |
| 👻 **[Ghostty](https://ghostty.org/)**                               | Terminal emulator    | • GPU-accelerated<br>• SilkCircuit theme<br>• Native macOS/Linux            |
| 🚀 **[Starship](https://starship.rs/)**                              | Cross-shell prompt   | • SilkCircuit gradient theme<br>• Git status integration<br>• Context-aware |
| 🖥️ **[Tmux](https://github.com/tmux/tmux)**                          | Terminal multiplexer | • Custom key bindings<br>• SilkCircuit color scheme<br>• Session management |
| 🤖 **[Claude Code](https://docs.anthropic.com/en/docs/claude-code)** | AI pair programmer   | • Custom status line<br>• Security hooks<br>• Project-aware assistance      |

### 🎯 Modern CLI Tools

| Tool                                                    | Description     | Features                                                              |
| ------------------------------------------------------- | --------------- | --------------------------------------------------------------------- |
| 🌳 **[FZF](https://github.com/junegunn/fzf)**           | Fuzzy finder    | • File searching<br>• History exploration<br>• Command completion     |
| 📂 **[LSDeluxe](https://github.com/Peltoche/lsd)**      | Modern ls       | • Icon support<br>• SilkCircuit colors<br>• Tree view                 |
| 🎨 **[Bat](https://github.com/sharkdp/bat)**            | Enhanced cat    | • Syntax highlighting<br>• SilkCircuit theme<br>• Line numbering      |
| 🔍 **[Ripgrep](https://github.com/BurntSushi/ripgrep)** | Fast searcher   | • Code searching<br>• Regular expressions<br>• Ignore rules           |
| 🔀 **[Delta](https://github.com/dandavison/delta)**     | Git diff viewer | • Syntax highlighting<br>• Side-by-side diffs<br>• SilkCircuit theme  |
| ⏪ **[Atuin](https://atuin.sh/)**                       | Shell history   | • SQLite-backed<br>• Cross-machine sync<br>• Per-directory filtering  |
| 📌 **[Zoxide](https://github.com/ajeetdsouza/zoxide)**  | Smart cd        | • Learns your habits<br>• Fuzzy matching<br>• Instant directory jumps |
| 🔧 **[Proto](https://moonrepo.dev/proto)**              | Version manager | • Node, Rust, pnpm versions<br>• Auto .prototools detection<br>• Fast |

### 🖼️ System & Customization

| Tool                                                           | Description    | Features                                                              |
| -------------------------------------------------------------- | -------------- | --------------------------------------------------------------------- |
| 📊 **[Fastfetch](https://github.com/fastfetch-cli/fastfetch)** | System info    | • Fast system information<br>• Performance metrics<br>• Custom config |
| ✨ **[shellint](./bin/shellint)**                              | Shell linter   | • Shellcheck integration<br>• Auto-fixing<br>• Format with shfmt      |
| 🔧 **[DotBot](https://github.com/anishathalye/dotbot)**        | Config manager | • Automated setup<br>• Cross-platform support<br>• Profile management |

## 📁 Repository Structure

```
dotfiles/
├── nvim/                 # AstroNvim v5 configuration (→ ~/.config/nvim)
│   └── lua/plugins/      #   Plugin configs (silkcircuit, avante, treesitter, …)
├── zsh/                  # Zsh configuration (zshrc + completion)
├── bash/                 # Bash configuration (profile + bashrc.local)
├── sh/                   # 28 modular shell scripts (git, docker, k8s, macos, …)
├── bin/                  # Utility scripts (shellint, diskclean, repo, …)
├── ghostty/              # Ghostty terminal config (macOS + Linux)
├── starship/             # Starship prompt with SilkCircuit gradient
├── tmux.conf             # Tmux multiplexer configuration
├── atuin/                # Atuin shell history + SilkCircuit theme
├── gitconfig             # Git config with SilkCircuit colors + Delta
├── proto/                # Proto version manager (.prototools)
├── claude/               # Claude Code settings, status line, security hooks
├── bat/                  # Bat syntax highlighting themes
├── lsd/                  # LSDeluxe file listing config
├── procs/                # Procs process viewer config
├── fastfetch/            # Fastfetch system info display
├── macos/                # macOS setup (Brewfile, system prefs, Karabiner)
├── hypershell/           # Windows PowerShell modules
├── docs/                 # VitePress documentation site
├── Makefile              # Install, lint, and format targets
└── *.yaml                # DotBot install manifests (macos, local, system, …)
```

## 🔤 Installing Nerd Fonts

Nerd Fonts are required for proper icon display in the terminal. These are not automatically installed by dotbot. Follow
these steps to install them:

1. Visit the [Nerd Fonts website](https://www.nerdfonts.com/)
2. Download your preferred font (I recommend JetBrainsMono Nerd Font)
3. Extract the downloaded zip file
4. Install the fonts:
   - On Windows: Right-click on each `.ttf` file and select "Install"
   - On macOS: Double-click each `.ttf` file and click "Install Font"
   - On Linux: Copy the `.ttf` files to `~/.local/share/fonts/` and run `fc-cache -fv`
5. Configure your terminal to use the installed Nerd Font

For WSL2 users, make sure to set the Nerd Font in your Windows Terminal settings as well.

## 🛠️ Installation

### Linux/WSL2

```bash
# Clone the repository
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles

# Install everything
cd ~/dev/dotfiles
make
```

### macOS

```bash
# Option 1: Using the installer script
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hyperb1iss/dotfiles/main/install_macos.sh)"

# Option 2: Manual installation
# Clone the repository
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles

# Install everything
cd ~/dev/dotfiles
make macos
```

### Windows

```powershell
# Clone the repository
git clone https://github.com/hyperb1iss/dotfiles.git $env:USERPROFILE\dev\dotfiles

# Install as administrator
cd $env:USERPROFILE\dev\dotfiles
.\install.ps1
```

## 🚀 Deep Dive

### 🐚 Shell Environment

The shell environment provides a unified experience across Bash and Zsh:

```bash
# Modern CLI Usage Examples
ls                # Beautiful file listings with icons
ll                # Detailed list view
lt                # Tree view of directories
bat script.sh     # Syntax-highlighted file viewing
z projects        # Smart directory jumping
fzf               # Fuzzy find files or history
```

**Key Features:**

- Unified configuration across Bash and Zsh with Zinit plugin management
- Enhanced history with timestamps and duplicate removal
- Intelligent tab completion with fuzzy finding
- Directory jumping with `z` command and bookmarking system
- Git worktree manager (`gwt`) with comprehensive subcommands
- Interactive FZF functions for files, processes, and Docker
- Cross-platform environment variables and platform detection

### 📱 Android Development

Comprehensive tooling for AOSP and device development:

```bash
# Environment Setup
envsetup                     # Initialize build environment
lunch aosp_pixel-userdebug   # Select build target

# Building
mka bacon                    # Optimized build command
installboot                  # Smart boot image installation

# Device Management
logcat                      # Smart device selection
apush system.img            # Intelligent file pushing
aospremote                  # Configure AOSP remote
cafremote                   # Configure CAF remote

# Navigation
gokernel                    # Jump to kernel directory
govendor                    # Jump to vendor directory
goapps                      # Jump to packages/apps
```

**Key Features:**

- Automated build environment setup
- Smart device detection and management
- Performance-optimized build commands
- Comprehensive udev rules
- Quick navigation aliases

### 🪟 WSL2 Integration

Seamless Windows and Linux integration:

```bash
# Path Conversion
wslpath "C:\Users\Stefanie"  # Convert Windows to WSL path
wslopen ~/projects           # Open WSL path in Windows Explorer

# Navigation
cdw                         # Jump to Windows user directory

# File Operations
apush file.txt              # Smart file pushing to Android
extract archive.tar.gz      # Smart archive extraction
```

**Key Features:**

- Seamless path conversion
- File system integration
- Shared Git configuration
- WSL backup utilities
- Cross-platform clipboard support

### 🤖 HyperShell (PowerShell)

A Linux-like experience for Windows PowerShell:

```powershell
# Linux-style Commands
ls --tree         # Directory tree with icons
grep "pattern"    # Search with ripgrep
which code        # Find executable paths

# Docker Management
dex container     # Interactive container selection
dlog container    # View container logs
dstop container   # Stop containers
```

**Key Features:**

- Modular architecture with 13 specialized modules
- Linux command aliases using GNU tools
- Kubernetes support with kubectl aliases and k9s
- Zoxide for smart directory navigation
- Android development utilities
- HyperShell branding with SilkCircuit theme
- Advanced FZF integration and Docker management

### 🤖 AI Integration

The environment includes AI coding assistance at two levels:

**[Claude Code CLI](https://docs.anthropic.com/en/docs/claude-code)** — Terminal AI pair programming:

- Custom SilkCircuit status line showing git, language versions, and context
- Security hooks for safe command execution
- Project-aware assistance with custom AGENTS.md configuration
- Integrated directly into the terminal workflow

**[Avante.nvim](https://github.com/yetone/avante.nvim)** — In-editor AI assistance:

- Configured with Claude Sonnet 4 for intelligent code suggestions
- Interactive sidebar with diff-based edits and conflict resolution
- Context-aware suggestions within your Neovim editing session

### 🎨 Theming System - SilkCircuit

The environment features the custom **SilkCircuit** color scheme, a cyberpunk-inspired theme with neon accents:

|                          Color Preview                          | Name               | Hex Code  | Usage                                   |
| :-------------------------------------------------------------: | ------------------ | --------- | --------------------------------------- |
|   ![Background](https://placehold.co/50x30/1a1a2e/1a1a2e.png)   | **Background**     | `#1a1a2e` | Terminal background, deep space purple  |
|  ![Neon Magenta](https://placehold.co/50x30/ff00ff/ff00ff.png)  | **Neon Magenta**   | `#ff00ff` | Current branches, prompts, highlights   |
| ![Electric Cyan](https://placehold.co/50x30/00ffff/00ffff.png)  | **Electric Cyan**  | `#00ffff` | Local branches, help text, dates        |
| ![Bright Magenta](https://placehold.co/50x30/ff79c6/ff79c6.png) | **Bright Magenta** | `#ff79c6` | Changed files, authors, remote branches |
|     ![Yellow](https://placehold.co/50x30/ffdc00/ffdc00.png)     | **Yellow**         | `#ffdc00` | Branch decorations, code files          |
|     ![Green](https://placehold.co/50x30/50fa7b/50fa7b.png)      | **Green**          | `#50fa7b` | Added files, executables                |
|      ![Red](https://placehold.co/50x30/ff5555/ff5555.png)       | **Red**            | `#ff5555` | Deleted files, errors                   |
|     ![Purple](https://placehold.co/50x30/c792ea/c792ea.png)     | **Purple**         | `#c792ea` | Keywords, tmux accents                  |

The SilkCircuit theme is powered by [**silkcircuit-nvim**](https://github.com/hyperb1iss/silkcircuit-nvim)—a standalone
Neovim colorscheme plugin with 5 variants (neon, vibrant, soft, glow, dawn), 30+ plugin integrations, and WCAG AA
accessibility compliance. It's loaded as a local plugin from `~/dev/silkcircuit-nvim` and also provides extras for
environment-wide theming.

The theme is consistently applied across the entire environment:

- **Neovim** - Full theme via silkcircuit-nvim with 30+ plugin support
- **Ghostty** - Terminal emulator with SilkCircuit colors
- **Git** - Custom log formatting with `silkcircuit` pretty format
- **Starship Prompt** - SilkCircuit gradient theme with powerline segments
- **Tmux** - Status bar with purple and pink accents
- **Atuin** - Shell history UI themed with SilkCircuit palette
- **FZF / fzf-tab** - Fuzzy finder with SilkCircuit color scheme
- **LSDeluxe** - File type colors matching the theme
- **Bat** - Custom SilkCircuit.tmTheme for syntax highlighting
- **Delta** - Git diff viewer with themed colors
- **Claude Code** - Custom status line with SilkCircuit RGB colors

## 🔄 Updating

To update the dotfiles repository:

```bash
cd ~/dev/dotfiles
git pull
make  # For Linux/WSL2
# Or
.\install.ps1  # For Windows (run as administrator)
```

## 🤝 Contributing

Got ideas for improvements? Found a bug? Feel free to:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 🚀 Other Projects

If you like these dotfiles, you might be interested in some of my other projects:

- [silkcircuit-nvim](https://github.com/hyperb1iss/silkcircuit-nvim): The cyberpunk Neovim colorscheme that powers this
  environment — 5 variants, 30+ integrations, extras for terminals, Git, VSCode, and more
- [git-iris](https://github.com/hyperb1iss/git-iris): AI-accelerated git workflow tool
- [contexter](https://github.com/hyperb1iss/contexter): Chrome extension and CLI for quickly copying code into LLMs
- [signalrgb-homeassistant](https://github.com/hyperb1iss/signalrgb-homeassistant): SignalRGB integration for Home
  Assistant
- [signalrgb-python](https://github.com/hyperb1iss/signalrgb-python): Python API client for SignalRGB Pro
- [hyper-light-card](https://github.com/hyperb1iss/hyper-light-card): Custom card for controlling SignalRGB through Home
  Assistant
- [aeonsync](https://github.com/hyperb1iss/aeonsync): An rsync backup tool for developers

## 📜 License

This project is open source and available under the [MIT License](LICENSE).

---

<div align="center">

Created by [Stefanie Jane 🌠](https://github.com/hyperb1iss)

If you find these dotfiles helpful, [buy me a Monster Ultra Violet](https://ko-fi.com/hyperb1iss)! ⚡️

</div>
