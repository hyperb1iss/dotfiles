# macos.sh
# macOS specific utilities and configurations

# Only load these functions if running on macOS
if is_macos; then
  # macOS application shortcuts
  alias code='open -a "Visual Studio Code"'
  alias subl='open -a "Sublime Text"'
  alias preview='open -a "Preview"'
  alias xcode='open -a "Xcode"'
  alias finder='open -a "Finder"'
  alias chrome='open -a "Google Chrome"'
  alias safari='open -a "Safari"'
  alias ghostty='open -a "Ghostty"'

  # Open file/directory in Finder
  function finder() {
    if [[ $# -eq 0 ]]; then
      open .
    else
      open "$@"
    fi
  }

  # Copy to clipboard
  function clip() {
    if [[ -p /dev/stdin ]]; then
      # If input is from a pipe, process it
      pbcopy
    elif [[ $# -eq 0 ]]; then
      # If no args, show usage
      echo "Usage: clip <text> or command | clip"
    else
      # If args are provided, copy them
      echo "$@" | pbcopy
    fi
  }

  # Paste from clipboard
  alias paste='pbpaste'

  # Quick look a file
  function ql() {
    qlmanage -p "$@" &> /dev/null
  }

  # Show/hide hidden files in Finder
  alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
  alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"

  # Open current directory in VSCode
  alias vsc='code .'

  # Add Homebrew's unversioned Python symlinks to PATH
  if [[ -d /opt/homebrew/opt/python@3.13/libexec/bin ]]; then
    export PATH="/opt/homebrew/opt/python@3.13/libexec/bin:${PATH}"
  elif [[ -d /usr/local/opt/python@3.13/libexec/bin ]]; then
    export PATH="/usr/local/opt/python@3.13/libexec/bin:${PATH}"
  fi

  # Accurate APFS disk free space (df -h lies on macOS)
  alias diskfree='diskutil info / | grep -E "Container (Free|Total) Space"'

  # Flush DNS cache
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

  # Get macOS version info
  function macversion() {
    sw_vers
  }

  # Enhanced clipboard utilities
  function copy-path() {
    local path="${1:-.}"
    local resolved_path
    resolved_path=$(realpath "${path}") || true
    echo -n "${resolved_path}" | pbcopy
    echo "Path copied to clipboard"
  }

  # Show current wifi network
  function wifi-name() {
    local airport_info
    airport_info=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I) || true
    echo "${airport_info}" | awk '/ SSID/ {print $2}'
  }

  # List all connected devices (USB, Thunderbolt, etc)
  function list-devices() {
    system_profiler SPUSBDataType SPBluetoothDataType SPThunderboltDataType
  }

  # Get battery status
  function battery() {
    local batt_info
    batt_info=$(pmset -g batt) || true
    echo "${batt_info}" | grep -o "[0-9]*%"
  }

  # Easy way to extract disk images
  function extract-dmg() {
    local dmg_file="$1"
    local mount_point
    mount_point="/Volumes/$(basename "${dmg_file}" .dmg)"
    local extract_dir="${2:-./$(basename "${dmg_file}" .dmg)_extracted}"

    if [[ ! -f "${dmg_file}" ]]; then
      echo "File not found: ${dmg_file}"
      return 1
    fi

    mkdir -p "${extract_dir}"
    hdiutil attach "${dmg_file}"
    cp -R "${mount_point}"/* "${extract_dir}"/
    hdiutil detach "${mount_point}"
    echo "Extracted to ${extract_dir}"
  }

  # Manage quarantine attributes (for downloaded files)
  function unquarantine() {
    xattr -d com.apple.quarantine "$@"
    echo "Quarantine attribute removed from $*"
  }

  # Toggle dark mode
  function toggle-dark-mode() {
    osascript -e 'tell application "System Events" to tell appearance preferences to set dark mode to not dark mode'
  }

  # Set volume level (0-100)
  function set-volume() {
    if [[ $1 -ge 0 && $1 -le 100 ]]; then
      osascript -e "set volume output volume $1"
      echo "Volume set to $1%"
    else
      echo "Please specify a volume level between 0 and 100"
    fi
  }

  # Mute/unmute
  alias mute='osascript -e "set volume output muted true"'
  alias unmute='osascript -e "set volume output muted false"'

  # Homebrew Services Management
  # List all services
  function brew-services-list() {
    brew services list
  }

  # Start a service
  function brew-start() {
    if [[ -z "$1" ]]; then
      echo "Usage: brew-start <service>"
      return 1
    fi
    brew services start "$1"
  }

  # Stop a service
  function brew-stop() {
    if [[ -z "$1" ]]; then
      echo "Usage: brew-stop <service>"
      return 1
    fi
    brew services stop "$1"
  }

  # Restart a service
  function brew-restart() {
    if [[ -z "$1" ]]; then
      echo "Usage: brew-restart <service>"
      return 1
    fi
    brew services restart "$1"
  }

  # Interactive service management with fzf
  function brew-services() {
    local selected
    local services_list
    services_list=$(brew services list) || true
    selected=$(echo "${services_list}" | fzf --header-lines=1 --preview="echo {}" --preview-window=up:1)

    if [[ -n "${selected}" ]]; then
      local service
      local status
      service=$(echo "${selected}" | awk '{print $1}')
      status=$(echo "${selected}" | awk '{print $2}')

      echo "Service: ${service} (Status: ${status})"
      echo "Actions:"
      echo "  1) Start"
      echo "  2) Stop"
      echo "  3) Restart"
      echo "  q) Quit"

      read -r -p "Select action: " action

      case "${action}" in
        1) brew services start "${service}" ;;
        2) brew services stop "${service}" ;;
        3) brew services restart "${service}" ;;
        q) return 0 ;;
        *) echo "Invalid action" ;;
      esac
    fi
  }

  # App Store CLI Functions
  # Search for an app
  function app-search() {
    if [[ -z "$1" ]]; then
      echo "Usage: app-search <query>"
      return 1
    fi
    mas search "$1"
  }

  # Install an app by ID
  function app-install() {
    if [[ -z "$1" ]]; then
      echo "Usage: app-install <app_id>"
      return 1
    fi
    mas install "$1"
  }

  # List installed App Store apps
  function app-list() {
    mas list
  }

  # Open Xcode developer tools (useful for iOS development)
  function xcode-select-install() {
    xcode-select --install
  }

  # Advanced Screenshot and Recording Functions

  # Take a screenshot of a selected area and save to desktop
  function screenshot-area() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S) || true
    screencapture -i ~/Desktop/screenshot-"${timestamp}".png
    echo "Screenshot saved to Desktop"
  }

  # Take a screenshot of a selected area and copy to clipboard
  function screenshot-area-clipboard() {
    screencapture -ic
    echo "Screenshot copied to clipboard"
  }

  # Take a screenshot of the entire screen
  function screenshot-screen() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S) || true
    screencapture ~/Desktop/screenshot-"${timestamp}".png
    echo "Screenshot saved to Desktop"
  }

  # Take a screenshot of a specific window (click to select)
  function screenshot-window() {
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S) || true
    screencapture -iW ~/Desktop/screenshot-"${timestamp}".png
    echo "Screenshot saved to Desktop"
  }

  # Start screen recording (press Ctrl+C to stop)
  function screen-record() {
    local output_file
    local timestamp
    timestamp=$(date +%Y%m%d-%H%M%S) || true
    output_file=~/Desktop/screen-recording-"${timestamp}".mov
    echo "Recording screen to ${output_file}..."
    echo "Press Control+C to stop recording..."
    screencapture -V 60 -v "${output_file}"
    echo "Screen recording saved to ${output_file}"
  }

  # Create a GIF from the last screen recording
  function gif-from-recording() {
    if [[ -z "$1" ]]; then
      echo "Usage: gif-from-recording <recording_file.mov>"
      return 1
    fi

    local input_file="$1"
    local output_file="${input_file%.*}.gif"

    if ! [[ -f "${input_file}" ]]; then
      echo "Error: File ${input_file} does not exist"
      return 1
    fi

    if ! has_command ffmpeg; then
      echo "Error: ffmpeg is required. Install with 'brew install ffmpeg'"
      return 1
    fi

    echo "Converting ${input_file} to GIF..."
    ffmpeg -i "${input_file}" -vf "fps=10,scale=1280:-1:flags=lanczos,split[s0][s1];[s0]palettegen[p];[s1][p]paletteuse" -loop 0 "${output_file}"
    echo "GIF saved to ${output_file}"
  }

  # Change default screenshot location
  function screenshot-location() {
    if [[ -z "$1" ]]; then
      # Print current location
      defaults read com.apple.screencapture location
      return 0
    fi

    # Set new location
    if [[ -d "$1" ]]; then
      defaults write com.apple.screencapture location "$1"
      killall SystemUIServer
      echo "Screenshot location changed to $1"
    else
      echo "Error: Directory $1 does not exist"
      return 1
    fi
  }

  # Modified PATH for macOS to include Homebrew
  brew_prefix=""
  if [[ -d /opt/homebrew/bin ]]; then
    brew_prefix="/opt/homebrew"
  elif [[ -d /usr/local/bin ]]; then
    brew_prefix="/usr/local"
  fi

  if [[ -n "${brew_prefix}" ]]; then
    export PATH="${brew_prefix}/bin:${brew_prefix}/sbin:${PATH}"
  fi

  # Homebrew's default Python is already properly linked, no manual PATH needed

  # Configure bash completions for Homebrew packages.
  # Zsh completions are added before compinit in zshrc.
  if [[ -n "${brew_prefix}" ]] && is_bash; then
    if [[ -r "${brew_prefix}/etc/profile.d/bash_completion.sh" ]]; then
      source "${brew_prefix}/etc/profile.d/bash_completion.sh"
    else
      for COMPLETION in "${brew_prefix}/etc/bash_completion.d/"*; do
        # shellcheck disable=SC1090
        [[ -r "${COMPLETION}" ]] && source "${COMPLETION}"
      done
    fi
  fi
fi
