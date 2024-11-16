# 🚀 Shell Environment Command Documentation

A comprehensive guide to every command and feature available in the shell environment.

## 📋 Table of Contents

- [Core Environment](#core-environment)
- [Directory Operations](#directory-operations)
- [Git Command Suite](#git-command-suite)
- [Search and Navigation](#search-and-navigation)
- [Android Development Tools](#android-development-tools)
- [WSL Integration Suite](#wsl-integration-suite)
- [Development Tools](#development-tools)
- [File Management](#file-management)

## 🌟 Core Environment

### Environment Variables

```bash
VISUAL=nvim                  # Default visual editor
EDITOR=nvim                  # Default editor
PAGER="batcat -p"           # Enhanced pager
HOSTNAME=$(hostname)         # Current hostname
USE_CCACHE=1                # Enable compiler cache
CCACHE_DIR=/b/.ccache       # Cache directory
GOPATH=~/dev/go            # Go workspace
```

### History Configuration

```bash
HISTSIZE=50000            # History size in memory
HISTFILESIZE=50000        # History size on disk
HISTCONTROL=ignoreboth:erasedups  # Ignore duplicates
HISTTIMEFORMAT="%F %T "   # Add timestamps
HISTIGNORE="ls:ll:cd:pwd:clear:history"  # Ignored commands
```

## 📂 Directory Operations

### Navigation Commands

| Command  | Description                         | Usage Example           |
| -------- | ----------------------------------- | ----------------------- |
| `mkcd`   | Create and enter directory          | `mkcd new-project`      |
| `take`   | Create and enter nested directories | `take projects/new/sub` |
| `up [n]` | Go up n directories                 | `up 3`                  |
| `fcd`    | Fuzzy directory navigation          | `fcd`                   |

### Directory Information

| Command | Description                     | Usage Example |
| ------- | ------------------------------- | ------------- |
| `duh`   | Human-readable directory sizes  | `duh /home`   |
| `dv`    | Interactive size visualization  | `dv`          |
| `lt`    | Tree view of directory          | `lt`          |
| `ll`    | Detailed list view              | `ll`          |
| `la`    | Show all files including hidden | `la`          |

### Directory Bookmarks

| Command  | Description                | Usage Example |
| -------- | -------------------------- | ------------- |
| `mark`   | Bookmark current directory | `mark dev`    |
| `unmark` | Remove bookmark            | `unmark dev`  |
| `marks`  | List all bookmarks         | `marks`       |
| `jump`   | Jump to bookmark           | `jump dev`    |

## 🔄 Git Command Suite

### Basic Git Operations

| Command    | Description           | Usage Example              |
| ---------- | --------------------- | -------------------------- |
| `ga`       | Git add               | `ga file.txt`              |
| `gaa`      | Git add all           | `gaa`                      |
| `gst`      | Git status            | `gst`                      |
| `gc`       | Git cherry-pick       | `gc abc123`                |
| `gcom`     | Git commit            | `gcom "feat: add feature"` |
| `gcom!`    | Amend commit          | `gcom!`                    |
| `gcomn!`   | Amend commit no edit  | `gcomn!`                   |
| `gcoma`    | Commit all tracked    | `gcoma`                    |
| `gcoma!`   | Amend commit all      | `gcoma!`                   |
| `gcomm`    | Commit with message   | `gcomm "fix: bug"`         |
| `gcoman!`  | Amend no edit all     | `gcoman!`                  |
| `gcomans!` | Amend no edit signed  | `gcomans!`                 |
| `gp`       | Git push              | `gp`                       |
| `gpf`      | Force push with lease | `gpf`                      |
| `gpsup`    | Push set upstream     | `gpsup`                    |
| `gl`       | Git pull              | `gl`                       |
| `gf`       | Git fetch             | `gf`                       |
| `gfa`      | Fetch all remotes     | `gfa`                      |
| `gfo`      | Fetch origin          | `gfo`                      |
| `gsw`      | Switch branch         | `gsw main`                 |
| `gswc`     | Switch to new branch  | `gswc feature`             |

### Interactive Git Operations

| Command   | Description                  | Usage Example |
| --------- | ---------------------------- | ------------- |
| `gadd`    | Interactive staging          | `gadd`        |
| `gco`     | Interactive checkout         | `gco`         |
| `glog`    | Interactive log viewer       | `glog`        |
| `gstash`  | Interactive stash management | `gstash`      |
| `grebase` | Interactive rebase           | `grebase`     |

### Git Diff & Branch Operations

| Command | Description         | Usage Example |
| ------- | ------------------- | ------------- |
| `gd`    | Git diff            | `gd`          |
| `gdca`  | Diff cached changes | `gdca`        |
| `gb`    | List branches       | `gb`          |
| `gba`   | List all branches   | `gba`         |

## 📱 Android Development Tools

### Build Commands

| Command        | Description             | Usage Example             |
| -------------- | ----------------------- | ------------------------- |
| `mka`          | Enhanced make           | `mka bacon`               |
| `reposync`     | Smart repo sync         | `reposync`                |
| `envsetup`     | Setup build environment | `envsetup`                |
| `lunch_device` | Select build target     | `lunch_device aosp_pixel` |
| `ld`           | Alias for lunch_device  | `ld aosp_pixel`           |

### Device Interaction

| Command       | Description           | Usage Example      |
| ------------- | --------------------- | ------------------ |
| `get_device`  | Smart device selector | `get_device`       |
| `logcat`      | Enhanced logging      | `logcat SystemUI`  |
| `installboot` | Install boot image    | `installboot`      |
| `apush`       | Push to device        | `apush system.img` |
| `apull`       | Pull from device      | `apull /data/log`  |

### Repository Management

| Command      | Description       | Usage Example |
| ------------ | ----------------- | ------------- |
| `aospremote` | Add AOSP remote   | `aospremote`  |
| `cafremote`  | Add CAF remote    | `cafremote`   |
| `rstat`      | Repository status | `rstat`       |

### Navigation Shortcuts

| Command       | Description         | Usage Example |
| ------------- | ------------------- | ------------- |
| `croot`       | Go to Android root  | `croot`       |
| `gokernel`    | Go to kernel        | `gokernel`    |
| `govendor`    | Go to vendor        | `govendor`    |
| `goapps`      | Go to apps          | `goapps`      |
| `goframework` | Go to framework     | `goframework` |
| `gosystem`    | Go to system        | `gosystem`    |
| `gohw`        | Go to hardware      | `gohw`        |
| `goout`       | Go to out directory | `goout`       |
| `godefault`   | Go to default       | `godefault`   |

## 🪟 WSL Integration Suite

### Path Operations

| Command     | Description              | Usage Example        |
| ----------- | ------------------------ | -------------------- |
| `wslpath`   | Convert paths            | `wslpath "C:\Users"` |
| `clip-path` | Copy path to clipboard   | `clip-path file.txt` |
| `explore`   | Open in Explorer         | `explore .`          |
| `cdw`       | Navigate to Windows home | `cdw Documents`      |

### Windows Integration

| Command | Description         | Usage Example      |
| ------- | ------------------- | ------------------ |
| `wopen` | Open with Windows   | `wopen file.pdf`   |
| `win`   | Run Windows command | `win ipconfig`     |
| `cmd`   | Run CMD command     | `cmd dir`          |
| `pwsh`  | Run PowerShell      | `pwsh Get-Process` |
| `wsld`  | Enter WSL           | `wsld`             |

### WSL-Specific Commands

| Command | Description | Usage Example            |
| ------- | ----------- | ------------------------ |
| `wgrep` | WSL grep    | `wgrep pattern`          |
| `wfind` | WSL find    | `wfind . -name "*.txt"`  |
| `wsed`  | WSL sed     | `wsed 's/old/new/' file` |
| `wawk`  | WSL awk     | `wawk '{print $1}' file` |

## 🛠️ Development Tools

### Java Version Management

| Command    | Description         | Usage Example |
| ---------- | ------------------- | ------------- |
| `setjdk`   | Switch Java version | `setjdk 11`   |
| `java8`    | Switch to Java 8    | `java8`       |
| `java11`   | Switch to Java 11   | `java11`      |
| `java17`   | Switch to Java 17   | `java17`      |
| `java21`   | Switch to Java 21   | `java21`      |
| `javalist` | List installations  | `javalist`    |

### Search Tools

| Command | Description          | Usage Example     |
| ------- | -------------------- | ----------------- |
| `ftext` | Search file contents | `ftext "pattern"` |
| `ff`    | Find files           | `ff "*.txt"`      |
| `fh`    | Search history       | `fh`              |
| `psg`   | Process search       | `psg firefox`     |

## 📦 File Management

### Archive Operations

| Command   | Description              | Usage Example            |
| --------- | ------------------------ | ------------------------ |
| `extract` | Smart archive extraction | `extract archive.tar.gz` |

### File Operations

| Command | Description       | Usage Example          |
| ------- | ----------------- | ---------------------- |
| `bat`   | Enhanced cat      | `bat file.txt`         |
| `touch` | Create empty file | `touch file.txt`       |
| `mkdir` | Create directory  | `mkdir -p path/to/dir` |
| `cp`    | Copy files        | `cp file1 file2`       |
| `mv`    | Move files        | `mv file1 dir/`        |

### FZF Keybindings

| Binding  | Description      |
| -------- | ---------------- |
| `Ctrl+R` | Search history   |
| `Ctrl+T` | Search files     |
| `Alt+C`  | Change directory |
