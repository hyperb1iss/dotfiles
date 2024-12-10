# Common shell configurations for both bash and zsh

# History Configuration
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "
HISTIGNORE="ls:ll:cd:pwd:clear:history:fg:bg:jobs"

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

# Show inspirational quote for interactive shells
if [[ $- == *i* ]]; then
    # Check if Python and the script exist
    if command -v python3 >/dev/null 2>&1 && [ -f ~/dev/dotfiles/inspiration/inspiration.py ]; then
        python3 ~/dev/dotfiles/inspiration/inspiration.py
    fi
fi
