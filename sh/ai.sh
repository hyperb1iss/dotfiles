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

alias goblinz='instructions=$(mktemp /tmp/gpt-5.5-instructions.XXXXXX) && jq -r '\''.models[] | select(.slug=="gpt-5.5") | .base_instructions'\'' ~/.codex/models_cache.json | grep -vi '\''goblins'\'' > "$instructions" && codex -m gpt-5.5 --yolo -c "model_instructions_file=\"$instructions\""'
