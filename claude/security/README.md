# Claude Code Security Module

Defense-in-depth protection for Claude Code. Blocks dangerous commands and protects sensitive files via PreToolUse
hooks.

## Quick Install

```bash
# From dotfiles repo
python3 ~/dev/dotfiles/claude/security/install.py

# Or for project-local installation
python3 ~/dev/dotfiles/claude/security/install.py --project
```

## What It Does

This module intercepts Claude Code tool calls **before execution** and evaluates them against configurable security
patterns. It provides three levels of protection:

| Action    | Behavior                               | Exit Code |
| --------- | -------------------------------------- | --------- |
| **block** | Immediately reject, command never runs | 2         |
| **ask**   | Prompt user for confirmation           | 0 + JSON  |
| **allow** | Proceed normally                       | 0         |

## Protected Operations

### Git (Critical)

- `git push` - Always blocked (you push manually)
- `git push --force` - History destruction
- `git reset --hard` - Destroys uncommitted work
- `git clean -f` - Permanent untracked file deletion
- `git checkout -- <file>` - Discards changes
- `git restore` (without --staged) - Discards changes
- `git stash drop/clear` - Loses stashed work
- `git branch -D` - Force delete without merge check

### Filesystem

- `rm -rf /` - Root deletion
- `sudo rm` - Privileged deletion
- `dd` to devices - Disk destruction
- `chmod 777` - Insecure permissions

### Containers & Orchestration

- `docker system prune` - Removes all unused data
- `docker-compose down -v` - Volume destruction
- `kubectl delete namespace` - Entire namespace deletion
- `kubectl delete --all` - Mass deletion
- `helm uninstall` - Release removal

### Cloud Providers

- AWS: `terminate-instances`, `delete-db-instance`, `s3 rm --recursive`
- GCP: `instances delete`, `sql instances delete`, `gsutil rm -r`
- Azure: `vm delete`, `group delete`

### Databases

- `DROP DATABASE/TABLE` - Schema destruction
- `TRUNCATE TABLE` - Data loss
- `DELETE FROM ... ;` (no WHERE) - Full table wipe
- `FLUSHALL/FLUSHDB` - Redis data loss
- `dropDatabase` - MongoDB destruction

### Infrastructure

- `terraform destroy` - Infrastructure teardown
- `pulumi destroy` - Infrastructure teardown

## File Structure

```
claude/security/
├── patterns.yaml      # Dangerous patterns to block/ask (edit to customize)
├── safe-tools.yaml    # Safe tools to auto-allow (edit to customize)
├── damage-control.py  # PreToolUse hook script
├── install.py         # Installer script
└── README.md          # This file
```

## Install Options

```bash
# Full installation (recommended)
python3 install.py

# Project-local only
python3 install.py --project

# Hooks only, no permission rules
python3 install.py --minimal

# Skip safe-tools auto-allow rules
python3 install.py --no-safe-tools

# List all safe tools (for review)
python3 install.py --list-safe-tools
```

## Customization

### Dangerous Patterns (patterns.yaml)

Edit `patterns.yaml` to customize what gets blocked or requires confirmation. This is the **single source of truth** for
security patterns.

### Safe Tools (safe-tools.yaml)

Edit `safe-tools.yaml` to customize what's auto-allowed. Includes **300+ rules** organized by category:

| Category            | Examples                                  |
| ------------------- | ----------------------------------------- |
| **Filesystem Read** | ls, find, tree, cat, head, tail, wc, stat |
| **Search**          | grep, rg, fd, ag, ack, fzf, locate        |
| **Git Read**        | status, log, diff, show, branch, blame    |
| **Git Safe Write**  | add, commit, fetch, stash, checkout -b    |
| **Node.js**         | npm/pnpm/yarn run, test, build, lint      |
| **Python**          | pytest, ruff, mypy, uv, poetry            |
| **Rust**            | cargo build, test, check, clippy, fmt     |
| **Go**              | go build, test, run, fmt, vet             |
| **Build Tools**     | make, moon, turbo, nx, just               |
| **Containers Read** | docker ps, images, logs, inspect          |
| **K8s Read**        | kubectl get, describe, logs, top          |
| **System Info**     | uname, whoami, ps, top, env               |
| **Web Domains**     | github.com, npmjs.com, docs.\*            |
| **MCP Servers**     | context7, sibyl, archon                   |

