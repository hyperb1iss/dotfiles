# typescript.sh
# ⚡ TypeScript & Monorepo development utilities

# Skip if in minimal mode
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2> /dev/null || true

# ─────────────────────────────────────────────────────────────
# Turborepo Aliases
# ─────────────────────────────────────────────────────────────

alias t='turbo'
alias tb='turbo build'
alias td='turbo dev'
alias tl='turbo lint:fix'
alias tt='turbo test'
alias tc='turbo typecheck'

# Filter shortcuts - build muscle memory
alias tf='turbo --filter'

# Quick filter patterns (expand as needed)
function tdf() { turbo dev --filter="$*"; }
function tbf() { turbo build --filter="$*"; }
function tcf() { turbo typecheck --filter="$*"; }
function ttf() { turbo test --filter="$*"; }

# Turbo housekeeping
alias tkill='pkill turbo'
alias tclear='rm -rf .turbo && sc_success "Turbo cache cleared"'
alias trestart='pkill turbo; sleep 1; turbo dev'

# ─────────────────────────────────────────────────────────────
# pnpm Aliases
# ─────────────────────────────────────────────────────────────

alias p='pnpm'
alias pi='pnpm install'
alias pa='pnpm add'
alias pad='pnpm add -D'
alias prm='pnpm remove'
alias pr='pnpm run'
alias pup='pnpm update'
alias pupi='pnpm update --interactive'
alias pout='pnpm outdated'
alias paudit='pnpm audit'

# ─────────────────────────────────────────────────────────────
# Git Iris Aliases (AI commit magic)
# ─────────────────────────────────────────────────────────────

# Your main workflow alias is already in git.sh as `gig`
# These are extras:
alias iris='git iris'
alias irisg='git iris gen'
alias irisp='git iris pr'
alias iriss='git iris studio'

# PR description generators
function gpr() {
  local from="${1:-HEAD~1}"
  git iris pr --from "${from}"
}

function gprc() {
  local from="${1:-HEAD~1}"
  git iris pr --from "${from}" --copy
}

# ─────────────────────────────────────────────────────────────
# TypeScript Type Checking
# ─────────────────────────────────────────────────────────────

alias tsc='pnpm exec tsc'
alias tcheck='pnpm exec tsc --noEmit'
alias tcw='pnpm exec tsc --noEmit --watch'
alias tsv='pnpm exec tsc --version'

# ─────────────────────────────────────────────────────────────
# Quick Runners
# ─────────────────────────────────────────────────────────────

alias tsx='pnpm exec tsx'

# Run TypeScript file directly
function ts() {
  __sc_init_colors
  if [[ -z "$1" ]]; then
    sc_warn "Usage: ts <file.ts> [args...]"
    return 1
  fi
  pnpm exec tsx "$@"
}

# Watch mode
function tsw() {
  __sc_init_colors
  if [[ -z "$1" ]]; then
    sc_warn "Usage: tsw <file.ts> [args...]"
    return 1
  fi
  pnpm exec tsx watch "$@"
}

# ─────────────────────────────────────────────────────────────
# Testing
# ─────────────────────────────────────────────────────────────

alias vt='pnpm exec vitest'
alias vtw='pnpm exec vitest --watch'
alias vtu='pnpm exec vitest --ui'
alias vtc='pnpm exec vitest --coverage'
alias vtr='pnpm exec vitest run'

# ─────────────────────────────────────────────────────────────
# Linting & Formatting
# ─────────────────────────────────────────────────────────────

alias lint='pnpm run lint:all'
alias lintf='pnpm run lint:fix'
alias fmt='pnpm exec prettier --write'
alias bio='pnpm exec biome'
alias biof='pnpm exec biome check --write'

# ─────────────────────────────────────────────────────────────
# Claude Code
# ─────────────────────────────────────────────────────────────

alias cc='claude'
alias ccc='claude --continue'

# ─────────────────────────────────────────────────────────────
# Monorepo Navigation (fzf-powered)
# ─────────────────────────────────────────────────────────────

