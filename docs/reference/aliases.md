# All Aliases

Quick reference for every alias - organized by category for fast scanning.

## Git

### Core Git Commands

| Alias  | Command             | Description                           |
| ------ | ------------------- | ------------------------------------- |
| `g`    | `git`               | Git shortcut                          |
| `ga`   | `git add`           | Add files to staging                  |
| `gaa`  | `git add --all`     | Add all changes to staging            |
| `gb`   | `git branch`        | List branches                         |
| `gba`  | `git branch -a`     | List all branches (including remotes) |
| `gc`   | `git cherry-pick`   | Cherry-pick commits                   |
| `gd`   | `git diff`          | Show unstaged changes                 |
| `gdca` | `git diff --cached` | Show staged changes                   |
| `gst`  | `git status`        | Show working tree status              |
| `gsw`  | `git switch`        | Switch branches                       |
| `gswc` | `git switch -c`     | Create and switch to new branch       |

### Commit Operations

| Alias    | Command                           | Description                       |
| -------- | --------------------------------- | --------------------------------- |
| `gcom`   | `git commit -v`                   | Commit with diff preview          |
| `gcom!`  | `git commit -v --amend`           | Amend last commit with editor     |
| `gcomn!` | `git commit -v --no-edit --amend` | Amend last commit without editing |
| `gcoma`  | `git commit -v -a`                | Commit all changes with preview   |
| `gcoma!` | `git commit -v -a --amend`        | Amend with all changes            |
| `gcomm`  | `git commit -m`                   | Commit with message               |

### Remote Operations

| Alias   | Command                                    | Description                 |
| ------- | ------------------------------------------ | --------------------------- |
| `gf`    | `git fetch`                                | Fetch from remote           |
| `gfa`   | `git fetch --all --prune`                  | Fetch all remotes and prune |
| `gfo`   | `git fetch origin`                         | Fetch from origin           |
| `gl`    | `git pull`                                 | Pull from remote            |
| `gp`    | `git push`                                 | Push to remote              |
| `gpf`   | `git push --force-with-lease`              | Safe force push             |
| `gpsup` | `git push --set-upstream origin $(branch)` | Push and set upstream       |

### Git Iris (AI-Powered Git)

| Alias   | Command                                             | Description                  |
| ------- | --------------------------------------------------- | ---------------------------- |
| `gig`   | `git iris gen -a --no-verify --preset conventional` | Generate conventional commit |
| `iris`  | `git iris`                                          | Git Iris CLI                 |
| `irisg` | `git iris gen`                                      | Generate commit message      |
| `irisp` | `git iris pr`                                       | Generate PR description      |
| `iriss` | `git iris studio`                                   | Open Iris studio             |

## Directory & Files

### Listing

| Alias | Command     | Description                   |
| ----- | ----------- | ----------------------------- |
| `ls`  | `lsd`       | Modern ls with colors/icons   |
| `ll`  | `ls -l`     | Long format listing           |
| `la`  | `ls -la`    | Long format with hidden files |
| `lla` | `ls -la`    | Long format with hidden files |
| `lt`  | `ls --tree` | Tree view of directory        |

## Turbo

| Alias      | Command                  | Description                        |
| ---------- | ------------------------ | ---------------------------------- |
| `t`        | `turbo`                  | Turborepo CLI                      |
| `tb`       | `turbo build`            | Build all packages                 |
| `td`       | `turbo dev`              | Run dev mode for all packages      |
| `tl`       | `turbo lint:fix`         | Lint and fix all packages          |
| `tt`       | `turbo test`             | Test all packages                  |
| `tc`       | `turbo typecheck`        | Type-check all packages            |
| `tf`       | `turbo --filter`         | Filter packages for turbo commands |
| `tkill`    | `pkill turbo`            | Kill all turbo processes           |
| `tclear`   | `rm -rf .turbo`          | Clear turbo cache                  |
| `trestart` | `pkill turbo; turbo dev` | Restart turbo dev server           |

## pnpm

| Alias    | Command                     | Description                     |
| -------- | --------------------------- | ------------------------------- |
| `p`      | `pnpm`                      | pnpm shortcut                   |
| `pi`     | `pnpm install`              | Install dependencies            |
| `pa`     | `pnpm add`                  | Add dependency                  |
| `pad`    | `pnpm add -D`               | Add dev dependency              |
| `prm`    | `pnpm remove`               | Remove dependency               |
| `pr`     | `pnpm run`                  | Run package script              |
| `pup`    | `pnpm update`               | Update dependencies             |
| `pupi`   | `pnpm update --interactive` | Interactive dependency update   |
| `pout`   | `pnpm outdated`             | Show outdated dependencies      |
| `paudit` | `pnpm audit`                | Audit dependencies for security |

## TypeScript

