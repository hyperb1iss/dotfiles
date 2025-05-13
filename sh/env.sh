# env.sh
# Environment variables and path configurations
# Shell-agnostic environment setup for both bash and zsh

# Ensure LS_COLORS is set if dircolors exists
if has_command dircolors; then
	eval "$(dircolors -b ~/.dircolors)" || true
fi

# Development tool configurations
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

# Development paths
export GOPATH=~/dev/go
export GO15VENDOREXPERIMENT=1
export ANDROID_HOME=~/Android/Sdk
export ANDROID_NDK_HOME=~/Android/android-ndk

# Editor configuration
export VISUAL=nvim
export EDITOR="${VISUAL}"

# Set up bat/batcat aliases based on what's available
if has_command batcat; then
	alias bat="batcat"
elif has_command bat; then
	alias batcat="bat"
fi

# HOSTNAME
HOSTNAME=$(hostname)
export HOSTNAME

# PATH configuration - separate declaration and assignment to avoid masking return values
PATH_COMPONENTS=""
PATH_COMPONENTS+="${HOME}/.cargo/bin:"
PATH_COMPONENTS+="${GOPATH}/bin:"
PATH_COMPONENTS+="${HOME}/.local/bin:"
PATH_COMPONENTS+="${HOME}/bin:"
# Add snap bin if it exists
[[ -d /snap/bin ]] && PATH_COMPONENTS+="/snap/bin:"
PATH_COMPONENTS+="${PATH}"

# Properly separate declaration and assignment
PATH_TEMP=$(echo -n "${PATH_COMPONENTS}" | tr -s ':')
export PATH="${PATH_TEMP}"

# FZF Configuration
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --preview 'bat --color=always --style=numbers --line-range=:500 {}'"

# Source private environment variables if they exist
# shellcheck source=/home/bliss/dev/dotfiles-private/env/private.sh
safe_source ~/dev/dotfiles-private/env/private.sh
