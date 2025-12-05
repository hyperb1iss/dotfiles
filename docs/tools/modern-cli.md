# Modern CLI Tools

_Better than the originals_

Modern CLI tools reimagine classic Unix commands with better defaults, richer output, and features that should have been
there all along. All written in Rust for performance and safety.

## lsd (ls replacement)

[lsd](https://github.com/lsd-rs/lsd) — LSDeluxe with icons and colors

### Why lsd?

- File type icons (requires Nerd Font)
- Git status indicators
- Tree view built-in
- Color-coded by type
- Human-readable sizes by default

### Aliases

```bash
ls → lsd
ll → lsd -l
la → lsd -la
lt → lsd --tree
```

### Usage

```bash
# Basic listing
ll

# Show all files (including hidden)
la

# Tree view (2 levels deep)
lt --depth 2

# Sort by time
ll --timesort

# Sort by size
ll --sizesort

# Long format with all info
ll --total-size
```

### Configuration

Located at `/Users/bliss/dev/dotfiles/lsd/config.yaml`:

```yaml
# Display settings
classic: false
blocks:
  - permission
  - user
  - group
  - size
  - date
  - name
date: relative
icons:
  when: always
  theme: fancy
```

## bat (cat replacement)

[bat](https://github.com/sharkdp/bat) — Cat with syntax highlighting

### Why bat?

- Syntax highlighting for 100+ languages
- Git integration (shows changes in gutter)
- Line numbers
- Pager integration for long files
- Non-printable character display

### Usage

```bash
# View file with highlighting
bat file.ts

# Plain mode (no decorations)
bat -p file.ts

# Show all characters (including whitespace)
bat -A file.ts

# View specific line range
bat file.ts --line-range 10:50

# Compare with git
bat --diff file.ts
```

### Configuration

The SilkCircuit theme is in `/Users/bliss/dev/dotfiles/bat/themes/`:

```bash
# Set default theme
export BAT_THEME="SilkCircuit"

# Or use a different theme
bat --theme="Dracula" file.ts

# List available themes
bat --list-themes
```

### As a Pager

```bash
# Use bat as man pager
export MANPAGER="sh -c 'col -bx | bat -l man -p'"

# Use for git diff
# Already configured in gitconfig via delta
```

## fd (find replacement)

[fd](https://github.com/sharkdp/fd) — Fast, user-friendly find

### Why fd?

- 5x faster than find
- Ignores .gitignore by default
- Regex patterns by default
- Smart case sensitivity
- Colored output
- Simpler syntax

### Usage

```bash
# Find files matching pattern
fd pattern

# Find specific file types
fd -e ts              # TypeScript files
fd -e js -e jsx       # JavaScript/JSX files

# Search in specific directory
fd pattern ~/projects

# Include hidden files
fd -H pattern

# Search directories only
fd -t d pattern

# Execute command on results
fd -e jpg -x convert {} {.}.png
```

### Integration with FZF

Already configured in `sh/fzf.sh`:

```bash
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
```

## ripgrep (grep replacement)

[ripgrep](https://github.com/BurntSushi/ripgrep) — Blazingly fast search

### Why ripgrep?

- 10x faster than grep
- Respects .gitignore automatically
- Recursive by default
- Smart case sensitivity
- Colored output
- Supports .ignore files

### Usage

```bash
# Search current directory
rg pattern

# Search specific file types
rg -t ts pattern          # TypeScript
rg -t js pattern          # JavaScript
rg -t py pattern          # Python

# Case insensitive
rg -i pattern

# Show context (3 lines before/after)
rg -C 3 pattern

# Search for whole words only
rg -w pattern

# Search hidden files
rg --hidden pattern

# Count matches
rg -c pattern

# List files with matches (no content)
rg -l pattern

# Invert match (files without pattern)
rg -v pattern
```

### File Type Shortcuts

```bash
rg --type-list          # Show all supported types

# Common types:
rg -t rust pattern      # Rust files
rg -t cpp pattern       # C++ files
rg -t md pattern        # Markdown files
rg -t json pattern      # JSON files
```

### Advanced Usage

```bash
# Search with regex
rg "function\s+\w+\("

# Search multiple patterns
rg -e pattern1 -e pattern2

# Search with replacements (dry-run)
rg pattern --replace replacement

# Search compressed files
rg -z pattern archive.gz

# Multiline search
rg -U "class\s+\w+\s+{" --multiline
```

## zoxide (cd replacement)

[zoxide](https://github.com/ajeetdsouza/zoxide) — Smarter cd

### Why zoxide?

- Learns your habits (frecency algorithm)
- Fuzzy matching
- Works across shells
- Minimal overhead
- Cross-platform

### Aliases

```bash
z  → zoxide (jump to directory)
zi → zoxide interactive (fzf picker)
```

### Usage

```bash
# Jump to directory (frecency-based)
z project               # Jumps to ~/dev/projects
z doc                   # Jumps to ~/Documents

# Multiple query terms
z dev proj              # Matches ~/dev/projects

# Interactive selection
zi                      # Opens fzf to choose

# Add current directory to database
zoxide add .

# Remove directory from database
zoxide remove ~/old-project

# Query database
zoxide query project
zoxide query --list     # List all tracked dirs
```

### How It Works

Zoxide scores directories based on:

- **Frequency** — How often you visit
- **Recency** — When you last visited

Higher score = more likely to match.

## procs (ps replacement)

[procs](https://github.com/dalance/procs) — Modern process viewer

### Why procs?

- Human-readable output
- Color-coded columns
- Docker container support
- Tree view
- Multi-column search
- Pager integration

### Usage

```bash
# List all processes
procs

# Filter by name
procs node
procs python

# Show process tree
procs --tree

# Sort by memory
procs --sortd mem

# Sort by CPU
procs --sortd cpu

# Watch mode (like top)
procs --watch

# Show threads
procs --thread

# Docker container info
procs --docker
```

### Configuration

Located at `/Users/bliss/dev/dotfiles/procs/config.toml`:

```toml
[display]
separator = "│"
ascending = false
color_mode = "auto"

[sort]
column = "cpu"
order = "descending"
```

## delta (diff replacement)

[delta](https://github.com/dandavison/delta) — Beautiful git diffs

### Why delta?

- Syntax highlighting in diffs
- Word-level diff highlighting
- Line numbers
- Side-by-side mode
- Git integration
- Multiple themes

### Usage

Delta is automatically used for git diffs (configured in `gitconfig`):

```bash
# Normal git commands use delta automatically
git diff
git show
git log -p

# Manual delta usage
diff -u file1 file2 | delta

# Side-by-side view
git diff | delta --side-by-side
```

### Configuration

In `/Users/bliss/dev/dotfiles/gitconfig`:

```ini
[core]
    pager = delta

[interactive]
    diffFilter = delta --color-only

[delta]
    navigate = true
    light = false
    line-numbers = true
    syntax-theme = Dracula

[delta "interactive"]
    keep-plus-minus-markers = false

[delta "decorations"]
    commit-decoration-style = blue ol
    commit-style = raw
    file-style = omit
    hunk-header-decoration-style = blue box
    hunk-header-file-style = red
    hunk-header-line-number-style = "#067a00"
    hunk-header-style = file line-number syntax
```

### Customization

```bash
# Try different themes
git config delta.syntax-theme "Monokai Extended"

# Enable side-by-side
git config delta.side-by-side true

# Change line number colors
git config delta.line-numbers-left-style "#5c6370"
git config delta.line-numbers-right-style "#5c6370"
```

## zoxide (cd replacement - Continued)

### Integration with Shell

Automatically initialized in `zshrc`:

```bash
# Zoxide is loaded via zinit
eval "$(zoxide init zsh)"
```

### Tips

1. **Use it for a few days** — It learns your habits
2. **Be specific initially** — Full paths until zoxide learns
3. **Use `zi` when unsure** — Interactive mode shows options
4. **Clean old entries** — Remove unused directories periodically

## Installation Reference

### macOS (Homebrew)

```bash
brew install lsd bat fd ripgrep zoxide procs git-delta htop
```

### Linux (Cargo)

```bash
cargo install lsd bat fd-find ripgrep zoxide procs git-delta
```

### Verification

```bash
lsd --version
bat --version
fd --version
rg --version
zoxide --version
procs --version
delta --version
```

## Comparison Table

| Feature         | Classic | Modern    | Speed Improvement   |
| --------------- | ------- | --------- | ------------------- |
| File listing    | `ls`    | `lsd`     | ~2x                 |
| File viewing    | `cat`   | `bat`     | Similar (richer)    |
| File finding    | `find`  | `fd`      | ~5x                 |
| Code search     | `grep`  | `ripgrep` | ~10x                |
| Directory jump  | `cd`    | `zoxide`  | Instant             |
| Process viewing | `ps`    | `procs`   | Similar (better UX) |
| Diff viewing    | `diff`  | `delta`   | Similar (prettier)  |

## Tips & Best Practices

1. **Let tools respect .gitignore** — fd and rg do this by default
2. **Use --help liberally** — Modern tools have excellent help
3. **Combine tools** — `fd | rg`, `rg | bat`, etc.
4. **Create aliases** — Save common flag combinations
5. **Explore themes** — bat and delta support custom themes

## Troubleshooting

### Icons Not Showing (lsd)

**Issue:** Boxes instead of icons

**Solution:** Install a Nerd Font:

```bash
brew install --cask font-jetbrains-mono-nerd-font
# Configure terminal to use it
```

### Bat Theme Not Loading

**Issue:** Wrong colors or theme not found

**Solution:**

```bash
# Rebuild cache
bat cache --build

# List themes
bat --list-themes

# Set specific theme
export BAT_THEME="Dracula"
```

### Slow Performance (ripgrep)

**Issue:** rg is slow in huge directories

**Solution:**

```bash
# Limit search depth
rg --max-depth 3 pattern

# Exclude specific directories
rg --glob '!node_modules' pattern

# Use type filters
rg -t ts pattern  # Only TypeScript files
```

### Zoxide Not Learning

**Issue:** z doesn't jump to expected directory

**Solution:**

```bash
# Manually add directory
zoxide add ~/important/path

# Check database
zoxide query --list

# Remove incorrect entry
zoxide remove ~/old/path
```

## External Resources

- [lsd GitHub](https://github.com/lsd-rs/lsd)
- [bat GitHub](https://github.com/sharkdp/bat)
- [fd GitHub](https://github.com/sharkdp/fd)
- [ripgrep GitHub](https://github.com/BurntSushi/ripgrep)
- [ripgrep Guide](https://github.com/BurntSushi/ripgrep/blob/master/GUIDE.md)
- [zoxide GitHub](https://github.com/ajeetdsouza/zoxide)
- [procs GitHub](https://github.com/dalance/procs)
- [delta GitHub](https://github.com/dandavison/delta)

## Next Steps

- [FZF Integration](./fzf) — Fuzzy finding everything
- [Starship Prompt](./starship) — Prompt customization
- [Tmux Configuration](./tmux) — Terminal multiplexer
