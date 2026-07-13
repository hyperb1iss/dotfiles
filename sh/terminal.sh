# terminal.sh
# Terminal title management functions

# Skip on minimal installations
is_minimal && return 0

# Get the last component of the current directory
function normalize_path() {
  local path=${PWD/#${HOME}/\~}
  echo "${path##*/}"
}

# Set the terminal title with optional prefix
# Only emits OSC 0 when the computed title actually changes, so terminals
# (e.g. Ghostty) don't redraw the tab on every prompt and flicker.
function set_terminal_title() {
  local title_prefix=""
  local normalized_path
  normalized_path=$(normalize_path)

  # Add target product prefix for Android development if applicable
  # Check both variables and provide defaults
  if [[ -n "${TARGET_PRODUCT}" ]]; then
    local build_variant="${TARGET_BUILD_VARIANT:-unknown}"
    title_prefix="[${TARGET_PRODUCT}-${build_variant}] "
  fi

  local new_title="${title_prefix}${debian_chroot:+(${debian_chroot})}${USER}@${HOSTNAME}: ${normalized_path}"
  [[ "${new_title}" == "${__LAST_TERMINAL_TITLE-}" ]] && return
  __LAST_TERMINAL_TITLE="${new_title}"

  # shellcheck disable=SC1090
  echo -ne "\033]0;${new_title}\007"
}

# Setup terminal title updating based on shell
function setup_terminal_title() {
  if is_zsh; then
    # For zsh, use add-zsh-hook for better compatibility
    autoload -Uz add-zsh-hook
    add-zsh-hook precmd set_terminal_title
  elif is_bash; then
    # For bash, use PROMPT_COMMAND
    PROMPT_COMMAND="set_terminal_title"
  fi
}

# Initialize terminal title updating
setup_terminal_title
