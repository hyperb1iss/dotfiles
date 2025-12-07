# colors.sh
# ⚡ SilkCircuit Neon — Shared color palette for terminal magic
#
# Electric meets elegant. This is the canonical source for all
# SilkCircuit colors across the dotfiles ecosystem.

# ─────────────────────────────────────────────────────────────
# Core Palette
# ─────────────────────────────────────────────────────────────

__sc_init_colors() {
  # Only initialize once
  [[ -n "${__SC_COLORS_READY:-}" ]] && return 0

  # Smart detection: colors only if terminal supports it
  if [[ -t 1 ]] && [[ -z "${NO_COLOR:-}" ]] && [[ "${TERM:-}" != "dumb" ]]; then
    # ═══ Primary Accent Colors ═══
    SC_PURPLE='\033[38;2;225;53;255m'   # #e135ff — Electric Purple (keywords, markers)
    SC_CYAN='\033[38;2;128;255;234m'    # #80ffea — Neon Cyan (functions, paths)
    SC_CORAL='\033[38;2;255;106;193m'   # #ff6ac1 — Coral (hashes, numbers)
    SC_PINK='\033[38;2;255;153;255m'    # #ff99ff — Pure Pink (decorative)

    # ═══ Semantic Colors ═══
    SC_YELLOW='\033[38;2;241;250;140m'  # #f1fa8c — Electric Yellow (warnings, timestamps)
    SC_GREEN='\033[38;2;80;250;123m'    # #50fa7b — Success Green (confirmations)
    SC_RED='\033[38;2;255;99;99m'       # #ff6363 — Error Red (failures, removals)
    SC_ORANGE='\033[38;2;255;170;100m'  # #ffaa64 — Warm Orange (caution)

    # ═══ Neutral Colors ═══
    SC_GRAY='\033[38;2;139;145;177m'    # #8b91b1 — Muted (secondary info)
    SC_DIM='\033[38;2;98;92;122m'       # #625c7a — Dim Purple (backgrounds)
    SC_WHITE='\033[38;2;248;248;242m'   # #f8f8f2 — Soft White (text)

    # ═══ Text Styles ═══
    SC_BOLD='\033[1m'
    SC_DIM_STYLE='\033[2m'
    SC_ITALIC='\033[3m'
    SC_UNDERLINE='\033[4m'
    SC_RESET='\033[0m'

    # ═══ Compound Styles ═══
    SC_HEADER="${SC_PURPLE}${SC_BOLD}"
    SC_SUCCESS="${SC_GREEN}${SC_BOLD}"
    SC_ERROR="${SC_RED}${SC_BOLD}"
    SC_WARNING="${SC_YELLOW}"
    SC_INFO="${SC_CYAN}"
    SC_MUTED="${SC_GRAY}"
  else
    # No colors — piped output or unsupported terminal
    SC_PURPLE='' SC_CYAN='' SC_CORAL='' SC_PINK=''
    SC_YELLOW='' SC_GREEN='' SC_RED='' SC_ORANGE=''
    SC_GRAY='' SC_DIM='' SC_WHITE=''
    SC_BOLD='' SC_DIM_STYLE='' SC_ITALIC='' SC_UNDERLINE='' SC_RESET=''
    SC_HEADER='' SC_SUCCESS='' SC_ERROR='' SC_WARNING='' SC_INFO='' SC_MUTED=''
  fi

  __SC_COLORS_READY=1
}

# ─────────────────────────────────────────────────────────────
# Output Helpers
# ─────────────────────────────────────────────────────────────

# Print styled header
# Usage: sc_header "Section Title"
sc_header() {
  __sc_init_colors
  echo -e "${SC_HEADER}⚡ $1${SC_RESET}"
}

# Print success message
# Usage: sc_success "Operation completed"
sc_success() {
  __sc_init_colors
  echo -e "${SC_GREEN}✓${SC_RESET} $1"
}

# Print error message
# Usage: sc_error "Something went wrong"
sc_error() {
  __sc_init_colors
  echo -e "${SC_RED}✗${SC_RESET} $1" >&2
}

# Print warning message
# Usage: sc_warn "Proceed with caution"
sc_warn() {
  __sc_init_colors
  echo -e "${SC_YELLOW}⚠${SC_RESET} $1"
}

# Print info message
# Usage: sc_info "Processing files..."
sc_info() {
  __sc_init_colors
  echo -e "${SC_CYAN}→${SC_RESET} $1"
}

# Print muted/secondary info
# Usage: sc_muted "Additional details"
sc_muted() {
  __sc_init_colors
  echo -e "${SC_GRAY}$1${SC_RESET}"
}

# Print a labeled value
# Usage: sc_label "Status" "Active"
sc_label() {
  __sc_init_colors
  echo -e "${SC_CYAN}•${SC_RESET} $1: ${SC_YELLOW}$2${SC_RESET}"
}

# Print a bullet point
# Usage: sc_bullet "Item description"
sc_bullet() {
  __sc_init_colors
  echo -e "  ${SC_PURPLE}▸${SC_RESET} $1"
}

# ─────────────────────────────────────────────────────────────
# Visual Elements
# ─────────────────────────────────────────────────────────────

# Print a separator line
# Usage: sc_separator [width]
sc_separator() {
  __sc_init_colors
  local width="${1:-60}"
  echo -e "${SC_DIM}$(printf '─%.0s' $(seq 1 "$width"))${SC_RESET}"
}

# Print a progress bar
# Usage: sc_progress_bar 75 100
sc_progress_bar() {
  __sc_init_colors
  local current="$1" total="$2" width="${3:-20}"
  local percent=$((current * 100 / total))
  local filled=$((percent * width / 100))
  local empty=$((width - filled))

  # Color based on percentage
  local color
  if [[ ${percent} -lt 50 ]]; then
    color="${SC_GREEN}"
  elif [[ ${percent} -lt 80 ]]; then
    color="${SC_YELLOW}"
  else
    color="${SC_RED}"
  fi

  echo -ne "${SC_GRAY}[${SC_RESET}"
  echo -ne "${color}"
  for ((i = 0; i < filled; i++)); do echo -n "▰"; done
  echo -ne "${SC_GRAY}"
  for ((i = 0; i < empty; i++)); do echo -n "▱"; done
  echo -e "${SC_GRAY}]${SC_RESET} ${percent}%"
}

# ─────────────────────────────────────────────────────────────
# FZF Integration
# ─────────────────────────────────────────────────────────────

# Get SilkCircuit FZF color scheme
# Usage: export FZF_DEFAULT_OPTS="$(sc_fzf_opts)"
sc_fzf_opts() {
  echo "--color=bg+:#3c3836,bg:#1d2021,spinner:#e135ff,hl:#80ffea"
  echo "--color=fg:#f8f8f2,header:#80ffea,info:#f1fa8c,pointer:#e135ff"
  echo "--color=marker:#50fa7b,fg+:#f8f8f2,prompt:#e135ff,hl+:#ff6ac1"
  echo "--color=border:#625c7a"
}

# ─────────────────────────────────────────────────────────────
# Auto-initialize on source
# ─────────────────────────────────────────────────────────────
__sc_init_colors
