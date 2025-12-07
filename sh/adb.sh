# adb.sh
# ⚡ ADB utilities with SilkCircuit energy

# Skip entire module if not in full installation
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2>/dev/null || true

# Smart device selector for multiple devices
function get_device() {
  local devices device_count choice
  local adb_output

  # Get devices and handle errors
  adb_output=$(adb devices) || true
  devices=$(echo "${adb_output}" | grep -v "List" | grep "device$" | cut -f1)
  device_count=$(echo "${devices}" | grep -c "^" || echo "0")

  if [[ "${device_count}" -eq 0 ]]; then
    echo "No devices found" >&2
    return 1
  elif [[ "${device_count}" -eq 1 ]]; then
    echo "${devices}"
  else
    echo "Multiple devices found:" >&2
    local i=1
    # shellcheck disable=SC2162
    echo "${devices}" | while read -r device; do
      local name
      name=$(adb -s "${device}" shell getprop ro.product.model 2>/dev/null)
      printf "[%d] %s (%s)\n" "${i}" "${device}" "${name}" >&2
      i=$((i + 1))
    done

    printf "Select device number: " >&2
    read -r choice
    echo "${devices}" | sed -n "${choice}p"
  fi
}

# Enhanced logcat with device selection and colorization
function logcat() {
  local device colorize

  # Default to colorized output
  colorize=true

  # Check if the first argument is --no-color
  if [[ "${1:-}" = "--no-color" ]]; then
    colorize=false
    shift
  fi

  if ! device=$(get_device); then
    return 1
  fi

  # Handle zsh globbing
  if is_zsh; then
    # Disable glob pattern expansion for this function
    setopt local_options no_nomatch
  fi

  # Build the adb command using arrays to avoid shell expansion issues
  local adb_cmd=("adb" "-s" "${device}" "logcat")

  if [[ $# -gt 0 ]]; then
    # Add tag filters
    for arg in "$@"; do
      adb_cmd+=("${arg}:*")
    done

    # Add silence filter for other tags
    adb_cmd+=("*:S")

    # Log command for user info
    echo "🚀 Running: ${adb_cmd[*]}"
  fi

  # Execute command with or without colorization
  if [[ "${colorize}" = true ]]; then
    "${adb_cmd[@]}" | colorize_logcat
  else
    "${adb_cmd[@]}"
  fi
}

# Logcat colorizer function using SilkCircuit palette
function colorize_logcat() {
  __sc_init_colors

  # Read logcat output line by line
  while IFS= read -r line; do
    # Check for beginning markers first to avoid grep errors
    if [[ "${line}" == *"--------- beginning of"* ]]; then
      # Log markers - neon cyan
      echo -e "${SC_BOLD}${SC_CYAN}${line}${SC_RESET}"
      continue
    fi

    # Color based on log level using safer pattern matching
    if [[ "${line}" == *" E "* ]]; then
      # Error - bold red
      echo -e "${SC_BOLD}${SC_RED}${line}${SC_RESET}"
    elif [[ "${line}" == *" W "* ]]; then
      # Warning - orange/yellow
      echo -e "${SC_ORANGE}${line}${SC_RESET}"
    elif [[ "${line}" == *" I "* ]]; then
      # Info - pink
      echo -e "${SC_PINK}${line}${SC_RESET}"
    elif [[ "${line}" == *" D "* ]]; then
      # Debug - purple
      echo -e "${SC_PURPLE}${line}${SC_RESET}"
    elif [[ "${line}" == *" V "* ]]; then
      # Verbose - gray
      echo -e "${SC_GRAY}${line}${SC_RESET}"
    # Check for special patterns without using grep
    elif [[ "${line}" == *"Exception"* ]] ||
      [[ "${line}" == *"Error:"* ]] ||
      [[ "${line}" == *"FATAL"* ]] ||
      [[ "${line}" == *"ANR"* ]]; then
      # Exception and error keywords - bold red
      echo -e "${SC_BOLD}${SC_RED}${line}${SC_RESET}"
    elif [[ "${line}" == *"success"* ]] ||
      [[ "${line}" == *"Success"* ]] ||
      [[ "${line}" == *"CONNECTED"* ]] ||
      [[ "${line}" == *"ready"* ]]; then
      # Success indicators - bold green
      echo -e "${SC_BOLD}${SC_GREEN}${line}${SC_RESET}"
    elif [[ "${line}" == *"WARNING"* ]] || [[ "${line}" == *"deprecated"* ]]; then
      # Add warning matches to use yellow
      echo -e "${SC_YELLOW}${line}${SC_RESET}"
    else
      # Other lines - plain but still visible
      echo -e "${line}"
    fi
  done
}

# Dynamic app-specific logging with process ID detection
function applog() {
  local device app_name pid_list colorize usage
  usage="Usage: applog [options] <app_name_or_package>
    
Options:
    -n, --no-color   Disable colorized output
    -h, --help       Show this help message"

  # Default values
  colorize=true

  # Parse options
  while [[ $# -gt 0 ]]; do
    case "$1" in
      -n | --no-color)
        colorize=false
        shift
        ;;
      -h | --help)
        echo "${usage}"
        return 0
        ;;
      -*)
        echo "Unknown option: $1" >&2
        echo "${usage}" >&2
        return 1
        ;;
      *)
        app_name="$1"
        shift
        break
        ;;
    esac
  done

  # Check if app name is provided
  if [[ -z "${app_name:-}" ]]; then
    echo "Error: No app name or package specified" >&2
    echo "${usage}" >&2
    return 1
  fi

  # Handle zsh globbing
  if is_zsh; then
    # Disable glob pattern expansion for this function
    setopt local_options no_nomatch
  fi

  # Get connected device
  if ! device=$(get_device); then
    return 1
  fi

  # First try exact package match
  local pm_packages
  pm_packages=$(adb -s "${device}" shell pm list packages) || true
  if echo "${pm_packages}" | grep -q "package:${app_name}"; then
    echo "✨ Found exact package match: ${app_name}"
  else
    # Try partial package match
    local package_matches
    package_matches=$(echo "${pm_packages}" | grep "${app_name}" | sed 's/package://') || true

    if [[ -n "${package_matches}" ]]; then
      # Count matches
      local match_count
      match_count=$(echo "${package_matches}" | wc -l)

      if [[ "${match_count}" -eq 1 ]]; then
        # Single match found
        app_name=$(echo "${package_matches}" | tr -d '\r')
        echo "✨ Found package: ${app_name}"
      else
        # Multiple matches, let user choose
        echo "Multiple matching packages found:"
        local i=1
        # shellcheck disable=SC2162
        echo "${package_matches}" | while read pkg; do
          printf "[%d] %s\n" "${i}" "${pkg}"
          i=$((i + 1))
        done

        printf "Select package number (or Ctrl+C to cancel): "
        local choice
        read -r choice
        local selected_app
        selected_app=$(echo "${package_matches}" | sed -n "${choice}p") || true
        app_name=$(echo "${selected_app}" | tr -d '\r')
        [[ -z "${app_name}" ]] && return 1
        echo "✨ Selected package: ${app_name}"
      fi
    fi
  fi

  # Get process IDs for the app
  echo "🔍 Looking for processes matching '${app_name}'..."
  local process_info
  process_info=$(adb -s "${device}" shell ps) || true
  pid_list=$(echo "${process_info}" | grep -i "${app_name}" | awk '{print $2}')

  if [[ -z "${pid_list}" ]]; then
    echo "⚠️ No running processes found for '${app_name}'"
    echo "💡 Is the app running? Try starting it first."
    return 1
  fi

  # Count processes
  local process_count
  process_count=$(echo "${pid_list}" | wc -l)
  echo "📱 Found ${process_count} running process(es) for '${app_name}'"

  # Extract process IDs into an array for reliable handling
  local pids=()
  while IFS= read -r pid; do
    pid=$(echo "${pid}" | tr -d '\r')
    if [[ -n "${pid}" ]]; then
      pids+=("${pid}")
    fi
  done <<<"${pid_list}"

  # Execute the logcat command directly with proper arguments
  echo "📊 Streaming logs for '${app_name}'..."
  echo "💡 Press Ctrl+C to stop"

  # Build the adb command properly to avoid shell expansion issues
  local adb_cmd=("adb" "-s" "${device}" "logcat")

  # Add pid filters if available
  for pid in "${pids[@]}"; do
    adb_cmd+=("--pid=${pid}")
  done

  # Show the command being run
  echo "🚀 Running: ${adb_cmd[*]}"
  echo "-------------------------------------------"

  # Execute based on colorization
  if [[ "${colorize}" = true ]]; then
    "${adb_cmd[@]}" | colorize_logcat
  else
    "${adb_cmd[@]}"
  fi
}

