# Keybindings

_Master your keyboard-driven workflow_

This is your complete reference for all keybindings in this Neovim configuration. Everything is organized by category to
help you discover powerful workflows. The leader key is `Space`.

## Essential Concepts

**Notation:**

- `Space` = Leader key
- `C-x` = Ctrl + x
- `M-x` = Alt/Option + x (Meta)
- `S-x` = Shift + x

**Modes:**

- `n` = Normal mode
- `i` = Insert mode
- `v` = Visual mode
- `t` = Terminal mode

## General Navigation

### Window Management

| Key       | Action               | Description             |
| --------- | -------------------- | ----------------------- |
| `C-h`     | Move to left window  | Navigate between splits |
| `C-j`     | Move to window below |                         |
| `C-k`     | Move to window above |                         |
| `C-l`     | Move to right window |                         |
| `C-Up`    | Resize +2 vertical   | Make window taller      |
| `C-Down`  | Resize -2 vertical   | Make window shorter     |
| `C-Left`  | Resize -2 horizontal | Make window narrower    |
| `C-Right` | Resize +2 horizontal | Make window wider       |

### Buffer Navigation

| Key        | Action               | Description              |
| ---------- | -------------------- | ------------------------ |
| `]b`       | Next buffer          | Cycle through open files |
| `[b`       | Previous buffer      |                          |
| `Space b`  | Buffer menu          | Shows buffer commands    |
| `Space bd` | Delete buffer (pick) | Choose buffer to close   |
| `Space bb` | Buffers list         | Shows all buffers        |

### Tab Management

| Key       | Action       | Description          |
| --------- | ------------ | -------------------- |
| `]t`      | Next tab     | Move to next tab     |
| `[t`      | Previous tab | Move to previous tab |
| `Space t` | Tab menu     | Shows tab commands   |

## File Explorer (Neo-tree)

| Key       | Action           | Mode | Description              |
| --------- | ---------------- | ---- | ------------------------ |
| `Space e` | Toggle file tree | n    | Open/close file explorer |
| `Space o` | Focus file tree  | n    | Jump to file explorer    |

**Inside Neo-tree:**

| Key    | Action              | Description                |
| ------ | ------------------- | -------------------------- |
| `a`    | Add file/directory  | Create new file or folder  |
| `d`    | Delete              | Delete file or directory   |
| `r`    | Rename              | Rename file or directory   |
| `y`    | Copy                | Copy to clipboard          |
| `x`    | Cut                 | Cut to clipboard           |
| `p`    | Paste               | Paste from clipboard       |
| `c`    | Copy name           | Copy filename to clipboard |
| `C`    | Copy relative path  | Copy path relative to cwd  |
| `m`    | Move                | Move file to new location  |
| `o`    | Open                | Open file                  |
| `s`    | Open in split       | Open in horizontal split   |
| `S`    | Open in vsplit      | Open in vertical split     |
| `t`    | Open in tab         | Open in new tab            |
| `<CR>` | Open/toggle folder  | Enter/expand folder        |
| `h`    | Collapse folder     | Close current folder       |
| `H`    | Toggle hidden files | Show/hide dotfiles         |
| `R`    | Refresh             | Reload file tree           |
| `?`    | Show help           | Display all keybindings    |
| `q`    | Close               | Close Neo-tree             |

## Finding & Searching

### Snacks Picker (Primary)

| Key         | Action           | Description                 |
| ----------- | ---------------- | --------------------------- |
| `Space f f` | Find files       | Fuzzy find files in project |
| `Space f w` | Find word (grep) | Search text in all files    |
| `Space f r` | Recent files     | Recently opened files       |
| `Space f b` | Find buffers     | Search through open buffers |
| `Space f c` | Config files     | Search Neovim config files  |

**Inside Picker:**

- `C-j` / `C-k` - Move down/up
- `Enter` - Select item
- `C-s` - Open in split
- `C-v` - Open in vsplit
- `Esc` - Close picker

### Telescope (Advanced)

| Key         | Action         | Description                  |
| ----------- | -------------- | ---------------------------- |
| `Space f F` | Find all files | Include hidden/ignored files |
| `Space f '` | Find marks     | Navigate to marks            |
| `Space f h` | Help tags      | Search help documentation    |
| `Space f k` | Keymaps        | Search keybindings           |
| `Space f m` | Man pages      | Search man pages             |
| `Space f n` | Notifications  | Browse notification history  |
| `Space f o` | Old files      | Recently opened files        |

