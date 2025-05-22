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

echo "🔧 Configuring macOS settings..."

# Close any open System Preferences panes to prevent them from overriding settings
osascript -e 'tell application "System Preferences" to quit' || handle_error "closing System Preferences"

# Ask for the administrator password upfront
sudo -v || { echo "⚠️ Failed to get sudo privileges. Some settings might not be applied."; }

# Keep-alive: update existing `sudo` time stamp until script has finished
while true; do
  sudo -n true
  sleep 60
  kill -0 "$$" || exit
done 2> /dev/null &

###############################################################################
# General UI/UX                                                               #
###############################################################################

# Hostname configuration removed as requested by user

# Disable the sound effects on boot
sudo nvram SystemAudioVolume=" " || handle_error "setting boot sound"

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

# Enable developer mode (prevents "Application downloaded from Internet" warnings)
sudo spctl --master-disable

# Configure key remapping for developers
# Map Caps Lock to Escape (useful for Vim users)
hidutil property --set '{"UserKeyMapping":[{"HIDKeyboardModifierMappingSrc":0x700000039,"HIDKeyboardModifierMappingDst":0x700000029}]}' || handle_error "setting keyboard mapping"

###############################################################################
# Safari & WebKit                                                             #
###############################################################################

# Privacy: don't send search queries to Apple
defaults write com.apple.Safari UniversalSearchEnabled -bool false || handle_error "Safari UniversalSearchEnabled"
defaults write com.apple.Safari SuppressSearchSuggestions -bool true || handle_error "Safari SuppressSearchSuggestions"

# Enable Safari's debug menu
defaults write com.apple.Safari IncludeInternalDebugMenu -bool true || handle_error "Safari IncludeInternalDebugMenu"

# Enable the Develop menu and the Web Inspector in Safari
defaults write com.apple.Safari IncludeDevelopMenu -bool true || handle_error "Safari IncludeDevelopMenu"
defaults write com.apple.Safari WebKitDeveloperExtrasEnabled -bool true || handle_error "Safari WebKitDeveloperExtrasEnabled"
defaults write com.apple.Safari com.apple.Safari.ContentPageGroupIdentifier.WebKit2DeveloperExtrasEnabled -bool true || handle_error "Safari WebKit2DeveloperExtrasEnabled"

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
  killall "${app}" &> /dev/null
done

echo "✅ macOS settings configured successfully! Some changes require a restart to take effect."
