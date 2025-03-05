# android.sh
# Android development environment extensions for bash and zsh

# Skip entire module if not in full installation
is_minimal && return 0

# Ensure script works in both bash and zsh
if [ -n "$ZSH_VERSION" ]; then
    SHELL_NAME="zsh"
elif [ -n "$BASH_VERSION" ]; then
    SHELL_NAME="bash"
else
    echo "Unsupported shell, some features may not work correctly"
    SHELL_NAME="unknown"
fi

# Configure shell options for compatibility
if [ "$SHELL_NAME" = "zsh" ]; then
    # Enable bash-style word splitting
    setopt SH_WORD_SPLIT
    # Enable extended globbing
    setopt EXTENDED_GLOB
    # Enable bash-style comments
    setopt INTERACTIVE_COMMENTS
elif [ "$SHELL_NAME" = "bash" ]; then
    # Enable extended pattern matching
    shopt -s extglob 2>/dev/null
    # Enable recursive globbing
    shopt -s globstar 2>/dev/null
fi

# Android build environment setup
function set_android_env() {
    if [ -f build/envsetup.sh ]; then
        # Save current options
        if [ "$SHELL_NAME" = "zsh" ]; then
            local old_opts=$(setopt)
        fi

        # Source build environment
        source build/envsetup.sh

        # Restore options for zsh
        if [ "$SHELL_NAME" = "zsh" ]; then
            eval "$old_opts"
            setopt SH_WORD_SPLIT
        fi

        echo "Android build environment initialized."
    else
        echo "Error: build/envsetup.sh not found. Are you in an AOSP directory?"
    fi
}
alias envsetup='set_android_env'

# Enhanced make command for Android
function mka() {
    local start_time cores make_args status
    start_time=$(date +%s)
    cores=$(grep -c ^processor /proc/cpuinfo)

    echo "Building with $cores cores..."

    # Combine all arguments into make_args
    make_args="$*"

    # Use command substitution safely
    if command -v schedtool >/dev/null 2>&1; then
        schedtool -B -n 10 -e ionice -n 7 make -j"$cores" $make_args
    else
        make -j"$cores" $make_args
    fi
    status=$?

    local end_time tdiff hours mins secs
    end_time=$(date +%s)
    tdiff=$((end_time - start_time))
    hours=$((tdiff / 3600))
    mins=$(((tdiff % 3600) / 60))
    secs=$((tdiff % 60))

    echo
    if [ $status -eq 0 ]; then
        printf "\033[32m#### Build completed successfully "
    else
        printf "\033[31m#### Build failed "
    fi

    if [ $hours -gt 0 ]; then
        printf "(%02d:%02d:%02d)\033[0m\n" $hours $mins $secs
    else
        printf "(%02d:%02d)\033[0m\n" $mins $secs
    fi

    return $status
}

# Quick repo sync with auto retry
function reposync() {
    local max_retries=3
    local retry_count=0
    local sync_success=false
    local cores

    cores=$(nproc 2>/dev/null || echo "4")

    while [ $retry_count -lt $max_retries ] && [ "$sync_success" = false ]; do
        echo "Attempt $((retry_count + 1)) of $max_retries"
        if repo sync -j"$cores" --force-sync; then
            sync_success=true
        else
            retry_count=$((retry_count + 1))
            if [ $retry_count -lt $max_retries ]; then
                echo "Sync failed, retrying in 5 seconds..."
                sleep 5
            fi
        fi
    done

    if [ "$sync_success" = true ]; then
        echo "Repo sync completed successfully"
    else
        echo "Repo sync failed after $max_retries attempts"
        return 1
    fi
}

# Enhanced repo status with portable sort
function rstat() {
    repo status | grep -v "^$" | grep -v "project " | LC_ALL=C sort
}

# Quick device setup with shell-agnostic variable handling
function lunch_device() {
    if [ -z "${1:-}" ]; then
        lunch
    else
        lunch "$1-userdebug"
    fi
}
alias ld='lunch_device'

