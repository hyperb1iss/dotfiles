#!/bin/bash
# macos_config.sh
# Configure macOS defaults for a developer-friendly environment

# Continue on error
set +e

# Function to handle errors gracefully
handle_error() {
  echo "⚠️ Command failed: $1"
  echo "Continuing with next setting..."
}

diagnose_sudo_failure() {
  local reattach_path

  reattach_path="$(awk '/pam_reattach\.so/ { print $NF; exit }' /etc/pam.d/sudo_local 2>/dev/null || true)"
  if [[ -n "${reattach_path}" && ! -f "${reattach_path}" ]]; then
    echo "⚠️ sudo appears to reference a missing pam_reattach module:"
    echo "   ${reattach_path}"
    echo "   Remove that line from /etc/pam.d/sudo_local from an admin/root shell,"
    echo "   then rerun make macos."
  fi
}

request_sudo() {
  if sudo -n -v 2>/dev/null; then
    SUDO_AVAILABLE=true
    return 0
  fi

  echo "Requesting administrator privileges for macOS settings..."
  if [[ -r /dev/tty ]] && sudo -v </dev/tty; then
    SUDO_AVAILABLE=true
    return 0
  fi

  SUDO_AVAILABLE=false
  echo "⚠️ Failed to get sudo privileges. Privileged settings will be skipped."
  diagnose_sudo_failure
  return 1
}

run_sudo() {
  local description="$1"
  shift

  if [[ "${SUDO_AVAILABLE}" == "true" ]]; then
    sudo "$@" || handle_error "${description}"
  else
    handle_error "${description} (sudo unavailable)"
  fi
}

echo "🔧 Configuring macOS settings..."

# Close any open System Preferences panes to prevent them from overriding settings
osascript -e 'tell application "System Preferences" to quit' || handle_error "closing System Preferences"

SUDO_AVAILABLE=false
request_sudo

# Enable Touch ID for sudo (survives macOS updates via sudo_local)
# pam_reattach allows Touch ID to work inside tmux/screen/IDE terminals
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
fi

if [[ -z "${BREW_PREFIX}" && "$(uname -m)" == "arm64" ]]; then
  BREW_PREFIX="/opt/homebrew"
elif [[ -z "${BREW_PREFIX}" ]]; then
  BREW_PREFIX="/usr/local"
fi

REATTACH_SO="${BREW_PREFIX}/lib/pam/pam_reattach.so"
DESIRED_SUDO_LOCAL="# sudo_local: Touch ID for sudo"

if [[ -f "${REATTACH_SO}" ]]; then
  DESIRED_SUDO_LOCAL="${DESIRED_SUDO_LOCAL} (including tmux/screen)
auth       optional       ${REATTACH_SO}"
else
  echo "⚠️ pam_reattach not found, configuring Touch ID without tmux/screen reattach"
fi

DESIRED_SUDO_LOCAL="${DESIRED_SUDO_LOCAL}
auth       sufficient     pam_tid.so"

if [[ "${SUDO_AVAILABLE}" != "true" ]]; then
  echo "⚠️ Skipping Touch ID for sudo setup because sudo is unavailable"
elif [[ -f /etc/pam.d/sudo_local ]] && diff -q <(printf '%s\n' "${DESIRED_SUDO_LOCAL}") /etc/pam.d/sudo_local &>/dev/null; then
  echo "✓ Touch ID for sudo already configured"
else
  echo "Enabling Touch ID for sudo..."
  if printf '%s\n' "${DESIRED_SUDO_LOCAL}" | sudo tee /etc/pam.d/sudo_local >/dev/null; then
    echo "✓ Touch ID enabled for sudo"
  else
    handle_error "enabling Touch ID for sudo"
  fi
fi

# Keep-alive: update existing `sudo` time stamp until script has finished
if [[ "${SUDO_AVAILABLE}" == "true" ]]; then
  while true; do
    sudo -n true
    sleep 60
    kill -0 "$$" || exit
  done 2>/dev/null &
fi

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Hostname configuration removed as requested by user

# Disable the sound effects on boot
run_sudo "setting boot sound" nvram SystemAudioVolume=" "

# Set sidebar icon size to medium
defaults write NSGlobalDomain NSTableViewDefaultSizeMode -int 2 || handle_error "NSTableViewDefaultSizeMode"

# Always show scrollbars
defaults write NSGlobalDomain AppleShowScrollBars -string "Always" || handle_error "AppleShowScrollBars"

# Disable the "Are you sure you want to open this application?" dialog
defaults write com.apple.LaunchServices LSQuarantine -bool false

# Disable automatic capitalization
defaults write NSGlobalDomain NSAutomaticCapitalizationEnabled -bool false

# Disable smart dashes
defaults write NSGlobalDomain NSAutomaticDashSubstitutionEnabled -bool false

# Disable automatic period substitution
defaults write NSGlobalDomain NSAutomaticPeriodSubstitutionEnabled -bool false

# Disable smart quotes
defaults write NSGlobalDomain NSAutomaticQuoteSubstitutionEnabled -bool false

# Disable auto-correct
defaults write NSGlobalDomain NSAutomaticSpellingCorrectionEnabled -bool false

###############################################################################
# Trackpad, mouse, keyboard, Bluetooth accessories, and input                 #
###############################################################################

# Trackpad: enable tap to click for this user and for the login screen
defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
defaults -currentHost write NSGlobalDomain com.apple.mouse.tapBehavior -int 1
defaults write NSGlobalDomain com.apple.mouse.tapBehavior -int 1

# Enable full keyboard access for all controls
defaults write NSGlobalDomain AppleKeyboardUIMode -int 3

