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

# Make sure we're using the latest Homebrew
echo "Updating Homebrew..."
brew update

# Upgrade any already-installed formulae
echo "Upgrading existing packages..."
brew upgrade

# Install brew-bundle if not already installed
if ! brew list brew-bundle &> /dev/null; then
	echo "Installing brew-bundle..."
	brew tap Homebrew/bundle
fi

# Install packages from Brewfile
echo "Installing packages from Brewfile..."
brew bundle --file="${HOME}/dev/dotfiles/macos/Brewfile"

# Install Rust via rustup (more flexible than Homebrew's rust)
if ! command -v rustup > /dev/null 2>&1; then
	echo "Installing Rust via rustup..."
	curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
	source "${HOME}/.cargo/env"
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
