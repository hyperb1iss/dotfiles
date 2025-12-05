# Tmux

_Terminal multiplexer for power users_

Tmux lets you manage multiple terminal sessions from a single window. Split panes, detach/reattach sessions, and work
seamlessly across local and remote environments.

## Key Bindings

### Prefix Key

The prefix key is **`Ctrl-b`** (default). All tmux commands start with pressing the prefix, then the command key.

```
Ctrl-b, then <key>
```

### Window Management

| Key          | Action          | Description                       |
| ------------ | --------------- | --------------------------------- |
| `prefix c`   | New window      | Create a new window               |
| `prefix n`   | Next window     | Switch to next window             |
| `prefix p`   | Previous window | Switch to previous window         |
| `prefix ,`   | Rename window   | Give the window a meaningful name |
| `prefix &`   | Kill window     | Close current window (confirms)   |
| `prefix w`   | List windows    | Interactive window selector       |
| `prefix 0-9` | Select window   | Jump to window by number          |

### Pane Management

| Key            | Action                     | Description                       |
| -------------- | -------------------------- | --------------------------------- |
| `prefix \|`    | Split horizontal           | Split pane left/right             |
| `prefix -`     | Split vertical             | Split pane top/bottom             |
| `Alt + Arrows` | Navigate panes (no prefix) | Move between panes without prefix |
| `prefix x`     | Kill pane                  | Close current pane (confirms)     |
| `prefix z`     | Zoom pane                  | Toggle pane full screen           |
| `prefix {`     | Move pane left             | Swap with previous pane           |
| `prefix }`     | Move pane right            | Swap with next pane               |
| `prefix Space` | Cycle layouts              | Switch between pane arrangements  |

### Session Management

| Key        | Action           | Description                         |
| ---------- | ---------------- | ----------------------------------- |
| `prefix d` | Detach           | Detach from session (keeps running) |
| `prefix s` | List sessions    | Interactive session selector        |
| `prefix $` | Rename session   | Give the session a meaningful name  |
| `prefix (` | Previous session | Switch to previous session          |
| `prefix )` | Next session     | Switch to next session              |

### Configuration & Help

| Key        | Action         | Description                  |
| ---------- | -------------- | ---------------------------- |
| `prefix r` | Reload config  | Source `~/.tmux.conf`        |
| `prefix ?` | List bindings  | Show all key bindings        |
| `prefix :` | Command prompt | Enter tmux commands directly |

## SilkCircuit Theme

The status bar uses the SilkCircuit color palette:

```
Background: #1a1a2e (deep space purple)
Active session: #c792ea (purple) bold
Current window: #ff79c6 (pink) bold
Inactive window: #7fdbca (cyan)
Pane borders: #c792ea (purple) active, #5a4a78 inactive
Time/Date: #ffcb6b (yellow), #7fdbca (cyan)
```

## Common Workflows

### Creating and Managing Sessions

```bash
# Create a new named session
tmux new -s project

# Create session with specific directory
tmux new -s project -c ~/dev/project

# Attach to existing session
tmux attach -t project
# Short form
tmux a -t project

# List all sessions
tmux ls

# Kill a session
tmux kill-session -t project

# Kill all sessions except current
tmux kill-session -a
```

### Working with Panes

```bash
# Typical workflow:
1. Prefix | to split horizontally (side-by-side)
2. Prefix - to split vertically (top-bottom)
3. Alt + Arrows to navigate
4. Prefix z to zoom focused pane
5. Prefix z again to un-zoom
```

Example layout for development:

```
┌─────────────────────────────┬─────────────────┐
│                             │                 │
│   Editor                    │   Tests         │
│   (main pane)               │   (watch mode)  │
│                             │                 │
├─────────────────────────────┼─────────────────┤
│   Server                    │   Git           │
│   (dev server)              │   (status/logs) │
└─────────────────────────────┴─────────────────┘
```

### Detaching and Reattaching

