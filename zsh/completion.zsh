# Completion settings

# Use modern completion system
autoload -Uz compinit
compinit

# Basic completion settings with enhanced colors
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' completer _expand _complete _correct _approximate
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# Enhanced list colors for file completions based on file types
zstyle ':completion:*' list-colors 'di=01;34:ln=01;36:so=01;35:pi=33:ex=01;32:bd=33;01:cd=33;01:su=37;41:sg=30;43:tw=30;42:ow=34;42:st=37;44:mi=05;37;41:or=05;37;41:fi=00'

# Matcher settings for case-insensitive completion
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# SSH Hostname completion based on ~/.ssh/config
if [[ -e "$HOME/.ssh/config" ]]; then
    zstyle ':completion:*:*:ssh:*' hosts "$(awk '/^Host / {print $2}' ~/.ssh/config | grep -v '[*?]')"
fi

# Enable extended globbing for more powerful pattern matching
setopt extended_glob

# Allow for case-insensitive completions
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# Enable path expansion (e.g., ~/ expands to the home directory)
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Integrate fzf with completion
export FZF_COMPLETION_TRIGGER=''
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'

# History and directory search using fzf
# Bind Ctrl+R to search through command history
bindkey '^R' fzf-history-widget
# Bind Ctrl+T to search for files
bindkey '^T' fzf-file-widget
# Bind Alt+C to search and cd into directories
bindkey '^[C' fzf-cd-widget

# Use color output for completions
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Additional color customization for different types of completions
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}: \
  'fi=00' 'di=01;34' 'ln=01;36' 'pi=33' 'so=01;35' \
  'bd=33;01' 'cd=33;01' 'or=01;31' 'mi=05;37;41' \
  'ex=01;32' 'su=37;41' 'sg=30;43' 'tw=30;42' \
  'ow=34;42' 'st=37;44'

# Enhancing colors for descriptions, messages, and warnings
zstyle ':completion:*:descriptions' format '%B%F{blue}%d%b%f'
zstyle ':completion:*:messages' format '%B%F{yellow}%d%b%f'
zstyle ':completion:*:warnings' format '%B%F{red}%d%b%f'
