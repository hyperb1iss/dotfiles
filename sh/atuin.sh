# atuin.sh
# Atuin shell history: SQLite-backed, workspace-aware, synced across machines.
# This module owns every atuin init and keybinding for both shells so nothing
# else has to know atuin exists. Config lives in atuin/config.toml (symlinked
# to ~/.config/atuin by dotbot). SilkCircuit's installer owns the theme.
#
# Keys (both shells):
#   Ctrl-R    full search; Ctrl-R again cycles workspace → directory → host → global
#   Up        inline prefix search seeded with the buffer, workspace scope
#   Ctrl-O    inspector tab (stats for the highlighted command)
#   Ctrl-1..9 pick a row by number
#   Ctrl-P/N  classic substring history, bound in zshrc
#
# Atuin AI (the `?` binding) is off: drop --disable-ai below and set
# [ai] enabled = true in config.toml to try it.

is_minimal && return 0
has_command atuin || return 0

# `atuin init` bakes settings and flags into its output. Key that output
# by the config path and contents, including a missing config, so an older
# restored file cannot reuse another configuration's bindings.
__atuin_init() {
  local shell="$1"
  local config="${ATUIN_CONFIG_DIR:-${XDG_CONFIG_HOME:-${HOME}/.config}/atuin}/config.toml"
  local fingerprint
  fingerprint=$({
    printf '%s\n' "${config}" "${shell}" '--disable-ai'
    if [[ -f "${config}" ]]; then
      cat "${config}"
    else
      printf '%s\n' '<default-config>'
    fi
  } | cksum)
  cached_eval atuin "atuin-init-${fingerprint// /-}.${shell}" \
    atuin init "${shell}" --disable-ai
}

if is_zsh; then
  # zsh-autosuggestions: atuin's init prepends its own "atuin" strategy
  # (author-filtered, so agent-run commands never surface as ghost text).
  # Seed the fallbacks first so the result is (atuin history completion).
  # shellcheck disable=SC2034 # read by the zsh-autosuggestions plugin
  ZSH_AUTOSUGGEST_STRATEGY=(history completion)
  __atuin_init zsh
elif is_bash; then
  __atuin_init bash
fi

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# History helpers (structured queries the TUI doesn't expose directly).
# hfail and hlast see your own commands only, same contract as Ctrl-R;
# hagents is the agent side.
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Failed commands in this workspace, newest first. Optional query narrows it.
# Usage: hfail [query] [limit]
function hfail() {
  # shellcheck disable=SC2016 # '$all-user' is an atuin author filter, not a shell variable
  atuin search --filter-mode workspace --exclude-exit 0 --author '$all-user' \
    --limit "${2:-25}" --format '{exit}	{time}	{command}' -- "${1:-}"
}

# Recall the last command that succeeded in this directory into the buffer.
# Usage: hlast [query]
function hlast() {
  local cmd
  # shellcheck disable=SC2016 # '$all-user' is an atuin author filter, not a shell variable
  cmd=$(atuin search --filter-mode directory --exit 0 --author '$all-user' --limit 1 --cmd-only -- "${1:-}") || return
  [[ -n "${cmd}" ]] || return 1
  if is_zsh; then
    print -z -- "${cmd}"
  else
    history -s "${cmd}"
    echo "${cmd}  ← recall with ↑"
  fi
}

# Usage stats for a named period: today, week, month, year, or all.
# Usage: hstats [period] [count]
function hstats() {
  atuin stats "${1:-week}" --count "${2:-15}"
}

# What the agents have been running: every command recorded via atuin hooks.
# Usage: hagents [query] [limit]
function hagents() {
  # shellcheck disable=SC2016 # '$all-agent' is an atuin author filter, not a shell variable
  atuin search --filter-mode global --author '$all-agent' \
    --limit "${2:-25}" --format '{exit}	{time}	{directory}	{command}' -- "${1:-}"
}

alias hwrapped='atuin wrapped'
