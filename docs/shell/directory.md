# Directory Navigation

_Get where you're going, fast_

Stop typing `cd ../../projects/work/repo` and start jumping. This is navigation that feels like teleportation.

## Aliases

Using [lsd](https://github.com/lsd-rs/lsd) as the modern ls replacement with icons and colors:

| Alias | Command     | Description              |
| ----- | ----------- | ------------------------ |
| `ls`  | `lsd`       | Modern ls with icons     |
| `ll`  | `ls -l`     | Long listing             |
| `la`  | `ls -la`    | Long with hidden files   |
| `lla` | `ls -la`    | Same as la (alias alias) |
| `lt`  | `ls --tree` | Tree view of directory   |

`lsd` shows file type icons, git status, and permission colors. It's `ls` but actually useful.

## Navigation Functions

### `mkcd` — Create & Enter

The most useful function you never knew you needed:

```bash
mkcd new-project
# Creates the directory and cds into it
# One command instead of two
```

### `take` — Multi-Argument mkcd

For deep directory structures:

```bash
take path/to/new/project
# Creates all intermediate directories
# Cds to the final one
```

### `up` — Go Up N Directories

Because `cd ../../..` is barbaric:

```bash
up      # cd ..
up 2    # cd ../..
up 3    # cd ../../..
up 5    # You get the idea
```

### `mktree` — Create & Show Tree

Create a directory and immediately see its structure:

```bash
mktree src/components
# Creates the directory
# Shows tree view
```

## Zoxide Integration

[Zoxide](https://github.com/ajeetdsouza/zoxide) is like autojump but actually maintained. It learns your habits and lets
you jump to frequently-used directories with minimal typing.

```bash
z project     # Jump to most frequent "project" match
z foo bar     # Multiple query terms
zi            # Interactive selection with fzf
```

The more you use it, the smarter it gets. After a week, you'll forget how you lived without it.

### `zp` — Zoxide with Directory Stack

Enhanced zoxide that maintains a stack:

```bash
zp project    # Jump to "project", push current dir to stack
zp --pop      # Pop from stack, return to previous dir
zp --list     # Show the stack
zp --clear    # Clear the stack
zpp           # Alias for zp --pop
```

Perfect for "I need to check something elsewhere then come back" workflows.

## Bookmarks

Persistent directory bookmarks that survive shell restarts. Stored in `~/.bookmarks`.

### `mark` — Create Bookmark

Bookmark the current directory:

```bash
cd ~/dev/important-project
mark proj     # Creates bookmark "proj"
```

### `jump` — Go to Bookmark

Jump to a bookmarked directory:

```bash
jump proj     # cd to ~/dev/important-project
jump          # No argument: interactive fzf selection
```

### `marks` — List Bookmarks

See all your bookmarks:

```bash
marks
# proj  →  /Users/bliss/dev/important-project
# dots  →  /Users/bliss/dev/dotfiles
# work  →  /Users/bliss/work/current-project
```

### `unmark` — Remove Bookmark

Delete a bookmark:

```bash
unmark proj   # Removes the "proj" bookmark
```

**When to use bookmarks vs zoxide**: Use bookmarks for permanent locations you visit infrequently. Use zoxide for places
you visit regularly—it learns automatically.

## FZF-Powered Navigation

### `fcd` — Interactive Directory Browser

Fuzzy-find directories with tree preview:

```bash
fcd
# Shows all directories in current tree
# Right pane shows tree preview
# Navigate with arrow keys
# Enter to cd
```

Excludes dotfiles and common ignored directories (node_modules, .git, etc.).

### `dv` — Directory Size Viewer

Find what's eating your disk space:

```bash
dv
# Shows directories sorted by size
# Tree preview for selected directory
# Perfect for finding space hogs
```

## Utility Functions

### `duh` — Sorted Directory Sizes

Human-readable sizes, sorted:

```bash
duh
# 2.3G  ./node_modules
# 856M  ./dist
# 124M  ./src
# 45M   ./.git
```

`du` but actually useful. Add a path argument to check a specific directory.

### `ff` — Find Files

Case-insensitive file search:

```bash
ff config
# Finds:
#   ./tsconfig.json
#   ./jest.config.js
#   ./.vscode/settings.json
```

Faster than trying to remember the exact filename.

## Workflows

### Exploring a New Codebase

```bash
# Jump to the repo
z my-new-project

# Get a sense of structure
lt

# Browse directories interactively
fcd

# Find that config file
ff eslint
```

### Rapid Context Switching

```bash
# You're in project A
zp project-b    # Jump to B, push A to stack

# Do something in B
# ...

# Return to A
zpp             # Pop from stack, back to A
```

### Managing Permanent Locations

```bash
# Bookmark important directories
cd ~/dev/client-work
mark client

cd ~/personal/blog
mark blog

# Jump between them
jump client
jump blog

# Or interactively
jump
# Fuzzy-find with fzf
```

### Finding Space Hogs

```bash
# Check current directory
duh

# Or specific location
duh ~/Downloads

# Interactive exploration
dv
# Browse and find the culprit
```

## Pro Tips

**Learn zoxide first**: It's the fastest way to move around. Let it learn your patterns for a week, then watch the magic
happen.

**Bookmark your workspace root**: Even if you use zoxide, having a bookmark for your main workspace is useful: `mark ws`
→ `jump ws`.

**Use `up` liberally**: Stop counting dots. `up 3` is faster and clearer than `cd ../../..`.

**Tree view for README writing**: Use `lt` to generate directory structures for documentation.

**Combine with tmux**: Different tmux panes in different directories = peak workflow efficiency.
