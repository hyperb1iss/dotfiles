# All Functions

Every shell function organized by category - comprehensive reference with descriptions.

## Git

### Interactive Git Operations

| Function             | Description                                      |
| -------------------- | ------------------------------------------------ |
| `git_current_branch` | Get current branch name (helper for other funcs) |
| `gadd`               | Interactive git add with fzf and preview         |
| `gco`                | Interactive branch checkout with fzf             |
| `glog`               | Interactive log browser with fzf preview         |
| `gstash`             | Interactive stash manager (apply/pop/drop/show)  |
| `grebase`            | Interactive rebase helper with fzf selection     |
| `gstatus`            | Enhanced status output (grouped by type)         |

### Git Utilities

| Function | Description                             |
| -------- | --------------------------------------- |
| `gsetup` | Initialize repo with sensible defaults  |
| `gclean` | Clean merged branches and prune remotes |

### Git Worktree Manager

| Function | Description                                      |
| -------- | ------------------------------------------------ |
| `gwt`    | Full-featured git worktree manager with fzf      |
|          | **Commands:**                                    |
|          | `gwt list [--date]` - Show all worktrees         |
|          | `gwt switch` - Fuzzy-find and switch to worktree |
|          | `gwt new <branch>` - Create new worktree         |
|          | `gwt remove` - Remove worktree(s)                |
|          | `gwt clean` - Prune stale worktrees              |
|          | `gwt info` - Show current worktree details       |

### Git Iris Integration

| Function | Description                                   |
| -------- | --------------------------------------------- |
| `gpr`    | Generate PR description from commits          |
| `gprc`   | Generate PR description and copy to clipboard |

## Directory Navigation

### Basic Navigation

| Function | Description                      |
| -------- | -------------------------------- |
| `mkcd`   | Create directory and cd into it  |
| `take`   | Multi-arg version of mkcd        |
| `up`     | Go up N directories (default: 1) |

### Smart Navigation

| Function | Description                               |
| -------- | ----------------------------------------- |
| `fcd`    | Interactive directory navigation with fzf |
| `zp`     | Zoxide with pushd/popd semantics          |
|          | `zp <query>` - Jump and push to stack     |
|          | `zp -p/--pop` - Pop from stack            |
|          | `zp -l/--list` - List directory stack     |
|          | `zp -c/--clear` - Clear stack             |

### Bookmarks

| Function | Description                              |
| -------- | ---------------------------------------- |
| `mark`   | Create bookmark for current dir          |
| `unmark` | Remove bookmark by name                  |
| `marks`  | List all bookmarks                       |
| `jump`   | Jump to bookmark (interactive if no arg) |

### Directory Analysis

| Function | Description                                |
| -------- | ------------------------------------------ |
| `duh`    | Sorted directory sizes (human-readable)    |
| `dv`     | Interactive directory size viewer with fzf |
| `mktree` | Create directory and show tree view        |
| `ff`     | Find files by name pattern                 |

## Docker

### Interactive Docker Functions

| Function | Description                               |
| -------- | ----------------------------------------- |
| `dexec`  | Interactive container exec with fzf       |
| `dlf`    | Interactive container logs with follow    |
| `dstopi` | Interactive container stop (multi-select) |
| `drmi`   | Interactive remove stopped containers     |

### Docker Utilities

| Function | Description                                   |
| -------- | --------------------------------------------- |
| `dip`    | Get container IP address                      |
| `dcr`    | Docker Compose restart with fzf               |
| `dstats` | Container resource stats (formatted)          |
| `dclean` | Full Docker cleanup (system/volumes/networks) |

## Kubernetes

| Function  | Description                    |
| --------- | ------------------------------ |
| `kconfig` | Switch kubeconfig file         |
| `klogs`   | Quick pod logs with follow     |
| `khelp`   | Kubernetes commands cheatsheet |

## TypeScript & Monorepo

### Turbo Filter Shortcuts

| Function | Description                |
| -------- | -------------------------- |
| `tdf`    | `turbo dev --filter`       |
| `tbf`    | `turbo build --filter`     |
| `tcf`    | `turbo typecheck --filter` |
| `ttf`    | `turbo test --filter`      |

### TypeScript Runners

| Function | Description                       |
| -------- | --------------------------------- |
| `ts`     | Run TypeScript file with tsx      |
| `tsw`    | Run TypeScript file in watch mode |

### Monorepo Navigation

| Function  | Description                            |
| --------- | -------------------------------------- |
| `mono`    | Interactive monorepo package navigator |
| `monols`  | List all workspace packages with info  |
| `ts-info` | Display project info (Node/TS/tooling) |

## Node.js

### Version Management

| Function         | Description                         |
| ---------------- | ----------------------------------- |
| `node-lts`       | Install and use latest LTS Node     |
| `node-latest`    | Install and use latest stable Node  |
| `node-switch`    | Interactive version picker with fzf |
| `node-list`      | List installed Node versions        |
| `node-install`   | Install specific Node version       |
| `node-uninstall` | Uninstall Node version              |
| `node-info`      | Show current Node/npm/nvm versions  |

