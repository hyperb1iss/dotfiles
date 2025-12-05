# FZF Integration

_Fuzzy finding everything, everywhere_

[FZF](https://github.com/junegunn/fzf) is a general-purpose fuzzy finder that's deeply integrated throughout the
dotfiles. It transforms clunky selection processes into smooth, interactive experiences.

## Core Fuzzy Functions

### File & Directory Operations

**`fcd` — Interactive Directory Navigation**

```bash
fcd
# Fuzzy-find directories with tree preview
# Navigate with arrow keys
# Press Enter to cd into selection
```

**`fopen` — Interactive File Opening**

```bash
fopen
# Fuzzy-find files with bat syntax preview
# Opens selection in $EDITOR (nvim by default)
```

### Git Operations

**`gadd` — Interactive Git Add**

```bash
gadd
# Multi-select modified files (Tab to select)
# Preview shows actual diff
# Adds selected files to staging area
```

**`gco` — Interactive Branch Checkout**

```bash
gco
# Shows all branches (local + remote)
# Preview displays commit log
# Checkout selected branch
```

**`glog` — Interactive Git Log Browser**

```bash
glog
# Beautiful graph visualization
# Press Enter on any commit to view full details
# Use ` to toggle sort order
```

**`gstash` — Interactive Stash Manager**

```bash
gstash
# Select from stashed changes
# Preview shows stash diff
# Choose action: [a]pply, [p]op, [d]rop, [s]how, [b]ranch
```

### System Operations

**`fkill` — Interactive Process Killer**

```bash
fkill
# Multi-select processes (Tab to select multiple)
# Shows full ps output
# Kills selected processes (SIGTERM by default)

# Force kill
fkill 9  # Sends SIGKILL instead
```

**`fh` — Fuzzy History Search**

```bash
fh
# Search through command history
# Press Enter to execute command
# Integrates with zsh history
```

**`fenv` — Environment Variable Search**

```bash
fenv
# Browse all environment variables
# Search by name or value
# Displays full variable content
```

**`frg` — Interactive Ripgrep Search**

```bash
frg "pattern"
# Search with ripgrep
# Select result to jump to file:line in $EDITOR
# Perfect for code exploration
```

### Docker Operations

**`fdocker` — Interactive Container Management**

```bash
fdocker
# Select running container
# Preview shows recent logs
# Opens shell in selected container
```

## Shell Keybindings

FZF adds powerful keybindings to your shell:

| Key         | Function                    | Description                              |
| ----------- | --------------------------- | ---------------------------------------- |
| `Ctrl-R`    | Fuzzy command history       | Search and execute previous commands     |
| `Ctrl-T`    | Fuzzy file search           | Insert file path at cursor               |
| `Alt-C`     | Fuzzy directory search (cd) | Change to selected directory             |
| `Tab`       | Multi-select mode           | Select multiple items (in fzf interface) |
| `Shift-Tab` | Deselect item               | Remove from selection                    |
| `Ctrl-/`    | Toggle preview window       | Show/hide preview pane                   |

## Configuration

### Default Options

Configured in `/Users/bliss/dev/dotfiles/sh/fzf.sh`:

```bash
export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
```

### File Search Command

Uses `fd` for fast, smart file finding:

```bash
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow --exclude .git"
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_ALT_C_COMMAND="fd --type d --hidden --follow --exclude .git"
```

### Preview Configuration

Preview uses `bat` for syntax highlighting:

```bash
export FZF_FILE_PREVIEW="bat --color=always --style=numbers --line-range=:500 {}"
```

## Customization

### Change Appearance

```bash
# In ~/.rc.local
export FZF_DEFAULT_OPTS="
  --height 80%
  --layout=reverse
  --border=rounded
  --preview-window=right:60%
  --color=fg:#f8f8f2,bg:#1a1a2e,hl:#c792ea
  --color=fg+:#ffffff,bg+:#44475a,hl+:#ff79c6
  --color=info:#8be9fd,prompt:#50fa7b,pointer:#ff79c6
  --color=marker:#ff79c6,spinner:#ffb86c,header:#6272a4
"
```

### Modify Preview Size

```bash
# Larger preview window
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window=right:70%"

# Preview below instead of right
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window=down:50%"

# Hide preview by default (toggle with Ctrl-/)
export FZF_DEFAULT_OPTS="$FZF_DEFAULT_OPTS --preview-window=hidden"
```

### Custom File Ignore Patterns

```bash
# Ignore node_modules, .git, build dirs
export FZF_DEFAULT_COMMAND="fd --type f --hidden --follow \
  --exclude .git \
  --exclude node_modules \
  --exclude dist \
  --exclude build"
```

## Advanced Usage

### Creating Custom FZF Functions

```bash
# Select and view git commit
function fgit-show() {
  git log --oneline --color=always | \
    fzf --ansi --preview 'git show --color=always {1}' | \
    awk '{print $1}' | \
    xargs -I {} git show {}
}

# Interactive npm script runner
function fnpm() {
  local script
  script=$(jq -r '.scripts | keys[]' package.json 2>/dev/null | fzf)
  [[ -n "$script" ]] && npm run "$script"
}

# Fuzzy cd into project
function fproject() {
  local project
  project=$(fd --type d --max-depth 2 . ~/dev ~/work | fzf)
  [[ -n "$project" ]] && cd "$project"
}
```

### Integration with Other Tools

**With ripgrep for live search:**

```bash
function frg-live() {
  rg --color=always --line-number --no-heading --smart-case "${*:-}" |
    fzf --ansi \
        --color "hl:-1:underline,hl+:-1:underline:reverse" \
        --delimiter : \
        --preview 'bat --color=always {1} --highlight-line {2}' \
        --preview-window 'up,60%,border-bottom,+{2}+3/3,~3'
}
```

**With z/zoxide for smart directory jumping:**

```bash
function fz() {
  local dir
  dir=$(zoxide query --list | fzf --height 40% --reverse) && cd "$dir"
}
```

## Performance Tips

FZF is already fast, but here are optimization tips:

1. **Use fd instead of find** — Already configured, 5x faster
2. **Limit preview lines** — `--line-range=:500` in bat preview
3. **Reduce search scope** — Use `--max-depth` with fd
4. **Disable preview for huge files** — Add file size checks

```bash
# Only preview files < 1MB
function smart-preview() {
  if [[ $(stat -f%z "$1" 2>/dev/null) -lt 1000000 ]]; then
    bat --color=always "$1"
  else
    echo "File too large for preview"
  fi
}
```

## Troubleshooting

### FZF Not Found

**Issue:** `fzf: command not found`

**Solution:**

```bash
# Check if fzf is installed
which fzf

# Install via Go (as done in dotfiles)
go install github.com/junegunn/fzf@latest

# Ensure Go bin is in PATH
export PATH="$HOME/go/bin:$PATH"
```

### Preview Not Working

**Issue:** Preview window shows errors or nothing

**Solution:**

```bash
# Check if bat is installed
which bat

# Test preview command manually
echo "test.ts" | fzf --preview 'bat --color=always {}'

# Verify bat themes
bat cache --build
```

### Slow Performance

**Issue:** FZF lags in large directories

**Solution:**

```bash
# Limit search depth
export FZF_DEFAULT_COMMAND="fd --type f --max-depth 5"

# Exclude more directories
export FZF_DEFAULT_COMMAND="fd --type f \
  --exclude node_modules \
  --exclude .git \
  --exclude vendor \
  --exclude target"

# Disable preview for huge result sets
fzf --no-preview
```

### Colors Look Wrong

**Issue:** Colors don't match theme

**Solution:**

```bash
# Verify terminal supports 256 colors
echo $TERM
# Should be: xterm-256color

# Use built-in color scheme
export FZF_DEFAULT_OPTS="--color=16"  # Use terminal's 16 colors
```

## Integration Points

FZF is used throughout the dotfiles:

| Module         | Functions                                   |
| -------------- | ------------------------------------------- |
| `sh/fzf.sh`    | Core functions (fcd, fopen, fkill, fh, frg) |
| `sh/git.sh`    | Git operations (gadd, gco, glog, gstash)    |
| `sh/git.sh`    | Git worktree manager (gwt)                  |
| `sh/docker.sh` | Container management (dexec, dlf, dstop)    |
| `sh/nvm.sh`    | Node version switching                      |
| `sh/rust.sh`   | Rust toolchain switching                    |
| `sh/macos.sh`  | Homebrew service management (brew-services) |

## Tips & Best Practices

1. **Use Tab for multi-select** — Select multiple files/processes/branches
2. **Learn Ctrl-/** — Toggle preview on demand
3. **Use --height for inline fzf** — Keeps context visible
4. **Combine with other tools** — Pipe anything into fzf
5. **Create project-specific functions** — Add to `~/.rc.local`

## Cheat Sheet

```bash
# Core keybindings
Ctrl-R      # Fuzzy history search
Ctrl-T      # Fuzzy file insert
Alt-C       # Fuzzy cd

# Custom functions
fcd         # Fuzzy directory navigation
fopen       # Fuzzy file open
fkill       # Fuzzy process kill
gadd        # Fuzzy git add
gco         # Fuzzy git checkout
glog        # Fuzzy git log
gwt switch  # Fuzzy worktree switch

# Inside fzf
Tab         # Select item (multi-select)
Shift-Tab   # Deselect item
Ctrl-/      # Toggle preview
Enter       # Confirm selection
Esc/Ctrl-C  # Cancel
```

## External Resources

- [FZF GitHub](https://github.com/junegunn/fzf)
- [FZF Wiki](https://github.com/junegunn/fzf/wiki)
- [Advanced Examples](https://github.com/junegunn/fzf/wiki/examples)
- [FZF + Vim](https://github.com/junegunn/fzf.vim)

## Next Steps

- [Starship Prompt](./starship) — Prompt customization
- [Tmux Configuration](./tmux) — Terminal multiplexer
- [Modern CLI Tools](./modern-cli) — Tool deep dive
