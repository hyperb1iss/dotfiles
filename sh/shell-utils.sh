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

# Enhanced mkdir that creates and changes to directory
function mkcd() {
    mkdir -p "$1" && cd "$1" || return
}

# Quick find files
function ff() {
    find . -type f -iname "*$1*"
}

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

# FZF Enhanced Functions

# Interactive directory navigation
function fcd() {
    local dir
    dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2>/dev/null | fzf +m) &&
        cd "$dir" || return
}

# Interactive history search
function fh() {
    if [ "$CURRENT_SHELL" = "zsh" ]; then
        eval "$(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//')"
    else
        eval "$(history | fzf +s --tac | sed 's/ *[0-9]* *//')"
    fi
}

# Interactive process kill
function fkill() {
    local pid
    pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
    if [ -n "$pid" ]; then
        echo "$pid" | xargs kill -"${1:-9}"
    fi
}

# Docker Functions

# Interactive docker container selection
function dex() {
    local cid
    cid=$(docker ps | sed 1d | fzf -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker exec -it "$cid" "${2:-bash}"
}

# Interactive docker container logs
function dlog() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker logs -f "$cid"
}

# Interactive docker container stop
function dstop() {
    local cid
    cid=$(docker ps | sed 1d | fzf -m -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker stop "$cid"
}

# Interactive docker container removal
function drm() {
    local cid
    cid=$(docker ps -a | sed 1d | fzf -m -q "$1" | awk '{print $1}')
    [ -n "$cid" ] && docker rm "$cid"
}

# System utilities

# Show directory size in human readable format
function duh() {
    du -h --max-depth=1 "${1:-.}" | sort -hr
}

# Create a new directory and enter it
function take() {
    mkdir -p "$@" && cd "${@:$#}" || return
}

# Find process by name
function psg() {
    ps aux | grep -v grep | grep -i "$@"
}
