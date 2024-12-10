#!/bin/bash

# Only load on Arch Linux
if [ ! -f /etc/arch-release ]; then
    return 0
fi

# AUR helper functions

# Check if paru is installed, if not, install it
ensure_paru() {
    if ! command -v paru &>/dev/null; then
        echo "🔧 Installing paru AUR helper..."
        git clone https://aur.archlinux.org/paru.git /tmp/paru
        (cd /tmp/paru && makepkg -si --noconfirm)
        rm -rf /tmp/paru
    fi
}

# Search AUR packages
aur_search() {
    if [ -z "$1" ]; then
        echo "Usage: aur_search package_name"
        return 1
    fi
    ensure_paru
    paru -Ss "^$1"
}

# Install AUR package
aur_install() {
    if [ -z "$1" ]; then
        echo "Usage: aur_install package_name"
        return 1
    fi
    ensure_paru
    paru -S "$1"
}

# Update AUR packages
aur_update() {
    ensure_paru
    paru -Sua
}

# Get AUR package info
aur_info() {
    if [ -z "$1" ]; then
        echo "Usage: aur_info package_name"
        return 1
    fi
    ensure_paru
    paru -Si "$1"
}

# List installed AUR packages
list_aur_packages() {
    echo "📦 Installed AUR packages:"
    pacman -Qm
}

# Clean AUR build directory
clean_aur_cache() {
    echo "🧹 Cleaning AUR cache..."
    rm -rf ~/.cache/paru/clone/*
    paru -Sc --noconfirm
}

# Add command aliases if running in interactive shell
if [[ $- == *i* ]]; then
    alias aurs='aur_search'
    alias auri='aur_install'
    alias auru='aur_update'
    alias aurinfo='aur_info'
    alias aurlist='list_aur_packages'
    alias aurclean='clean_aur_cache'
fi
