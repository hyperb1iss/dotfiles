# CLI Tools

_Modern replacements for classic commands_

The dotfiles embrace a new generation of CLI tools that improve on Unix classics with better defaults, richer output,
and modern features.

## The Modern CLI Stack

| Classic | Modern      | Why Upgrade                                      |
| ------- | ----------- | ------------------------------------------------ |
| `ls`    | **lsd**     | Icons, colors, tree view, git integration        |
| `cat`   | **bat**     | Syntax highlighting, line numbers, git diff      |
| `find`  | **fd**      | 5x faster, respects .gitignore, regex by default |
| `grep`  | **ripgrep** | 10x faster, smart defaults, beautiful output     |
| `cd`    | **zoxide**  | Learns your habits, fuzzy matching               |
| `ps`    | **procs**   | Human-readable, colorful, tree view              |
| `diff`  | **delta**   | Syntax highlighting, side-by-side, git aware     |
| `top`   | **htop**    | Interactive, better UI, easier to read           |

All tools are pre-configured with the SilkCircuit theme and sensible defaults.

## Tool Highlights

### [Starship Prompt](./starship)

Fast, minimal, cross-shell prompt with:

- Git status and branch
- Language versions (Node, Python, Rust, Go, Java, Kotlin)
- Command duration
- Custom SilkCircuit gradient theme
- Context-aware modules

### [Tmux](./tmux)

Terminal multiplexer configured with:

- SilkCircuit-themed status bar
- Mouse support enabled
- Intuitive split bindings (`|` and `-`)
- Plugin manager (TPM) pre-configured
- Seamless pane navigation

### [FZF](./fzf)

Fuzzy finder integrated throughout the system:

- File and directory navigation
- Command history search
- Git operations (add, checkout, log, stash)
- Process management
- Docker container selection
- Environment variable search

### [Modern CLI Tools](./modern-cli)

Detailed guides for each tool:

- **lsd** — File listing with icons
- **bat** — File viewing with syntax highlighting
- **fd** — Fast file finding
- **ripgrep** — Blazing fast code search
- **zoxide** — Smart directory jumping
- **procs** — Modern process viewer
- **delta** — Beautiful git diffs

## Quick Examples

### File Operations

```bash
# List with icons and colors
ll

# Tree view
lt

# View file with syntax highlighting
bat config.ts

# Find files fast (respects .gitignore)
fd pattern

# Search code (10x faster than grep)
rg "TODO" --type ts
```

### Navigation

```bash
# Jump to frequently used directory
z project

# Interactive directory selection
zi

# Fuzzy-find and cd
fcd
```

### Git Operations

```bash
# Beautiful git diffs (automatic)
git diff

# Interactive file staging
gadd

# Fuzzy branch checkout
gco

# Interactive log browser
glog
```

### System Information

```bash
# Modern process viewer
procs

# Interactive process killer
fkill

# System overview
sys

# Memory info with visual bar
meminfo
```

## Installation

All modern CLI tools are automatically installed during dotfiles setup:

**macOS:**

```bash
# Installed via Homebrew in macos/brew.sh
brew install lsd bat fd ripgrep zoxide procs git-delta htop
```

**Linux:**

```bash
# Ubuntu/Debian
apt-get install lsd bat fd-find ripgrep

# Install via cargo for latest versions
cargo install lsd bat fd-find ripgrep zoxide procs git-delta
```

**Post-Install:**

```bash
# Verify installation
lsd --version
bat --version
fd --version
rg --version
delta --version
zoxide --version
```

## Configuration

Each tool is configured in the dotfiles:

| Tool         | Config Location                     | Purpose                |
| ------------ | ----------------------------------- | ---------------------- |
| **lsd**      | `lsd/config.yaml`                   | Display settings       |
| **bat**      | `bat/config`, `bat/themes/`         | Theme, syntax settings |
| **Starship** | `starship/starship.toml`            | Prompt customization   |
| **Tmux**     | `tmux.conf`                         | Key bindings, theme    |
| **Delta**    | `gitconfig` (delta section)         | Git diff styling       |
| **procs**    | `procs/config.toml`                 | Process display        |
| **FZF**      | `sh/fzf.sh`, `sh/env.sh` (ENV vars) | Defaults, key bindings |
| **zoxide**   | Automatic (tracks your usage)       | Database stored in XDG |

