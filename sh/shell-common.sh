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

# Initialize Starship prompt (moved to the end)
eval "$(starship init ${SHELL_NAME:-$([[ -n "$ZSH_VERSION" ]] && echo "zsh" || echo "bash")})"
