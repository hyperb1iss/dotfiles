# Node.js / NVM

_Version management done right_

Node versions change fast. NVM makes switching between them painless.

## Setup

NVM initializes automatically via `sh/nvm.sh` with platform-specific detection:

- **macOS**: Detects Homebrew installation
- **Linux**: Uses standard `~/.nvm` installation

No manual sourcing needed—it just works.

## Quick Commands

| Command       | Description                         |
| ------------- | ----------------------------------- |
| `node-lts`    | Install & use latest LTS            |
| `node-latest` | Install & use latest stable         |
| `node-switch` | Interactive version picker (fzf)    |
| `node-list`   | List installed versions             |
| `node-info`   | Show current Node/npm/pnpm versions |

Start with `node-lts` for most projects. It's the safe choice.

## Version Management

### Install Versions

```bash
node-lts              # Latest LTS (recommended)
node-latest           # Latest stable (bleeding edge)
node-install 20.10.0  # Specific version
node-install lts/iron # Named LTS release
```

LTS versions get long-term support. Use them for production projects.

### Switch Versions

```bash
node-switch           # Interactive fzf picker
nvm use 20            # Switch to Node 20.x
nvm use --lts         # Switch to latest LTS
nvm use node          # Switch to latest installed
```

`node-switch` with fzf is the best experience—see all versions, pick one.

### Remove Versions

Clean up old Node versions:

```bash
node-uninstall 18.0.0
# or: nvm uninstall 18.0.0
```

Free up disk space by removing versions you don't need anymore.

## .nvmrc Support

`.nvmrc` files let projects specify their Node version. Essential for team consistency.

### Auto-Detection

```bash
auto-nvm
# Reads .nvmrc in current directory
# Installs version if missing
# Switches to specified version
```

Run this when entering a new project directory.

### Create .nvmrc

Save the current Node version to `.nvmrc`:

```bash
nvmrc-create
# Creates .nvmrc with current Node version
# Commit this to your repo
```

### Auto-Switch on cd (Optional)

Enable automatic version switching:

```bash
# Add to ~/.rc.local
export NVM_AUTO_SWITCH=true
```

With this enabled, `cd`-ing into a directory with `.nvmrc` automatically switches Node versions. Magic.

## npm Aliases

| Alias          | Command                 | Description          |
| -------------- | ----------------------- | -------------------- |
| `n`            | `node`                  | Node CLI             |
| `npm-global`   | `npm list -g --depth=0` | List global packages |
| `npm-outdated` | `npm outdated`          | Check outdated deps  |
| `npm-update`   | `npm update`            | Update packages      |

Use `pnpm` for projects (see [TypeScript](./typescript) docs), but these are handy for global packages.

## Workflows

### New Project Setup

```bash
# Install LTS
node-lts

# Verify version
node-info

# Create .nvmrc for the project
nvmrc-create

# Initialize project
npm init -y
# or: pnpm init
```

### Switching Between Projects

```bash
# Enter project A
cd ~/projects/project-a
auto-nvm          # Switches to project A's Node version

# Enter project B
cd ~/projects/project-b
auto-nvm          # Switches to project B's Node version
```

Or enable `NVM_AUTO_SWITCH` and it happens automatically.

### Upgrading Node

```bash
# Check current version
node-info

# See what's available
nvm ls-remote --lts

# Install new LTS
node-lts

# Update .nvmrc if needed
nvmrc-create
```

## Troubleshooting

### NVM Not Found

```bash
# Check if NVM is installed
ls ~/.nvm

# macOS Homebrew check
brew info nvm

# Manual install
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.39.0/install.sh | bash
```

### Slow Shell Startup

NVM can slow down shell startup. These dotfiles use lazy loading via zinit to mitigate this. If it's still slow:

```bash
# Check startup time
time zsh -i -c exit

# Profile to find slow parts
zsh -xv 2>&1 | head -100
```

### Wrong Node Version

```bash
# Check what's active
node-info

# See installed versions
node-list

# Switch to correct version
node-switch

# Or save current version to .nvmrc
nvmrc-create
```

### Global Packages Missing After Switch

NVM installs are version-specific. Global packages need reinstalling per Node version:

```bash
# See what's installed globally
npm-global

# Reinstall global tools
npm install -g pnpm turbo vercel
```

Or use `nvm reinstall-packages <version>` when installing a new Node version.

## Pro Tips

**Always use LTS for production**: `node-latest` is fun for experimenting, but LTS is what you want for stability.

**Commit .nvmrc files**: Every project should have one. It ensures everyone uses the same Node version.

**Enable auto-switch**: Set `NVM_AUTO_SWITCH=true`. No more "it works on my machine" because of Node version mismatches.

**Use pnpm over npm**: It's faster, especially in monorepos. Install globally with `npm install -g pnpm` (yes, use npm
to install pnpm).

**Check version on new projects**: Before cloning a repo, see if it has `.nvmrc`. Run `auto-nvm` to match the version.

**Update regularly**: LTS versions still get updates. Run `node-lts` occasionally to stay current within your LTS
release line.