## LSP Actions

### Code Intelligence

| Key  | Action                | Description                     |
| ---- | --------------------- | ------------------------------- |
| `gd` | Go to definition      | Jump to where symbol is defined |
| `gD` | Go to declaration     | Jump to symbol declaration      |
| `gi` | Go to implementation  | Jump to implementation          |
| `gr` | Go to references      | Show all references             |
| `gy` | Go to type definition | Jump to type definition         |
| `K`  | Hover documentation   | Show symbol documentation       |
| `gK` | Signature help        | Show function signature         |

### LSP Commands

| Key         | Action              | Description                         |
| ----------- | ------------------- | ----------------------------------- |
| `Space l a` | Code actions        | Show available code actions         |
| `Space l d` | Buffer diagnostics  | Show diagnostics for current buffer |
| `Space l D` | Project diagnostics | Show all project diagnostics        |
| `Space l f` | Format buffer       | Format current file                 |
| `Space l i` | LSP info            | Show LSP server info                |
| `Space l r` | Rename symbol       | Rename symbol across project        |
| `Space l s` | Document symbols    | List symbols in file                |
| `Space l S` | Workspace symbols   | List symbols in workspace           |
| `Space l T` | LSP references      | LSP references via Trouble          |

### Diagnostics Navigation

| Key   | Action                | Description                   |
| ----- | --------------------- | ----------------------------- |
| `]d`  | Next diagnostic       | Jump to next issue            |
| `[d`  | Previous diagnostic   | Jump to previous issue        |
| `gl`  | Show line diagnostics | Float with error details      |
| `C-\` | Toggle Trouble panel  | Quick diagnostic panel toggle |

## Trouble (Diagnostics Panel)

| Key         | Action              | Description                        |
| ----------- | ------------------- | ---------------------------------- |
| `Space l d` | Buffer diagnostics  | Trouble panel for current file     |
| `Space l D` | Project diagnostics | Trouble panel for all files        |
| `Space l s` | Symbols outline     | Document symbols in Trouble        |
| `Space l T` | LSP references      | References/definitions via Trouble |
| `C-\`       | Quick toggle        | Toggle diagnostics panel           |

**Inside Trouble:**

| Key         | Action             | Description                |
| ----------- | ------------------ | -------------------------- |
| `<CR>`      | Jump and close     | Go to item and close panel |
| `o`         | Jump and close     | Same as Enter              |
| `<Tab>`     | Toggle fold        | Expand/collapse item       |
| `j` / `k`   | Next/previous      | Navigate items             |
| `]]` / `[[` | Next/previous item | Alternative navigation     |
| `q`         | Close              | Close Trouble panel        |
| `<Esc>`     | Close              | Alternative close          |
| `r` / `R`   | Refresh            | Reload diagnostics         |
| `?`         | Help               | Show all keybindings       |

## AI Integration

### Avante (Claude in Editor)

| Key         | Action           | Description                       |
| ----------- | ---------------- | --------------------------------- |
| `Space a a` | Ask AI           | Ask Claude about selection/buffer |
| `Space a e` | Edit with AI     | Get code suggestions from Claude  |
| `Space a r` | Refresh response | Regenerate AI response            |

**Suggestions:**

| Key   | Action              | Description                  |
| ----- | ------------------- | ---------------------------- |
| `M-l` | Accept suggestion   | Apply AI suggestion          |
| `M-]` | Next suggestion     | Cycle to next suggestion     |
| `M-[` | Previous suggestion | Cycle to previous suggestion |
| `C-]` | Dismiss suggestion  | Reject current suggestion    |

**Navigation in Avante panel:**

| Key     | Action                 | Description                     |
| ------- | ---------------------- | ------------------------------- |
| `]]`    | Next section           | Jump to next response section   |
| `[[`    | Previous section       | Jump to previous section        |
| `Tab`   | Switch panes           | Toggle between input and output |
| `S-Tab` | Switch panes (reverse) | Toggle in reverse               |

**Diff resolution:**

| Key   | Action            | Description                |
| ----- | ----------------- | -------------------------- |
| `c o` | Choose ours       | Keep your code             |
| `c t` | Choose theirs     | Accept AI suggestion       |
| `c a` | Choose all        | Accept all AI changes      |
| `c b` | Choose both       | Keep both versions         |
| `c c` | Choose cursor     | Resolve at cursor position |
| `]x`  | Next conflict     | Jump to next conflict      |
| `[x`  | Previous conflict | Jump to previous conflict  |

### Claude Code CLI

| Key         | Action                | Description                      |
| ----------- | --------------------- | -------------------------------- |
| `C-,`       | Toggle terminal       | Open/close Claude Code terminal  |
| `Space a c` | Toggle Claude Code    | Alternative toggle               |
| `Space c C` | Continue conversation | Resume last Claude Code session  |
| `Space c V` | Verbose mode          | Claude Code with detailed output |

## Terminal Management

| Key   | Action          | Mode | Description                    |
| ----- | --------------- | ---- | ------------------------------ |
| `C-t` | Toggle terminal | n, t | Open/close integrated terminal |
| `C-,` | Claude terminal | n, t | Claude Code terminal           |

**Terminal mode navigation:**

- `C-h/j/k/l` - Move between windows from terminal
- `C-t` - Close terminal
- `C-,` - Close Claude Code terminal

## Git Integration

### Git Commands

| Key         | Action            | Description             |
| ----------- | ----------------- | ----------------------- |
| `Space g g` | Git browse        | Open file in GitHub     |
| `Space g b` | Git blame line    | Show git blame for line |
| `Space g B` | Git browse (open) | Open in browser         |
| `Space g f` | File history      | Lazygit file history    |
| `Space g l` | Lazygit           | Open Lazygit            |
| `Space g L` | Lazygit log       | Show git log            |

### Gitsigns (Hunk Operations)

| Key         | Action          | Description                 |
| ----------- | --------------- | --------------------------- |
| `]g`        | Next hunk       | Jump to next git change     |
| `[g`        | Previous hunk   | Jump to previous git change |
| `Space g h` | Preview hunk    | Show git diff for hunk      |
| `Space g s` | Stage hunk      | Stage current hunk          |
| `Space g r` | Reset hunk      | Discard hunk changes        |
| `Space g S` | Stage buffer    | Stage entire file           |
| `Space g u` | Undo stage hunk | Unstage hunk                |

## Editing Enhancements

### Comments

| Key     | Action               | Mode | Description             |
| ------- | -------------------- | ---- | ----------------------- |
| `g c c` | Toggle comment line  | n    | Comment/uncomment line  |
| `g c`   | Toggle comment       | v    | Comment selection       |
| `g b c` | Toggle block comment | n    | Block comment line      |
| `g b`   | Toggle block comment | v    | Block comment selection |

### Text Objects & Selection

| Key  | Action             | Description                     |
| ---- | ------------------ | ------------------------------- |
| `]]` | Next reference     | Jump to next word reference     |
| `[[` | Previous reference | Jump to previous word reference |

### Completion (Insert Mode)

| Key       | Action             | Mode | Description              |
| --------- | ------------------ | ---- | ------------------------ |
| `C-Space` | Trigger completion | i    | Show completion menu     |
| `Tab`     | Select next        | i    | Next completion item     |
| `S-Tab`   | Select previous    | i    | Previous completion item |
| `Enter`   | Confirm            | i    | Accept completion        |
| `C-e`     | Close menu         | i    | Dismiss completion       |

**Snippet navigation:**

- `Tab` - Next placeholder
- `S-Tab` - Previous placeholder

## UI Toggles

### Visual Elements

| Key         | Action                  | Description                |
| ----------- | ----------------------- | -------------------------- |
| `Space u a` | Toggle autopairs        | Enable/disable autopairs   |
| `Space u b` | Toggle background       | Light/dark background      |
| `Space u c` | Toggle completion       | Enable/disable nvim-cmp    |
| `Space u C` | Toggle conceallevel     | Show/hide concealed text   |
| `Space u d` | Toggle diagnostics      | All/some/none              |
| `Space u g` | Toggle signcolumn       | Show/hide sign column      |
| `Space u i` | Toggle indent guides    | Show/hide indent lines     |
| `Space u l` | Toggle statusline       | Show/hide status bar       |
| `Space u n` | Toggle line numbers     | Show/hide line numbers     |
| `Space u N` | Toggle relative numbers | Relative/absolute numbers  |
| `Space u p` | Toggle paste mode       | Paste mode on/off          |
| `Space u s` | Toggle spell check      | Enable/disable spell check |
| `Space u S` | Toggle syntax           | Enable/disable syntax hl   |
| `Space u t` | Toggle tabline          | Show/hide buffer tabs      |
| `Space u u` | Toggle URL highlighting | Highlight URLs             |
| `Space u w` | Toggle word wrap        | Enable/disable line wrap   |
| `Space u y` | Toggle syntax (buffer)  | Buffer-local syntax toggle |
| `Space u Y` | Toggle semantic tokens  | LSP semantic highlighting  |

### Notifications

| Key         | Action                    | Description               |
| ----------- | ------------------------- | ------------------------- |
| `Space u n` | Dismiss all notifications | Clear notification popups |

## Debug Adapter Protocol

### Debugging

| Key         | Action                 | Description               |
| ----------- | ---------------------- | ------------------------- |
| `Space d b` | Toggle breakpoint      | Set/remove breakpoint     |
| `Space d B` | Conditional breakpoint | Breakpoint with condition |
| `Space d c` | Continue               | Resume execution          |
| `Space d C` | Run to cursor          | Continue to cursor        |
| `Space d i` | Step into              | Step into function        |
| `Space d o` | Step over              | Step over function        |
| `Space d O` | Step out               | Step out of function      |
| `Space d p` | Pause                  | Pause execution           |
| `Space d r` | REPL                   | Open debug REPL           |
| `Space d s` | Start debugging        | Start debug session       |
| `Space d t` | Terminate              | Stop debugging            |
| `Space d u` | Toggle UI              | Show/hide debug UI        |

## Plugin Management

| Key         | Action           | Description               |
| ----------- | ---------------- | ------------------------- |
| `Space p l` | Lazy             | Open Lazy plugin manager  |
| `Space p s` | Mason            | Open Mason tool installer |
| `Space p d` | Profiler scratch | Open profiler results     |

## Session Management

| Key         | Action         | Description           |
| ----------- | -------------- | --------------------- |
| `Space S s` | Save session   | Save current session  |
| `Space S l` | Load session   | Load previous session |
| `Space S d` | Delete session | Delete saved session  |
| `Space S f` | Find session   | Browse sessions       |

## Advanced Features

### Macros

| Key   | Action         | Mode | Description                     |
| ----- | -------------- | ---- | ------------------------------- |
| `q a` | Record macro   | n    | Record macro to register 'a'    |
| `q`   | Stop recording | n    | Stop macro recording            |
| `@ a` | Play macro     | n    | Execute macro from register 'a' |
| `@@`  | Repeat macro   | n    | Repeat last macro               |

### Marks

| Key         | Action       | Description              |
| ----------- | ------------ | ------------------------ |
| `m a`       | Set mark     | Set mark 'a' at cursor   |
| `' a`       | Jump to mark | Jump to mark 'a'         |
| `Space f '` | Find marks   | Search marks with picker |

## Pro Tips

### Workflow Optimization

1. **Learn the leader key menus** - Press `Space` and wait a moment to see available commands
2. **Use Trouble for diagnostics** - `Space l d` gives you a better view than inline diagnostics
3. **Master buffer navigation** - `]b` and `[b` are faster than finding files again
4. **Leverage AI wisely** - Use `Space a a` for quick questions, `C-,` for larger refactors
5. **Git integration is powerful** - `Space g l` opens Lazygit without leaving Neovim

### Custom Keybinding Template

Add your own keybindings in `nvim/lua/plugins/astrocore.lua`:

```lua
mappings = {
  n = {
    ["<leader>X"] = { "<cmd>MyCommand<cr>", desc = "My custom command" },
  },
}
```

### Which-Key Integration

Press any leader key (`Space`, `g`, `]`, `[`) and pause - which-key will show you available completions. This is the
best way to discover keybindings you didn't know existed.

## Cheat Sheet Summary

**Most used commands:**

```
Space f f   - Find files
Space f w   - Grep files
Space e     - File explorer
C-,         - Claude Code
Space l d   - Diagnostics
g d         - Go to definition
K           - Hover docs
Space l a   - Code actions
Space l f   - Format
```

Master these, and you'll be productive immediately. The rest will come naturally as you explore.