### nvmrc Support

| Function       | Description                        |
| -------------- | ---------------------------------- |
| `auto-nvm`     | Use .nvmrc in current directory    |
| `nvmrc-create` | Create .nvmrc with current version |

## Python

### Virtual Environments

| Function | Description                               |
| -------- | ----------------------------------------- |
| `venv`   | Create and activate virtual environment   |
| `va`     | Auto-find and activate venv (searches up) |
| `vd`     | Deactivate current virtual environment    |

### Django

| Function | Description                            |
| -------- | -------------------------------------- |
| `drs`    | Django runserver (default: port 8000)  |
| `dsh`    | Django shell (shell_plus if available) |
| `dmm`    | Django makemigrations                  |
| `dm`     | Django migrate                         |
| `dsu`    | Django createsuperuser                 |
| `dt`     | Django test                            |

### Testing & Formatting

| Function | Description                    |
| -------- | ------------------------------ |
| `pt`     | Run pytest with verbose output |
| `ptd`    | Run pytest with debug logging  |
| `format` | Format code with black + isort |

## Rust

| Function  | Description                             |
| --------- | --------------------------------------- |
| `cadd`    | Add dependency with cargo-edit          |
| `cwatch`  | Watch and rebuild with cargo-watch      |
| `rswitch` | Interactive toolchain switcher with fzf |
| `crtree`  | Interactive dependency tree viewer      |

## Java

| Function             | Description                       |
| -------------------- | --------------------------------- |
| `setjdk`             | Switch Java version               |
| `list_java_versions` | Show available Java installations |

## System Info

### Overview

| Function  | Description                       |
| --------- | --------------------------------- |
| `sys`     | Full system information dashboard |
| `sysinfo` | Basic system information          |
| `health`  | Quick health check (CPU/mem/disk) |

### Components

| Function   | Description                    |
| ---------- | ------------------------------ |
| `cpuinfo`  | CPU details and usage          |
| `meminfo`  | Memory usage and statistics    |
| `diskinfo` | Disk usage for all mounts      |
| `gpuinfo`  | GPU information (if available) |
| `battery`  | Battery status (laptops)       |
| `temps`    | System temperatures            |
| `services` | Service status                 |

## Network

| Function      | Description                           |
| ------------- | ------------------------------------- |
| `port`        | Show what's using a specific port     |
| `ports`       | List all listening ports              |
| `netcheck`    | Connectivity test (ping common hosts) |
| `netif`       | Show active network interfaces        |
| `connections` | Show active network connections       |
| `bandwidth`   | Monitor bandwidth usage               |
| `wifi`        | WiFi information (macOS)              |

## Process Management

| Function | Description                   |
| -------- | ----------------------------- |
| `pme`    | Show my processes             |
| `ptree`  | Process tree view             |
| `pwatch` | Live process monitoring       |
| `pfind`  | Find processes by name        |
| `pk`     | Kill processes by pattern     |
| `pmem`   | Top processes by memory usage |
| `pcpu`   | Top processes by CPU usage    |

## macOS Specific

### File Operations

| Function    | Description                      |
| ----------- | -------------------------------- |
| `finder`    | Open current directory in Finder |
| `clip`      | Copy to clipboard                |
| `ql`        | Quick Look preview               |
| `copy-path` | Copy file path to clipboard      |

### System Utilities

| Function           | Description                            |
| ------------------ | -------------------------------------- |
| `wifi-name`        | Show current WiFi SSID                 |
| `list-devices`     | List USB/Bluetooth/Thunderbolt devices |
| `extract-dmg`      | Mount and extract DMG contents         |
| `unquarantine`     | Remove quarantine attribute            |
| `toggle-dark-mode` | Switch between dark/light mode         |
| `set-volume`       | Set system volume                      |
| `brew-services`    | Interactive Homebrew service manager   |

### Screenshots

Multiple screenshot functions for various capture modes (see source for details).

## FZF Interactive Tools

| Function  | Description                        |
| --------- | ---------------------------------- |
| `fopen`   | Open file in editor with preview   |
| `fkill`   | Kill processes interactively       |
| `fh`      | Search command history             |
| `fenv`    | Search environment variables       |
| `frg`     | Ripgrep search with file opening   |
| `fdocker` | Docker container selector and exec |

## Shell Utilities

### Detection Functions

| Function      | Description                   |
| ------------- | ----------------------------- |
| `is_zsh`      | Check if running in Zsh       |
| `is_bash`     | Check if running in Bash      |
| `is_macos`    | Check if running on macOS     |
| `is_linux`    | Check if running on Linux     |
| `is_wsl`      | Check if running in WSL       |
| `has_command` | Check if command exists       |
| `is_minimal`  | Check if minimal install mode |
| `is_full`     | Check if full install mode    |

### Helper Functions

| Function      | Description                     |
| ------------- | ------------------------------- |
| `safe_source` | Source file with error handling |
| `extract`     | Extract various archive formats |
| `ftext`       | Search file contents            |
| `psg`         | Find process by name (grep ps)  |