# Smart device selector for multiple devices
function get_device() {
    local devices device_count choice

    # Use process substitution in a shell-agnostic way
    devices=$(adb devices | grep -v "List" | grep "device$" | cut -f1)
    device_count=$(echo "$devices" | grep -c "^" || echo "0")

    if [ "$device_count" -eq 0 ]; then
        echo "No devices found" >&2
        return 1
    elif [ "$device_count" -eq 1 ]; then
        echo "$devices"
    else
        echo "Multiple devices found:" >&2
        local i=1
        echo "$devices" | while IFS= read -r device; do
            local name
            name=$(adb -s "$device" shell getprop ro.product.model 2>/dev/null)
            printf "[%d] %s (%s)\n" "$i" "$device" "$name" >&2
            i=$((i + 1))
        done

        printf "Select device number: " >&2
        read -r choice
        echo "$devices" | sed -n "${choice}p"
    fi
}

# Enhanced logcat with device selection and colorization
function logcat() {
    local device colorize

    # Default to colorized output
    colorize=true

    # Check if the first argument is --no-color
    if [ "${1:-}" = "--no-color" ]; then
        colorize=false
        shift
    fi

    device=$(get_device)
    [ $? -ne 0 ] && return 1

    # Handle zsh globbing
    if [ "$SHELL_NAME" = "zsh" ]; then
        # Disable glob pattern expansion for this function
        setopt local_options no_nomatch
    fi

    # Build the adb command using arrays to avoid shell expansion issues
    local adb_cmd=("adb" "-s" "$device" "logcat")

    if [ $# -gt 0 ]; then
        # Build tag filters
        local tag_filters=()
        for arg in "$@"; do
            adb_cmd+=("$arg:*")
        done

        # Add silence filter for other tags
        adb_cmd+=("*:S")

        # Log command for user info
        echo "🚀 Running: ${adb_cmd[*]}"
    fi

    # Execute command with or without colorization
    if [ "$colorize" = true ]; then
        "${adb_cmd[@]}" | colorize_logcat
    else
        "${adb_cmd[@]}"
    fi
}

# Logcat colorizer function
function colorize_logcat() {
    # violet circuit color codes
    local RED='\033[38;5;197m'     # Hot pink-red for errors
    local ORANGE='\033[38;5;203m'  # Vibrant orange for warnings
    local MAGENTA='\033[38;5;171m' # Bright magenta for info
    local PURPLE='\033[38;5;141m'  # Lavender purple for debug
    local BLUE='\033[38;5;75m'     # Soft blue for verbose
    local CYAN='\033[38;5;123m'    # Cyan for markers
    local PINK='\033[38;5;219m'    # Pink for special highlights
    local YELLOW='\033[38;5;227m'  # Bright yellow for emphasis
    local RESET='\033[0m'
    local BOLD='\033[1m'

    # Read logcat output line by line
    while IFS= read -r line; do
        # Check for beginning markers first to avoid grep errors
        if [[ "$line" == *"--------- beginning of"* ]]; then
            # Log markers - bright cyan
            echo -e "${BOLD}${CYAN}${line}${RESET}"
            continue
        fi

        # Color based on log level using safer pattern matching
        if [[ "$line" == *" E "* ]]; then
            # Error - hot pink-red with bold
            echo -e "${BOLD}${RED}${line}${RESET}"
        elif [[ "$line" == *" W "* ]]; then
            # Warning - vibrant orange
            echo -e "${ORANGE}${line}${RESET}"
        elif [[ "$line" == *" I "* ]]; then
            # Info - bright magenta
            echo -e "${MAGENTA}${line}${RESET}"
        elif [[ "$line" == *" D "* ]]; then
            # Debug - lavender purple
            echo -e "${PURPLE}${line}${RESET}"
        elif [[ "$line" == *" V "* ]]; then
            # Verbose - soft blue
            echo -e "${BLUE}${line}${RESET}"
        # Check for special patterns without using grep
        elif [[ "$line" == *"Exception"* ]] ||
            [[ "$line" == *"Error:"* ]] ||
            [[ "$line" == *"FATAL"* ]] ||
            [[ "$line" == *"ANR"* ]]; then
            # Exception and error keywords - bold hot pink
            echo -e "${BOLD}${RED}${line}${RESET}"
        elif [[ "$line" == *"success"* ]] ||
            [[ "$line" == *"Success"* ]] ||
            [[ "$line" == *"CONNECTED"* ]] ||
            [[ "$line" == *"ready"* ]]; then
            # Success indicators - bold pink
            echo -e "${BOLD}${PINK}${line}${RESET}"
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
    while [ $# -gt 0 ]; do
        case "$1" in
        -n | --no-color)
            colorize=false
            shift
            ;;
        -h | --help)
            echo "$usage"
            return 0
            ;;
        -*)
            echo "Unknown option: $1" >&2
            echo "$usage" >&2
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
    if [ -z "${app_name:-}" ]; then
        echo "Error: No app name or package specified" >&2
        echo "$usage" >&2
        return 1
    fi

    # Handle zsh globbing
    if [ "$SHELL_NAME" = "zsh" ]; then
        # Disable glob pattern expansion for this function
        setopt local_options no_nomatch
    fi

    # Get connected device
    device=$(get_device)
    [ $? -ne 0 ] && return 1

    # First try exact package match
    if adb -s "$device" shell pm list packages | grep -q "package:$app_name"; then
        echo "✨ Found exact package match: $app_name"
    else
        # Try partial package match
        local package_matches
        package_matches=$(adb -s "$device" shell pm list packages | grep "$app_name" | sed 's/package://')

        if [ -n "$package_matches" ]; then
            # Count matches
            local match_count
            match_count=$(echo "$package_matches" | wc -l)

            if [ "$match_count" -eq 1 ]; then
                # Single match found
                app_name=$(echo "$package_matches" | tr -d '\r')
                echo "✨ Found package: $app_name"
            else
                # Multiple matches, let user choose
                echo "Multiple matching packages found:"
                local i=1
                echo "$package_matches" | while IFS= read -r pkg; do
                    printf "[%d] %s\n" "$i" "$pkg"
                    i=$((i + 1))
                done

                printf "Select package number (or Ctrl+C to cancel): "
                read -r choice
                app_name=$(echo "$package_matches" | sed -n "${choice}p" | tr -d '\r')
                [ -z "$app_name" ] && return 1
                echo "✨ Selected package: $app_name"
            fi
        fi
    fi

    # Get process IDs for the app
    echo "🔍 Looking for processes matching '$app_name'..."
    pid_list=$(adb -s "$device" shell ps | grep -i "$app_name" | awk '{print $2}')

    if [ -z "$pid_list" ]; then
        echo "⚠️ No running processes found for '$app_name'"
        echo "💡 Is the app running? Try starting it first."
        return 1
    fi

    # Count processes
    local process_count
    process_count=$(echo "$pid_list" | wc -l)
    echo "📱 Found $process_count running process(es) for '$app_name'"

    # Extract process IDs into an array for reliable handling
    local pids=()
    while IFS= read -r pid; do
        pid=$(echo "$pid" | tr -d '\r')
        if [ -n "$pid" ]; then
            pids+=("$pid")
        fi
    done <<<"$pid_list"

    # Execute the logcat command directly with proper arguments
    echo "📊 Streaming logs for '$app_name'..."
    echo "💡 Press Ctrl+C to stop"

    # Build the adb command properly to avoid shell expansion issues
    local adb_cmd=("adb" "-s" "$device" "logcat")

    # Add pid filters if available
    for pid in "${pids[@]}"; do
        adb_cmd+=("--pid=$pid")
    done

    # Show the command being run
    echo "🚀 Running: ${adb_cmd[*]}"
    echo "-------------------------------------------"

    # Execute based on colorization
    if [ "$colorize" = true ]; then
        "${adb_cmd[@]}" | colorize_logcat
    else
        "${adb_cmd[@]}"
    fi
}

