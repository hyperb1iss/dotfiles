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
    echo "   Boot into Recovery, open Terminal, and run:"
    echo "   rm '/Volumes/Macintosh HD - Data/private/etc/pam.d/sudo_local'"
    echo "   Then reboot and rerun the installer."
  else
    echo "❌ Administrator sudo access is required for Homebrew setup."
    echo "   Make sure the bliss account is an Administrator, then rerun the installer."
  fi
}

function repair_stale_sudo_local() {
  local reattach_path
  local backup_path
  local sudo_local="/etc/pam.d/sudo_local"
  local tmp_path

  reattach_path="$(awk '/pam_reattach\.so/ { print $NF; exit }' "${sudo_local}" 2>/dev/null || true)"
  if [[ -z "${reattach_path}" || -f "${reattach_path}" ]]; then
    return 1
  fi

  if [[ "$(id -u)" != "0" ]]; then
    return 1
  fi

  backup_path="${sudo_local}.bak.$(date +%Y%m%d%H%M%S)"
  tmp_path="$(mktemp)"

  if ! cp -p "${sudo_local}" "${backup_path}" ||
    ! awk '!/pam_reattach\.so/' "${sudo_local}" >"${tmp_path}" ||
    ! cat "${tmp_path}" >"${sudo_local}"; then
    rm -f "${tmp_path}"
    echo "❌ Failed to repair ${sudo_local}"
    exit 1
  fi
  rm -f "${tmp_path}"

  echo "✓ Removed stale pam_reattach entry from ${sudo_local}"
  echo "  Backup saved to ${backup_path}"
  echo "  Reboot if sudo still errors, then rerun the installer as bliss."
  exit 0
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

function ensure_zshrc_link() {
  local backup_path
  local link_path="${HOME}/.zshrc"
  local target_path="${DOTFILES_DIR}/zsh/zshrc"

  if [[ -L "${link_path}" && "$(readlink "${link_path}")" == "${target_path}" ]]; then
    return 0
  fi

  if [[ -e "${link_path}" || -L "${link_path}" ]]; then
    backup_path="${link_path}.pre-dotfiles.$(date +%Y%m%d%H%M%S)"
    print_step "Backing up existing ~/.zshrc to ${backup_path}"
    mv "${link_path}" "${backup_path}"
  fi

  print_step "Linking ~/.zshrc to dotfiles"
  ln -s "${target_path}" "${link_path}"
}

# Detect if running on macOS
if [[ "${OSTYPE}" != "darwin"* ]]; then
  echo "❌ This script is only for macOS systems."
  exit 1
fi

print_step "Welcome to Stefanie's dotfiles installation for macOS!"

repair_stale_sudo_local || true

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

ensure_zshrc_link

# Run the installation
print_step "Running macOS installation..."
make macos

print_step "Setting Zsh as default shell..."
if [[ "${SHELL}" != "$(command -v zsh)" ]]; then
  chsh -s "$(command -v zsh)"
fi

print_step "Installation complete! 🎉"
echo "Some changes might require a restart to take effect."
echo "Please restart your terminal or run 'source ~/.zshrc' to apply changes."
