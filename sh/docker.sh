# docker.sh
# ⚡ Docker utilities with SilkCircuit energy

# Skip on minimal installations
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2>/dev/null || true

# ─────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────

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
alias dcp='docker container prune -f'
alias dvp='docker volume prune -f'
alias dnp='docker network prune -f'

# ─────────────────────────────────────────────────────────────
# Interactive Functions
# ─────────────────────────────────────────────────────────────

# Interactive docker exec into running container
function dexec() {
  __sc_init_colors
  local container

  container=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' |
    fzf --height 50% --reverse \
      --header="⚡ Select container to exec into" \
      --prompt="container ▸ " \
      --preview 'docker inspect {1} | head -50' \
      --preview-window=right:40% |
    awk '{print $1}') || return 0

  if [[ -n "${container}" ]]; then
    sc_info "Connecting to ${SC_CYAN}${container}${SC_RESET}..."
    docker exec -it "${container}" bash 2>/dev/null || docker exec -it "${container}" sh
  fi
}

# Interactive docker logs with follow
function dlf() {
  __sc_init_colors
  local container

  container=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' |
    fzf --height 50% --reverse \
      --header="⚡ Select container for logs" \
      --prompt="logs ▸ " \
      --preview 'docker logs --tail 20 {1} 2>&1' \
      --preview-window=right:50% |
    awk '{print $1}') || return 0

  if [[ -n "${container}" ]]; then
    sc_info "Following logs for ${SC_CYAN}${container}${SC_RESET}..."
    echo ""
    docker logs -f "${container}"
  fi
}

# Interactive docker stop
function dstopi() {
  __sc_init_colors
  local containers

  containers=$(docker ps --format '{{.Names}}\t{{.Image}}\t{{.Status}}' |
    fzf -m --height 50% --reverse \
      --header="⚡ Select containers to stop (TAB to multi-select)" \
      --prompt="stop ▸ " \
      --preview 'docker inspect {1} | head -30' |
    awk '{print $1}') || return 0

  if [[ -n "${containers}" ]]; then
    sc_header "Stopping Containers"
    echo ""
    while IFS= read -r container; do
      [[ -z "${container}" ]] && continue
      echo -ne "  ${SC_PURPLE}▸${SC_RESET} ${container}... "
      if docker stop "${container}" >/dev/null 2>&1; then
        echo -e "${SC_GREEN}stopped${SC_RESET}"
      else
        echo -e "${SC_RED}failed${SC_RESET}"
      fi
    done <<<"${containers}"
    echo ""
    sc_success "Done"
  fi
}

# Interactive docker rm for stopped containers
function drmi() {
  __sc_init_colors
  local containers

  containers=$(docker ps -a --filter "status=exited" --format '{{.Names}}\t{{.Image}}\t{{.Status}}' |
    fzf -m --height 50% --reverse \
      --header="⚡ Select stopped containers to remove (TAB to multi-select)" \
      --prompt="remove ▸ " |
    awk '{print $1}') || return 0

  if [[ -n "${containers}" ]]; then
    sc_header "Removing Containers"
    echo ""
    while IFS= read -r container; do
      [[ -z "${container}" ]] && continue
      echo -ne "  ${SC_PURPLE}▸${SC_RESET} ${container}... "
      if docker rm "${container}" >/dev/null 2>&1; then
        echo -e "${SC_GREEN}removed${SC_RESET}"
      else
        echo -e "${SC_RED}failed${SC_RESET}"
      fi
    done <<<"${containers}"
    echo ""
    sc_success "Done"
  fi
}

# Get container IP address
function dip() {
  __sc_init_colors
  local container="$1"

  if [[ -z "${container}" ]]; then
    container=$(docker ps --format '{{.Names}}\t{{.Image}}' |
      fzf --height 40% --reverse \
        --header="⚡ Select container" \
        --prompt="ip ▸ " |
      awk '{print $1}') || return 0
  fi

  if [[ -n "${container}" ]]; then
    local ip
    ip=$(docker inspect -f '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' "${container}")
    if [[ -n "${ip}" ]]; then
      sc_label "Container" "${container}"
      sc_label "IP Address" "${ip}"
    else
      sc_warn "No IP address found for ${container}"
    fi
  fi
}

# Docker compose helper with fuzzy finding
function dcr() {
  __sc_init_colors
  local service

  if [[ -f "docker-compose.yml" ]] || [[ -f "docker-compose.yaml" ]] || [[ -f "compose.yml" ]]; then
    service=$(docker compose config --services |
      fzf --height 40% --reverse \
        --header="⚡ Select service to restart" \
        --prompt="service ▸ ") || return 0

    if [[ -n "${service}" ]]; then
      sc_info "Restarting ${SC_CYAN}${service}${SC_RESET}..."
      docker compose restart "${service}"
      sc_success "Service restarted"
    fi
  else
    sc_error "No docker-compose.yml found in current directory"
  fi
}