| Alias    | Command                          | Description                   |
| -------- | -------------------------------- | ----------------------------- |
| `tsc`    | `pnpm exec tsc`                  | TypeScript compiler           |
| `tcheck` | `pnpm exec tsc --noEmit`         | Type-check without emitting   |
| `tcw`    | `pnpm exec tsc --noEmit --watch` | Type-check in watch mode      |
| `tsv`    | `pnpm exec tsc --version`        | Show TypeScript version       |
| `tsx`    | `pnpm exec tsx`                  | Run TypeScript files with tsx |

## Testing

| Alias | Command                       | Description                |
| ----- | ----------------------------- | -------------------------- |
| `vt`  | `pnpm exec vitest`            | Run vitest                 |
| `vtw` | `pnpm exec vitest --watch`    | Run vitest in watch mode   |
| `vtu` | `pnpm exec vitest --ui`       | Run vitest with UI         |
| `vtc` | `pnpm exec vitest --coverage` | Run vitest with coverage   |
| `vtr` | `pnpm exec vitest run`        | Run vitest once (no watch) |

## Linting & Formatting

| Alias   | Command                         | Description                |
| ------- | ------------------------------- | -------------------------- |
| `lint`  | `pnpm run lint:all`             | Lint all files             |
| `lintf` | `pnpm run lint:fix`             | Lint and fix all files     |
| `fmt`   | `pnpm exec prettier --write`    | Format with Prettier       |
| `bio`   | `pnpm exec biome`               | Run Biome linter/formatter |
| `biof`  | `pnpm exec biome check --write` | Run Biome with auto-fix    |

## Docker

| Alias    | Command                     | Description                  |
| -------- | --------------------------- | ---------------------------- |
| `d`      | `docker`                    | Docker shortcut              |
| `dc`     | `docker compose`            | Docker Compose               |
| `dps`    | `docker ps`                 | List running containers      |
| `dpsa`   | `docker ps -a`              | List all containers          |
| `di`     | `docker images`             | List images                  |
| `dex`    | `docker exec -it`           | Execute command in container |
| `dlogs`  | `docker logs`               | View container logs          |
| `dprune` | `docker system prune -f`    | Prune system resources       |
| `dstop`  | `docker stop`               | Stop container               |
| `drm`    | `docker rm`                 | Remove container             |
| `drmi`   | `docker rmi`                | Remove image                 |
| `dcp`    | `docker container prune -f` | Prune stopped containers     |
| `dip`    | `docker image prune -f`     | Prune unused images          |
| `dvp`    | `docker volume prune -f`    | Prune unused volumes         |
| `dnp`    | `docker network prune -f`   | Prune unused networks        |

## Kubernetes

| Alias  | Command            | Description              |
| ------ | ------------------ | ------------------------ |
| `k`    | `kubectl`          | Kubectl shortcut         |
| `kx`   | `kubectx`          | Switch context           |
| `kns`  | `kubens`           | Switch namespace         |
| `kgp`  | `kubectl get pods` | List pods                |
| `kaf`  | `kubectl apply -f` | Apply resource from file |
| `keti` | `kubectl exec -ti` | Execute in pod           |

## Rust

| Alias    | Command        | Description         |
| -------- | -------------- | ------------------- |
| `cr`     | `cargo run`    | Run Rust project    |
| `cb`     | `cargo build`  | Build Rust project  |
| `ct`     | `cargo test`   | Test Rust project   |
| `cf`     | `cargo fmt`    | Format Rust code    |
| `cc`     | `cargo clippy` | Lint Rust code      |
| `cbench` | `cargo bench`  | Benchmark Rust code |

## Node.js

| Alias          | Command                 | Description              |
| -------------- | ----------------------- | ------------------------ |
| `n`            | `node`                  | Node.js shortcut         |
| `npm-global`   | `npm list -g --depth=0` | List global npm packages |
| `npm-outdated` | `npm outdated`          | Show outdated packages   |
| `npm-update`   | `npm update`            | Update npm packages      |

## Java

| Alias      | Command              | Description                  |
| ---------- | -------------------- | ---------------------------- |
| `java8`    | `setjdk 8`           | Switch to Java 8             |
| `java11`   | `setjdk 11`          | Switch to Java 11            |
| `java17`   | `setjdk 17`          | Switch to Java 17            |
| `java21`   | `setjdk 21`          | Switch to Java 21            |
| `javalist` | `list_java_versions` | List available Java versions |

## Claude Code

| Alias | Command             | Description               |
| ----- | ------------------- | ------------------------- |
| `cc`  | `claude`            | Claude Code CLI           |
| `ccc` | `claude --continue` | Continue previous session |

## Zsh

| Alias | Command        | Description          |
| ----- | -------------- | -------------------- |
| `zzz` | `zinit update` | Update zinit plugins |

## Zoxide

| Alias | Command    | Description                     |
| ----- | ---------- | ------------------------------- |
| `zpp` | `zp --pop` | Pop from zoxide directory stack |
