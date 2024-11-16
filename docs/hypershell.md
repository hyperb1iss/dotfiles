# 🪟 Windows/HyperShell Environment Documentation

A comprehensive guide to the Windows-specific environment configurations, tools, and features available in HyperShell.

## 📋 Table of Contents

- [Core Components](#core-components)
- [PowerShell Configuration](#powershell-configuration)
- [WSL Integration](#wsl-integration)
- [Tool Suite](#tool-suite)
- [Keybindings and Shortcuts](#keybindings-and-shortcuts)
- [Git Integration](#git-integration)
- [Docker Integration](#docker-integration)

## 🌟 Core Components

### Essential Tools

```powershell
# These tools are automatically installed by setup-windows.ps1
powershell-core         # Modern PowerShell
microsoft-windows-terminal  # Enhanced terminal
git                    # Version control
vscode                 # Code editor
nodejs                 # JavaScript runtime
python                 # Python interpreter
rust                   # Rust toolchain
fzf                    # Fuzzy finder
ripgrep                # Enhanced grep
bat                    # Enhanced cat
lsd                    # Enhanced ls
starship              # Cross-shell prompt
neovim                # Text editor
```

### Environment Variables

```powershell
$env:FZF_DEFAULT_OPTS  # FZF configuration
$env:EDITOR           # Default editor (nvim)
$env:VISUAL          # Visual editor (nvim)
$PROFILE            # PowerShell profile location
```

## 🛠️ PowerShell Configuration

### PSReadLine Settings

| Setting       | Description         | Configuration                                                           |
| ------------- | ------------------- | ----------------------------------------------------------------------- |
| EditMode      | Emacs-style editing | `Set-PSReadLineOption -EditMode Emacs`                                  |
| HistorySearch | Search as you type  | `Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward` |
| MenuComplete  | Enhanced completion | `Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete`              |

### Syntax Highlighting

```powershell
Set-PSReadLineOption -Colors @{
    Command   = [ConsoleColor]::Cyan
    Parameter = [ConsoleColor]::DarkCyan
    Operator  = [ConsoleColor]::DarkGray
    Variable  = [ConsoleColor]::Green
    String    = [ConsoleColor]::Yellow
    Number    = [ConsoleColor]::Magenta
    Type      = [ConsoleColor]::DarkYellow
    Comment   = [ConsoleColor]::DarkGreen
}
```

## 🔄 WSL Integration

### Path Operations

| Command   | Description                           | Usage Example             |
| --------- | ------------------------------------- | ------------------------- |
| `wslpath` | Convert between Windows and WSL paths | `wslpath "C:\Users\name"` |
| `explore` | Open Windows Explorer                 | `explore .`               |
| `cdw`     | Change to Windows user directory      | `cdw Documents`           |
| `wslopen` | Open WSL path in Windows              | `wslopen ~/projects`      |

### WSL Commands

| Command | Description           | Usage Example            |
| ------- | --------------------- | ------------------------ |
| `wsl`   | Run WSL commands      | `wsl ls -la`             |
| `wsld`  | Enter WSL environment | `wsld`                   |
| `wgrep` | Use WSL grep          | `wgrep pattern`          |
| `wfind` | Use WSL find          | `wfind . -name "*.txt"`  |
| `wsed`  | Use WSL sed           | `wsed 's/old/new/' file` |
| `wawk`  | Use WSL awk           | `wawk '{print $1}' file` |

## 🔧 Tool Suite

### File Operations

| Command | Description                | Usage Example       |
| ------- | -------------------------- | ------------------- |
| `ls`    | Enhanced directory listing | `ls`                |
| `ll`    | Long format listing        | `ll`                |
| `la`    | Show hidden files          | `la`                |
| `lt`    | Tree view                  | `lt`                |
| `cat`   | Enhanced file viewing      | `cat file.txt`      |
| `grep`  | Enhanced text search       | `grep pattern file` |

### Navigation

| Command                   | Description                | Usage Example     |
| ------------------------- | -------------------------- | ----------------- |
| `Set-LocationWithHistory` | Enhanced cd with history   | `cd -`            |
| `mkcd`                    | Create and enter directory | `mkcd new-folder` |
| `up`                      | Go up directories          | `up 2`            |
| `fcd`                     | Fuzzy directory navigation | `fcd`             |

### Path Management

| Command             | Description        | Usage Example                |
| ------------------- | ------------------ | ---------------------------- |
| `Add-ToPath`        | Add to system PATH | `Add-ToPath "C:\tools"`      |
| `Remove-FromPath`   | Remove from PATH   | `Remove-FromPath "C:\tools"` |
| `Update-SystemPath` | Refresh PATH       | `Update-SystemPath`          |

## ⌨️ Keybindings and Shortcuts

### FZF Integration

| Binding  | Description      | Action                           |
| -------- | ---------------- | -------------------------------- |
| `Ctrl+f` | Find files       | Interactive file search          |
| `Ctrl+r` | Search history   | Interactive history search       |
| `Alt+c`  | Change directory | Interactive directory navigation |

### PowerShell Navigation

| Binding           | Description   | Action                        |
| ----------------- | ------------- | ----------------------------- |
| `Ctrl+Space`      | Menu complete | Show completion menu          |
| `Ctrl+RightArrow` | Forward word  | Move cursor forward one word  |
| `Ctrl+LeftArrow`  | Backward word | Move cursor backward one word |

## 🔄 Git Integration

### Basic Git Commands

| Command | Description | Usage Example    |
| ------- | ----------- | ---------------- |
| `gst`   | Git status  | `gst`            |
| `ga`    | Git add     | `ga file.txt`    |
| `gaa`   | Git add all | `gaa`            |
| `gcom`  | Git commit  | `gcom "message"` |
| `gp`    | Git push    | `gp`             |

### Interactive Git

| Command  | Description          | Usage Example |
| -------- | -------------------- | ------------- |
| `gadd`   | Interactive staging  | `gadd`        |
| `gco`    | Interactive checkout | `gco`         |
| `glog`   | Interactive log      | `glog`        |
| `gstash` | Interactive stash    | `gstash`      |

## 🐳 Docker Integration

### Basic Commands

| Command | Description     | Usage Example          |
| ------- | --------------- | ---------------------- |
| `dps`   | List containers | `dps`                  |
| `di`    | List images     | `di`                   |
| `dlog`  | Container logs  | `dlog container-name`  |
| `dstop` | Stop container  | `dstop container-name` |

## 🔄 Profile Management

### Profile Operations

| Command                  | Description          | Usage Example            |
| ------------------------ | -------------------- | ------------------------ |
| `reload`                 | Reload profile       | `reload`                 |
| `$PROFILE`               | Edit profile         | `nvim $PROFILE`          |
| `Show-HyperShellStartup` | Show welcome message | `Show-HyperShellStartup` |

### Customization

The PowerShell profile is located at:

```powershell
~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
```

To add custom configurations:

1. Create `user_profile.ps1` in the same directory
2. Add your customizations
3. They will be automatically loaded

## 🎨 Terminal Customization

### Windows Terminal Settings

- Location: `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_<hash>\LocalState\settings.json`
- Key settings:
  - Font: Pragmata Pro (or other Nerd Font)
  - Color scheme: Dracula
  - Cursor shape: Underscore
  - Background opacity: 95%

### Starship Prompt

- Configuration: `~/.config/starship.toml`
- Customizable segments:
  - Directory
  - Git status
  - Python version
  - Node.js version
  - Rust version
  - Command duration
  - Exit status

## 🔧 Maintenance

### Updates

```powershell
# Update all Chocolatey packages
choco upgrade all

# Update PowerShell modules
Update-Module

# Update Starship
cargo install starship --force

# Update HyperShell
cd ~/dev/dotfiles
git pull
./install.ps1
```

### Troubleshooting

1. Profile not loading:

   ```powershell
   Test-Path $PROFILE  # Check if profile exists
   . $PROFILE         # Manually load profile
   ```

2. Path issues:

   ```powershell
   Update-SystemPath  # Refresh PATH
   ```

3. WSL connectivity:
   ```powershell
   wsl --shutdown     # Restart WSL
   wsl --status      # Check WSL status
   ```
