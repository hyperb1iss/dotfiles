# Common shell configurations for both bash and zsh

# History Configuration
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "
HISTIGNORE="ls:ll:cd:pwd:clear:history:fg:bg:jobs"

# Load FZF key bindings and completion
if [ -n "$BASH_VERSION" ]; then
    [ -f /usr/share/doc/fzf/examples/key-bindings.bash ] && source /usr/share/doc/fzf/examples/key-bindings.bash
    [ -f /usr/share/bash-completion/completions/fzf ] && source /usr/share/bash-completion/completions/fzf
elif [ -n "$ZSH_VERSION" ]; then
    [ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
fi

# Initialize Starship prompt
eval "$(starship init ${SHELL_NAME:-bash})"

# Source all utility scripts
for script in ~/dev/dotfiles/sh/*.sh; do
    if [[ "$script" != *"shell-common.sh" ]]; then
        source "$script"
    fi
done

# Load private configurations if they exist
[ -f ~/.rc.local ] && source ~/.rc.local
