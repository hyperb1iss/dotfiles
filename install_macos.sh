#!/bin/bash
# install_macos.sh
# Installer script for macOS dotfiles

set -e # Exit on error

# Print with emoji
function print_step() {
  echo "✨ $1"
}

function diagnose_sudo_failure() {
  local reattach_path

  reattach_path="$(awk '/pam_reattach\.so/ { print $NF; exit }' /etc/pam.d/sudo_local 2>/dev/null || true)"
  if [[ -n "${reattach_path}" && ! -f "${reattach_path}" ]]; then
    echo "❌ sudo is blocked by a stale pam_reattach entry:"
    echo "   ${reattach_path}"
    echo "   Remove that line from /etc/pam.d/sudo_local from an admin/root shell,"
    echo "   then rerun the installer."
  else
    echo "❌ Administrator sudo access is required for Homebrew setup."
    echo "   Make sure the bliss account is an Administrator, then rerun the installer."
  fi
}

function require_sudo() {
  if sudo -n -v 2>/dev/null; then
    return 0
  fi

  echo "Requesting administrator privileges for Homebrew setup..."
  if [[ -r /dev/tty ]] && sudo -v </dev/tty; then
    return 0
  fi

  diagnose_sudo_failure
  exit 1
}

function start_sudo_keepalive() {
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT
}

# Detect if running on macOS
if [[ "${OSTYPE}" != "darwin"* ]]; then
  echo "❌ This script is only for macOS systems."
  exit 1
fi

print_step "Welcome to Stefanie's dotfiles installation for macOS!"

# Install command line tools if needed
if ! xcode-select -p &>/dev/null; then
  print_step "Installing Command Line Tools..."
  xcode-select --install

  echo "⚠️ Command Line Tools installation has been initiated."
  echo "⚠️ Please complete the installation prompt that appeared."
  echo "⚠️ Once installation is complete, run this script again."
  exit 0
fi

# Install Homebrew if needed
if ! command -v brew &>/dev/null; then
  require_sudo
  start_sudo_keepalive
  print_step "Installing Homebrew..."
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

  # Add Homebrew to PATH based on architecture
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

# Ensure Homebrew is in PATH
if [[ $(uname -m) == "arm64" ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
else
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Update Homebrew
print_step "Updating Homebrew..."
brew update

# Install git if not already installed
if ! command -v git &>/dev/null; then
  print_step "Installing Git..."
  brew install git
fi

# Clone repository if not already cloned
DOTFILES_DIR="${HOME}/dev/dotfiles"
if [[ ! -d "${DOTFILES_DIR}" ]]; then
  print_step "Cloning dotfiles repository..."
  mkdir -p "${HOME}/dev"
  git clone https://github.com/hyperb1iss/dotfiles.git "${DOTFILES_DIR}"
  cd "${DOTFILES_DIR}"
else
  print_step "Using existing dotfiles repository..."
  cd "${DOTFILES_DIR}"
  git pull
fi

# Install or update Dotbot submodule
if [[ ! -d "dotbot" ]]; then
  print_step "Installing Dotbot..."
  git submodule update --init --recursive
else
  print_step "Updating Dotbot..."
  git submodule update --remote dotbot
fi

# Ensure Go is installed for fzf
if ! command -v go &>/dev/null; then
  print_step "Installing Go (required for fzf)..."
  brew install go
fi

# Run the installation
print_step "Running macOS installation..."
make macos

# Create zsh setup if it doesn't exist
if [[ ! -f ~/.zshrc ]]; then
  print_step "Setting up Zsh configuration..."
  ln -sf "${DOTFILES_DIR}/zsh/zshrc" ~/.zshrc
fi

print_step "Setting Zsh as default shell..."
if [[ "${SHELL}" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

print_step "Installation complete! 🎉"
echo "Some changes might require a restart to take effect."
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
