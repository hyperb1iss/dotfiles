# Environment variables and path configurations
# Shell-agnostic environment setup for both bash and zsh

# Ensure LS_COLORS is set if dircolors exists
if command -v dircolors >/dev/null 2>&1; then
    eval "$(dircolors -b ~/.dircolors)"
fi

# Development tool configurations
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

# AWS and Kubernetes configurations
export AWS_DEFAULT_PROFILE=mason-devops
export KUBECONFIG=$HOME/.kube/eksctl/clusters/mason-devops

# Development paths
export GOPATH=~/dev/go
export GO15VENDOREXPERIMENT=1
export ANDROID_NDK_HOME=~/Android/android-ndk-r21e

# Editor configuration
export VISUAL=nvim
export EDITOR="$VISUAL"

# Add bat alias
alias bat="batcat"

# HOSTNAME
export HOSTNAME=$(hostname)

# PATH configuration
export PATH=$(echo -n "\
$HOME/.cargo/bin:\
$GOPATH/bin:\
$HOME/.local/bin:\
$HOME/bin:\
$PATH" | tr -s ':')

# FZF Configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Source private environment variables if they exist
if [ -f ~/dev/dotfiles-private/env/private.sh ]; then
    source ~/dev/dotfiles-private/env/private.sh
fi
