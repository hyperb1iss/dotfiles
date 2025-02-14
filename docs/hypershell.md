# 🪟 Windows/HyperShell Environment Documentation

This guide covers the core configuration and tools that make HyperShell on Windows a productive environment. You’ll find details on essential components, PowerShell tuning, WSL usage, handy shortcuts, Git and Docker commands, directory navigation tricks, and more. By the time you reach the end, you’ll have a Windows setup tailored for smooth development and system administration tasks.

## 📋 Table of Contents

- [Core Components](#core-components)
- [PowerShell Configuration](#⚙️-powershell-configuration)
- [WSL Integration](#🌐-wsl-integration)
- [Tool Suite](#🛠️-tool-suite)
- [Keybindings and Shortcuts](#⌨️-keybindings-and-shortcuts)
- [Git Integration](#🔄-git-integration)
- [Docker Integration](#🐳-docker-integration)
- [Frequent Directory Navigation (z)](#🧭-frequent-directory-navigation-z)
- [Android Tools](#🤖-android-tools)
- [Java Management](#☕-java-management)
- [Network Commands](#🌐-network-commands)
- [Profile Management](#👤-profile-management)
- [Terminal Customization](#🎨-terminal-customization)
- [Maintenance](#🔧-maintenance)

## 🌟 Core Components

These are the fundamental building blocks for your Windows + HyperShell setup, automatically installed via **setup-windows.ps1**.

### Essential Tools

```powershell
powershell-core            # Modern PowerShell
microsoft-windows-terminal # Modern terminal
git                        # Version control
vscode                     # Code editor
nodejs                     # JavaScript runtime
python                     # Python interpreter
rust                       # Rust toolchain
fzf                        # Fuzzy finder
ripgrep                    # A modern grep alternative
bat                        # A cat clone with syntax highlighting
lsd                        # A modern ls alternative
starship                   # Cross-shell prompt
neovim                     # Text editor
```

### Environment Variables

```powershell
$env:FZF_DEFAULT_OPTS  # FZF configuration
$env:EDITOR            # Default editor (nvim)
$env:VISUAL            # Visual editor (nvim)
$PROFILE               # PowerShell profile location
```

## ⚙️ PowerShell Configuration

Fine-tune PowerShell’s behavior with PSReadLine options, custom syntax highlighting, and other settings.

### PSReadLine Settings

| Setting       | Description           | Configuration                                                           |
| ------------- | --------------------- | ----------------------------------------------------------------------- |
| EditMode      | Emacs-style editing   | `Set-PSReadLineOption -EditMode Emacs`                                  |
| HistorySearch | Search as you type    | `Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward` |
| MenuComplete  | Menu-based completion | `Set-PSReadLineKeyHandler -Key Tab -Function MenuComplete`              |

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

## 🌐 WSL Integration

HyperShell provides commands to bridge Windows and WSL, making path conversions and cross-environment tooling straightforward.

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

## 🛠️ Tool Suite

A collection of commands to streamline file management, navigation, and system paths.

### File Operations

| Command | Description              | Usage Example       |
| ------- | ------------------------ | ------------------- |
| `ls`    | Modern directory listing | `ls`                |
| `ll`    | Long format listing      | `ll`                |
| `la`    | Show hidden files        | `la`                |
| `lt`    | Tree view                | `lt`                |
| `cat`   | Modern file viewer       | `cat file.txt`      |
| `grep`  | Modern text search       | `grep pattern file` |

### Navigation

| Command                   | Description                              | Usage Example     |
| ------------------------- | ---------------------------------------- | ----------------- |
| `Set-LocationWithHistory` | Change directories with history tracking | `cd -`            |
| `mkcd`                    | Create and enter directory               | `mkcd new-folder` |
| `up`                      | Go up directories                        | `up 2`            |
| `fcd`                     | Fuzzy directory navigation               | `fcd`             |

### Path Management

| Command             | Description        | Usage Example                |
| ------------------- | ------------------ | ---------------------------- |
| `Add-ToPath`        | Add to system PATH | `Add-ToPath "C:\tools"`      |
| `Remove-FromPath`   | Remove from PATH   | `Remove-FromPath "C:\tools"` |
| `Update-SystemPath` | Refresh PATH       | `Update-SystemPath`          |

## ⌨️ Keybindings and Shortcuts

HyperShell maps many commands to keyboard shortcuts that save time and keep your fingers on the home row.

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

Simplify Git commands with these aliases and interactive helpers.

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

Manage containers and images with short aliases.

### Basic Commands

| Command | Description      | Usage Example          |
| ------- | ---------------- | ---------------------- |
| `dps`   | List containers  | `dps`                  |
| `di`    | List images      | `di`                   |
| `dlog`  | Container logs   | `dlog container-name`  |
| `dstop` | Stop a container | `dstop container-name` |

## 🧭 Frequent Directory Navigation (z)

HyperShell includes a port of the **z** directory jumper (`z.ps1`). It tracks how often and how recently you visit directories, then helps you jump to them quickly:

- **`z [options] <query>`**: Jump to the directory matching `<query>` (using a frecency algorithm).
- **`-l, --list`**: List matching directories.
- **`-r, --rank`**: Use rank (frequency) only.
- **`-t, --recent`**: Use recent (time-based) only.
- **`-c, --current`**: Restrict matches to subdirectories of the current directory.
- **`-e, --echo`**: Echo the best match without switching directories.
- **`-x, --remove`**: Remove a directory from tracking.
- **`--add`**: Manually add a directory to the database.

## 🤖 Android Tools

For anyone working with multiple Android devices, **android.ps1** provides `Set-AndroidDevice` (aliased as `adbdev`):

- **`adbdev --list`**: Lists all configured device aliases.
- **`adbdev --add <alias> <serial>`**: Creates or updates an alias for a device by serial number.
- **`adbdev --remove <alias>`**: Removes a device alias.
- **`adbdev <alias>`**: Sets `$env:ANDROID_SERIAL` to the chosen alias.

## ☕ Java Management

Use **java.ps1** to handle multiple JDK installations. Switch versions and automatically update environment variables:

- **`setjdk <version>`**: Switches the default Java version (e.g., `setjdk 11`).
- **`javalist`**: Shows all available Java installations and highlights the active one.
- **`java<version>`**: A quick alias to set a particular version (e.g., `java17`).

When you switch, `$JAVA_HOME` and your `PATH` are updated so that the correct tools are always in use.

## 🌐 Network Commands

The **network.ps1** module gives you convenient shortcuts for common network diagnostics:

- **`testport <host> <port>`**: Checks whether a port is open on a given host.
- **`flushdns`**: Clears the DNS resolver cache.
- **`pubip`**: Shows your public IP address.
- **`port <port>`**: Identifies which process is bound to a given port.
- **`nics`**: Lists interface details (status, speed, MAC, etc.).
- **`netcons`**: Displays active TCP connections and the processes that own them.

## 👤 Profile Management

Keep your customizations separate and easily reloaded.

### Profile Operations

| Command                  | Description          | Usage Example            |
| ------------------------ | -------------------- | ------------------------ |
| `reload`                 | Reloads your profile | `reload`                 |
| `$PROFILE`               | Edit main profile    | `nvim $PROFILE`          |
| `Show-HyperShellStartup` | Show welcome message | `Show-HyperShellStartup` |

### Customization

- The main PowerShell profile is stored at:
  ```powershell
  ~/Documents/PowerShell/Microsoft.PowerShell_profile.ps1
  ```
- To add your own configuration:
  1. Create `user_profile.ps1` in the same folder.
  2. Place your customizations in `user_profile.ps1`.
  3. They’ll be automatically loaded whenever you start PowerShell.

## 🎨 Terminal Customization

Make your terminal your own by tweaking settings and applying custom themes.

### Windows Terminal Settings

- **Location:**  
  `%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_<hash>\LocalState\settings.json`
- **Key settings:**
  - Font: Pragmata Pro (or another Nerd Font)
  - Color scheme: Dracula
  - Cursor shape: Underscore
  - Background opacity: 95%

### Starship Prompt

- **Configuration file:** `~/.config/starship.toml`
- **Customizable segments:**
  - Directory
  - Git status
  - Python/Node.js/Rust version
  - Command duration
  - Exit status

## 🔧 Maintenance

Regular updates keep your environment stable.

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

1. **Profile not loading**:

   ```powershell
   Test-Path $PROFILE  # Check if profile exists
   . $PROFILE          # Manually load profile
   ```

2. **Path issues**:

   ```powershell
   Update-SystemPath   # Refresh PATH
   ```

3. **WSL connectivity**:
   ```powershell
   wsl --shutdown      # Restart WSL
   wsl --status        # Check WSL status
   ```
