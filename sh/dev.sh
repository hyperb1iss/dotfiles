# dev.sh
# ⚡ Project navigation — fast jumping across ~/dev/

# Skip on minimal installations
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2> /dev/null || true

# ─────────────────────────────────────────────────────────────
# Project Picker
# ─────────────────────────────────────────────────────────────

# Jump to a project in ~/dev/ using fzf
function dev() {
  local dev_root="${HOME}/dev"

  if ! has_command fzf; then
    sc_error "fzf required"
    return 1
  fi

  if [[ ! -d "${dev_root}" ]]; then
    sc_error "${dev_root} not found"
    return 1
  fi

  # If an argument is provided, try zoxide first for quick matching
  if [[ -n "$1" ]]; then
    local target="${dev_root}/$1"
    if [[ -d "${target}" ]]; then
      cd "${target}" || return 1
      return 0
    fi
    # Fall through to fzf with query pre-filled
  fi

  local project
  project=$(command ls -1 "${dev_root}" \
    | fzf --height 60% --reverse \
      --header="⚡ ~/dev/ projects" \
      --prompt="project ▸ " \
      --query="${1:-}" \
      --preview '
        dir="'"${dev_root}"'/{}"
        if [ -d "$dir/.git" ]; then
          echo "⚡ $(basename {})"
          echo ""
          git -C "$dir" log --oneline --color=always -8 2>/dev/null
          echo ""
          git -C "$dir" status --short 2>/dev/null
        else
          ls -la "$dir" 2>/dev/null | head -20
        fi
      ' \
      --preview-window=right:50%) || return 0

  if [[ -n "${project}" ]]; then
    cd "${dev_root}/${project}" || return 1
  fi
}
