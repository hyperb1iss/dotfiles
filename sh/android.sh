# android.sh
# Core Android development environment settings

# Skip entire module if not in full installation
# shellcheck disable=SC2154  # is_minimal is defined in the parent shell context
is_minimal && return 0

# ─────────────────────────────────────────────────────────────────────────────
# Android SDK Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Set ANDROID_HOME if not already set (standard location)
if [[ -z "${ANDROID_HOME:-}" ]]; then
  if [[ -d "$HOME/Android/Sdk" ]]; then
    export ANDROID_HOME="$HOME/Android/Sdk"
  elif [[ -d "$HOME/android-sdk" ]]; then
    export ANDROID_HOME="$HOME/android-sdk"
  fi
fi

# ANDROID_SDK_ROOT is the newer variable name (same as ANDROID_HOME)
if [[ -n "${ANDROID_HOME:-}" ]]; then
  export ANDROID_SDK_ROOT="${ANDROID_HOME}"
fi

# ─────────────────────────────────────────────────────────────────────────────
# NDK Configuration
# ─────────────────────────────────────────────────────────────────────────────

# Find the latest installed NDK version
if [[ -n "${ANDROID_HOME:-}" && -d "${ANDROID_HOME}/ndk" ]]; then
  # Get the newest NDK version directory
  NDK_VERSION=$(ls -1 "${ANDROID_HOME}/ndk" 2> /dev/null | sort -V | tail -1)
  if [[ -n "${NDK_VERSION}" ]]; then
    export ANDROID_NDK_HOME="${ANDROID_HOME}/ndk/${NDK_VERSION}"
    export ANDROID_NDK="${ANDROID_NDK_HOME}" # Some tools use this
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# PATH Setup
# ─────────────────────────────────────────────────────────────────────────────

if [[ -n "${ANDROID_HOME:-}" ]]; then
  # Command-line tools (sdkmanager, avdmanager, etc.)
  if [[ -d "${ANDROID_HOME}/cmdline-tools/latest/bin" ]]; then
    export PATH="${ANDROID_HOME}/cmdline-tools/latest/bin:${PATH}"
  fi

  # Platform tools (adb, fastboot, etc.)
  if [[ -d "${ANDROID_HOME}/platform-tools" ]]; then
    export PATH="${ANDROID_HOME}/platform-tools:${PATH}"
  fi

  # Emulator
  if [[ -d "${ANDROID_HOME}/emulator" ]]; then
    export PATH="${ANDROID_HOME}/emulator:${PATH}"
  fi

  # CMake (find latest version)
  if [[ -d "${ANDROID_HOME}/cmake" ]]; then
    CMAKE_VERSION=$(ls -1 "${ANDROID_HOME}/cmake" 2> /dev/null | sort -V | tail -1)
    if [[ -n "${CMAKE_VERSION}" && -d "${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin" ]]; then
      export PATH="${ANDROID_HOME}/cmake/${CMAKE_VERSION}/bin:${PATH}"
    fi
  fi
fi

# ─────────────────────────────────────────────────────────────────────────────
# Gradle Configuration (Android builds)
# ─────────────────────────────────────────────────────────────────────────────

# Use parallel garbage collection for faster builds
export GRADLE_OPTS="${GRADLE_OPTS:-} -Dorg.gradle.parallel=true -Dorg.gradle.caching=true"
