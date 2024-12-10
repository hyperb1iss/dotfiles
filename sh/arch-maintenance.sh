#!/bin/bash

# Only load on Arch Linux
if [ ! -f /etc/arch-release ]; then
    return 0
fi

# Arch Linux system maintenance functions

# Update system and clean package cache
update_system() {
    echo "📦 Updating system packages..."
    sudo pacman -Syu

    echo "🧹 Cleaning package cache..."
    sudo pacman -Sc --noconfirm

    if command -v paru &>/dev/null; then
        echo "🔄 Updating AUR packages..."
        paru -Sua
    fi
}

# Remove orphaned packages
remove_orphans() {
    echo "🗑️ Removing orphaned packages..."
    sudo pacman -Rns $(pacman -Qtdq) 2>/dev/null || echo "No orphaned packages found."
}

# Check systemd failed services
check_failed_services() {
    echo "🔍 Checking failed systemd services..."
    systemctl --failed
}

# Clean journal logs
clean_journals() {
    echo "📝 Cleaning old journal logs..."
    sudo journalctl --vacuum-time=2weeks
}

# Check for pacnew files
check_pacnew() {
    echo "📄 Checking for .pacnew configuration files..."
    find /etc -name "*.pacnew" -o -name "*.pacsave"
}

# Main maintenance function
arch_maintenance() {
    update_system
    remove_orphans
    check_failed_services
    clean_journals
    check_pacnew
    echo "✅ System maintenance completed!"
}

# Add command aliases if running in interactive shell
if [[ $- == *i* ]]; then
    alias arch-update='update_system'
    alias arch-clean='remove_orphans'
    alias arch-maintain='arch_maintenance'
fi