```bash
# Start work
tmux new -s work
# ... do stuff ...
# Prefix d to detach (or just close terminal)

# Later, from anywhere:
tmux a -t work
# Everything is still running!
```

Perfect for:

- Long-running processes
- Remote SSH sessions
- Switching between machines
- Surviving network disconnects

## Configuration

Located at `/Users/bliss/dev/dotfiles/tmux.conf`

### Useful Settings

```bash
# Mouse support (already enabled)
set -g mouse on

# Increase history
set -g history-limit 10000  # Default is 5000

# Start windows at 1 (already configured)
set -g base-index 1
set -g pane-base-index 1

# Renumber windows on close (already configured)
set -g renumber-windows on

# Faster command sequences
set -s escape-time 0

# Activity monitoring
setw -g monitor-activity on
set -g visual-activity off
```

### Custom Key Bindings

Add to `tmux.conf`:

```bash
# Easier split commands
bind h split-window -h -c "#{pane_current_path}"
bind v split-window -v -c "#{pane_current_path}"

# Quick pane resizing
bind -r H resize-pane -L 5
bind -r J resize-pane -D 5
bind -r K resize-pane -U 5
bind -r L resize-pane -R 5

# Vim-style pane navigation
bind h select-pane -L
bind j select-pane -D
bind k select-pane -U
bind l select-pane -R

# Synchronize panes (type in all at once)
bind C-s set-window-option synchronize-panes
```

### Change Prefix Key

To use `Ctrl-a` instead of `Ctrl-b`:

```bash
# Add to tmux.conf
unbind C-b
set-option -g prefix C-a
bind-key C-a send-prefix
```

Then reload: `prefix r`

### Theme Customization

Modify the status bar:

```bash
# Change status bar position (bottom is default)
set-option -g status-position top

# Customize left side
set -g status-left-length 50
set -g status-left '#[fg=#1a1a2e,bg=#c792ea,bold] #S #[fg=#c792ea,bg=#1a1a2e]'

# Customize right side
set -g status-right '#[fg=#ffcb6b]%H:%M #[fg=#7fdbca]%Y-%m-%d '

# Window status format
set -g window-status-format '#[fg=#7fdbca] #I:#W '
set -g window-status-current-format '#[fg=#1a1a2e,bg=#ff79c6,bold] #I:#W '
```

## Plugin Management

Tmux uses TPM (Tmux Plugin Manager) included as a submodule.

### Current Plugins

```bash
set -g @plugin 'tmux-plugins/tpm'           # Plugin manager itself
set -g @plugin 'tmux-plugins/tmux-sensible' # Sensible defaults
set -g @plugin '2kabhishek/tmux2k'          # Theme framework
```

### Managing Plugins

| Key            | Action            | Description            |
| -------------- | ----------------- | ---------------------- |
| `prefix I`     | Install plugins   | Install new plugins    |
| `prefix U`     | Update plugins    | Update all plugins     |
| `prefix alt+u` | Uninstall plugins | Remove deleted plugins |

### Adding Plugins

1. Add to `tmux.conf`:

```bash
set -g @plugin 'author/plugin-name'
```

2. Press `prefix I` to install
3. Reload config with `prefix r`

### Recommended Plugins

```bash
# Save/restore sessions
set -g @plugin 'tmux-plugins/tmux-resurrect'

# Automatic session save/restore
set -g @plugin 'tmux-plugins/tmux-continuum'
set -g @continuum-restore 'on'

# Copy to system clipboard
set -g @plugin 'tmux-plugins/tmux-yank'

# Better mouse support
set -g @plugin 'nhdaly/tmux-better-mouse-mode'
```

## Advanced Features

### Copy Mode

Enter copy mode to scroll and copy text:

```bash
# Enter copy mode
prefix [

# Navigate with vim keys
h, j, k, l  # Move cursor
Ctrl-b, Ctrl-f  # Page up/down
/  # Search forward
?  # Search backward

# Select and copy
Space  # Start selection
Enter  # Copy selection
prefix ]  # Paste
```

