#!/bin/bash
# brew.sh
# Homebrew installation and package setup for macOS

set -e # Exit on error

echo "🍺 Setting up Homebrew for macOS..."

diagnose_sudo_failure() {
  local reattach_path

  reattach_path="$(awk '/pam_reattach\.so/ { print $NF; exit }' /etc/pam.d/sudo_local 2>/dev/null || true)"
  if [[ -n "${reattach_path}" && ! -f "${reattach_path}" ]]; then
    echo "❌ sudo is blocked by a stale pam_reattach entry:"
    echo "   ${reattach_path}"
    echo "   Boot into Recovery, open Terminal, and run:"
    echo "   rm '/Volumes/Macintosh HD - Data/private/etc/pam.d/sudo_local'"
    echo "   Then reboot and rerun make macos."
  else
    echo "❌ Administrator sudo access is required for Homebrew setup."
    echo "   Make sure the bliss account is an Administrator, then rerun make macos."
  fi
}

repair_stale_sudo_local() {
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
  echo "  Reboot if sudo still errors, then rerun make macos as bliss."
  exit 0
}

require_sudo() {
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

start_sudo_keepalive() {
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!
  trap 'kill "${SUDO_KEEPALIVE_PID}" 2>/dev/null || true' EXIT
}

repair_stale_sudo_local || true
require_sudo
start_sudo_keepalive

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

# git-delta and lsd are installed via Brewfile — no need for cargo duplicates

# Remove outdated versions
echo "Cleaning up..."
brew cleanup

echo "✅ Homebrew packages installed successfully!"