# Set language and text formats
defaults write NSGlobalDomain AppleLanguages -array "en" "es"
defaults write NSGlobalDomain AppleLocale -string "en_US@currency=USD"
defaults write NSGlobalDomain AppleMeasurementUnits -string "Inches"
defaults write NSGlobalDomain AppleMetricUnits -bool false

# Set a blazingly fast keyboard repeat rate
defaults write NSGlobalDomain KeyRepeat -int 2
defaults write NSGlobalDomain InitialKeyRepeat -int 15

###############################################################################
# Screen                                                                      #
###############################################################################

# Require password immediately after sleep or screen saver begins
defaults write com.apple.screensaver askForPassword -int 1
defaults write com.apple.screensaver askForPasswordDelay -int 0

# Save screenshots to the desktop
defaults write com.apple.screencapture location -string "${HOME}/Desktop"

# Save screenshots in PNG format (other options: BMP, GIF, JPG, PDF, TIFF)
defaults write com.apple.screencapture type -string "png"

# Disable shadow in screenshots
defaults write com.apple.screencapture disable-shadow -bool true

###############################################################################
# Finder                                                                      #
###############################################################################

# Show hidden files in Finder by default
defaults write com.apple.finder AppleShowAllFiles -bool true

# Show all filename extensions in Finder
defaults write NSGlobalDomain AppleShowAllExtensions -bool true

# Show status bar in Finder
defaults write com.apple.finder ShowStatusBar -bool true

# Show path bar in Finder
defaults write com.apple.finder ShowPathbar -bool true

# Display full POSIX path as Finder window title
defaults write com.apple.finder _FXShowPosixPathInTitle -bool true

# Keep folders on top when sorting by name
defaults write com.apple.finder _FXSortFoldersFirst -bool true

# When performing a search, search the current folder by default
defaults write com.apple.finder FXDefaultSearchScope -string "SCcf"

# Disable the warning when changing a file extension
defaults write com.apple.finder FXEnableExtensionChangeWarning -bool false

# Use list view in all Finder windows by default
defaults write com.apple.finder FXPreferredViewStyle -string "Nlsv"

# Show the ~/Library folder
chflags nohidden ~/Library

###############################################################################
# Dock, Dashboard, and hot corners                                            #
###############################################################################

# Dock settings removed as requested by user

###############################################################################
# Terminal & Warp                                                            #
###############################################################################

# Only use UTF-8 in Terminal.app
defaults write com.apple.terminal StringEncodings -array 4

# Enable "focus follows mouse" for Terminal.app and all X11 apps
defaults write com.apple.terminal FocusFollowsMouse -bool true
defaults write org.x.X11 wm_ffm -bool true

# Warp configuration is handled through symlinked theme files

###############################################################################
# Mac App Store                                                               #
###############################################################################

# Enable the automatic update check
defaults write com.apple.SoftwareUpdate AutomaticCheckEnabled -bool true

# Check for software updates daily, not just once per week
defaults write com.apple.SoftwareUpdate ScheduleFrequency -int 1

# Download newly available updates in background
defaults write com.apple.SoftwareUpdate AutomaticDownload -int 1

# Install System data files & security updates
defaults write com.apple.SoftwareUpdate CriticalUpdateInstall -int 1

###############################################################################
# Developer settings                                                          #
###############################################################################

# Enable developer mode
# Note: spctl --master-disable requires manual confirmation in
# System Settings > Privacy & Security on modern macOS — can't be automated.
# Uncomment to attempt it (will show a GUI prompt that may not work):
# sudo spctl --master-disable
run_sudo "enabling developer mode" spctl developer-mode enable-terminal

# Configure key remapping for developers
# Map Caps Lock to Escape (useful for Vim users)
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' || handle_error "setting keyboard mapping"

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Note: Safari preferences are sandboxed in modern macOS and must be changed
# through System Settings > Safari, or via the container path.
SAFARI_PLIST="${HOME}/Library/Containers/com.apple.Safari/Data/Library/Preferences/com.apple.Safari"

# Privacy: don't send search queries to Apple
defaults write "${SAFARI_PLIST}" UniversalSearchEnabled -bool false || handle_error "Safari UniversalSearchEnabled"
defaults write "${SAFARI_PLIST}" SuppressSearchSuggestions -bool true || handle_error "Safari SuppressSearchSuggestions"

# Enable Safari's debug menu
defaults write "${SAFARI_PLIST}" IncludeInternalDebugMenu -bool true || handle_error "Safari IncludeInternalDebugMenu"

# Enable the Develop menu and the Web Inspector in Safari
defaults write "${SAFARI_PLIST}" IncludeDevelopMenu -bool true || handle_error "Safari IncludeDevelopMenu"
defaults write "${SAFARI_PLIST}" WebKitDeveloperExtrasEnabled -bool true || handle_error "Safari WebKitDeveloperExtrasEnabled"
defaults write "${SAFARI_PLIST}" com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true || handle_error "Safari WebKit2DeveloperExtrasEnabled"

# Add a context menu item for showing the Web Inspector in web views
defaults write NSGlobalDomain WebKitDeveloperExtras -bool true || handle_error "WebKitDeveloperExtras"

###############################################################################
# Kill affected applications                                                  #
###############################################################################

for app in "Activity Monitor" \
  "Address Book" \
  "Calendar" \
  "cfprefsd" \
  "Contacts" \
  "Dock" \
  "Finder" \
  "Mail" \
  "Messages" \
  "Photos" \
  "Safari" \
  "SystemUIServer" \
  "Terminal" \
  "iCal"; do
  killall "${app}" &>/dev/null
done

echo "✅ macOS settings configured successfully! Some changes require a restart to take effect."
