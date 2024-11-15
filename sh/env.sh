# Environment variables and path configurations
# Shell-agnostic environment setup for both bash and zsh

# Ensure LS_COLORS is set if dircolors exists
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b ~/.dircolors)"
fi

# Enable CCACHE and set its directory
export USE_CCACHE=1
export CCACHE_DIR=/b/.ccache
export CCACHE_EXEC=/usr/bin/ccache

# AWS and Kubernetes configurations
export AWS_DEFAULT_PROFILE=mason-devops
export KUBECONFIG=$HOME/.kube/eksctl/clusters/mason-devops

# Python, Go, and other development environment setups
export GOPATH=~/dev/go
export GO15VENDOREXPERIMENT=1
export ANDROID_NDK_HOME=~/Android/android-ndk-r21e

# HOSTNAME
export HOSTNAME=$(hostname)

# PATH additions
# Using : to join paths for better readability
export PATH=$(echo -n "\
$HOME/.cargo/bin:\
$GOPATH/bin:\
$HOME/.local/bin:\
$HOME/bin:\
$PATH" | tr -s ':')

# Editor
export VISUAL=nvim
export EDITOR="$VISUAL"

# Source private environment variables if they exist
if [ -f ~/dev/dotfiles-private/env/private.sh ]; then
    source ~/dev/dotfiles-private/env/private.sh
fi
