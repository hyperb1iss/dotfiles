# Common shell configurations for both bash and zsh

# History Configuration
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "
HISTIGNORE="ls:ll:cd:pwd:clear:history:fg:bg:jobs"

# Environment detection functions
get_installation_type() {
    local install_state_file="${HOME}/dev/dotfiles/.install_state"
    if [ -f "$install_state_file" ]; then
        cat "$install_state_file"
    else
        echo "unknown"
    fi
}

is_minimal() {
    [ "$(get_installation_type)" = "minimal" ]
}

is_full() {
    [ "$(get_installation_type)" = "full" ]
}

# Export these functions so they can be used in other scripts
export -f get_installation_type
export -f is_minimal
export -f is_full

# Source all utility scripts
for script in ~/dev/dotfiles/sh/*.sh; do
    if [[ "$script" != *"shell-common.sh" ]]; then
        source "$script"
    fi
done

# Load private configurations if they exist
[ -f ~/.rc.local ] && source ~/.rc.local

# Initialize Starship prompt
eval "$(starship init ${SHELL_NAME:-$([[ -n "$ZSH_VERSION" ]] && echo "zsh" || echo "bash")})"

# Show inspirational quote for interactive shells (only in full installation)
if [[ $- == *i* ]] && is_full; then
    # Check if Python and the script exist
    if command -v python3 >/dev/null 2>&1 && [ -f ~/dev/dotfiles/inspiration/inspiration.py ]; then
        python3 ~/dev/dotfiles/inspiration/inspiration.py
    fi
fi
