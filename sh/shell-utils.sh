# shell-utils.sh
# Cross-compatible utility functions for bash and zsh

# Skip on minimal installations
is_minimal && return 0

# Search file contents
function ftext() {
  grep -iIHrn --color=always "$1" . | ${PAGER:-less}
}

# Extract common archive formats
function extract() {
  if [[ -f "$1" ]]; then
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
  if is_zsh; then
    # shellcheck disable=SC1090,SC2046,SC2086
    eval "$(fc -l 1 | fzf +s --tac | sed 's/ *[0-9]* *//')"
  else
    # shellcheck disable=SC1090,SC2046,SC2086
    eval "$(history | fzf +s --tac | sed 's/ *[0-9]* *//')"
  fi
}

# Find process by name
function psg() {
  pgrep -f -a "$@"
}
