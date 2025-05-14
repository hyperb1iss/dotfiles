# android.sh
# Core Android development environment settings

# Skip entire module if not in full installation
is_minimal && return 0

# Add Android SDK platform tools to PATH if directory exists
if [[ -d "${ANDROID_HOME}/platform-tools" ]]; then
  export PATH="${PATH}:${ANDROID_HOME}/platform-tools"
fi
