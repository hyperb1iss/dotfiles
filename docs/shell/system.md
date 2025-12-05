# System Utilities

_Know your machine inside and out_

System monitoring and health checks with SilkCircuit styling. Because guessing what your machine is doing is for
amateurs.

## System Overview

### `sys` — Full System Info

Everything at a glance:

```bash
sys
# Displays: hostname, CPU, memory, disk, GPU, battery
# Complete system overview in one command
```

Your system dashboard in the terminal.

### `sysinfo` — Basic Info

Formatted system information:

```bash
sysinfo
# ━━━ System Info ━━━
# ▸ Hostname: MacBook-Pro
# ▸ User: bliss
# ▸ Shell: /bin/zsh
# ▸ OS: macOS 14.6
# ▸ Kernel: Darwin 24.6.0
# ▸ Arch: arm64
# ▸ Uptime: 3 days, 4:20
# ▸ Load: 1.50 2.00 1.80
```

Great for bug reports or showing off your uptime.

### `health` — Quick Health Check

Color-coded system health status:

```bash
health
# ✓ CPU Load: 15% (normal)
# ✓ Memory: 45% used (8.0G/16.0G)
# ⚠ Disk /: 82% used
# ✓ Temperature: 45°C
```

Status indicators:

- Green checkmark: Normal
- Yellow warning: Needs attention
- Red cross: Critical

Run this when things feel slow. Usually reveals the culprit instantly.

## Resource Monitoring

### `cpuinfo` — CPU Details

Processor information and current usage:

```bash
cpuinfo
# ━━━ CPU ━━━
# ▸ Model: Apple M2 Pro
# ▸ Cores: 10
# ▸ Usage: 12%
```

### `meminfo` — Memory Usage

Visual memory consumption:

```bash
meminfo
# ━━━ Memory ━━━
# ▸ Total: 16.0G
# ▸ Used: 8.5G (53%)
# ▸ Free: 7.5G
# [████████████░░░░░░░░] 53%
```

Progress bar changes color based on usage:

- Green: < 70%
- Yellow: 70-85%
- Red: > 85%

### `diskinfo` — Disk Usage

All mounted filesystems:

```bash
diskinfo
# ━━━ Disk Usage ━━━
# /          [████████████████░░░░] 78%  234G/300G
# /Volumes/Data [██████░░░░░░░░░░░░░░] 28%  140G/500G
```

Visual bars make it obvious which disk needs attention.

### `gpuinfo` — GPU Information

Graphics processor details:

```bash
gpuinfo
# ━━━ GPU ━━━
# ▸ Apple M2 Pro (integrated)
# ▸ Metal: Supported
```

Platform-aware:

- macOS: Integrated/discrete GPU info
- Linux: nvidia-smi output if available

### `battery` — Battery Status

Power status with visual indicator:

```bash
battery
# ━━━ Battery ━━━
# ▸ Status: Charging
# ▸ Level: 78%
# [███████████████░░░░░] 78%
# ▸ Time: 2:30 remaining
```

macOS only. Shows time remaining (charging or discharging).

## Temperature Monitoring

### `temps` — System Temperatures

Thermal information:

```bash
temps
# ━━━ Temperatures ━━━
# ▸ CPU: 52°C
# ▸ GPU: 48°C
# ▸ SSD: 35°C
```

Platform-specific tools:

- macOS: `powermetrics` or `osx-cpu-temp`
- Linux: `lm-sensors`

Useful when diagnosing thermal throttling or fan noise.

## Service Management

### `services` — Service Status

Running services overview:

```bash
services
# ━━━ Services ━━━
# ▸ postgresql: running
# ▸ redis: running
# ▸ nginx: stopped
```

Platform-aware:

- macOS: `brew services` and `launchctl`
- Linux: `systemctl`

## Network Utilities

Quick reference (see [Network](./network) docs for full details):

| Command     | Description               |
| ----------- | ------------------------- |
| `port 3000` | What's using port 3000?   |
| `ports`     | All listening ports       |
| `netcheck`  | Full connectivity test    |
| `netif`     | Active network interfaces |
| `wifi`      | WiFi info (macOS)         |

## Process Management

Quick reference (see [Process](./process) docs for full details):

| Command      | Description                |
| ------------ | -------------------------- |
| `pmem`       | Top 10 processes by memory |
| `pcpu`       | Top 10 processes by CPU    |
| `pfind node` | Find processes by name     |
| `pk pattern` | Kill matching processes    |

## Platform Detection

Used internally by system scripts:

```bash
is_macos && echo "On macOS"
is_linux && echo "On Linux"
is_wsl && echo "In WSL"
```

Scripts use these to provide platform-specific functionality.

## Color Coding

All output uses the SilkCircuit palette:

| Color           | Meaning            | Example         |
| --------------- | ------------------ | --------------- |
| Neon Cyan       | Labels, headers    | Function names  |
| Electric Purple | Markers            | Current item    |
| Success Green   | Good/normal values | < 70% disk use  |
| Electric Yellow | Warnings           | 70-85% disk use |
| Error Red       | Errors/critical    | > 85% disk use  |

Consistent color usage makes output scannable at a glance.

## Workflows

### Morning System Check

```bash
# Quick health overview
health

# If something looks off, dig deeper
meminfo    # Memory hog?
diskinfo   # Disk full?
temps      # Running hot?
```

### Debugging Slowness

```bash
# CPU bottleneck?
pcpu

# Memory bottleneck?
pmem

# Disk I/O?
diskinfo

# Network issue?
netcheck
```

### Before Deploying

```bash
# System healthy?
health

# Services running?
services

# Disk space adequate?
diskinfo
```

### Monitoring a Long-Running Process

```bash
# Start watch mode
watch -n 2 'meminfo && echo && cpuinfo'

# Or use htop/btop for live monitoring
htop
```

## Pro Tips

**Run `health` daily**: Make it part of your morning routine. Catches issues before they become problems.

**Watch disk usage**: Run `diskinfo` weekly. Disks fill up faster than you think.

**Temperature monitoring**: If fans are loud, check `temps`. Thermal throttling kills performance.

**Service management**: Use `services` to verify databases and servers are running before debugging app issues.

**Color indicators**: Trust the colors. Yellow = investigate soon. Red = investigate now.

**Platform-aware scripts**: These utilities work on macOS, Linux, and WSL. Same commands, different implementations.

**Combine with tmux**: Keep a tmux pane with `watch health` running. Passive monitoring while you work.

**Use htop/btop**: For continuous monitoring, dedicated tools like htop or btop (modern htop) are better than scripts.
