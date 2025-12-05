# Starship Prompt

_Fast, minimal, infinitely customizable_

[Starship](https://starship.rs/) is a cross-shell prompt written in Rust. It's fast (typically <10ms), configurable, and
works in any shell. The dotfiles include a custom SilkCircuit theme with a beautiful gradient design.

## Visual Design

The SilkCircuit theme uses a progressive gradient from deep purple to hot pink:

```
┌──────────────────┬──────────────────┬──────────────────┬──────────────────┐
│  Segment 1       │  Segment 2       │  Segment 3       │  Segment 4       │
│  #4a1a4a         │  #7a2d7a         │  #a040a0         │  #d060d0         │
│  Deep magenta    │  Royal purple    │  Electric purple │  Hot pink        │
│  OS + User       │  Directory       │  Git             │  Languages       │
└──────────────────┴──────────────────┴──────────────────┴──────────────────┘
```

## What's Displayed

### Always Visible

- **OS Symbol** — (macOS), (Linux), (Windows)
- **Username** — Current user
- **Directory** — Current path with 3-level truncation
- **Git branch** — Current branch name
- **Git status** — Modified, staged, ahead/behind indicators

### Contextual (When Relevant)

**Language Versions** — Automatically detected when in a project directory:

| Language | Icon | Triggered By                         |
| -------- | ---- | ------------------------------------ |
| Node.js  |      | `package.json`, `.nvmrc`             |
| Python   |      | `requirements.txt`, `pyproject.toml` |
| Rust     | 󱘗    | `Cargo.toml`                         |
| Go       | 󰟓    | `go.mod`, `go.sum`                   |
| Java     | 󰬷    | `pom.xml`, `build.gradle`            |
| Kotlin   | 󱈙    | `*.kt` files                         |
| C/C++    | 󰙱    | `CMakeLists.txt`, `Makefile`         |
| Lua      | 󰢱    | `*.lua` files                        |

**Other Context:**

- **Docker** — When Docker context is active
- **Kubernetes** — When kubectl context is set
- **Command duration** — For commands taking >500ms
- **Battery** — On laptops (charge level + status)

### Optional (Disabled by Default)

- **Time** — Current time
- **Shell indicator** — Which shell you're using
- **Package version** — From `package.json`, `Cargo.toml`, etc.

## Configuration

Located at `/Users/bliss/dev/dotfiles/starship/starship.toml`

### Common Customizations

**Enable time display:**

```toml
[time]
disabled = false
format = '󱑍 [$time]($style) '
time_format = "%H:%M"
style = "bold fg:#FF6666"
```

**Show more directory segments:**

```toml
[directory]
truncation_length = 5  # Show 5 levels instead of 3
truncation_symbol = "…/"
truncate_to_repo = false  # Don't truncate at git root
```

**Custom git symbols:**

```toml
[git_branch]
symbol = "🌿 "  # Emoji
# or
symbol = " "  # Nerd Font icon
```

**Change colors:**

```toml
[directory]
style = "bold fg:#00ffff"  # Cyan directories

[git_branch]
style = "bold fg:#ff1493"  # Deep pink branches

[nodejs]
style = "bold fg:#68a063"  # Green Node version
```

**Add hostname (for SSH):**

```toml
[hostname]
ssh_only = true  # Only show when SSH'd
format = "[@$hostname]($style) "
style = "bold fg:#FF66FF"
disabled = false
```

**Disable modules:**

```toml
[docker_context]
disabled = true  # Hide Docker context

[kubernetes]
disabled = true  # Hide K8s context

[battery]
disabled = true  # Hide battery
```

### Reordering Segments

Modify the `format` string to reorder segments:

```toml
format = """
[](bg:#1a1a2e fg:#4a1a4a)\
$os\
$username\
$directory\
[](bg:#7a2d7a fg:#4a1a4a)\
$git_branch\
$git_status\
[](bg:#a040a0 fg:#7a2d7a)\
$time\
$cmd_duration\
[](bg:#1a1a2e fg:#a040a0)\
[➤](bold fg:#ff69b4) \
"""
```

## Performance

Starship is extremely fast thanks to being written in Rust:

```bash
# Benchmark your prompt
time starship prompt
# Typically: 5-15ms

# Profile slow modules
starship timings
```

### Optimization Tips

If your prompt feels slow:

1. **Disable unused modules:**

```toml
[python]
disabled = true
```

2. **Reduce directory depth:**

```toml
[directory]
truncation_length = 1
```

3. **Disable command duration:**

```toml
[cmd_duration]
disabled = true
```

4. **Use scan_timeout for slow detections:**

```toml
[nodejs]
detect_files = ["package.json"]
scan_timeout = 10  # milliseconds
```

## Shell Integration

Starship is automatically initialized in `zsh/zshrc` via Zinit:

```bash
# Zinit loads and initializes Starship
zinit ice atload"eval \"\$(starship init zsh)\""
zinit light starship/starship
```

This lazy-loads Starship for fast shell startup.

### Manual Initialization (If Needed)

```bash
# Zsh
eval "$(starship init zsh)"

# Bash
eval "$(starship init bash)"

# Fish
starship init fish | source
```

## Advanced Features

### Transient Prompt

Show a minimal prompt for previous commands:

```toml
[character]
success_symbol = "[➜](bold green)"
error_symbol = "[✗](bold red)"
```

### Custom Commands

Add custom modules that run commands:

```toml
[custom.git_worktree]
command = "git rev-parse --show-top-level 2>/dev/null | xargs basename"
when = "git rev-parse --is-inside-work-tree 2>/dev/null"
format = "[ $output]($style) "
style = "bold blue"
```

### Conditional Formatting

Show different output based on conditions:

```toml
[battery]
[[battery.display]]
threshold = 10
style = "bold red"

[[battery.display]]
threshold = 30
style = "bold yellow"
```

## Troubleshooting

### Prompt Not Showing

**Issue:** Plain prompt, no Starship theme

**Solution:**

```bash
# Check if Starship is installed
which starship

# Verify config exists
ls -la ~/.config/starship.toml

# Check for errors
starship explain

# Manually initialize
eval "$(starship init zsh)"
source ~/.zshrc
```

### Icons Not Rendering

**Issue:** Boxes or weird characters instead of icons

**Solution:**

Install a Nerd Font (see [Installation Guide](../getting-started/installation#font-requirements)):

```bash
# macOS
brew install --cask font-jetbrains-mono-nerd-font

# Configure your terminal to use the Nerd Font
```

### Colors Look Wrong

**Issue:** Colors are off or not matching the theme

**Solution:**

```bash
# Check terminal color support
echo $TERM
# Should output: xterm-256color or screen-256color

# Force 256 colors if needed
export TERM=xterm-256color
```

### Git Status Slow

**Issue:** Prompt lags in large git repositories

**Solution:**

```toml
[git_status]
disabled = false
ahead = "⇡${count}"
behind = "⇣${count}"
diverged = "⇕⇡${ahead_count}⇣${behind_count}"
untracked = "?${count}"
stashed = "$${count}"
modified = "!${count}"
staged = "+${count}"
renamed = "»${count}"
deleted = "✘${count}"
```

Or disable git status entirely for huge repos:

```toml
[git_status]
disabled = true
```

## Configuration Examples

### Minimal Prompt

```toml
format = """
$directory\
$git_branch\
$character
"""

[directory]
truncation_length = 2
```

### Two-Line Prompt

```toml
format = """
$username\
$hostname\
$directory\
$git_branch\
$git_status
$character """

[character]
success_symbol = "[❯](bold green)"
error_symbol = "[❯](bold red)"
```

### Time + Duration Focus

```toml
format = """
$time\
$directory\
$git_branch\
$cmd_duration
$character """

[time]
disabled = false
format = "[$time]($style) "

[cmd_duration]
min_time = 100  # Show all commands > 100ms
```

## Learning More

```bash
# View all available modules
starship modules

# Explain current prompt
starship explain

# Show configuration
starship config

# Official presets
starship preset -h
```

## External Resources

- [Official Documentation](https://starship.rs/)
- [Configuration Guide](https://starship.rs/config/)
- [Preset Gallery](https://starship.rs/presets/)
- [Advanced Config](https://starship.rs/advanced-config/)

## Next Steps

- [Tmux Configuration](./tmux) — Terminal multiplexer
- [FZF Integration](./fzf) — Fuzzy finding
- [Modern CLI Tools](./modern-cli) — Tool replacements
