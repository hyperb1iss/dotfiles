# Configuration

Customize your environment to perfection.

## Shell Configuration

### Installation Types

The installation saves its type to `.install_state`:

```bash
cat ~/dev/dotfiles/.install_state
# Output: minimal, full, or macos
```

Scripts check this with `is_minimal` and `is_full` functions to conditionally load features. This ensures lightweight
servers don't load desktop-specific utilities.

### Environment Variables

Key variables configured in `sh/env.sh`:

```bash
EDITOR=nvim              # Default editor
VISUAL=nvim              # Visual editor
GOPATH=~/dev/go          # Go workspace
FZF_DEFAULT_COMMAND      # fd with smart defaults
FZF_DEFAULT_OPTS         # fzf UI preferences
```

### Private Configuration

Create `~/.rc.local` for machine-specific settings that won't be committed to git:

```bash
# ~/.rc.local - This file is sourced automatically if it exists
export ANTHROPIC_API_KEY="sk-..."
export GITHUB_TOKEN="ghp_..."
export OPENAI_API_KEY="sk-..."

# Machine-specific aliases
alias work="cd ~/work/projects"
alias personal="cd ~/personal/code"

# Custom PATH additions
export PATH="$HOME/.local/bin:$PATH"

# Override defaults
export EDITOR="code"
export GWT_ROOT=~/custom/worktrees
```

This file is automatically sourced by `zshrc` if it exists and is completely ignored by git.

## Neovim Configuration

The dotfiles include a complete AstroNvim setup with custom plugins and keybindings.

### Adding Plugins

Create a new file in `nvim/lua/plugins/`:

```lua
-- nvim/lua/plugins/my-plugin.lua
return {
  "author/plugin-name",
  event = "VeryLazy",  -- Lazy load
  dependencies = {
    "required-plugin",
  },
  opts = {
    -- plugin configuration
    setting = "value",
  },
  config = function(_, opts)
    require("plugin-name").setup(opts)
  end,
}
```

Restart Neovim and the plugin will be automatically installed via lazy.nvim.

### Configuring LSP Servers

Add language servers in `nvim/lua/plugins/mason.lua`:

```lua
ensure_installed = {
  -- Existing servers
  "lua_ls",
  "ts_ls",
  "rust_analyzer",

  -- Add your servers
  "gopls",          -- Go
  "pyright",        -- Python
  "tailwindcss",    -- Tailwind CSS
},
```

Mason will automatically install these servers on next launch.

### Colorscheme

The SilkCircuit theme is loaded from `~/dev/silkcircuit-nvim`. To use a different theme:

```lua
-- nvim/lua/plugins/astroui.lua
return {
  "AstroNvim/astroui",
  opts = {
    colorscheme = "catppuccin",  -- or tokyonight, gruvbox, etc.
  },
}
```

### Custom Keybindings

Add keybindings in `nvim/lua/plugins/astrocore.lua`:

```lua
mappings = {
  n = {  -- Normal mode
    ["<leader>ft"] = { "<cmd>TodoTelescope<cr>", desc = "Find TODOs" },
    ["<leader>gg"] = { "<cmd>LazyGit<cr>", desc = "LazyGit" },
  },
  v = {  -- Visual mode
    ["<leader>y"] = { '"+y', desc = "Copy to system clipboard" },
  },
}
```

## Git Configuration

### User Settings

Configure your git identity:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"

# Or edit gitconfig directly
# The dotfiles symlink ~/.gitconfig to ~/dev/dotfiles/gitconfig
```

### Git Iris (AI Commit Messages)

Configure AI-powered commit messages:

```bash
# Project-level configuration
git iris project-config --no-gitmoji --preset conventional

# Or use the alias
gig  # git iris gen -a --no-verify --preset conventional
```

### Git Worktree Configuration

Customize worktree behavior:

```bash
# In ~/.rc.local
export GWT_ROOT=~/worktrees                    # Base directory for worktrees
export GWT_DEFAULT_BASE=origin/main            # Default base branch
export GWT_NO_COLOR=1                          # Disable colors (for scripts)
```

### Delta (Git Diff Tool)

Delta is configured in `gitconfig` as the default pager. Customize in `~/.gitconfig` or `~/dev/dotfiles/gitconfig`:

```ini
[delta]
    navigate = true
    light = false
    line-numbers = true
    syntax-theme = Dracula
    side-by-side = false  # Enable for split view
```

## Starship Prompt

The configuration lives at `starship/starship.toml`.

### Common Customizations

**Enable time display:**

```toml
[time]
disabled = false
format = '[$time]($style) '
time_format = "%H:%M"
```

**Change directory truncation:**

```toml
[directory]
truncation_length = 5  # Show 5 segments instead of 3
truncate_to_repo = false  # Don't truncate to git root
```

**Custom git branch symbol:**

```toml
[git_branch]
symbol = "🌿 "  # Use emoji
# or
symbol = " "  # Use Nerd Font icon
```

**Disable specific modules:**

```toml
[docker_context]
disabled = true  # Hide Docker context

[kubernetes]
disabled = true  # Hide K8s context
```

**Change colors:**

```toml
[directory]
style = "bold fg:#00ffff"  # Cyan directory

[git_branch]
style = "bold fg:#ff69b4"  # Hot pink branches
```

### Testing Your Changes

```bash
# Test configuration
starship config

# Check for errors
starship explain

# Reload immediately
source ~/.zshrc
```

## Tmux Configuration

Located at `tmux.conf` in the repository root.

### Change Prefix Key

```bash
# Default is Ctrl-b, change to Ctrl-a:
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

### Custom Key Bindings

