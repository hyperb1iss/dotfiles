#!/bin/bash
# macos.sh
# macOS specific utilities and configurations

# Only load these functions if running on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    # macOS application shortcuts
    alias code='open -a "Visual Studio Code"'
    alias subl='open -a "Sublime Text"'
    alias preview='open -a "Preview"'
    alias xcode='open -a "Xcode"'
    alias finder='open -a "Finder"'
    alias chrome='open -a "Google Chrome"'
    alias safari='open -a "Safari"'
    alias iterm='open -a "iTerm"'

    # Open file/directory in Finder
    function finder() {
        if [ $# -eq 0 ]; then
            open .
        else
            open "$@"
        fi
    }

    # Copy to clipboard
    function clip() {
        if [ -p /dev/stdin ]; then
            # If input is from a pipe, process it
            pbcopy
        elif [ $# -eq 0 ]; then
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
        qlmanage -p "$@" &>/dev/null
    }

    # Show/hide hidden files in Finder
    alias showfiles="defaults write com.apple.finder AppleShowAllFiles YES; killall Finder"
    alias hidefiles="defaults write com.apple.finder AppleShowAllFiles NO; killall Finder"

    # Open current directory in VSCode
    alias vsc='code .'

    # Flush DNS cache
    alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'

    # Get macOS version info
    function macversion() {
        sw_vers
    }

    # Enhanced clipboard utilities
    function copy-path() {
        local path="${1:-.}"
        realpath "$path" | tr -d '\n' | pbcopy
        echo "Path copied to clipboard"
    }

    # Show current wifi network
    function wifi-name() {
        /System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | awk '/ SSID/ {print $2}'
    }

    # List all connected devices (USB, Thunderbolt, etc)
    function list-devices() {
        system_profiler SPUSBDataType SPBluetoothDataType SPThunderboltDataType
    }

    # Get battery status
    function battery() {
        pmset -g batt | grep -o "[0-9]*%"
    }

    # Easy way to extract disk images
    function extract-dmg() {
        local dmg_file="$1"
        local mount_point="/Volumes/$(basename "$dmg_file" .dmg)"
        local extract_dir="${2:-./$(basename "$dmg_file" .dmg)_extracted}"
        
        if [[ ! -f "$dmg_file" ]]; then
            echo "File not found: $dmg_file"
            return 1
        fi
        
        mkdir -p "$extract_dir"
        hdiutil attach "$dmg_file"
        cp -R "$mount_point"/* "$extract_dir"/
        hdiutil detach "$mount_point"
        echo "Extracted to $extract_dir"
    }

    # Manage quarantine attributes (for downloaded files)
    function unquarantine() {
        xattr -d com.apple.quarantine "$@"
        echo "Quarantine attribute removed from $@"
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

    # Modified PATH for macOS to include Homebrew
    if [[ $(uname -m) == "arm64" ]]; then
        # M1/M2 Mac
        export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
    else
        # Intel Mac
        export PATH="/usr/local/bin:/usr/local/sbin:$PATH"
    fi

    # Add common Homebrew Python locations to PATH
    if [ -d /opt/homebrew/opt/python@3.10/libexec/bin ]; then
        export PATH="/opt/homebrew/opt/python@3.10/libexec/bin:$PATH"
    elif [ -d /usr/local/opt/python@3.10/libexec/bin ]; then
        export PATH="/usr/local/opt/python@3.10/libexec/bin:$PATH"
    fi

    # Fix for Java on macOS
    if [ -d /opt/homebrew/opt/openjdk@17 ]; then
        export JAVA_HOME="/opt/homebrew/opt/openjdk@17"
    elif [ -d /usr/local/opt/openjdk@17 ]; then
        export JAVA_HOME="/usr/local/opt/openjdk@17"
    fi
    export PATH="$JAVA_HOME/bin:$PATH"

    # Configure zsh and bash completions for Homebrew packages
    if type brew &>/dev/null; then
        FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
        
        if [ -n "$ZSH_VERSION" ]; then
            # ZSH completions
            FPATH="$(brew --prefix)/share/zsh-completions:$FPATH"
            if [[ -d $(brew --prefix)/share/zsh/site-functions ]]; then
                FPATH="$(brew --prefix)/share/zsh/site-functions:$FPATH"
            fi
            autoload -Uz compinit
            compinit
        elif [ -n "$BASH_VERSION" ]; then
            # Bash completions
            if [[ -r "$(brew --prefix)/etc/profile.d/bash_completion.sh" ]]; then
                source "$(brew --prefix)/etc/profile.d/bash_completion.sh"
            else
                for COMPLETION in "$(brew --prefix)/etc/bash_completion.d/"*; do
                    [[ -r "$COMPLETION" ]] && source "$COMPLETION"
                done
            fi
        fi
    fi

    # Initialize zsh-autosuggestions if installed through Homebrew
    if [ -n "$ZSH_VERSION" ]; then
        if [ -f "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh" ]; then
            source "$(brew --prefix)/share/zsh-autosuggestions/zsh-autosuggestions.zsh"
        fi
        
        # Initialize syntax highlighting if installed through Homebrew
        if [ -f "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" ]; then
            source "$(brew --prefix)/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh"
        fi
    fi
fi 