### Vi Mode

Enable vi-style keys in copy mode:

```bash
# Add to tmux.conf
setw -g mode-keys vi

# Vi-style copy bindings
bind-key -T copy-mode-vi v send-keys -X begin-selection
bind-key -T copy-mode-vi y send-keys -X copy-selection-and-cancel
```

### Pane Synchronization

Type the same command in all panes simultaneously:

```bash
# Toggle synchronize panes
prefix : setw synchronize-panes

# Useful for:
# - Running commands on multiple servers
# - Updating multiple containers
# - Testing in parallel
```

### Layouts

Cycle through automatic layouts:

```bash
prefix Space  # Cycle layouts

# Available layouts:
# - even-horizontal: Panes side-by-side
# - even-vertical: Panes stacked
# - main-horizontal: One large pane on top
# - main-vertical: One large pane on left
# - tiled: Grid layout
```

## Troubleshooting

### Colors Look Wrong

**Issue:** Colors don't match theme, look washed out

**Solution:**

```bash
# Check TERM
echo $TERM
# Should be: screen-256color inside tmux

# If not, add to ~/.zshrc BEFORE tmux starts:
export TERM=xterm-256color

# Then in tmux.conf:
set -g default-terminal "screen-256color"
set -ga terminal-overrides ",xterm-256color:Tc"
```

### Mouse Not Working

**Issue:** Can't click or scroll in tmux

**Solution:**

Mouse support is enabled by default. If not working:

```bash
# Ensure mouse is enabled in tmux.conf
set -g mouse on

# Reload config
prefix r

# Some terminals need additional config:
# - iTerm2: Preferences → Profiles → Terminal → Enable mouse reporting
# - Terminal.app: Should work by default on modern macOS
```

### Panes Not Splitting

**Issue:** Split commands don't work

**Solution:**

```bash
# Check bindings
prefix ?

# Should see:
# bind-key | split-window -h
# bind-key - split-window -v

# If missing, add to tmux.conf:
bind | split-window -h
bind - split-window -v

# Reload
prefix r
```

### Status Bar Not Showing

**Issue:** Status bar is missing or hidden

**Solution:**

```bash
# Enable status bar
prefix : set-option -g status on

# Make it permanent in tmux.conf:
set -g status on
set -g status-position bottom
```

## Tips & Tricks

1. **Use named sessions** — `tmux new -s project-name` makes it easy to remember
2. **Zoom panes frequently** — `prefix z` for focused work, `prefix z` again to see all
3. **Learn Alt+Arrows** — Navigate panes without prefix for speed
4. **Detach liberally** — Let long-running processes survive terminal closes
5. **Use copy mode** — `prefix [` to scroll back through history
6. **Rename windows** — `prefix ,` helps identify what each window is for

## Cheat Sheet

```bash
# Sessions
tmux new -s name             # Create named session
tmux ls                      # List sessions
tmux a -t name               # Attach to session
tmux kill-session -t name    # Kill session

# Inside tmux
prefix d                     # Detach
prefix c                     # New window
prefix n/p                   # Next/previous window
prefix |                     # Split horizontal
prefix -                     # Split vertical
Alt + arrows                 # Navigate panes
prefix z                     # Zoom/unzoom pane
prefix [                     # Copy mode
prefix r                     # Reload config
prefix ?                     # List all bindings
```

## External Resources

- [Tmux Official](https://github.com/tmux/tmux/wiki)
- [TPM Plugin Manager](https://github.com/tmux-plugins/tpm)
- [Awesome Tmux](https://github.com/rothgar/awesome-tmux)
- [Tmux Cheat Sheet](https://tmuxcheatsheet.com/)

## Next Steps

- [Starship Prompt](./starship) — Customize your prompt
- [FZF Integration](./fzf) — Fuzzy finder integration
- [Modern CLI Tools](./modern-cli) — Tool replacements
