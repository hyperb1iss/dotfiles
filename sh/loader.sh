# loader.sh
# The one place that decides which shell modules load, and in what order.
#
# zsh/zshrc and bash/bashrc.local both source this file instead of
# carrying their own copy of the glob loop. Loading happens in two
# phases because zsh has to slot work between them:
#
#   dotfiles_load_core     ordered core, listed explicitly below
#   dotfiles_load_modules  the rest of sh/*.sh, alphabetically
#
# zsh puts its fpath edits, compinit and the zinit plugins between the
# two calls. Completions need the PATH that env.sh builds, and the
# plugins want their keybindings in place before fzf.sh rebinds ^R, so a
# single "load everything" call cannot express the order. Bash has no
# such constraint and calls dotfiles_load_all.
#
# Core order, and why:
#   shell-common.sh  defines DOTFILES, cached_eval, has_command and the
#                    is_* predicates that every other file calls
#   env.sh           builds PATH, so it must precede any module that
#                    probes for a tool with has_command
#   colors.sh        defines the SC_* palette and sc_* helpers that
#                    seven modules use. Nothing needs it at parse time,
#                    but loading it here retires the old accident where
#                    it worked only because "colors" sorts early in the
#                    glob
#   terminal.sh      registers the precmd hook and PROMPT_COMMAND that
#                    set the terminal title, which zshrc invokes by hand
#                    right after the core phase

# Modules the core phase owns. The module phase skips them by name.
DOTFILES_CORE_MODULES="shell-common.sh env.sh colors.sh terminal.sh"

# Work out where this checkout lives when the caller has not said.
# Deriving it from our own path means a worktree or a test clone loads
# its own modules rather than the installed ones. Pure parameter
# expansion, no subshell, because a fork here costs more than every
# module in sh/ put together.
if [ -z "${DOTFILES:-}" ]; then
  if [ -n "${ZSH_VERSION:-}" ]; then
    # zsh's prompt-expansion route to "the file being sourced". Bash
    # parses the branch fine and never runs it.
    # shellcheck disable=SC2296
    __dotfiles_self="${(%):-%x}"
  else
    __dotfiles_self="${BASH_SOURCE[0]}"
  fi

  case "${__dotfiles_self}" in
    */sh/loader.sh) __dotfiles_root="${__dotfiles_self%/sh/loader.sh}" ;;
    sh/loader.sh) __dotfiles_root="${PWD}" ;;
    *) __dotfiles_root="" ;;
  esac

  # A relative source path resolves against the caller's cwd.
  case "${__dotfiles_root}" in
    /*) ;;
    "") __dotfiles_root="${HOME}/dev/dotfiles" ;;
    *) __dotfiles_root="${PWD}/${__dotfiles_root}" ;;
  esac

  export DOTFILES="${__dotfiles_root}"
  unset __dotfiles_self __dotfiles_root
fi

# Source one file, surviving a module that is missing or blows up.
# Sourcing from inside a function is safe in both shells: a `return` in
# the sourced file ends that file, not this function, which is what the
# `is_minimal && return 0` guard at the top of most modules relies on.
#
# A module's exit status is a poor health signal, since plenty of them
# end on a conditional or on a cached_eval whose last command belongs to
# somebody else's init script. So the status only surfaces under
# DOTFILES_LOADER_DEBUG=1. A module with a real syntax error still
# prints the shell's own parse error either way.
__dotfiles_source() {
  [ -r "$1" ] || return 0
  # shellcheck disable=SC1090
  . "$1"
  __dotfiles_status=$?
  if [ "${__dotfiles_status}" -ne 0 ] && [ -n "${DOTFILES_LOADER_DEBUG:-}" ]; then
    printf 'dotfiles: %s returned %s\n' "$1" "${__dotfiles_status}" >&2
  fi
  unset __dotfiles_status
  return 0
}

# Phase one: the ordered core, everything else depends on it.
dotfiles_load_core() {
  __dotfiles_source "${DOTFILES}/sh/shell-common.sh"
  __dotfiles_source "${DOTFILES}/sh/env.sh"
  __dotfiles_source "${DOTFILES}/sh/colors.sh"
  __dotfiles_source "${DOTFILES}/sh/terminal.sh"
}

# Phase two: every other module, alphabetically. Modules gate themselves
# on platform and install type (is_minimal, is_macos, is_wsl), so the
# loader stays dumb about which ones apply here.
#
# Set DOTFILES_SKIP_MODULES to a space-separated list of basenames to
# leave some out, e.g. DOTFILES_SKIP_MODULES="kubernetes.sh docker.sh".
dotfiles_load_modules() {
  # zsh aborts the function outright when a glob matches nothing, where
  # bash leaves the pattern literal for the [ -r ] test below to skip.
  # Our own presence in sh/ guarantees at least one match, so check for
  # it rather than reaching for NULL_GLOB, which would otherwise stay
  # in effect while every module's top level runs.
  [ -r "${DOTFILES}/sh/loader.sh" ] || return 0

  # Prefixed names: these stay in scope while each module's top level
  # runs, so they must not collide with anything a module assigns.
  local __dotfiles_module __dotfiles_name
  for __dotfiles_module in "${DOTFILES}"/sh/*.sh; do
    [ -r "${__dotfiles_module}" ] || continue
    __dotfiles_name="${__dotfiles_module##*/}"

    # Skip the core (already loaded), ourselves, and anything the user
    # asked to leave out.
    case " ${DOTFILES_CORE_MODULES} loader.sh ${DOTFILES_SKIP_MODULES:-} " in
      *" ${__dotfiles_name} "*) continue ;;
    esac

    __dotfiles_source "${__dotfiles_module}"
  done
}

# Both phases back to back, for shells with nothing to slot between.
dotfiles_load_all() {
  dotfiles_load_core
  dotfiles_load_modules
}