# Install boot image with proper variable handling
function installboot() {
    if [ -z "${TARGET_PRODUCT:-}" ]; then
        echo "No TARGET_PRODUCT specified."
        return 1
    fi
    if [ ! -e "${OUT:-}/boot.img" ]; then
        echo "No boot.img found. Run make bootimage first."
        return 1
    fi

    local device PARTITION
    device=$(get_device)
    [ $? -ne 0 ] && return 1

    PARTITION="/dev/block/bootdevice/by-name/boot"
    adb -s "$device" root
    sleep 1
    adb -s "$device" wait-for-device
    adb -s "$device" shell mount /system 2>/dev/null
    adb -s "$device" remount

    if adb -s "$device" shell getprop ro.product.name | grep -q "$TARGET_PRODUCT"; then
        adb -s "$device" push "$OUT/boot.img" /data/local/tmp/
        for module in "$OUT"/system/lib/modules/*; do
            [ -f "$module" ] && adb -s "$device" push "$module" /system/lib/modules/
        done
        adb -s "$device" shell "dd if=/data/local/tmp/boot.img of=$PARTITION"
        adb -s "$device" shell "chmod 644 /system/lib/modules/*"
        echo "Installation complete."
    else
        echo "The connected device does not appear to be $TARGET_PRODUCT, run away!"
    fi
}

# Remote management functions with proper error handling
function aospremote() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi

    git remote rm aosp 2>/dev/null
    local PROJECT PFX
    PROJECT=$(pwd -P | sed -e "s#${ANDROID_BUILD_TOP:-}/##; s#-caf.*##; s#/default##")
    if echo "$PROJECT" | grep -qv "^device"; then
        PFX="platform/"
    fi
    git remote add aosp "https://android.googlesource.com/${PFX}${PROJECT}"
    echo "Remote 'aosp' created"
}

function cafremote() {
    if ! git rev-parse --git-dir >/dev/null 2>&1; then
        echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
        return 1
    fi

    git remote rm caf 2>/dev/null
    local PROJECT PFX
    PROJECT=$(pwd -P | sed -e "s#${ANDROID_BUILD_TOP:-}/##; s#-caf.*##; s#/default##")
    if echo "$PROJECT" | grep -qv "^device"; then
        PFX="platform/"
    fi
    git remote add caf "https://source.codeaurora.org/quic/la/${PFX}${PROJECT}"
    echo "Remote 'caf' created"
}

# File operations with proper quoting and error handling
function apush() {
    if [ -z "${OUT:-}" ]; then
        echo "Android environment not configured."
        return 1
    fi

    local device
    device=$(get_device)
    [ $? -ne 0 ] && return 1

    local status=0
    for file in "$@"; do
        if [ ! -f "$file" ]; then
            echo "File not found: $file"
            status=1
            continue
        fi

        local realfile relpath
        realfile=$(readlink -f "$file" 2>/dev/null || realpath "$file" 2>/dev/null || echo "$file")
        relpath=$(echo "$realfile" | sed "s|${OUT}/||")

        echo "Pushing $file to /$relpath"
        if ! adb -s "$device" push "$realfile" "/$relpath"; then
            status=1
        fi
    done

    return $status
}

function apull() {
    local device
    device=$(get_device)
    [ $? -ne 0 ] && return 1

    local status=0
    for path in "$@"; do
        echo "Pulling $path"
        if ! adb -s "$device" pull "$path" .; then
            status=1
        fi
    done

    return $status
}

# Environment variables
export USE_CCACHE=1
export CCACHE_EXEC=${CCACHE_EXEC:-/usr/bin/ccache}
export CCACHE_DIR=${CCACHE_DIR:-/b/.ccache}
export CCACHE_SIZE=${CCACHE_SIZE:-50G}
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4g"

# Initialize ccache if directory exists
if [ -d "/b/.ccache" ] && [ -x "$CCACHE_EXEC" ]; then
    "$CCACHE_EXEC" -M "$CCACHE_SIZE" >/dev/null 2>&1
fi

# Add Android SDK platform tools to PATH if directory exists
if [ -d "$HOME/Android/Sdk/platform-tools" ]; then
    export PATH="$PATH:$HOME/Android/Sdk/platform-tools"
fi

# Initialize repo completion for both shells
if [ -f ~/bin/repo ]; then
    if [ "$SHELL_NAME" = "zsh" ]; then
        autoload -Uz compinit && compinit
        eval "$(~/bin/repo --help | grep -A 1 "Shell completion" | tail -1)"
    else
        eval "$(~/bin/repo --help | grep -A 1 "Shell completion" | tail -1)"
    fi
fi

# Quick navigation aliases (work in both shells)
alias croot='cd ${ANDROID_BUILD_TOP:-.}'
alias godefault='cd ${ANDROID_BUILD_TOP:-.}/default'
alias gokernel='cd ${ANDROID_BUILD_TOP:-.}/kernel'
alias govendor='cd ${ANDROID_BUILD_TOP:-.}/vendor'
alias godevice='cd ${ANDROID_BUILD_TOP:-.}/device'
alias goapps='cd ${ANDROID_BUILD_TOP:-.}/packages/apps'
alias goframework='cd ${ANDROID_BUILD_TOP:-.}/frameworks'
alias gosystem='cd ${ANDROID_BUILD_TOP:-.}/system'
alias gohw='cd ${ANDROID_BUILD_TOP:-.}/hardware'
alias goout='cd ${OUT:-.}'

# Gradle helper functions
function gtest() {
    local module="${1:-.}"
    local variant="${2:-Debug}"
    local filter="$3"

    # Build command with proper test output formatting
    local cmd="./gradlew"
    cmd+=" ${module}:test${variant}"
    [ -n "$filter" ] && cmd+=" --tests $filter"
    cmd+=" -q"              # Quiet Gradle output
    cmd+=" --console=plain" # Plain console output
    cmd+=" --stacktrace"    # Full stacktrace for errors
    cmd+=" -Pandroid.testInstrumentationRunnerArguments.filter=$filter"

    echo "Running tests for ${module} (${variant})"
    eval "$cmd"
}

function grun() {
    local task="$1"
    shift

    # Build command with clean output
    local cmd="./gradlew"
    cmd+=" ${task}"
    cmd+=" -q"                   # Quiet Gradle output
    cmd+=" --console=plain"      # Plain console output
    [ "$#" -gt 0 ] && cmd+=" $*" # Add any additional arguments

    echo "Running Gradle task: ${task}"
    eval "$cmd"
}

function gclear() {
    echo "Cleaning Gradle caches and build files..."
    rm -rf ~/.gradle/caches/
    rm -rf .gradle
    rm -rf */build
    rm -rf build
    ./gradlew clean
    echo "Gradle clean complete"
}

