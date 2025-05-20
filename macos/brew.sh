#!/bin/bash
# brew.sh
# Homebrew installation and package setup for macOS

set -e # Exit on error

echo "🍺 Setting up Homebrew for macOS..."

# Install Homebrew if it's not installed
if ! command -v brew > /dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to path based on architecture
  if [[ $(uname -m) == "arm64" ]]; then
    # M1/M2 Mac
    echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" >> ~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Intel Mac
    echo "eval \"\$(/usr/local/bin/brew shellenv)\"" >> ~/.zprofile
    eval "$(/usr/local/bin/brew shellenv)"
  fi
fi

# Ensure Homebrew is in PATH (fixes "not in your PATH" warning)
if [[ $(uname -m) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Make sure we're using the latest Homebrew
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae
echo "Upgrading existing packages..."
brew upgrade

# Install packages from Brewfile (directly, without the deprecated brew-bundle)
echo "Installing packages from Brewfile..."
brew bundle --file="${HOME}/dev/dotfiles/macos/Brewfile"

# Install Rust via rustup (more flexible than Homebrew's rust)
if ! command -v rustup > /dev/null 2>&1; then
  echo "Installing Rust via rustup..."
  curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
  # Export PATH immediately so cargo is available in this script
  export PATH="${HOME}/.cargo/bin:${PATH}"
  
  # Add to profile files for persistence
  if [[ ! -f "${HOME}/.zprofile" ]] || ! grep -q "source \"\${HOME}/.cargo/env\"" "${HOME}/.zprofile"; then
    echo 'source "${HOME}/.cargo/env"' >> "${HOME}/.zprofile"
  fi
  
  if [[ ! -f "${HOME}/.profile" ]] || ! grep -q "source \"\${HOME}/.cargo/env\"" "${HOME}/.profile"; then
    echo 'source "${HOME}/.cargo/env"' >> "${HOME}/.profile"
  fi
  
  # Also add to zshrc for immediate use
  if [[ ! -f "${HOME}/.zshrc" ]] || ! grep -q "source \"\${HOME}/.cargo/env\"" "${HOME}/.zshrc"; then
    echo 'source "${HOME}/.cargo/env"' >> "${HOME}/.zshrc"
  fi
fi

# Ensure cargo is available for the rest of this script
if [[ -f "${HOME}/.cargo/env" ]]; then
  source "${HOME}/.cargo/env"
fi

# Install cargo packages
if command -v cargo > /dev/null 2>&1; then
  echo "Installing cargo packages..."
  cargo install git-delta lsd macchina || true
fi

# Create symlinks for Homebrew-installed JDK
if [[ -d /opt/homebrew/opt/openjdk@17 ]]; then
  echo "Setting up JDK symlinks..."
  sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
elif [[ -d /usr/local/opt/openjdk@17 ]]; then
  echo "Setting up JDK symlinks..."
  sudo ln -sfn /usr/local/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
fi

# Remove outdated versions
echo "Cleaning up..."
brew cleanup

echo "✅ Homebrew packages installed successfully!"
