#!/bin/bash

# Only load on Arch Linux
if [ ! -f /etc/arch-release ]; then
    return 0
fi

# Arch Linux helper functions

# Search for packages in official repositories
search_pkg() {
    if [ -z "$1" ]; then
        echo "Usage: search_pkg package_name"
        return 1
    fi
    pacman -Ss "$1"
}

# Get package info
pkg_info() {
    if [ -z "$1" ]; then
        echo "Usage: pkg_info package_name"
        return 1
    fi
    pacman -Si "$1"
}

# List explicitly installed packages
list_installed() {
    echo "📋 Explicitly installed packages:"
    pacman -Qe
}

# Check which package owns a file
owns_file() {
    if [ -z "$1" ]; then
        echo "Usage: owns_file /path/to/file"
        return 1
    fi
    pacman -Qo "$1"
}

# List package files
list_pkg_files() {
    if [ -z "$1" ]; then
        echo "Usage: list_pkg_files package_name"
        return 1
    fi
    pacman -Ql "$1"
}

# Check for modified package files
check_modified() {
    echo "🔍 Checking for modified package files..."
    pacman -Qk
}

# Show package dependencies
show_deps() {
    if [ -z "$1" ]; then
        echo "Usage: show_deps package_name"
        return 1
    fi
    pactree "$1"
}

# Show reverse dependencies
show_rdeps() {
    if [ -z "$1" ]; then
        echo "Usage: show_rdeps package_name"
        return 1
    fi
    pactree -r "$1"
}

# Add command aliases if running in interactive shell
if [[ $- == *i* ]]; then
    alias search='search_pkg'
    alias pkginfo='pkg_info'
    alias installed='list_installed'
    alias owns='owns_file'
    alias pkgfiles='list_pkg_files'
    alias deps='show_deps'
    alias rdeps='show_rdeps'
fi
