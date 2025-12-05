# Network Utilities

_Diagnose and monitor connections_

Network debugging shouldn't require a degree in networking. These utilities make it straightforward.

## Port Investigation

### `port` — What's Using a Port?

Find what's listening on a specific port:

```bash
port 3000
# ▸ PID: 12345
# ▸ Process: node
# ▸ User: bliss
# ▸ Command: node server.js
```

Cross-platform (uses lsof, ss, or netstat depending on availability).

The first command to run when "port already in use" errors appear.

### `ports` — All Listening Ports

See everything listening:

```bash
ports
# ━━━ Listening Ports ━━━
# PORT    PID     PROCESS     USER
# 22      1234    sshd        root
# 3000    5678    node        bliss
# 5432    9012    postgres    postgres
# 8080    3456    nginx       www-data
```

Quick overview of all services accepting connections.

## Connectivity Testing

### `netcheck` — Full Connectivity Test

Comprehensive network diagnostics:

```bash
netcheck
# ━━━ Network Check ━━━
# ✓ DNS Resolution: OK (1.1.1.1)
# ✓ Gateway: OK (192.168.1.1)
# ✓ Internet: OK (google.com)
```

Three-stage test:

1. DNS resolution (can we resolve domain names?)
2. Gateway reachability (can we reach our router?)
3. Internet connectivity (can we reach the internet?)

Run this first when debugging network issues. Pinpoints where the problem is.

## Interface Information

### `netif` — Active Interfaces

Network interface details:

```bash
netif
# ━━━ Network Interfaces ━━━
# ▸ en0 (WiFi)
#   └─ IP: 192.168.1.100
#   └─ MAC: aa:bb:cc:dd:ee:ff
# ▸ lo0 (Loopback)
#   └─ IP: 127.0.0.1
```

Quick way to find your local IP address.

### `wifi` — WiFi Details (macOS)

WiFi status and signal strength:

```bash
wifi
# ━━━ WiFi ━━━
# ▸ SSID: MyNetwork
# ▸ BSSID: 00:11:22:33:44:55
# ▸ Channel: 36
# ▸ Signal: -45 dBm
# [████████████████░░░░] 80%
```

Visual signal strength bar. macOS only.

Signal quality:

- -30 dBm: Excellent (100%)
- -50 dBm: Good (75%)
- -70 dBm: Fair (50%)
- -80 dBm: Poor (25%)

## Connection Monitoring

### `connections` — Active Connections

See all network connections:

```bash
connections        # All protocols
connections tcp    # TCP only
connections udp    # UDP only
```

Shows:

- Protocol (TCP/UDP)
- Local address and port
- Remote address and port
- Connection state (ESTABLISHED, LISTEN, etc.)

Useful for seeing what your machine is talking to.

## Bandwidth Monitoring

### `bandwidth` — Live Bandwidth Usage

Real-time network usage:

```bash
bandwidth
# Opens: nload, iftop, or nethogs (whichever is available)
```

Priority order:

1. `nload` — Simple bandwidth graph (recommended)
2. `iftop` — Connection-based view
3. `nethogs` — Process-based view

Install one for live monitoring:

```bash
# macOS
brew install nload

# Linux
sudo apt install nload
# or: sudo pacman -S nload
```

## Quick Aliases

| Alias            | Command         | Description                  |
| ---------------- | --------------- | ---------------------------- |
| `lsof-net`       | `lsof -i -P -n` | All network file descriptors |
| `netstat-listen` | `netstat -tlnp` | Listening sockets (Linux)    |
| `ss-listen`      | `ss -tlnp`      | Listening sockets (modern)   |

`ss` is faster than `netstat`. Use it on modern Linux systems.

## Workflows

### "Port Already in Use" Error

```bash
# Find what's using the port
port 8080

# Kill it if it's stale
kill <PID>

# Or find and kill in one go
pk node  # Kill all node processes
```

### Debug Network Issues

```bash
# Start with connectivity check
netcheck

# If DNS fails: flush DNS cache
flushdns  # macOS

# If gateway fails: check interface
netif

# If internet fails but gateway works: ISP issue

# Check signal strength (WiFi)
wifi
```

### Find Your Local IP

```bash
# Quick method
netif

# Or specific interface
ifconfig en0 | grep inet
# or: ip addr show wlan0  # Linux
```

### Monitor Suspicious Activity

```bash
# See all connections
connections

# Find specific remote host
connections | grep 93.184.216.34

# Live bandwidth monitoring
bandwidth
```

### Debug Slow Network

```bash
# Check if it's WiFi signal
wifi

# Monitor bandwidth usage
bandwidth

# Check what's using network
nethogs  # Shows per-process usage
```

## Pro Tips

**Use `port` first**: 90% of port issues are solved by finding and killing the process using it.

**Trust `netcheck`**: It pinpoints the problem layer. DNS vs gateway vs internet issues need different solutions.

**Monitor bandwidth**: If things are slow, run `bandwidth`. Often reveals a background process hogging the connection.

**WiFi signal matters**: Below -70 dBm and you'll have issues. Move closer to the router or use ethernet.

**`ss` over `netstat`**: On modern Linux, `ss` is faster and has better filtering options.

**Kill stale processes**: If `port 3000` shows a process but you're not running anything, kill it. Probably a zombie
from a crashed dev server.

**Know your local IP**: Use `netif` to quickly grab it for SSH or local testing.

**Use proper tools**: Install `nload` or `iftop` for serious network monitoring. The scripts are for quick checks.
