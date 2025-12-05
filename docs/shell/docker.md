# Docker

_Container management with style_

Managing containers shouldn't require memorizing 16-character hexadecimal IDs. These utilities make Docker feel
intuitive.

## Aliases

### Core Commands

| Alias  | Command          | Description          |
| ------ | ---------------- | -------------------- |
| `d`    | `docker`         | Because 6 letters... |
| `dc`   | `docker compose` | Compose CLI          |
| `dps`  | `docker ps`      | List running         |
| `dpsa` | `docker ps -a`   | List all containers  |
| `di`   | `docker images`  | List images          |

### Container Operations

| Alias   | Command           | Description      |
| ------- | ----------------- | ---------------- |
| `dex`   | `docker exec -it` | Interactive exec |
| `dlogs` | `docker logs`     | View logs        |
| `dstop` | `docker stop`     | Stop container   |
| `drm`   | `docker rm`       | Remove container |
| `drmi`  | `docker rmi`      | Remove image     |

### Cleanup

| Alias    | Command                  | Description            |
| -------- | ------------------------ | ---------------------- |
| `dprune` | `docker system prune -f` | Prune everything       |
| `dcp`    | Container prune          | Remove stopped         |
| `dip`    | Image prune              | Remove dangling images |
| `dvp`    | Volume prune             | Remove unused volumes  |
| `dnp`    | Network prune            | Remove unused networks |

Run `dprune` weekly to reclaim disk space. Docker accumulates cruft fast.

## Interactive Functions

All these leverage fzf for container/service selection. No more copying container IDs.

### `dexec` — Interactive Exec

Shell into a running container:

```bash
dexec
# fzf list of running containers
# Select one, hit Enter
# Tries bash, falls back to sh if unavailable
```

The most-used Docker command, now friction-free.

### `dlf` — Interactive Logs Follow

Tail logs from any container:

```bash
dlf
# Select container
# Shows logs with -f (follow mode)
# Ctrl-C to exit
```

### `dstopi` — Interactive Stop

Stop containers with multi-select:

```bash
dstopi
# Multi-select containers with Tab
# Enter to stop all selected
# Also removes them after stopping
```

### `drmi` — Interactive Remove

Clean up exited containers:

```bash
drmi
# Shows only exited containers
# Multi-select with Tab
# Enter to remove
```

Note: This is the function `drmi`, not the alias. The alias removes images, the function removes containers. Yeah, it's
confusing. Use the function.

### `dip` — Get Container IP

Find a container's IP address:

```bash
dip              # Interactive selection
dip my-container # Direct lookup
```

Useful for debugging networking or connecting to services.

### `dcr` — Docker Compose Restart

Restart a service from your docker-compose.yml:

```bash
dcr
# Shows all services from compose file
# Select one to restart
```

Only works if there's a `docker-compose.yml` in the current directory.

## Utility Functions

### `dstats` — Container Stats

Live resource usage for all running containers:

```bash
dstats
# Shows: Name, CPU%, Memory Usage, Network I/O, Block I/O
# Updates continuously (like `docker stats`)
```

Press Ctrl-C to exit.

### `dclean` — Full Cleanup

Nuclear option for disk space:

```bash
dclean
# Runs:
#   docker system prune -f
#   docker volume prune -f
#   docker network prune -f
# Removes all unused data
```

Use when you need to reclaim serious space. Be careful—this is destructive.

## Compose Workflows

Common docker-compose patterns:

### Starting Services

```bash
dc up -d              # Start in background
dc up -d --build      # Rebuild and start
```

### Viewing Logs

```bash
dc logs -f            # All services, follow mode
dc logs -f api        # Specific service
dc logs --tail=100 api # Last 100 lines
```

### Restarting Services

```bash
dcr                   # Interactive selection
dc restart api        # Direct restart
```

### Stopping Everything

```bash
dc down               # Stop all services
dc down -v            # Stop and remove volumes (destructive!)
```

## Common Patterns

### Quick Container Shell

```bash
# Direct approach (if you know the name)
dex my-container bash

# Interactive (if you don't)
dexec
```

### Follow Logs

```bash
# Direct
dlogs -f my-container

# Interactive
dlf
```

### Cleanup After Development

```bash
# Stop compose services
dc down

# Remove all unused resources
dclean
```

Free up 10GB instantly.

### Debug a Container

```bash
# Check if it's running
dps

# Shell into it
dexec
# or: dex <container> bash

# Inside the container:
ps aux              # Check processes
env                 # Check environment
cat /etc/os-release # Check base image
```

### Port Mapping Check

```bash
dps
# Look at PORTS column
# Or get detailed info:
d inspect <container> | grep -A 10 Ports
```

### Image Cleanup

```bash
# List images
di

# Remove specific image
drmi <image-id>

# Remove dangling images
dip

# Remove all unused images
docker image prune -a
```

## Compose Multi-Environment

If you use multiple compose files:

```bash
# Development
dc -f docker-compose.yml -f docker-compose.dev.yml up -d

# Production
dc -f docker-compose.yml -f docker-compose.prod.yml up -d

# Alias these in your ~/.rc.local
alias dcdev='dc -f docker-compose.yml -f docker-compose.dev.yml'
alias dcprod='dc -f docker-compose.yml -f docker-compose.prod.yml'
```

## Pro Tips

**Use `dexec` liberally**: Shell into containers to debug. It's faster than reading logs alone.

**`dstats` for performance issues**: If something's slow, run `dstats` first. Often reveals CPU/memory hogs immediately.

**Prune regularly**: Run `dprune` weekly. Docker accumulates stopped containers and dangling images fast.

**Name your containers**: Use `container_name` in compose files. Makes `dps` output readable.

**Check logs first**: 90% of container issues are in the logs. `dlf` makes this painless.

**Compose down vs stop**: Use `down` to clean up properly. `stop` leaves containers around.
