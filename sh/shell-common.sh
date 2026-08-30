# shell-common.sh
# Common shell configurations for both bash and zsh

# Canonical dotfiles location — modules and colors.sh sourcing rely on it
export DOTFILES="${DOTFILES:-$HOME/dev/dotfiles}"

# Cache a tool's init-script output and source it, regenerating when the
# tool binary is newer than the cache. Each eval'd `tool init <shell>`
# spawn costs 10-50ms of startup; this makes them one-time costs.
# Usage: cached_eval <tool> <cache-name> <command...>
function cached_eval() {
  local tool="$1" cache_name="$2"
  shift 2
  local tool_path cache_dir cache_file
  tool_path=$(command -v "${tool}" 2> /dev/null) || return 0
  cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles"
  [[ -d "${cache_dir}" ]] || mkdir -p "${cache_dir}"
  cache_file="${cache_dir}/${cache_name}"
  if [[ ! -s "${cache_file}" || "${tool_path}" -nt "${cache_file}" ]]; then
    "$@" > "${cache_file}" 2> /dev/null || {
      rm -f "${cache_file}"
      return 0
    }
  fi
  # shellcheck disable=SC1090
  source "${cache_file}"
}

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

# Read /proc/version in-shell rather than shelling out to grep. The
# grep spawn cost 2ms of every shell start, and on macOS it paid that
# to look for a file that cannot exist. WSL1 writes "Microsoft" in the
# kernel string, WSL2 writes "microsoft".
function is_wsl() {
  [[ -r /proc/version ]] || return 1
  local kernel_version
  IFS= read -r kernel_version < /proc/version 2> /dev/null || return 1
  case "${kernel_version}" in
    *[Mm]icrosoft*) return 0 ;;
    *) return 1 ;;
  esac
}

function is_linux() {
  [[ "${OSTYPE}" == "linux-gnu"* ]] && ! is_wsl
}

# Command availability check
function has_command() {
  command -v "$1" > /dev/null 2>&1
}

# Installation role detection. `make install` writes the composed role
# (desktop or server) to .dotfiles_role; .install_state is the pre-layers
# name, still read so a machine that has not reinstalled keeps its role.
# The file is gitignored, so a worktree has none of its own: fall back to
# the installed tree rather than reporting "unknown", which on a server
# would load every module where the real shell loads a trimmed set.
DOTFILES_INSTALLATION_TYPE="unknown"
for __dotfiles_state in \
  "${DOTFILES}/.dotfiles_role" \
  "${HOME}/dev/dotfiles/.dotfiles_role" \
  "${DOTFILES}/.install_state" \
  "${HOME}/dev/dotfiles/.install_state"; do
  if [[ -r "${__dotfiles_state}" ]]; then
    IFS= read -r DOTFILES_INSTALLATION_TYPE < "${__dotfiles_state}"
    break
  fi
done
unset __dotfiles_state
if [[ "${DOTFILES_INSTALLATION_TYPE}" = "minimal" ]]; then
  DOTFILES_INSTALLATION_TYPE="server"
fi

function get_installation_type() {
  printf '%s\n' "${DOTFILES_INSTALLATION_TYPE}"
}

function is_minimal() {
  [[ "${DOTFILES_INSTALLATION_TYPE}" = "server" ]]
}

function is_full() {
  [[ "${DOTFILES_INSTALLATION_TYPE}" != "server" && "${DOTFILES_INSTALLATION_TYPE}" != "unknown" ]]
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
  if has_command python3 && [[ -f "${DOTFILES}/inspiration/inspiration.py" ]]; then
    python3 "${DOTFILES}/inspiration/inspiration.py"
  fi
}

if [[ $- == *i* ]] && is_full && [[ "${SHOW_SHELL_INSPIRATION:-0}" = "1" ]] && [[ -z "${DOTFILES_NO_INSPIRATION:-}" ]]; then
  show_inspiration
fi
