# TypeScript & Turbo

_Monorepo mastery_

Modern JavaScript development means TypeScript monorepos with Turborepo. These aliases make it feel native.

## Turborepo Aliases

### Basic Commands

| Alias | Command           | Description        |
| ----- | ----------------- | ------------------ |
| `t`   | `turbo`           | Turbo CLI          |
| `tb`  | `turbo build`     | Build all packages |
| `td`  | `turbo dev`       | Dev mode (all)     |
| `tl`  | `turbo lint:fix`  | Lint & auto-fix    |
| `tt`  | `turbo test`      | Run all tests      |
| `tc`  | `turbo typecheck` | Type check         |
| `tf`  | `turbo --filter`  | Filter prefix      |

Most turbo commands work on all packages by default. Use filters to target specific ones.

### Filter Functions

Run turbo commands scoped to specific packages:

```bash
tdf temporal          # turbo dev --filter=temporal
tbf @packages/agents  # turbo build --filter=@packages/agents
tcf @apps/tools       # turbo typecheck --filter=@apps/tools
ttf temporal          # turbo test --filter=temporal
```

These save massive amounts of typing in large monorepos. Build muscle memory for your most-used packages.

### Housekeeping

| Alias      | Command                  | Description                  |
| ---------- | ------------------------ | ---------------------------- |
| `tkill`    | `pkill turbo`            | Kill all turbo processes     |
| `tclear`   | `rm -rf .turbo`          | Clear turbo cache            |
| `trestart` | `pkill turbo; turbo dev` | Kill and restart dev servers |

When turbo gets into a weird state (it happens), `trestart` is your friend.

## pnpm Aliases

| Alias    | Command                     | Description             |
| -------- | --------------------------- | ----------------------- |
| `p`      | `pnpm`                      | pnpm CLI                |
| `pi`     | `pnpm install`              | Install dependencies    |
| `pa`     | `pnpm add`                  | Add dependency          |
| `pad`    | `pnpm add -D`               | Add dev dependency      |
| `prm`    | `pnpm remove`               | Remove package          |
| `pr`     | `pnpm run`                  | Run script              |
| `pup`    | `pnpm update`               | Update packages         |
| `pupi`   | `pnpm update --interactive` | Interactive update      |
| `pout`   | `pnpm outdated`             | Check outdated packages |
| `paudit` | `pnpm audit`                | Security audit          |

pnpm is faster than npm, especially in monorepos. These aliases make it even faster.

## TypeScript Commands

### Type Checking

| Alias    | Command                          | Description                |
| -------- | -------------------------------- | -------------------------- |
| `tsc`    | `pnpm exec tsc`                  | TypeScript compiler        |
| `tcheck` | `pnpm exec tsc --noEmit`         | Type check only (no build) |
| `tcw`    | `pnpm exec tsc --noEmit --watch` | Watch mode type checking   |
| `tsv`    | `pnpm exec tsc --version`        | Show TypeScript version    |

`tcheck` is your friend. Run it before committing to catch type errors early.

### Running TypeScript

Direct TypeScript execution with tsx:

```bash
ts file.ts           # Run TypeScript file directly
tsw file.ts          # Watch mode - reruns on changes
tsx                  # Direct tsx access
```

No build step needed. Perfect for quick scripts and testing.

## Testing

### Vitest

| Alias | Command                       | Description           |
| ----- | ----------------------------- | --------------------- |
| `vt`  | `pnpm exec vitest`            | Run vitest            |
| `vtw` | `pnpm exec vitest --watch`    | Watch mode            |
| `vtu` | `pnpm exec vitest --ui`       | UI mode (in browser)  |
| `vtc` | `pnpm exec vitest --coverage` | With coverage report  |
| `vtr` | `pnpm exec vitest run`        | Single run (no watch) |

Vitest is fast. Really fast. Use watch mode during development.

## Linting & Formatting

| Alias   | Command                         | Description          |
| ------- | ------------------------------- | -------------------- |
| `lint`  | `pnpm run lint:all`             | Run all linters      |
| `lintf` | `pnpm run lint:fix`             | Lint with auto-fix   |
| `fmt`   | `pnpm exec prettier --write`    | Format with Prettier |
| `bio`   | `pnpm exec biome`               | Biome CLI            |
| `biof`  | `pnpm exec biome check --write` | Biome check and fix  |

