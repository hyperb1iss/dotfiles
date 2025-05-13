# docker.sh
# Comprehensive Docker utilities for bash and zsh

# Skip on minimal installations
is_minimal && return 0

# Docker Aliases
alias d='docker'
alias dc='docker compose'
alias dps='docker ps'
alias dpsa='docker ps -a'
alias di='docker images'
alias dex='docker exec -it'
alias dlogs='docker logs'
alias dprune='docker system prune -f'
alias dstop='docker stop'
alias drm='docker rm'
alias drmi='docker rmi'
alias dcp='docker container prune -f'
alias dip='docker image prune -f'
alias dvp='docker volume prune -f'
alias dnp='docker network prune -f'

# Enhanced Docker Functions

# Interactive docker exec into running container
function dexec() {
  local container

  container=$(docker ps --format '{{.Names}}' | fzf --height 40% --reverse --prompt="Select container > ") || return 0

  if [[ -n "${container}" ]]; then
    docker exec -it "${container}" bash || docker exec -it "${container}" sh
  fi
}

# Interactive docker logs with follow
function dlf() {
  local container

  container=$(docker ps --format '{{.Names}}' | fzf --height 40% --reverse --prompt="Select container > ") || return 0

  if [[ -n "${container}" ]]; then
    docker logs -f "${container}"
  fi
}

# Interactive docker stop
function dstopi() {
  local containers

  containers=$(docker ps --format '{{.Names}}' | fzf -m --height 40% --reverse --prompt="Select containers to stop > ") || return 0

  if [[ -n "${containers}" ]]; then
    # shellcheck disable=SC2086
    echo "${containers}" | xargs docker stop
    echo "Stopped containers:"
    while IFS= read -r container; do
      echo "  ${container}"
    done <<< "${containers}"
  fi
}

# Interactive docker rm for stopped containers
function drmi() {
  local containers

  containers=$(docker ps -a --filter "status=exited" --format '{{.Names}}' | fzf -m --height 40% --reverse --prompt="Select containers to remove > ") || return 0

  if [[ -n "${containers}" ]]; then
    # shellcheck disable=SC2086
    echo "${containers}" | xargs docker rm
    echo "Removed containers:"
    while IFS= read -r container; do
      echo "  ${container}"
    done <<< "${containers}"
  fi
}

# Get container IP address
function dip() {
  local container="$1"

  if [[ -z "${container}" ]]; then
    container=$(docker ps --format '{{.Names}}' | fzf --height 40% --reverse --prompt="Select container > ") || return 0
  fi

  if [[ -n "${container}" ]]; then
    docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}"
  fi
}

# Docker compose helper with fuzzy finding
function dcr() {
  local service

  if [[ -f "docker-compose.yml" ]]; then
    service=$(docker compose config --services | fzf --height 40% --reverse --prompt="Select service > ") || return 0

    if [[ -n "${service}" ]]; then
      docker compose restart "${service}"
    fi
  else
    echo "No docker-compose.yml found in current directory"
  fi
}

# Show container resource usage
function dstats() {
  docker stats --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Clean up Docker system
function dclean() {
  echo "Cleaning up Docker system..."
  docker system prune -f
  docker volume prune -f
  docker network prune -f
  echo "Docker cleanup complete!"
}
