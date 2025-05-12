# 🍎 macOS Configuration

This directory contains macOS-specific setup files and utilities for Stefanie's dotfiles.

## 🔧 Components

- **brew.sh** - Installs Homebrew and essential packages
- **Brewfile** - Declarative package list for `brew bundle`
- **macos_config.sh** - Sets macOS system preferences for a developer-friendly environment
- **iterm2_profile.json** - Custom iTerm2 profile with Elektra color scheme

## 🚀 Installation

The macOS setup can be installed in two ways:

### Option 1: Quick install

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/hyperb1iss/dotfiles/main/install_macos.sh)"
```

### Option 2: Manual installation

```bash
# Clone the repository
git clone https://github.com/hyperb1iss/dotfiles.git ~/dev/dotfiles

# Install everything
cd ~/dev/dotfiles
make macos
```

## 🧩 Key Differences from Linux Setup

1. **Package Management**
   - Uses Homebrew instead of apt/pacman
   - Supports both CLI tools and GUI applications via Homebrew Casks

2. **Path Handling**
   - Handles different paths for Intel and Apple Silicon Macs
   - Provides seamless support for both architectures

3. **System Configuration**
   - Uses `defaults` command to configure macOS preferences
   - Sets up developer-friendly keyboard shortcuts and UI settings

4. **Terminal Setup**
   - Configures iTerm2 as the preferred terminal emulator
   - Provides custom profile with key bindings and appearance settings

5. **CLI Utilities**
   - Adds macOS-specific shell functions in `sh/macos.sh`
   - Provides convenient wrappers for macOS-specific operations

## 🔍 Additional Features

- **Clipboard Integration** - Enhanced clipboard utilities with pbcopy/pbpaste
- **Finder Integration** - Quick commands to show/hide hidden files
- **Quick Look** - Utility function for previewing files
- **App Shortcuts** - Aliases for common macOS applications
- **System Management** - Volume control, dark mode toggle, Wi-Fi info

## 📝 Post-Install Tasks

After installation, you might want to:

1. **Set up SSH keys** - Generate and configure SSH keys for GitHub, etc.
2. **Configure git** - Set your global git user and email
3. **Import iTerm2 profile** - The installation should set this up, but verify
4. **Restart your terminal** - Some changes require a restart to take effect

## 🔄 Updating

To update your configuration:

```bash
cd ~/dev/dotfiles
git pull
make macos
``` 