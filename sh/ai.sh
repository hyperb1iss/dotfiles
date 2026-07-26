# ai.sh
# 🔮 AI CLI shortcuts

# Skip if in minimal mode
is_minimal && return 0

# ─────────────────────────────────────────────────────────────
# Claude Code
# ─────────────────────────────────────────────────────────────

alias cc='claude'
alias ccc='claude --continue'

# ─────────────────────────────────────────────────────────────
# Codex
# ─────────────────────────────────────────────────────────────

# Launch codex on gpt-5.5 with the goblins stripped out of its base
# instructions. This was a single-line alias whose quote nesting hid the
# temp-file assignment from shellcheck and never cleaned the file up.
function goblinz() {
  local instructions
  instructions=$(mktemp "${TMPDIR:-/tmp}/gpt-5.5-instructions.XXXXXX") || return 1

  if ! jq -r '.models[] | select(.slug=="gpt-5.5") | .base_instructions' \
    ~/.codex/models_cache.json \
    | grep -vi 'goblins' > "${instructions}"; then
    rm -f "${instructions}"
    return 1
  fi

  codex -m gpt-5.5 --yolo -c "model_instructions_file=\"${instructions}\""
  local status=$?
  rm -f "${instructions}"
  return "${status}"
}
