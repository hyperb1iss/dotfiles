# Git Utilities

_The crown jewel of the shell scripts_

This is where the magic happens. Comprehensive aliases, an advanced worktree manager with SilkCircuit styling, and
interactive functions that make git feel like it was designed for the terminal.

## Aliases

### Basic Operations

| Alias  | Command             | Description              |
| ------ | ------------------- | ------------------------ |
| `g`    | `git`               | Because two letters hurt |
| `ga`   | `git add`           | Stage files              |
| `gaa`  | `git add --all`     | Stage everything         |
| `gst`  | `git status`        | Check status             |
| `gd`   | `git diff`          | Show diff                |
| `gdca` | `git diff --cached` | Diff staged changes      |

### Commits

| Alias    | Command                           | Description           |
| -------- | --------------------------------- | --------------------- |
| `gcom`   | `git commit -v`                   | Commit with diff view |
| `gcomm`  | `git commit -m`                   | Commit with message   |
| `gcom!`  | `git commit -v --amend`           | Amend last commit     |
| `gcomn!` | `git commit -v --no-edit --amend` | Amend without editing |
| `gcoma`  | `git commit -v -a`                | Commit all changes    |
| `gcoma!` | `git commit -v -a --amend`        | Amend all changes     |

Pro tip: The `!` suffix means "amend". Get used to `gcom!` for quick fixups.

### Branches & Navigation

| Alias  | Command           | Description          |
| ------ | ----------------- | -------------------- |
| `gb`   | `git branch`      | List branches        |
| `gba`  | `git branch -a`   | List all branches    |
| `gsw`  | `git switch`      | Switch to branch     |
| `gswc` | `git switch -c`   | Create & switch      |
| `gc`   | `git cherry-pick` | Cherry-pick a commit |

### Remote Operations

| Alias   | Command                                    | Description              |
| ------- | ------------------------------------------ | ------------------------ |
| `gf`    | `git fetch`                                | Fetch updates            |
| `gfa`   | `git fetch --all --prune`                  | Fetch all, prune stale   |
| `gl`    | `git pull`                                 | Pull changes             |
| `gp`    | `git push`                                 | Push changes             |
| `gpf`   | `git push --force-with-lease`              | Safe force push          |
| `gpsup` | `git push --set-upstream origin $(branch)` | Push new branch upstream |

Always use `gpf` over `git push --force`. It protects you from overwriting others' work.

### AI-Powered Commits

Git Iris integration for AI-generated commit messages:

| Alias   | Command                                             | Description                   |
| ------- | --------------------------------------------------- | ----------------------------- |
| `gig`   | `git iris gen -a --no-verify --preset conventional` | AI commit message (stage all) |
| `iris`  | `git iris`                                          | Git Iris CLI                  |
| `irisp` | `git iris pr`                                       | Generate PR description       |

`gig` is your new best friend. Stage your changes, run `gig`, and get a perfectly formatted conventional commit.

## Interactive Functions

These leverage fzf for beautiful, interactive git workflows.

### `gadd` — Interactive Staging

Select exactly what you want to stage with diff preview:

```bash
gadd
# Shows unstaged files in fzf
# Preview pane shows the actual diff
# Tab to multi-select files
# Enter to stage selected files
```

No more accidentally staging that debug print statement.

### `gco` — Interactive Branch Checkout

Fuzzy-find and switch branches with commit preview:

```bash
gco
# Shows all branches (local and remote)
# Preview shows recent commits for each branch
# Enter to checkout
```

Perfect when you can't remember if it was `feature/auth` or `feature/authentication`.

### `glog` — Interactive Commit Browser

Browse your commit history like a pro:

```bash
glog
# Beautiful graphical log in fzf
# Ctrl-m to see full commit details
# Color-coded, navigable history
```

This beats scrolling through `git log --oneline` any day.

### `gstash` — Stash Management

Interactive stash operations with preview:

```bash
gstash
# Select a stash entry
# See diff preview
# Choose action:
#   [a]pply  - Apply stash, keep it
#   [p]op    - Apply stash, delete it
#   [d]rop   - Delete stash
#   [s]how   - View full diff
#   [b]ranch - Create branch from stash
```

Stash management finally makes sense.

### `grebase` — Interactive Rebase

Multi-select commits for interactive rebase:

```bash
grebase
# Shows last 50 commits
# Multi-select commits with Tab
# Opens interactive rebase starting at selected commit
```

Rebase without counting how many commits back you need.

## Git Worktree Manager (`gwt`)

The piece de resistance. Modern worktree management with SilkCircuit styling and intelligent workflows.

### Commands

```bash
gwt                    # Interactive action picker (requires fzf)
gwt list              # Show all worktrees
gwt list --date       # Sort by last commit date
gwt switch [pattern]  # fzf-select and cd to worktree
gwt new <branch>      # Create new worktree
gwt remove [pattern]  # Remove worktree(s)
gwt clean             # Prune stale worktrees
gwt info              # Current worktree details
```

### Creating Worktrees

The `new` command is where the magic happens:

