# android.sh
# Core Android development environment settings

# Skip entire module if not in full installation
# shellcheck disable=SC2154  # is_minimal is defined in the parent shell context
is_minimal && return 0

# Add Android SDK platform tools to PATH if ANDROID_HOME is set and directory exists
if [[ -n "${ANDROID_HOME:-}" && -d "${ANDROID_HOME}/platform-tools" ]]; then
  export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi
