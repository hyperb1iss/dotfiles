# Keybindings

Keyboard shortcuts across all tools - organized for quick reference.

## Neovim

### Leader Keys

| Key     | Role         |
| ------- | ------------ |
| `Space` | Leader       |
| `,`     | Local leader |

### Navigation

| Key         | Action                     |
| ----------- | -------------------------- |
| `Space f f` | Find files (Telescope)     |
| `Space f w` | Find word (grep)           |
| `Space f r` | Recent files               |
| `Space e`   | File explorer (Neo-tree)   |
| `]b`        | Next buffer                |
| `[b`        | Previous buffer            |
| `Space b d` | Close buffer (with picker) |

### LSP (Language Server)

| Key         | Action               |
| ----------- | -------------------- |
| `gd`        | Go to definition     |
| `gD`        | Go to declaration    |
| `gr`        | Show references      |
| `gi`        | Go to implementation |
| `K`         | Hover documentation  |
| `Space l a` | Code actions         |
| `Space l r` | Rename symbol        |
| `Space l f` | Format document      |
| `Space l d` | Show diagnostics     |
| `]d`        | Next diagnostic      |
| `[d`        | Previous diagnostic  |

### AI (Avante & Claude Code)

| Key         | Action                   |
| ----------- | ------------------------ |
| `Ctrl ,`    | Toggle Claude Code panel |
| `Space a a` | Ask AI                   |
| `Space a e` | Edit with AI             |
| `Space a c` | Chat with AI             |
| `Meta-l`    | Accept AI suggestion     |

### Git

| Key         | Action                  |
| ----------- | ----------------------- |
| `Space g l` | Open Lazygit            |
| `Space g b` | Git blame               |
| `Space g h` | Git hunks (diff)        |
| `Space g o` | Octo (GitHub PR/Issues) |

### Trouble (Diagnostics)

| Key         | Action                |
| ----------- | --------------------- |
| `Space x x` | Toggle Trouble        |
| `Space x w` | Workspace diagnostics |
| `Space x d` | Document diagnostics  |
| `Space x q` | Quickfix list         |
| `Space x l` | Location list         |

### Search

| Key         | Action        |
| ----------- | ------------- |
| `Space s g` | Grep search   |
| `Space s b` | Buffer search |
| `Space s h` | Help tags     |
| `Space s k` | Keymaps       |

## Tmux

### Prefix: `Ctrl-b`

| Key            | Action                        |
| -------------- | ----------------------------- |
| `prefix \|`    | Split window horizontally     |
| `prefix -`     | Split window vertically       |
| `prefix c`     | Create new window             |
| `prefix n`     | Next window                   |
| `prefix p`     | Previous window               |
| `prefix d`     | Detach from session           |
| `prefix r`     | Reload tmux config            |
| `prefix [`     | Enter copy mode               |
| `prefix ]`     | Paste buffer                  |
| `Alt + arrows` | Navigate panes (no prefix)    |
| `prefix z`     | Zoom pane (toggle fullscreen) |
| `prefix x`     | Kill pane                     |
| `prefix &`     | Kill window                   |
| `prefix w`     | List windows                  |
| `prefix s`     | List sessions                 |

## FZF (in fzf prompts)

| Key         | Action                |
| ----------- | --------------------- |
| `Ctrl j`    | Move down             |
| `Ctrl k`    | Move up               |
| `Tab`       | Toggle selection      |
| `Shift-Tab` | Toggle selection (up) |
| `Enter`     | Confirm selection     |
| `Ctrl c`    | Cancel                |
| `Ctrl /`    | Toggle preview        |
| `Ctrl u`    | Page up               |
| `Ctrl d`    | Page down             |
| `Alt a`     | Select all            |
| `Alt d`     | Deselect all          |

## Shell (Zsh/Bash)

### Standard Emacs Bindings

| Key      | Action                      |
| -------- | --------------------------- |
| `Ctrl a` | Move to line start          |
| `Ctrl e` | Move to line end            |
| `Ctrl b` | Move backward one character |
| `Ctrl f` | Move forward one character  |
| `Alt b`  | Move backward one word      |
| `Alt f`  | Move forward one word       |
| `Ctrl w` | Delete word backward        |
| `Ctrl u` | Delete to line start        |
| `Ctrl k` | Delete to line end          |
| `Ctrl y` | Paste (yank)                |
| `Ctrl l` | Clear screen                |

### FZF Shell Integration

| Key      | Action                       |
| -------- | ---------------------------- |
| `Ctrl r` | Search command history (fzf) |
| `Ctrl t` | Find files and insert path   |
| `Alt c`  | cd to directory (fzf)        |

### Zsh Specific

| Key      | Action                      |
| -------- | --------------------------- |
| `Ctrl p` | Previous command in history |
| `Ctrl n` | Next command in history     |
| `Tab`    | Complete / show completions |

## macOS (Yabai + skhd)

### Window Focus

| Key     | Action             |
| ------- | ------------------ |
| `Alt h` | Focus left window  |
| `Alt j` | Focus down window  |
| `Alt k` | Focus up window    |
| `Alt l` | Focus right window |

### Window Movement

| Key           | Action            |
| ------------- | ----------------- |
| `Shift-Alt h` | Move window left  |
| `Shift-Alt j` | Move window down  |
| `Shift-Alt k` | Move window up    |
| `Shift-Alt l` | Move window right |

### Space Management

| Key             | Action                   |
| --------------- | ------------------------ |
| `Alt 1-9`       | Switch to space 1-9      |
| `Shift-Alt 1-9` | Move window to space 1-9 |

### Window Actions

| Key     | Action             |
| ------- | ------------------ |
| `Alt f` | Toggle fullscreen  |
| `Alt t` | Toggle float       |
| `Alt r` | Rotate window tree |
| `Alt m` | Toggle window zoom |

## Karabiner Elements

### Caps Lock Remapping

| Key                | Action                       |
| ------------------ | ---------------------------- |
| `Caps Lock` (tap)  | Escape                       |
| `Caps Lock` (hold) | Control (Hyper key modifier) |

### Hyper Key Combinations

If you have Hyper key (Caps Lock held) set up, it can be combined with other keys for custom actions.

## Lazygit

### Navigation

| Key     | Action              |
| ------- | ------------------- |
| `1-5`   | Switch panels       |
| `h/l`   | Navigate left/right |
| `j/k`   | Navigate up/down    |
| `Enter` | Confirm/Open        |
| `Esc`   | Cancel/Close        |

### Actions

| Key     | Action             |
| ------- | ------------------ |
| `Space` | Stage/unstage file |
| `a`     | Stage all          |
| `c`     | Commit             |
| `P`     | Push               |
| `p`     | Pull               |
| `o`     | Open file          |
| `d`     | Delete/discard     |
| `s`     | Stash changes      |
| `b`     | Create branch      |
| `m`     | Merge              |
| `r`     | Rebase             |

## K9s (Kubernetes)

### Navigation

| Key   | Action            |
| ----- | ----------------- |
| `0-9` | Jump to namespace |
| `:`   | Command mode      |
| `/`   | Filter            |
| `Esc` | Back/exit filter  |

### Common Resources

| Key    | Action           |
| ------ | ---------------- |
| `:pod` | View pods        |
| `:svc` | View services    |
| `:dep` | View deployments |
| `:ns`  | View namespaces  |
| `:ctx` | View contexts    |

### Actions

| Key      | Action            |
| -------- | ----------------- |
| `d`      | Describe resource |
| `y`      | YAML view         |
| `l`      | View logs         |
| `s`      | Shell into pod    |
| `Ctrl k` | Delete resource   |
| `e`      | Edit resource     |

## Quick Reference Tips

- Most tools use vim-style navigation (`h/j/k/l`) when applicable
- `Ctrl c` is universal for cancel/exit
- `Tab` for completion is standard across shell, vim, and fzf
- `?` often shows help in interactive tools
- `Esc` is a common way to go back/cancel in modal interfaces
