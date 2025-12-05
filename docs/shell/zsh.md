# Zsh Setup

_Modern shell with superpowers_

Zsh configuration using Zinit for fast, lazy-loaded plugins and a comprehensive completion system.

## Plugin Manager: Zinit

[Zinit](https://github.com/zdharma-continuum/zinit) handles all plugin management with async loading for fast shell
startup.

### Auto-Installation

Zinit auto-installs if missing:

```bash
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
# Automatically clones on first shell launch
# No manual setup needed
```

Just start a shell and it handles the rest.

### Loaded Plugins

| Plugin                    | Purpose                           |
| ------------------------- | --------------------------------- |
| `zsh-autosuggestions`     | History-based command suggestions |
| `zsh-syntax-highlighting` | Real-time syntax coloring         |
| `starship`                | Cross-shell prompt                |

Minimal plugin set. Quality over quantity.

### Script Loading

All `sh/*.sh` files load automatically via zinit snippets:

```bash
for script_file in "${HOME}/dev/dotfiles/sh/"*.sh; do
  zinit ice lucid wait"0"
  zinit snippet "${script_file}"
done
```

Async loading means fast shell startup even with 100+ aliases.

## Shell Options

### History

Persistent, shared history across sessions:

```bash
setopt share_history          # Share across all sessions
setopt hist_ignore_all_dups   # No duplicates
setopt inc_append_history     # Immediate append (real-time sharing)
setopt EXTENDED_HISTORY       # Timestamps in history

HISTSIZE=50000                # Huge history
SAVEHIST=50000
HISTFILE=~/.zsh_history
```

Your command history is a valuable asset. These settings protect it.

### Compatibility

Bash-like behavior where it matters:

```bash
setopt SH_WORD_SPLIT          # Bash-style word splitting
setopt EXTENDED_GLOB          # Advanced pattern matching
setopt INTERACTIVE_COMMENTS   # Allow # comments in interactive shell
```

### Navigation

```bash
setopt AUTO_CD                # Just type directory name to cd
setopt AUTO_PUSHD             # Automatic directory stack
setopt PUSHD_IGNORE_DUPS      # No duplicates in stack
```

Type `~/projects` and it `cd`s there automatically.

## Completion System

Located in `zsh/completion.zsh`. Comprehensive and fast.

### Features

- **Case-insensitive matching**: `cd doc` matches `Documents`
- **Partial matching**: `cd d/p` matches `dev/project`
- **Menu selection**: Tab through options with arrow keys
- **Color-coded**: Different colors for files, directories, executables
- **Context-aware**: Completion adapts to the command

### File Type Colors

```bash
di=01;34   # Directories (bold blue)
ln=01;36   # Symlinks (bold cyan)
ex=01;32   # Executables (bold green)
```

Makes `ls` output and completions instantly scannable.

### SSH Host Completion

Reads `~/.ssh/config` automatically:

```bash
ssh dev<Tab>
# Completes to: devserver, dev-staging, dev-prod
```

No more typing full hostnames.

### Process Completion

`kill` command shows running processes:

```bash
kill <Tab>
# Shows: PID, CPU%, TTY, Command
# Select the process to kill
```

Makes `kill` almost user-friendly.

## Terminal Title

Managed by `sh/terminal.sh`:

- Updates on each prompt
- Shows: `user@host:directory`
- Android build context in AOSP environments
- Works in tmux, screen, and standard terminals

Your terminal tabs/windows have meaningful titles.

## Initialization Flow

Startup sequence:

```
~/.zshrc
  │
  ├─ History & options configured
  │
  ├─ Zinit initialized (auto-install if missing)
  │
  ├─ Early critical sources:
  │  ├─ shell-common.sh  (platform detection, helpers)
  │  ├─ env.sh           (PATH setup)
  │  └─ terminal.sh      (title management)
  │
  ├─ Plugins loaded async:
  │  ├─ zsh-autosuggestions
  │  ├─ zsh-syntax-highlighting
  │  └─ starship prompt
  │
  ├─ All sh/*.sh loaded as lazy snippets
  │
  └─ Platform-specific handlers (macOS, Linux, WSL)
```

Carefully orchestrated for maximum speed.

## Customization

### Private Configuration

Create `~/.rc.local` for machine-specific settings:

```bash
# Machine-specific overrides
export MY_API_KEY="secret"
alias work='cd ~/work/current-project'

# Override defaults
export GWT_ROOT=~/custom/worktree/path
```

Never committed to dotfiles. Perfect for secrets and local preferences.

### Adding Plugins

Edit `zsh/zshrc`:

```bash
# Add after existing plugins
zinit light author/plugin-name
```

Keep it minimal. Every plugin adds startup time.

### Updating Plugins

```bash
zzz  # Alias for: zinit update
```

Updates all plugins and zinit itself.

## Troubleshooting

### Slow Startup

Profile startup time:

```bash
# Measure overall time
time zsh -i -c exit

# Detailed profiling
zsh -xv 2>&1 | head -100
```

Target: < 0.5s startup time.

### Missing Completions

Rebuild completion cache:

```bash
rm ~/.zcompdump
compinit
```

Fixes most completion issues.

### Plugin Issues

Reset zinit completely:

```bash
rm -rf ~/.local/share/zinit
# Restart shell — will reinstall everything
```

Nuclear option for broken plugin states.

### History Not Saving

Check file permissions:

```bash
ls -la ~/.zsh_history
# Should be writable by you

# Fix if needed
chmod 600 ~/.zsh_history
```

### Syntax Highlighting Not Working

Load order matters. Syntax highlighting must load last:

```bash
# In zshrc, make sure this is near the end
zinit light zsh-users/zsh-syntax-highlighting
```

## Pro Tips

**Trust autosuggestions**: Grey text from history? Press right arrow to accept. Massive time saver.

**Learn completion**: Tab completion is powerful. `git <Tab><Tab>` shows all git commands. `cd /u/l/b<Tab>` expands to
`/usr/local/bin`.

**Use directory stack**: `cd -<Tab>` shows recent directories. `cd -2` jumps to the second most recent.

**History search**: `Ctrl-R` for reverse search. Type a few letters, get matching commands from history.

**Comment your experimentation**: `setopt INTERACTIVE_COMMENTS` lets you comment out commands at the prompt. `# ls -la`
won't execute.

**Keep it fast**: Resist the urge to add too many plugins. Fast shell startup > fancy features.

**Use `~/.rc.local`**: Machine-specific settings go here. Keep your main dotfiles clean and portable.

**Profile before adding plugins**: Measure startup time before and after. If a plugin adds >100ms, consider if it's
worth it.