Biome is faster than ESLint + Prettier combined. Consider it for new projects.

## Git Iris Integration

AI-powered git workflows:

| Alias   | Command           | Description                |
| ------- | ----------------- | -------------------------- |
| `iris`  | `git iris`        | Git Iris CLI               |
| `irisg` | `git iris gen`    | Generate commit message    |
| `irisp` | `git iris pr`     | Generate PR description    |
| `iriss` | `git iris studio` | Open Iris studio interface |

### PR Description Functions

Generate PR descriptions from commits:

```bash
gpr            # Generate PR desc from HEAD~1
gpr HEAD~3     # From last 3 commits
gprc HEAD~2    # Generate and copy to clipboard
```

Let AI write your PR descriptions. Edit as needed, but it's a great starting point.

## Monorepo Navigation

### `mono` — Package Jumper

Fuzzy-find and jump to packages in your monorepo:

```bash
mono
# Shows all packages (finds all package.json files)
# Preview shows package name from package.json
# Enter to cd into selected package
```

Works in any monorepo with package.json files. Faster than remembering paths.

### `monols` — List Packages

Display all workspace packages with SilkCircuit styling:

```bash
monols
# ━━━ Workspace Packages ━━━
# ▸ @apps/web                      0.0.1
# ▸ @apps/api                      0.0.1
# ▸ @packages/agents               1.0.0
# ▸ temporal                       0.0.1
```

Quick overview of your monorepo structure and versions.

## Project Info

### `ts-info` — Project Details

Show comprehensive TypeScript project information:

```bash
ts-info
# ━━━ Project Info ━━━
# ▸ Node: v22.0.0
# ▸ PM: pnpm (monorepo)
# ▸ TypeScript: 5.6.3
# ▸ Turbo: enabled
#
# ━━━ Tooling ━━━
#   ✓ vitest
#   ✓ biome
#   ✓ eslint
```

Great for onboarding or debugging environment issues.

## Claude Code

| Alias | Command             | Description      |
| ----- | ------------------- | ---------------- |
| `cc`  | `claude`            | Claude CLI       |
| `ccc` | `claude --continue` | Continue session |

For AI-assisted development in the terminal.

## Workflows

### Starting Development

```bash
# Jump to package
mono
# Select the one you're working on

# Start dev server (filtered)
tdf @apps/web

# In another terminal, watch tests
ttf @apps/web
```

### Before Commit

```bash
# Type check
tcheck

# Lint and fix
lintf

# Run tests
vtr

# Commit with AI
gig
```

### Managing Dependencies

```bash
# Check outdated packages
pout

# Interactive update
pupi

# Or update all
pup
```

### Building for Production

```bash
# Type check first
tc

# Build all
tb

# Or filter specific packages
tbf @apps/web @apps/api
```

### Debugging Type Errors

```bash
# Watch mode shows errors as you fix them
tcw

# Or check specific package
tsc --noEmit -p packages/agents/tsconfig.json
```

### Cleaning Up

```bash
# Clear turbo cache
tclear

# Kill stuck dev servers
tkill

# Reinstall dependencies
rm -rf node_modules
pi
```

## Pro Tips

**Use filters aggressively**: In large monorepos, `tdf mypackage` is way faster than `td` (which starts everything).

**Watch mode for tests**: Keep `vtw` running in a tmux pane. Instant feedback on changes.

**Type check before build**: `tcheck` is faster than a full build and catches type errors early.

**Learn your package names**: Muscle memory for filter commands pays off fast. `tdf temporal` becomes automatic.

**AI for boilerplate**: Use `iris` for commit messages and PR descriptions. Edit the output, but let AI do the first
draft.

**Navigate with `mono`**: Stop typing paths. `mono` + fuzzy search is faster.

**Cache awareness**: Turbo cache is smart, but sometimes you need `tclear` to fix weird issues.

**Workspace commands**: Use `pnpm -r` for workspace-wide commands: `pnpm -r build` builds everything.
