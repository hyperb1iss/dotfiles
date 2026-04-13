# brew.sh
# ⚡ Homebrew shortcuts

# Only load on macOS
is_macos || return 0

# Skip on minimal installations
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2> /dev/null || true

# ─────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────

alias bi='brew install'
alias bic='brew install --cask'
alias bls='brew list'
alias bsr='brew search'
alias binfo='brew info'

# ─────────────────────────────────────────────────────────────
# Functions
# ─────────────────────────────────────────────────────────────

# Brew update + upgrade with preview of what will change
function bup() {
  __sc_init_colors
  sc_header "Homebrew Update"
  echo ""

  sc_info "Fetching latest formulae..."
  brew update

  echo ""
  sc_info "Outdated packages:"
  local outdated
  outdated=$(brew outdated)

  if [[ -z "${outdated}" ]]; then
    sc_success "Everything is up to date"
    return 0
  fi

  echo "${outdated}"
  echo ""
  echo -ne "Upgrade all? [y/N] "
  read -r confirm
  if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    brew upgrade
    echo ""
    sc_success "Upgrade complete"
  else
    sc_muted "Skipped"
  fi
}