```bash
# Interactive base branch selection
gwt new my-feature
# You'll get an fzf picker to choose the base branch
# Defaults to origin/main

# Specify base branch directly
gwt new my-feature --from origin/develop

# Custom path
gwt new my-feature --path ~/work/feature-branch

# Skip auto-switching
gwt new my-feature --no-switch

# Skip fetching
gwt new my-feature --no-fetch
```

Pro workflow: Create a worktree per feature/bug. Your main worktree stays clean, and context switching is instant.

### Switching Worktrees

```bash
# Interactive selection
gwt switch

# Pattern matching
gwt switch feat
# Matches any worktree with "feat" in the name

# Alias for switch
gwt cd
gwt open  # Same thing
```

The switch command actually changes your directory. Perfect for rapid context switching.

### Listing Worktrees

The list command shows a beautiful table with the SilkCircuit color scheme:

```
━━━ Worktrees ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
   BRANCH                    HEAD       UPDATED          PATH
────────────────────────────────────────────────────────────────────
 * main                      a1b2c3d    2 hours ago      ~/dev/project
   feature/auth              e4f5g6h    3 days ago       ~/worktrees/auth
   fix/bug-123               i7j8k9l    1 week ago       ~/worktrees/bug-123
```

Features:

- Current worktree marked with `*` in electric purple
- Prunable worktrees highlighted in electric yellow
- Commit hash in coral, age in electric yellow
- Can sort by date with `--date` flag

### Removing Worktrees

```bash
# Interactive multi-select
gwt remove

# Pattern matching
gwt remove old-feat

# Force removal (with uncommitted changes)
gwt remove pattern --force
```

The main worktree is protected—you can't accidentally remove it.

### Configuration

Customize default behavior with environment variables:

```bash
# Default worktree location
export GWT_ROOT=~/dev/worktrees

# Default base branch for new worktrees
export GWT_DEFAULT_BASE=origin/main

# Disable colors
export GWT_NO_COLOR=1
```

Put these in your `~/.rc.local` for machine-specific settings.

## Utility Functions

### `gsetup` — Repository Initialization

Bootstrap a new repository with sensible defaults:

```bash
gsetup
# Configures:
#   pull.rebase = true
#   push.default = current
#   core.autocrlf = input
# Creates .gitignore with common patterns
# Initializes main branch
# Creates initial commit
```

Run this in every new repo. Save yourself from bad defaults.

### `gclean` — Branch Cleanup

Remove merged and stale branches:

```bash
gclean
# Removes merged local branches (except main/master)
# Prunes remote tracking branches that no longer exist
```

Run this after merging PRs to keep your branch list tidy.

### `gstatus` — Enhanced Status

Categorized file listing (alternative to `git status`):

```bash
gstatus
# Modified files:
#   src/app.ts
#   src/utils.ts
# Staged files:
#   src/index.ts
# Untracked files:
#   notes.md
```

Cleaner output when you have lots of changes.

### `git_current_branch`

Utility function used by aliases:

```bash
git_current_branch  # → main
```

Useful in scripts and custom aliases.

## Git Config Integration

Your global gitconfig is configured with:

- **Delta** for syntax-highlighted diffs
- **SilkCircuit colors** for status, branch, diff output
- **Pretty formats** for log commands
- **LFS support** for large files
- **zdiff3** merge conflict style (clearest diffs)

### Custom Log Formats

These are configured in your gitconfig:

```bash
git lg     # One-line graph
git l      # Full format with SilkCircuit colors
git lgf    # Full graph with SilkCircuit
git lga    # All branches graph
```

Try `git lg` instead of `git log`. You'll never go back.

## Workflows

### Feature Development

```bash
# Create feature worktree
gwt new feature/awesome-thing

# Work in isolation
# Make commits, test, iterate

# When done, switch back to main
gwt switch main

# Merge or create PR
```

### Quick Fixes

```bash
# Create hotfix worktree
gwt new hotfix/critical-bug --from origin/production

# Fix the bug
# Commit with AI
gig

# Switch back
gwt switch main

# Clean up when merged
gwt remove hotfix
```

### Multi-Context Work

```bash
# List all your worktrees
gwt list --date

# Jump between them
gwt switch
# Use fzf to pick

# See where you are
gwt info
```

## Pro Tips

**Worktree Strategy**: Keep your main worktree pristine. Create worktrees for all feature work. This way
`gwt switch main` always gives you a clean slate.

**AI Commits**: Use `gig` for conventional commits. It stages everything and generates a proper commit message. Edit
before confirming if needed.

**Interactive Functions**: Learn `gadd`, `gco`, and `glog`. They're faster than manual commands once you build muscle
memory.

**Force Push Safety**: Always use `gpf` instead of `git push --force`. It uses `--force-with-lease` which prevents
overwriting others' work.

**Stale Branch Cleanup**: Run `gclean` regularly to keep your local branches tidy. Especially after PR merges.

**Rebase Workflow**: Configure `pull.rebase = true` (done in `gsetup`) to avoid merge commits on pull.