## Font Requirements

Many modern CLI tools use Nerd Font icons for the best experience:

**Recommended Fonts:**

- JetBrains Mono Nerd Font
- Fira Code Nerd Font
- Hack Nerd Font
- Meslo LG Nerd Font

**Install on macOS:**

```bash
brew install --cask font-jetbrains-mono-nerd-font
brew install --cask font-fira-code-nerd-font
```

**Configure your terminal:**

- iTerm2: Preferences → Profiles → Text → Font
- Kitty: Edit `~/.config/kitty/kitty.conf`
- Alacritty: Edit `~/.config/alacritty/alacritty.yml`

## Customization Examples

### Change lsd Colors

```yaml
# lsd/config.yaml
color:
  when: always
  theme: custom

icons:
  when: always
  theme: fancy
```

### Customize bat Theme

```bash
# Use a different syntax theme
bat --theme="TwoDark" file.ts

# Set permanently
export BAT_THEME="TwoDark"
```

### Modify FZF Appearance

```bash
# In ~/.rc.local
export FZF_DEFAULT_OPTS="
  --height 80%
  --layout=reverse-list
  --border rounded
  --preview-window right:60%
"
```

### Delta Side-by-Side Diffs

```ini
# In gitconfig
[delta]
    side-by-side = true
    line-numbers-left-format = ""
    line-numbers-right-format = "│ "
```

## Performance

Modern tools are significantly faster than their classic counterparts:

| Tool    | Performance          | Comparison        |
| ------- | -------------------- | ----------------- |
| ripgrep | 10x faster than grep | Recursive search  |
| fd      | 5x faster than find  | File finding      |
| lsd     | ~2x faster than ls   | Directory listing |
| bat     | Similar to cat       | With features     |
| zoxide  | Instant              | Directory jump    |

All tools are written in Rust, providing memory safety and blazing performance.

## Integration Points

Modern CLI tools are integrated throughout the dotfiles:

**Shell Scripts:**

- `sh/fzf.sh` — FZF functions
- `sh/git.sh` — Delta for diffs, FZF for git operations
- `sh/docker.sh` — FZF for container selection
- `sh/directory.sh` — zoxide integration
- `sh/process.sh` — procs integration

**Neovim:**

- Telescope uses fd and ripgrep
- File explorer shows lsd-style icons
- Git diff uses delta preview

**Tmux:**

- Status bar styled with SilkCircuit theme
- Integrates with system clipboard

## Troubleshooting

### Icons Not Showing

**Issue:** Boxes or question marks instead of icons

**Solution:**

1. Install a Nerd Font (see Font Requirements above)
2. Configure your terminal to use the Nerd Font
3. Restart your terminal

### Colors Look Wrong

**Issue:** Colors are off or missing

**Solution:**

```bash
# Check terminal color support
echo $TERM

# Should be: xterm-256color or screen-256color
# If not, add to ~/.zshrc:
export TERM=xterm-256color
```

### FZF Not Working

**Issue:** FZF commands hang or don't show preview

**Solution:**

```bash
# Check if fzf is installed
which fzf

# Verify preview command works
bat --version

# Test manually
echo "test" | fzf --preview 'echo {}'
```

### Bat Can't Find Theme

**Issue:** `bat: Unknown theme` error

**Solution:**

```bash
# Rebuild bat cache
bat cache --build

# List available themes
bat --list-themes
```

## Next Steps

- [Starship Configuration](./starship) — Customize your prompt
- [Tmux Guide](./tmux) — Terminal multiplexer setup
- [FZF Integration](./fzf) — Fuzzy finding everywhere
- [Modern CLI Deep Dive](./modern-cli) — Tool-by-tool guide
