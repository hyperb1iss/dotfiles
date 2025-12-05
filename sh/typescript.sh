# typescript.sh
# TypeScript & Monorepo development utilities

# Skip if in minimal mode
is_minimal && return 0

# ============================================================================
# Turborepo Aliases
# ============================================================================

alias t='turbo'
alias tb='turbo build'
alias td='turbo dev'
alias tl='turbo lint:fix'
alias tt='turbo test'
alias tc='turbo typecheck'

# Filter shortcuts - build muscle memory
alias tf='turbo --filter'

# Quick filter patterns (expand as needed)
function tdf() { turbo dev --filter="$@"; }
function tbf() { turbo build --filter="$@"; }
function tcf() { turbo typecheck --filter="$@"; }
function ttf() { turbo test --filter="$@"; }

# Turbo housekeeping
alias tkill='pkill turbo'
alias tclear='rm -rf .turbo && printf "\033[38;2;80;250;123m✓\033[0m Turbo cache cleared\n"'
alias trestart='pkill turbo; sleep 1; turbo dev'

# ============================================================================
# pnpm Aliases
# ============================================================================

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

# ============================================================================
# Git Iris Aliases (AI commit magic)
# ============================================================================

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

# ============================================================================
# TypeScript Type Checking
# ============================================================================

alias tsc='pnpm exec tsc'
alias tcheck='pnpm exec tsc --noEmit'
alias tcw='pnpm exec tsc --noEmit --watch'
alias tsv='pnpm exec tsc --version'

# ============================================================================
# Quick Runners
# ============================================================================

alias tsx='pnpm exec tsx'

# Run TypeScript file directly
function ts() {
  if [[ -z "$1" ]]; then
    printf '\033[38;2;241;250;140m⚠\033[0m Usage: ts <file.ts> [args...]\n'
    return 1
  fi
  pnpm exec tsx "$@"
}

# Watch mode
function tsw() {
  if [[ -z "$1" ]]; then
    printf '\033[38;2;241;250;140m⚠\033[0m Usage: tsw <file.ts> [args...]\n'
    return 1
  fi
  pnpm exec tsx watch "$@"
}

# ============================================================================
# Testing
# ============================================================================

alias vt='pnpm exec vitest'
alias vtw='pnpm exec vitest --watch'
alias vtu='pnpm exec vitest --ui'
alias vtc='pnpm exec vitest --coverage'
alias vtr='pnpm exec vitest run'

# ============================================================================
# Linting & Formatting
# ============================================================================

alias lint='pnpm run lint:all'
alias lintf='pnpm run lint:fix'
alias fmt='pnpm exec prettier --write'
alias bio='pnpm exec biome'
alias biof='pnpm exec biome check --write'

# ============================================================================
# Claude Code
# ============================================================================

alias cc='claude'
alias ccc='claude --continue'

# ============================================================================
# Monorepo Navigation (fzf-powered)
# ============================================================================

# Jump to a package/app in the monorepo
function mono() {
  if ! has_command fzf; then
    printf '\033[38;2;255;99;99m✗\033[0m fzf required\n'
    return 1
  fi

  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf '\033[38;2;255;99;99m✗\033[0m Not in a git repo\n'
    return 1
  }

  local pkg
  pkg=$(fd -t d -d 3 'package.json' "${root}" --exec dirname {} \; 2>/dev/null |
    fzf --preview 'jq -r ".name // \"(no name)\"" {}/package.json 2>/dev/null; echo "---"; ls -la {}' \
      --header 'Select package')

  if [[ -n "${pkg}" ]]; then
    cd "${pkg}" || return 1
    printf '\033[38;2;128;255;234m→\033[0m %s\n' "${pkg}"
  fi
}

# List all workspace packages
function monols() {
  local root
  root=$(git rev-parse --show-toplevel 2>/dev/null) || {
    printf '\033[38;2;255;99;99m✗\033[0m Not in a git repo\n'
    return 1
  }

  printf '\033[38;2;128;255;234;1m━━━ Workspace Packages ━━━\033[0m\n\n'

  fd -t f 'package.json' "${root}" -d 3 --exec sh -c '
    dir=$(dirname "$1")
    name=$(jq -r ".name // \"(unnamed)\"" "$1" 2>/dev/null)
    version=$(jq -r ".version // \"-\"" "$1" 2>/dev/null)
    printf "\033[38;2;225;53;255m▸\033[0m \033[38;2;128;255;234m%-35s\033[0m \033[38;2;241;250;140m%s\033[0m\n" "${name}" "${version}"
  ' _ {} \; 2>/dev/null | grep -v node_modules | sort
}

# ============================================================================
# Project Info
# ============================================================================

function ts-info() {
  printf '\033[38;2;128;255;234;1m━━━ Project Info ━━━\033[0m\n\n'

  # Node version
  if has_command node; then
    printf '\033[38;2;225;53;255m▸\033[0m Node: \033[38;2;128;255;234m%s\033[0m\n' "$(node --version)"
  fi

  # Package manager
  if [[ -f "pnpm-lock.yaml" ]]; then
    printf '\033[38;2;225;53;255m▸\033[0m PM: \033[38;2;128;255;234mpnpm\033[0m'
    [[ -f "pnpm-workspace.yaml" ]] && printf ' (monorepo)'
    printf '\n'
  fi

  # TypeScript version
  if [[ -f "node_modules/.bin/tsc" ]]; then
    local tsv
    tsv=$(pnpm exec tsc --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+')
    printf '\033[38;2;225;53;255m▸\033[0m TypeScript: \033[38;2;128;255;234m%s\033[0m\n' "${tsv:-not installed}"
  fi

  # Turbo
  if [[ -f "turbo.json" ]]; then
    printf '\033[38;2;225;53;255m▸\033[0m Turbo: \033[38;2;80;250;123menabled\033[0m\n'
  fi

  # Check for common tooling in package.json
  if [[ -f "package.json" ]]; then
    printf '\n\033[38;2;128;255;234;1m━━━ Tooling ━━━\033[0m\n\n'
    local pkg="package.json"
    [[ $(grep -c '"vitest"' "${pkg}") -gt 0 ]] && printf '  \033[38;2;80;250;123m✓\033[0m vitest\n'
    [[ $(grep -c '"biome"' "${pkg}") -gt 0 ]] && printf '  \033[38;2;80;250;123m✓\033[0m biome\n'
    [[ $(grep -c '"eslint"' "${pkg}") -gt 0 ]] && printf '  \033[38;2;80;250;123m✓\033[0m eslint\n'
    [[ $(grep -c '"prettier"' "${pkg}") -gt 0 ]] && printf '  \033[38;2;80;250;123m✓\033[0m prettier\n'
  fi
}
