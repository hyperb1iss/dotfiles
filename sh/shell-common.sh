# shell-common.sh
# Common shell configurations for both bash and zsh

# 1. Core utilities - Load first
#-------------------------------------------------

# Shell detection functions
function is_zsh() {
  [[ -n "${ZSH_VERSION}" ]]
}

function is_bash() {
  [[ -n "${BASH_VERSION}" ]]
}

# Shell detection (used internally)
function get_shell_type() {
  if is_zsh; then
    echo "zsh"
  elif is_bash; then
    echo "bash"
  else
    echo "unknown"
  fi
}

# Platform detection
function is_macos() {
  [[ "${OSTYPE}" == "darwin"* ]]
}

function is_wsl() {
  grep -qi microsoft /proc/version 2> /dev/null
}

function is_linux() {
  [[ "${OSTYPE}" == "linux-gnu"* ]] && ! is_wsl
}

# Command availability check
function has_command() {
  command -v "$1" > /dev/null 2>&1
}

# Installation type detection
DOTFILES_INSTALLATION_TYPE="unknown"
if [[ -r "${HOME}/dev/dotfiles/.install_state" ]]; then
  IFS= read -r DOTFILES_INSTALLATION_TYPE < "${HOME}/dev/dotfiles/.install_state"
fi

function get_installation_type() {
  printf '%s\n' "${DOTFILES_INSTALLATION_TYPE}"
}

function is_minimal() {
  [[ "${DOTFILES_INSTALLATION_TYPE}" = "minimal" ]]
}

function is_full() {
  [[ "${DOTFILES_INSTALLATION_TYPE}" = "full" ]]
}

# Safe source function that doesn't break on errors
function safe_source() {
  if [[ -f "$1" ]]; then
    # shellcheck disable=SC1090
    source "$1" || echo "Warning: Error sourcing $1"
    return 0
  fi
  return 1
}

# 2. History configuration (bash-specific; zsh history is in zshrc)
#-------------------------------------------------
if is_bash; then
  HISTSIZE=50000
  HISTFILESIZE=50000
  HISTCONTROL=ignoreboth:erasedups
  HISTTIMEFORMAT="%F %T "
  HISTIGNORE="ls:ll:cd:pwd:clear:history:fg:bg:jobs"
fi

# 3. Load all utility scripts with consistent error handling
#-------------------------------------------------
# Zsh will use Zinit to load these scripts individually.
# Bash will load them in bashrc.local.

# 4. Load private configurations
#-------------------------------------------------
safe_source ~/.rc.local

# 5. Initialize prompt
#-------------------------------------------------
# Shell-specific prompt initialization (e.g., Starship)
# will be handled in their respective rc files (zshrc, bashrc.local).

# 6. Inspiration helper (opt-in for interactive shells)
#    Set DOTFILES_NO_INSPIRATION=1 to disable
#-------------------------------------------------
function show_inspiration() {
  if has_command python3 && [[ -f ~/dev/dotfiles/inspiration/inspiration.py ]]; then
    python3 ~/dev/dotfiles/inspiration/inspiration.py
  fi
}

if [[ $- == *i* ]] && is_full && [[ "${SHOW_SHELL_INSPIRATION:-0}" = "1" ]] && [[ -z "${DOTFILES_NO_INSPIRATION:-}" ]]; then
  show_inspiration
fi