```bash
# Add to tmux.conf
bind-key h split-window -h  # Horizontal split with 'h'
bind-key v split-window -v  # Vertical split with 'v'

bind-key -n C-Left previous-window   # Ctrl-Left for prev window
bind-key -n C-Right next-window      # Ctrl-Right for next window
```

### Plugin Management

Tmux uses TPM (Tmux Plugin Manager). Add plugins to `tmux.conf`:

```bash
# List of plugins
set -g @plugin 'tmux-plugins/tpm'
set -g @plugin 'tmux-plugins/tmux-sensible'
set -g @plugin 'tmux-plugins/tmux-resurrect'  # Save sessions
set -g @plugin 'tmux-plugins/tmux-continuum'  # Auto-save

# Install new plugins: Prefix + I
# Update plugins: Prefix + U
# Remove plugins: Prefix + alt + u
```

### Theme Customization

The SilkCircuit theme is defined inline in `tmux.conf`. Modify the colors:

```bash
# Status bar colors
set -g status-style 'bg=#1a1a2e,fg=#f8f8f2'

# Window colors
set -g window-status-current-format '#[fg=#1a1a2e,bg=#ff79c6,bold] #I:#W '

# Pane borders
set -g pane-active-border-style 'fg=#c792ea'
```

## Platform-Specific Configuration

### macOS

**Window Management:**

Yabai and skhd configs are in `macos/`:

```bash
# macos/yabairc - Tiling behavior
yabai -m config layout bsp
yabai -m config window_gap 10

# macos/skhdrc - Keyboard shortcuts
alt - return : open -a iTerm
alt - h : yabai -m window --focus west
```

**Homebrew:**

Customize installed packages in `macos/brew.sh`:

```bash
# Add your preferred packages
brew install neovim
brew install --cask visual-studio-code
```

### WSL2

WSL-specific functions are in `sh/wsl.sh`. Configure Windows integration:

```bash
# In ~/.rc.local
export BROWSER=wslview  # Open links in Windows browser
export DISPLAY=:0       # X11 forwarding

# Custom Windows path helpers
alias explorer='explorer.exe'
alias code='code.exe'
```

## FZF Configuration

Customize FZF behavior in `sh/fzf.sh` or `~/.rc.local`:

```bash
# Change default options
export FZF_DEFAULT_OPTS="
  --height 60%
  --layout=reverse
  --border
  --preview-window right:50%
  --color fg:#f8f8f2,bg:#1a1a2e,hl:#c792ea
"

# Use ripgrep for file search
export FZF_DEFAULT_COMMAND="rg --files --hidden --follow --glob '!.git/*'"

# Custom preview command
export FZF_FILE_PREVIEW="bat --color=always --style=numbers --line-range=:500 {}"
```

## Extending Shell Scripts

### Adding New Aliases

Edit the relevant domain file in `sh/`:

```bash
# sh/git.sh - Git-related aliases
alias gpr='git pull --rebase'
alias gfp='git fetch --prune'

# sh/docker.sh - Docker aliases
alias dcu='docker compose up -d'
alias dcd='docker compose down'
```

### Creating New Functions

```bash
# sh/custom.sh (create if it doesn't exist)
function myfunction() {
  echo "Hello from my custom function"
  # Your code here
}

# With fzf integration
function my-fuzzy-finder() {
  local selection
  selection=$(fd --type f | fzf --preview 'bat --color=always {}')
  if [[ -n "$selection" ]]; then
    echo "You selected: $selection"
  fi
}
```

New `.sh` files in `sh/` are automatically loaded by Zinit.

### Creating Domain-Specific Scripts

```bash
# sh/python.sh - Python utilities
function venv() {
  python3 -m venv .venv
  source .venv/bin/activate
}

function pipr() {
  pip install -r requirements.txt
}

alias py='python3'
alias ipy='ipython'
```

## Debugging & Troubleshooting

### Check What's Loaded

```bash
# List all aliases
alias | grep git

# List all functions
typeset -f | grep "^[a-z]" | head -20

# Check if specific function exists
type gwt
type gadd

# Show function source
which gwt
```

### Reload Configuration

```bash
# Reload zshrc
source ~/.zshrc

# Update Zinit plugins
zinit update
zinit self-update

# Clear Zinit cache (if having issues)
zinit delete --all
zinit update
```

### Verbose Loading

Debug slow startup or loading issues:

```bash
# Add to top of ~/.zshrc temporarily
zmodload zsh/zprof

# At the bottom of ~/.zshrc
zprof
```

This shows which plugins/scripts take longest to load.

### Check Environment

```bash
# View all environment variables
fenv  # Fuzzy search

# Check specific variable
echo $EDITOR
echo $FZF_DEFAULT_OPTS

# Verify PATH
echo $PATH | tr ':' '\n'
```

## Configuration Locations

Quick reference for where everything lives:

| Component          | Configuration File                      |
| ------------------ | --------------------------------------- |
| Zsh                | `~/dev/dotfiles/zsh/zshrc`              |
| Shell scripts      | `~/dev/dotfiles/sh/*.sh`                |
| Neovim             | `~/dev/dotfiles/nvim/`                  |
| Starship           | `~/dev/dotfiles/starship/starship.toml` |
| Tmux               | `~/dev/dotfiles/tmux.conf`              |
| Git                | `~/dev/dotfiles/gitconfig`              |
| Git Iris           | `.git-iris.yaml` (per-project)          |
| Private settings   | `~/.rc.local`                           |
| Installation state | `~/dev/dotfiles/.install_state`         |

All configs are symlinked from `~/dev/dotfiles` to their expected locations (`~/.zshrc`, `~/.config/nvim`, etc.).

## Next Steps

- [Shell Utilities](/shell/) — Deep dive into shell scripts
- [Neovim Configuration](/neovim/) — Editor setup details
- [CLI Tools](/tools/) — Modern tool configuration