function gdeps() {
    local module="${1:-.}"
    echo "Showing dependencies for ${module}"
    ./gradlew ${module}:dependencies --configuration implementation
}

function gbuild() {
    local variant="${1:-Debug}"
    local module="${2:-.}"

    echo "Building ${module} (${variant})"
    ./gradlew "${module}:assemble${variant}" --console=plain
}

# Quick task to show all tasks for current project or specific module
function gtasks() {
    local module="${1:-.}"
    echo "Available Gradle tasks for ${module}:"
    ./gradlew ${module}:tasks --all
}

# Android device management with named aliases
function adbdev() {
    local config_file="$HOME/.adbdevs"
    local usage="Usage:
    adbdev <alias>            - Set ANDROID_SERIAL to the device with given alias
    adbdev --add <alias> <serial>    - Add or update device alias
    adbdev --remove <alias>   - Remove device alias
    adbdev --list            - List all device aliases"

    # Create config file if it doesn't exist
    touch "$config_file" 2>/dev/null || {
        echo "Error: Cannot create/access $config_file" >&2
        return 1
    }

    case "${1:-}" in
    --add)
        if [ -z "${2:-}" ] || [ -z "${3:-}" ]; then
            echo "$usage" >&2
            return 1
        fi
        local alias="$2"
        local serial="$3"
        # Remove existing entry if any
        sed -i "/$alias:/d" "$config_file"
        # Add new entry
        echo "$alias:$serial" >>"$config_file"
        echo "Added device alias '$alias' for serial '$serial'"
        ;;
    --remove)
        if [ -z "${2:-}" ]; then
            echo "$usage" >&2
            return 1
        fi
        local alias="$2"
        if sed -i "/$alias:/d" "$config_file"; then
            echo "Removed device alias '$alias'"
        else
            echo "Error: Could not remove alias '$alias'" >&2
            return 1
        fi
        ;;
    --list)
        if [ ! -s "$config_file" ]; then
            echo "No device aliases configured"
            return 0
        fi
        echo "Configured device aliases:"
        while IFS=: read -r alias serial || [ -n "$alias" ]; do
            printf "  %-20s %s\n" "$alias" "$serial"
        done <"$config_file"
        ;;
    "")
        echo "$usage" >&2
        return 1
        ;;
    *)
        local alias="$1"
        local serial
        serial=$(grep "^$alias:" "$config_file" | cut -d: -f2)
        if [ -z "$serial" ]; then
            echo "Error: No device found with alias '$alias'" >&2
            return 1
        fi
        export ANDROID_SERIAL="$serial"
        echo "Set ANDROID_SERIAL=$ANDROID_SERIAL"
        ;;
    esac
}

# Ensure proper exit status
true