# File operations with proper quoting and error handling
function apush() {
  if [[ -z "${OUT:-}" ]]; then
    echo "Android environment not configured."
    return 1
  fi

  local device
  if ! device=$(get_device); then
    return 1
  fi

  local status=0
  for file in "$@"; do
    if [[ ! -f "${file}" ]]; then
      echo "File not found: ${file}"
      status=1
      continue
    fi

    local realfile relpath
    realfile=$(readlink -f "${file}" 2>/dev/null || realpath "${file}" 2>/dev/null || echo "${file}")
    relpath=${realfile#"${OUT}/"}

    echo "Pushing ${file} to /${relpath}"
    if ! adb -s "${device}" push "${realfile}" "/${relpath}"; then
      status=1
    fi
  done

  return "${status}"
}

function apull() {
  local device
  if ! device=$(get_device); then
    return 1
  fi

  local status=0
  for path in "$@"; do
    echo "Pulling ${path}"
    if ! adb -s "${device}" pull "${path}" .; then
      status=1
    fi
  done

  return "${status}"
}

# Android device management with named aliases
function adbdev() {
  local config_file="${HOME}/.adbdevs"
  local usage="Usage:
    adbdev <alias>            - Set ANDROID_SERIAL to the device with given alias
    adbdev --add <alias> <serial>    - Add or update device alias
    adbdev --remove <alias>   - Remove device alias
    adbdev --list            - List all device aliases"

  # Create config file if it doesn't exist
  touch "${config_file}" 2>/dev/null || {
    echo "Error: Cannot create/access ${config_file}" >&2
    return 1
  }

  case "${1:-}" in
    --add)
      if [[ -z "${2:-}" ]] || [[ -z "${3:-}" ]]; then
        echo "${usage}" >&2
        return 1
      fi
      local alias="$2"
      local serial="$3"
      # Remove existing entry if any
      sed -i "/${alias}:/d" "${config_file}"
      # Add new entry
      echo "${alias}:${serial}" >>"${config_file}"
      echo "Added device alias '${alias}' for serial '${serial}'"
      ;;
    --remove)
      if [[ -z "${2:-}" ]]; then
        echo "${usage}" >&2
        return 1
      fi
      local alias="$2"
      if sed -i "/${alias}:/d" "${config_file}"; then
        echo "Removed device alias '${alias}'"
      else
        echo "Error: Could not remove alias '${alias}'" >&2
        return 1
      fi
      ;;
    --list)
      if [[ ! -s "${config_file}" ]]; then
        echo "No device aliases configured"
        return 0
      fi
      echo "Configured device aliases:"
      # shellcheck disable=SC2162
      while IFS=: read -r alias serial || [[ -n "${alias}" ]]; do
        printf "  %-20s %s\n" "${alias}" "${serial}"
      done <"${config_file}"
      ;;
    "")
      echo "${usage}" >&2
      return 1
      ;;
    *)
      local alias="$1"
      local serial
      local grep_result
      grep_result=$(grep "^${alias}:" "${config_file}") || true
      serial=$(echo "${grep_result}" | cut -d: -f2)
      if [[ -z "${serial}" ]]; then
        echo "Error: No device found with alias '${alias}'" >&2
        return 1
      fi
      export ANDROID_SERIAL="${serial}"
      echo "Set ANDROID_SERIAL=${ANDROID_SERIAL}"
      ;;
  esac
}