# Jump to a package/app in the monorepo
function mono() {
  __sc_init_colors
  if ! has_command fzf; then
    sc_error "fzf required"
    return 1
  fi

  local root
  root=$(git rev-parse --show-toplevel 2> /dev/null) || {
    sc_error "Not in a git repo"
    return 1
  }

  local pkg
  pkg=$(fd -t d -d 3 'package.json' "${root}" --exec dirname {} \; 2> /dev/null \
    | fzf --preview 'jq -r ".name // \"(no name)\"" {}/package.json 2>/dev/null; echo "---"; ls -la {}' \
      --header '⚡ Select package')

  if [[ -n "${pkg}" ]]; then
    cd "${pkg}" || return 1
    sc_info "${pkg}"
  fi
}

# List all workspace packages
function monols() {
  __sc_init_colors
  local root
  root=$(git rev-parse --show-toplevel 2> /dev/null) || {
    sc_error "Not in a git repo"
    return 1
  }

  echo -e "${SC_CYAN}${SC_BOLD}━━━ Workspace Packages ━━━${SC_RESET}"
  echo ""

  # shellcheck disable=SC2016  # Single quotes intentional - subshell expands $1
  fd -t f 'package.json' "${root}" -d 3 --exec sh -c '
    dir=$(dirname "$1")
    name=$(jq -r ".name // \"(unnamed)\"" "$1" 2>/dev/null)
    version=$(jq -r ".version // \"-\"" "$1" 2>/dev/null)
    printf "\033[38;2;225;53;255m▸\033[0m \033[38;2;128;255;234m%-35s\033[0m \033[38;2;241;250;140m%s\033[0m\n" "${name}" "${version}"
  ' _ {} \; 2> /dev/null | grep -v node_modules | sort
}

# ─────────────────────────────────────────────────────────────
# Project Info
# ─────────────────────────────────────────────────────────────

function ts-info() {
  __sc_init_colors

  echo -e "${SC_CYAN}${SC_BOLD}━━━ Project Info ━━━${SC_RESET}"
  echo ""

  # Node version
  if has_command node; then
    echo -e "${SC_PURPLE}▸${SC_RESET} Node: ${SC_CYAN}$(node --version)${SC_RESET}"
  fi

  # Package manager
  if [[ -f "pnpm-lock.yaml" ]]; then
    echo -ne "${SC_PURPLE}▸${SC_RESET} PM: ${SC_CYAN}pnpm${SC_RESET}"
    [[ -f "pnpm-workspace.yaml" ]] && echo -ne " (monorepo)"
    echo ""
  fi

  # TypeScript version
  if [[ -f "node_modules/.bin/tsc" ]]; then
    local tsv
    tsv=$(pnpm exec tsc --version 2> /dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    echo -e "${SC_PURPLE}▸${SC_RESET} TypeScript: ${SC_CYAN}${tsv:-not installed}${SC_RESET}"
  fi

  # Turbo
  if [[ -f "turbo.json" ]]; then
    echo -e "${SC_PURPLE}▸${SC_RESET} Turbo: ${SC_GREEN}enabled${SC_RESET}"
  fi

  # Check for common tooling in package.json
  if [[ -f "package.json" ]]; then
    echo ""
    echo -e "${SC_CYAN}${SC_BOLD}━━━ Tooling ━━━${SC_RESET}"
    echo ""
    local pkg="package.json"
    [[ $(grep -c '"vitest"' "${pkg}") -gt 0 ]] && echo -e "  ${SC_GREEN}✓${SC_RESET} vitest"
    [[ $(grep -c '"biome"' "${pkg}") -gt 0 ]] && echo -e "  ${SC_GREEN}✓${SC_RESET} biome"
    [[ $(grep -c '"eslint"' "${pkg}") -gt 0 ]] && echo -e "  ${SC_GREEN}✓${SC_RESET} eslint"
    [[ $(grep -c '"prettier"' "${pkg}") -gt 0 ]] && echo -e "  ${SC_GREEN}✓${SC_RESET} prettier"
  fi
}
