#!/bin/bash
# brew.sh
# Homebrew installation and package setup for macOS

set -e # Exit on error

echo "🍺 Setting up Homebrew for macOS..."

# Install Homebrew if it's not installed
if ! command -v brew >/dev/null 2>&1; then
  echo "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to path based on architecture
  if [[ $(uname -m) == "arm64" ]]; then
    # M1/M2 Mac
    echo "eval \"\$(/opt/homebrew/bin/brew shellenv)\"" >>~/.zprofile
    eval "$(/opt/homebrew/bin/brew shellenv)"
  else
    # Intel Mac
    echo "eval \"\$(/usr/local/bin/brew shellenv)\"" >>~/.zprofile
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

# Set up Java symlink for java_home utility
echo "Setting up Java symlink..."
if [[ $(uname -m) == "arm64" ]]; then
  brew_prefix="/opt/homebrew"
else
  brew_prefix="/usr/local"
fi

if [[ -d "${brew_prefix}/opt/openjdk" ]]; then
  sudo ln -sfn "${brew_prefix}/opt/openjdk/libexec/openjdk.jdk" "/Library/Java/JavaVirtualMachines/openjdk.jdk"
  echo "✓ Linked latest OpenJDK for java_home utility"
else
  echo "⚠️  No OpenJDK installation found to link"
fi

# Set up Rust environment for Homebrew's rustup
echo "Setting up Rust environment..."
if command -v rustup >/dev/null 2>&1; then
  # Install stable toolchain if none exists
  if ! rustup toolchain list | grep -q "stable"; then
    echo "Installing stable Rust toolchain..."
    rustup toolchain install stable
    rustup default stable
  fi

  # Get the active toolchain and set up PATH for current session
  active_toolchain=$(rustup show active-toolchain 2>/dev/null | cut -d' ' -f1) || true
  if [[ -n "${active_toolchain}" && -d "${HOME}/.rustup/toolchains/${active_toolchain}/bin" ]]; then
    export PATH="${HOME}/.rustup/toolchains/${active_toolchain}/bin:${PATH}"
  fi

  # Also add ~/.cargo/bin for installed packages
  [[ -d "${HOME}/.cargo/bin" ]] && export PATH="${HOME}/.cargo/bin:${PATH}"
else
  echo "⚠️  rustup not found. Please install it with 'brew install rustup-init && rustup-init'"
fi

# Install cargo packages if cargo is available
if command -v cargo >/dev/null 2>&1; then
  echo "Installing useful cargo packages..."
  cargo install --quiet git-delta lsd macchina || echo "⚠️  Some cargo packages failed to install"
else
  echo "⚠️  cargo not available, skipping cargo package installation"
fi

# Remove outdated versions
echo "Cleaning up..."
brew cleanup

echo "✅ Homebrew packages installed successfully!"
