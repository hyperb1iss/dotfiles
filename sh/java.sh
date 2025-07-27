# Java version switching - using native platform tools
# Works on macOS, Arch Linux, and Debian-based systems

# Skip entire module if not in full installation
is_minimal && return 0

# Function to list available Java versions using native tools
function list_java_versions() {
  echo "╔════════════════════════════════════════════════╗"
  echo "║           Available Java Versions              ║"
  echo "╚════════════════════════════════════════════════╝"
  echo

  if is_macos; then
    # macOS: Use the built-in java_home utility
    if [[ -x /usr/libexec/java_home ]]; then
      echo "Using macOS java_home utility:"
      echo
      /usr/libexec/java_home -V 2>&1 | grep -E "^\s+[0-9]" | while read -r line; do
        echo "  ${line}"
      done
      echo
      echo "Usage:"
      echo "  - Set JAVA_HOME: export JAVA_HOME=\$(/usr/libexec/java_home -v 11)"
      echo "  - Or use setjdk function: setjdk 11"
    else
      echo "No Java installations found or java_home utility not available."
      echo "Install Java with: brew install openjdk@17"
    fi
  elif command -v archlinux-java >/dev/null 2>&1; then
    # Arch Linux: Use archlinux-java
    echo "Using Arch Linux archlinux-java utility:"
    echo
    archlinux-java status
    echo
    echo "Usage:"
    echo "  - Switch version: sudo archlinux-java set java-17-openjdk"
    echo "  - Or use setjdk function: setjdk 17"
  elif command -v update-java-alternatives >/dev/null 2>&1; then
    # Debian/Ubuntu: Use update-java-alternatives
    echo "Using Debian update-java-alternatives:"
    echo
    update-java-alternatives --list
    echo
    echo "Usage:"
    echo "  - Switch version: sudo update-java-alternatives --set java-1.17.0-openjdk-amd64"
    echo "  - Or use setjdk function: setjdk 17"
  else
    echo "No native Java management tool found."
    echo "Please install Java through your system's package manager."
  fi
}

# Function to switch Java version using native tools
function setjdk() {
  if [[ $# -ne 1 ]]; then
    echo "Usage: setjdk <version>"
    echo "Run 'javalist' to see available versions"
    return 1
  fi

  local target_version="$1"

  if is_macos; then
    # macOS: Use java_home
    if [[ -x /usr/libexec/java_home ]]; then
      local java_home
      java_home=$(/usr/libexec/java_home -v "${target_version}" 2>/dev/null)
      if [[ $? -eq 0 && -n "${java_home}" ]]; then
        export JAVA_HOME="${java_home}"
        local cleaned_path
        cleaned_path=$(echo "${PATH}" | sed -E 's|/[^:]*java[^:]*bin:||g')
        export PATH="${JAVA_HOME}/bin:${cleaned_path}"
        echo "Switched to Java ${target_version}"
        java -version
      else
        echo "Error: Java ${target_version} not found"
        echo "Available versions:"
        /usr/libexec/java_home -V 2>&1 | grep -E "^\s+[0-9]"
        return 1
      fi
    else
      echo "Error: /usr/libexec/java_home not available"
      return 1
    fi
  elif command -v archlinux-java >/dev/null 2>&1; then
    # Arch Linux: Use archlinux-java
    local java_env="java-${target_version}-openjdk"
    if archlinux-java status | grep -q "${java_env}"; then
      if [[ ${EUID} -eq 0 ]]; then
        archlinux-java set "${java_env}"
      else
        sudo archlinux-java set "${java_env}"
      fi
      echo "Switched to Java ${target_version}"
      java -version
    else
      echo "Error: Java ${target_version} not installed"
      echo "Available versions:"
      archlinux-java status
      return 1
    fi
  elif command -v update-java-alternatives >/dev/null 2>&1; then
    # Debian/Ubuntu: Use update-java-alternatives
    local alternatives
    alternatives=$(update-java-alternatives --list | grep "${target_version}" | head -n1 | awk '{print $1}')
    if [[ -n "${alternatives}" ]]; then
      if [[ ${EUID} -eq 0 ]]; then
        update-java-alternatives --set "${alternatives}"
      else
        sudo update-java-alternatives --set "${alternatives}"
      fi
      echo "Switched to Java ${target_version}"
      java -version
    else
      echo "Error: Java ${target_version} not found"
      echo "Available versions:"
      update-java-alternatives --list
      return 1
    fi
  else
    echo "Error: No native Java management tool available"
    echo "Please install Java through your system's package manager"
    return 1
  fi
}

# Create aliases for common Java versions (8, 11, 17, 21)
for version in 8 11 17 21; do
  # Use eval to create the alias at runtime
  # shellcheck disable=SC2139
  eval "alias java${version}='setjdk ${version}'"
done

# Alias for listing versions
alias javalist="list_java_versions"
