# shell-utils.sh
# Cross-compatible utility functions for bash and zsh

# Detect current shell
if [ -n "$ZSH_VERSION" ]; then
    CURRENT_SHELL="zsh"
elif [ -n "$BASH_VERSION" ]; then
    CURRENT_SHELL="bash"
else
    CURRENT_SHELL="unknown"
fi

# Search file contents
function ftext() {
    grep -iIHrn --color=always "$1" . | less -R
}

# Extract common archive formats
function extract() {
    if [ -f "$1" ]; then
        case "$1" in
        *.tar.bz2) tar xjf "$1" ;;
        *.tar.gz) tar xzf "$1" ;;
        *.bz2) bunzip2 "$1" ;;
        *.rar) unrar e "$1" ;;
        *.gz) gunzip "$1" ;;
        *.tar) tar xf "$1" ;;
        *.tbz2) tar xjf "$1" ;;
        *.tgz) tar xzf "$1" ;;
        *.zip) unzip "$1" ;;
        *.Z) uncompress "$1" ;;
        *.7z) 7z x "$1" ;;
        *) echo "'$1' cannot be extracted via extract()" ;;
        esac
    else
        echo "'$1' is not a valid file"
    fi
}

# Interactive history search
function fh() {
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        eval "$(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//')"
    else
        eval "$(history | fzf +s --tac | sed 's/ *[0-9]* *//')"
    fi
}

# Find process by name
function psg() {
    ps aux | grep -v grep | grep -i "$@"
}
