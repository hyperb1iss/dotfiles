# Node.js / proto

_One version manager for every runtime_

Node, npm, pnpm, Python, uv, and moon all come from [proto](https://moonrepo.dev/proto). There is no nvm module anymore;
proto reads `.prototools`, `.nvmrc`, and `package.json` engines on its own.

## Setup

`sh/env.sh` wires proto into every shell:

- **PATH**: `~/.proto/shims` and `~/.proto/bin` sit ahead of Homebrew and system tools.
- **Activation**: `proto activate` runs through `cached_eval`, so its hook script is generated once and reused until
  proto changes.
- **Global npm binaries**: shims don't cover `npm install -g`, so the active Node's `bin` directory is resolved once and
  cached in `~/.cache/dotfiles/proto-node-bin`.
- **`~/.local/bin` guard**: proto's directory-change hook can strip `~/.local/bin` when you leave a pinned repo, which
  makes uv tools disappear. A `chpwd` hook (zsh) or `PROMPT_COMMAND` entry (bash) puts it back.

## Global Pins

The tracked `proto/.prototools` is linked to `~/.proto/.prototools` by the desktop and headless roles. Per-project
`.prototools` files always win over it. Edit the tracked file rather than running `proto pin --global`, which would
write through the symlink and dirty the repo.

`auto-install` is on, so entering a project that pins a version you don't have installs it on first use.

## Quick Commands

```bash
proto status              # Pinned versions in this project and their source
proto install node        # Install the pinned Node
proto install node 22     # Install a specific major
proto pin node 22         # Pin Node 22 in ./.prototools
proto outdated            # Pins with newer releases available
proto upgrade             # Update proto itself
```