### Pattern Syntax

```yaml
bash:
  block:
    - pattern: '\bmy-dangerous-command\b'
      reason: "Description shown when blocked"

  ask:
    - pattern: '\bneeds-confirmation\b'
      reason: "Reason shown in confirmation dialog"

  allow:
    - pattern: '\bsafe-variant\b'
      reason: "Why this is allowed despite matching other patterns"
```

### Pattern Evaluation Order

1. **allow** patterns checked first (override blocks)
2. **block** patterns checked second
3. **ask** patterns checked last

This means you can create broad block patterns and carve out specific exceptions with allow patterns.

### Adding Custom Rules

Example: Block a company-specific dangerous command:

```yaml
bash:
  block:
    - pattern: '\bdeploy-prod\s+--force\b'
      reason: "Blocked: production force deploy requires manual execution"
```

Example: Require confirmation for database migrations:

```yaml
bash:
  ask:
    - pattern: '\balembic\s+upgrade\b'
      reason: "Database migration requires confirmation"
    - pattern: '\bprisma\s+migrate\s+deploy\b'
      reason: "Database migration requires confirmation"
```

## How It Works

1. **PreToolUse Hook**: Intercepts Bash, Edit, Write, and Read tool calls
2. **Pattern Matching**: Evaluates command/path against `patterns.yaml`
3. **Decision**: Returns block (exit 2), ask (JSON), or allow (exit 0)
4. **Enforcement**: Claude Code respects the hook's decision

```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────┐
│ Claude attempts │────▶│ damage-control.py│────▶│ patterns.yaml│
│ tool use        │     │ (PreToolUse)     │     │             │
└─────────────────┘     └──────────────────┘     └─────────────┘
                               │
                               ▼
                    ┌─────────────────────┐
                    │ block │ ask │ allow │
                    └─────────────────────┘
```

## Layered Defense

This module provides **defense in depth** with multiple layers:

1. **Hooks (Primary)**: PreToolUse hooks catch commands before execution
2. **Permissions (Backup)**: `deny` rules in settings.json as fallback
3. **CLAUDE.md (Instructions)**: Document rules Claude should follow
4. **Git/Backups (Recovery)**: Time Machine, git reflog for recovery

⚠️ **Important**: Hooks are the most reliable enforcement mechanism. There have been
[reported issues](https://github.com/anthropics/claude-code/issues/6699) with `deny` rules being bypassed, so hooks are
the primary defense.

## Troubleshooting

### Check if hooks are active

```bash
claude /hooks
```

### Test a pattern manually

```bash
echo '{"tool_name": "Bash", "tool_input": {"command": "rm -rf /"}}' | python3 damage-control.py
```

### Debug mode

```bash
claude --debug
```

### Common Issues

| Issue               | Solution                                               |
| ------------------- | ------------------------------------------------------ |
| Hook not triggering | Check `matcher` matches tool name exactly              |
| PyYAML not found    | `pip install pyyaml` or patterns will use basic parser |
| Permission denied   | Ensure `damage-control.py` is executable               |

## Sources & Credits

This module synthesizes patterns from:

- [claude-code-damage-control](https://github.com/disler/claude-code-damage-control) by @disler
- [destructive_command_guard](https://github.com/Dicklesworthstone/destructive_command_guard) by @Dicklesworthstone
- [Claude Code Official Docs](https://code.claude.com/docs/en/hooks.md)
- [Backslash Security Best Practices](https://www.backslash.security/blog/claude-code-security-best-practices)

## License

MIT - Use freely, stay safe.