# ─────────────────────────────────────────────────────────────
# Information & Stats
# ─────────────────────────────────────────────────────────────

# Show container resource usage with style
function dstats() {
  __sc_init_colors
  sc_header "Container Resources"
  echo ""
  docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.NetIO}}\t{{.BlockIO}}"
}

# Show Docker system overview
function dinfo() {
  __sc_init_colors

  sc_header "Docker System Overview"
  echo ""

  # Containers
  local running stopped total
  running=$(docker ps -q 2>/dev/null | wc -l | tr -d ' ')
  stopped=$(docker ps -aq --filter "status=exited" 2>/dev/null | wc -l | tr -d ' ')
  total=$(docker ps -aq 2>/dev/null | wc -l | tr -d ' ')

  echo -e "${SC_CYAN}•${SC_RESET} Containers: ${SC_GREEN}${running} running${SC_RESET}, ${SC_YELLOW}${stopped} stopped${SC_RESET}, ${SC_GRAY}${total} total${SC_RESET}"

  # Images
  local images
  images=$(docker images -q 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${SC_CYAN}•${SC_RESET} Images: ${SC_PINK}${images}${SC_RESET}"

  # Volumes
  local volumes
  volumes=$(docker volume ls -q 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${SC_CYAN}•${SC_RESET} Volumes: ${SC_CORAL}${volumes}${SC_RESET}"

  # Networks
  local networks
  networks=$(docker network ls -q 2>/dev/null | wc -l | tr -d ' ')
  echo -e "${SC_CYAN}•${SC_RESET} Networks: ${SC_CYAN}${networks}${SC_RESET}"

  echo ""

  # Disk usage
  sc_info "Disk Usage"
  docker system df 2>/dev/null | tail -n +2 | while read -r line; do
    local type size reclaimable
    type=$(echo "${line}" | awk '{print $1}')
    size=$(echo "${line}" | awk '{print $3}')
    reclaimable=$(echo "${line}" | awk '{print $5}')
    echo -e "  ${SC_PURPLE}▸${SC_RESET} ${type}: ${SC_YELLOW}${size}${SC_RESET} ${SC_GRAY}(${reclaimable} reclaimable)${SC_RESET}"
  done
}

# ─────────────────────────────────────────────────────────────
# Cleanup
# ─────────────────────────────────────────────────────────────

# Clean up Docker system with visual feedback
function dclean() {
  __sc_init_colors

  sc_header "Docker Cleanup"
  echo ""

  # Containers
  echo -ne "  ${SC_PURPLE}▸${SC_RESET} Pruning containers... "
  local containers_removed
  containers_removed=$(docker container prune -f 2>&1 | grep -oE '[0-9]+' | head -1)
  echo -e "${SC_GREEN}${containers_removed:-0} removed${SC_RESET}"

  # Images
  echo -ne "  ${SC_PURPLE}▸${SC_RESET} Pruning images... "
  local images_removed
  images_removed=$(docker image prune -f 2>&1 | grep -oE '[0-9]+' | head -1)
  echo -e "${SC_GREEN}${images_removed:-0} removed${SC_RESET}"

  # Volumes
  echo -ne "  ${SC_PURPLE}▸${SC_RESET} Pruning volumes... "
  local volumes_removed
  volumes_removed=$(docker volume prune -f 2>&1 | grep -oE '[0-9]+' | head -1)
  echo -e "${SC_GREEN}${volumes_removed:-0} removed${SC_RESET}"

  # Networks
  echo -ne "  ${SC_PURPLE}▸${SC_RESET} Pruning networks... "
  local networks_removed
  networks_removed=$(docker network prune -f 2>&1 | grep -oE '[0-9]+' | head -1)
  echo -e "${SC_GREEN}${networks_removed:-0} removed${SC_RESET}"

  echo ""

  # Show reclaimed space
  local reclaimed
  reclaimed=$(docker system df 2>/dev/null | awk 'NR>1 {sum+=$4} END {print sum}')
  sc_success "Cleanup complete"
}

# Deep clean - removes everything unused
function dclean!() {
  __sc_init_colors

  sc_header "Docker Deep Clean"
  sc_warn "This will remove ALL unused containers, images, volumes, and networks!"
  echo ""

  echo -ne "Continue? [y/N] "
  read -r confirm
  if [[ "${confirm}" =~ ^[Yy]$ ]]; then
    echo ""
    sc_info "Running deep clean..."
    docker system prune -af --volumes
    echo ""
    sc_success "Deep clean complete"
  else
    sc_muted "Cancelled"
  fi
}
