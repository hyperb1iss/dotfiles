# wsl.sh
# WSL (Windows Subsystem for Linux) specific utilities and configurations

# Only load these functions if running in WSL
if grep -qi microsoft /proc/version 2>/dev/null; then
    # Detect Windows username and set $W
    if [ -z "$W" ]; then
        WIN_USERNAME=$(powershell.exe -Command '[System.Environment]::UserName' | tr -d '\r')
        if [ -n "$WIN_USERNAME" ] && [ -d "/mnt/c/Users/$WIN_USERNAME" ]; then
            export W="/mnt/c/Users/$WIN_USERNAME"
        else
            echo "Warning: Could not determine Windows user directory. \$W is not set." >&2
        fi
    fi

    # Convert between Windows and WSL paths
    # Usage: wslpath "C:\Users\name" or wslpath "/home/user"
    function wslpath() {
        if [[ $1 == /* ]]; then
            # WSL to Windows path
            wslpath -w "$1"
        elif [[ $1 =~ ^[A-Za-z]: ]]; then
            # Windows to WSL path
            wslpath -u "$1"
        else
            echo "Error: Invalid path format. Please provide a full path." >&2
            return 1
        fi
    }

    # Open Windows Explorer in current directory
    # Usage: explore [path]
    function explore() {
        local path="${1:-.}"
        if [[ -d "$path" ]]; then
            explorer.exe "$(wslpath -w "$path")"
        else
            echo "Error: Directory does not exist: $path" >&2
            return 1
        fi
    }

    # Quick access to Windows User directory
    # Usage: cdw [subdirectory]
    function cdw() {
        local win_home="/mnt/c/Users/$USER"
        if [[ ! -d "$win_home" ]]; then
            # Try common Windows username if Linux username doesn't match
            win_home="/mnt/c/Users/$(whoami)"
        fi

        if [[ ! -d "$win_home" ]]; then
            echo "Error: Could not find Windows user directory" >&2
            return 1
        fi

        if [[ -n "$1" ]]; then
            cd "$win_home/$1" || return 1
        else
            cd "$win_home" || return 1
        fi
    }

    # Open file or URL in default Windows application
    # Usage: wopen file.pdf OR wopen https://example.com
    function wopen() {
        if [[ -z "$1" ]]; then
            echo "Usage: wopen <file|url>" >&2
            return 1
        fi

        if [[ "$1" =~ ^https?:// ]]; then
            # Handle URLs
            cmd.exe /c "start $1" 2>/dev/null
        else
            # Handle files
            local path="$1"
            if [[ -e "$path" ]]; then
                cmd.exe /c "start $(wslpath -w "$path")" 2>/dev/null
            else
                echo "Error: File does not exist: $path" >&2
                return 1
            fi
        fi
    }

    # Copy file path to Windows clipboard
    # Usage: clip-path [path]
    function clip-path() {
        local path="${1:-.}"
        if [[ -e "$path" ]]; then
            wslpath -w "$(realpath "$path")" | clip.exe
            echo "Path copied to clipboard"
        else
            echo "Error: Path does not exist: $path" >&2
            return 1
        fi
    }

    # Run Windows commands from WSL
    # Usage: win command [args]
    function win() {
        if [[ $# -eq 0 ]]; then
            echo "Usage: win <command> [arguments]" >&2
            return 1
        fi
        cmd.exe /c "$*" 2>/dev/null
    }

    # WSL-specific environment variables
    export BROWSER="wslview"
    export WSLENV=BROWSER

    # WSL-specific aliases
    alias cmd='cmd.exe /c'
    alias pwsh='powershell.exe'
    alias notepad='notepad.exe'
    alias clip='clip.exe'
    alias explorer='explorer.exe'
fi
