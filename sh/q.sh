# q.sh
# q - The tiniest Claude Code CLI
# https://github.com/hyperb1iss/q

# Skip on minimal installations
is_minimal && return 0

# Initialize q shell integration (Q_QUIET suppresses init message)
if has_command q; then
  # shellcheck disable=SC1090
  if is_zsh; then
    Q_QUIET=1 eval "$(q --shell-init zsh)" 2> /dev/null || true
  elif is_bash; then
    Q_QUIET=1 eval "$(q --shell-init bash)" 2> /dev/null || true
  fi
fi
