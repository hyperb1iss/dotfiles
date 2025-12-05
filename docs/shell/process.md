# Process Management

_Find and control running processes_

Process management made simple. No more grepping through ps output.

## Modern Process Viewer

If [procs](https://github.com/dalance/procs) is installed, it's used automatically for enhanced output with colors and
better formatting.

### `pme` — My Processes

Show processes owned by current user:

```bash
pme
# Lists your processes
# Uses procs if available, falls back to ps
```

Filters out system processes you don't care about.

### `ptree` — Process Tree

Hierarchical process view:

```bash
ptree
# Shows parent-child process relationships
# Useful for understanding process spawning
```

See what spawned what. Great for debugging daemon issues.

### `pwatch` — Live Monitoring

Continuous process monitoring:

```bash
pwatch
# Like top, but filtered to your processes
# Refreshes automatically
# Ctrl-C to exit
```

## Finding Processes

### `pfind` — Search by Name

Find processes by name pattern:

```bash
pfind node
# Lists all processes matching "node"
# Shows PID, CPU%, memory, command
```

Case-insensitive search through process names and arguments.

### `pgrep_custom` — Full Command Search

Search through complete command lines:

```bash
pgrep_custom webpack
# Shows full command line for matching processes
# Useful when process names aren't unique
```

## Resource Usage

### `pmem` — Top Memory Users

Top 10 processes by memory:

```bash
pmem
# Sorted by memory usage descending
# Shows: PID, %MEM, RSS, COMMAND
```

First command to run when system feels sluggish and you suspect memory issues.

### `pcpu` — Top CPU Users

Top 10 processes by CPU:

```bash
pcpu
# Sorted by CPU usage descending
# Shows: PID, %CPU, COMMAND
```

Find what's burning your CPU.

## Killing Processes

### `pk` — Pattern Kill

Kill processes matching a pattern:

```bash
pk node
# Finds all processes matching "node"
# Asks for confirmation
# Kills them (SIGTERM)
```

Safer than `killall` because it shows you what it's about to kill.

### `fkill` — Interactive Kill (fzf)

Multi-select processes to kill:

```bash
fkill
# fzf interface showing all processes
# Tab to multi-select
# Enter to kill selected (SIGTERM)
```

Most user-friendly way to kill processes. See what you're killing before you kill it.

## Workflows

### Find and Kill a Process

```bash
# Find it
pfind runaway-app
# Note the PID

# Kill it
kill 12345

# Or use pattern kill
pk runaway-app

# Or interactive
fkill
# Search, select, kill
```

### Debug Resource Issues

```bash
# High memory usage?
pmem
# Check top consumers

# High CPU usage?
pcpu
# Find the culprit

# Both?
htop  # Or use a proper monitoring tool
```

### Monitor Process Over Time

```bash
# Watch specific process
watch -n 1 'ps aux | grep myapp'

# Or use pwatch for all your processes
pwatch

# For serious monitoring
htop  # Interactive
btop  # Modern alternative
```

### Kill Stubborn Process

```bash
# Try gentle termination first
kill 12345

# Wait a few seconds...

# Still running? Force it
kill -9 12345

# Or use pk with force
pk -9 pattern
```

### Find Process Using a File

```bash
# What's using this file?
lsof /path/to/file

# What's using this directory?
lsof +D /path/to/dir

# Who has the camera?
lsof | grep -i camera
```

### Debug Zombie Processes

```bash
# Find zombies
ps aux | grep Z

# Find their parent
ps -o ppid= -p <zombie-pid>

# Kill the parent (zombies can't be killed directly)
kill <parent-pid>
```

## Pro Tips

**Use `fkill` for safety**: Interactive selection prevents accidents. See what you're killing.

**`pmem` and `pcpu` first**: Before opening htop, run these. Often they're all you need.

**Pattern matching is powerful**: `pk node` kills all node processes. Use carefully.

**SIGTERM before SIGKILL**: Let processes clean up. Only use `-9` when necessary.

**Watch for memory leaks**: If a process's memory keeps growing, it's probably leaking. Restart it.

**htop/btop for continuous monitoring**: These scripts are for quick checks. Use proper tools for extended monitoring.

**Zombie processes**: Can't be killed directly. Kill their parent process.

**Use `lsof` for file locks**: "File in use" errors? `lsof` shows what has it open.

**Parent-child relationships matter**: Use `ptree` to understand process hierarchies before killing things.
