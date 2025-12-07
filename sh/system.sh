# system.sh
# ⚡ System information utilities with SilkCircuit energy

# Skip on minimal installations
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2>/dev/null || true

# ─────────────────────────────────────────────────────────────
# System Information
# ─────────────────────────────────────────────────────────────

# Show system overview with style
function sysinfo() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ System Information${SC_RESET}"
  echo ""

  # Hostname and User
  echo -e "${SC_CYAN}•${SC_RESET} Host: ${SC_YELLOW}$(hostname)${SC_RESET}"
  echo -e "${SC_CYAN}•${SC_RESET} User: ${SC_PINK}$(whoami)${SC_RESET}"
  echo -e "${SC_CYAN}•${SC_RESET} Shell: ${SC_GREEN}$(basename "$SHELL")${SC_RESET} ${SC_GRAY}$(${SHELL} --version 2>/dev/null | head -1 | awk '{print $NF}')${SC_RESET}"
  echo ""

  # OS Information
  if is_macos; then
    local os_version
    os_version=$(sw_vers -productVersion)
    local os_build
    os_build=$(sw_vers -buildVersion)
    local os_name
    os_name=$(sw_vers -productName)
    echo -e "${SC_CYAN}•${SC_RESET} OS: ${SC_YELLOW}${os_name} ${os_version}${SC_RESET} ${SC_GRAY}(${os_build})${SC_RESET}"

    # Hardware info
    local model
    model=$(sysctl -n hw.model 2>/dev/null)
    [[ -n "${model}" ]] && echo -e "${SC_CYAN}•${SC_RESET} Model: ${SC_PINK}${model}${SC_RESET}"
  else
    # Linux version
    if [[ -f /etc/os-release ]]; then
      source /etc/os-release
      echo -e "${SC_CYAN}•${SC_RESET} OS: ${SC_YELLOW}${PRETTY_NAME:-${NAME} ${VERSION}}${SC_RESET}"
    else
      echo -e "${SC_CYAN}•${SC_RESET} OS: ${SC_YELLOW}$(uname -s) $(uname -r)${SC_RESET}"
    fi

    # Hardware info
    if [[ -f /sys/devices/virtual/dmi/id/product_name ]]; then
      local model
      model=$(cat /sys/devices/virtual/dmi/id/product_name 2>/dev/null)
      [[ -n "${model}" ]] && echo -e "${SC_CYAN}•${SC_RESET} Model: ${SC_PINK}${model}${SC_RESET}"
    fi
  fi

  # Kernel
  echo -e "${SC_CYAN}•${SC_RESET} Kernel: ${SC_GREEN}$(uname -r)${SC_RESET}"
  echo -e "${SC_CYAN}•${SC_RESET} Arch: ${SC_PINK}$(uname -m)${SC_RESET}"
  echo ""

  # Uptime
  if is_macos; then
    local boot_time
    boot_time=$(sysctl -n kern.boottime | awk '{print $4}' | sed 's/,//')
    local current_time
    current_time=$(date +%s)
    local uptime_seconds=$((current_time - boot_time))
    local days=$((uptime_seconds / 86400))
    local hours=$(((uptime_seconds % 86400) / 3600))
    local minutes=$(((uptime_seconds % 3600) / 60))
    echo -e "${SC_CYAN}•${SC_RESET} Uptime: ${SC_YELLOW}${days}d ${hours}h ${minutes}m${SC_RESET}"
  else
    echo -e "${SC_CYAN}•${SC_RESET} Uptime: ${SC_YELLOW}$(uptime -p 2>/dev/null || uptime)${SC_RESET}"
  fi

  # Load average
  echo -e "${SC_CYAN}•${SC_RESET} Load: ${SC_GRAY}$(uptime | awk -F'load average:' '{print $2}')${SC_RESET}"
}

# CPU information with style
function cpuinfo() {
  echo "⚡ CPU Information"
  echo ""

  if is_macos; then
    # macOS CPU info
    local cpu_name
    cpu_name=$(sysctl -n machdep.cpu.brand_string 2>/dev/null)
    local cpu_cores
    cpu_cores=$(sysctl -n hw.ncpu 2>/dev/null)
    local cpu_freq
    cpu_freq=$(sysctl -n hw.cpufrequency_max 2>/dev/null | awk '{printf "%.2f GHz", $1/1000000000}')

    [[ -n "${cpu_name}" ]] && echo "• Model: ${cpu_name}"
    [[ -n "${cpu_cores}" ]] && echo "• Cores: ${cpu_cores}"
    [[ -n "${cpu_freq}" && "${cpu_freq}" != "0.00 GHz" ]] && echo "• Speed: ${cpu_freq}"

    # Temperature if available
    if has_command osx-cpu-temp; then
      local temp
      temp=$(osx-cpu-temp 2>/dev/null)
      [[ -n "${temp}" ]] && echo "• Temp: ${temp}"
    fi
  else
    # Linux CPU info
    if [[ -f /proc/cpuinfo ]]; then
      local cpu_name
      cpu_name=$(grep "model name" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs)
      local cpu_cores
      cpu_cores=$(grep -c "processor" /proc/cpuinfo)
      local cpu_freq
      cpu_freq=$(grep "cpu MHz" /proc/cpuinfo | head -1 | cut -d: -f2 | xargs | awk '{printf "%.2f GHz", $1/1000}')

      [[ -n "${cpu_name}" ]] && echo "• Model: ${cpu_name}"
      [[ -n "${cpu_cores}" ]] && echo "• Cores: ${cpu_cores}"
      [[ -n "${cpu_freq}" ]] && echo "• Speed: ${cpu_freq}"
    fi

    # Temperature if available
    if has_command sensors; then
      local temp
      temp=$(sensors 2>/dev/null | grep "Core 0" | awk '{print $3}')
      [[ -n "${temp}" ]] && echo "• Temp: ${temp}"
    fi
  fi

  # Current CPU usage
  echo ""
  echo "→ Current Usage:"
  if is_macos; then
    top -l 1 | grep "CPU usage" | awk '{printf "  User: %s  System: %s  Idle: %s\n", $3, $5, $7}'
  else
    top -bn1 | grep "Cpu(s)" | awk '{printf "  User: %.1f%%  System: %.1f%%  Idle: %.1f%%\n", $2, $4, $8}'
  fi
}

# Memory information with visual bars
function meminfo() {
  echo "⚡ Memory Information"
  echo ""

  if is_macos; then
    # macOS memory info
    local total_mem=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))
    local page_size
    page_size=$(sysctl -n hw.pagesize)
    local vm_stat
    vm_stat=$(vm_stat)

    local free_pages
    free_pages=$(echo "$vm_stat" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local inactive_pages
    inactive_pages=$(echo "$vm_stat" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    local speculative_pages
    speculative_pages=$(echo "$vm_stat" | grep "Pages speculative" | awk '{print $3}' | sed 's/\.//')

    local free_mem=$(((free_pages + inactive_pages + speculative_pages) * page_size / 1024 / 1024 / 1024))
    local used_mem=$((total_mem - free_mem))
    local percent=$(((used_mem * 100) / total_mem))

    echo "• Total: ${total_mem} GB"
    echo "• Used: ${used_mem} GB (${percent}%)"
    echo "• Free: ${free_mem} GB"
  else
    # Linux memory info
    local mem_info
    mem_info=$(free -h | grep "^Mem:")
    local total_mem
    total_mem=$(echo "${mem_info}" | awk '{print $2}')
    local used_mem
    used_mem=$(echo "${mem_info}" | awk '{print $3}')
    local free_mem
    free_mem=$(echo "${mem_info}" | awk '{print $4}')
    local available_mem
    available_mem=$(echo "${mem_info}" | awk '{print $7}')

    # Calculate percentage
    local total_kb
    total_kb=$(free | grep "^Mem:" | awk '{print $2}')
    local used_kb
    used_kb=$(free | grep "^Mem:" | awk '{print $3}')
    local percent=$(((used_kb * 100) / total_kb))

    echo "• Total: ${total_mem}"
    echo "• Used: ${used_mem} (${percent}%)"
    echo "• Free: ${free_mem}"
    [[ -n "${available_mem}" ]] && echo "• Available: ${available_mem}"
  fi

  # Visual bar
  echo ""
  echo -ne "${SC_CYAN}•${SC_RESET} Usage: ${SC_GRAY}[${SC_RESET}"
  local bar_length=30
  local filled=$(((percent * bar_length) / 100))
  local empty=$((bar_length - filled))

  # Color bar based on usage
  if [[ ${percent} -lt 50 ]]; then
    echo -ne "${SC_GREEN}"
  elif [[ ${percent} -lt 80 ]]; then
    echo -ne "${SC_YELLOW}"
  else
    echo -ne "${SC_RED}"
  fi

  for ((i = 0; i < filled; i++)); do echo -n "▰"; done
  echo -ne "${SC_GRAY}"
  for ((i = 0; i < empty; i++)); do echo -n "▱"; done
  echo -e "${SC_GRAY}]${SC_RESET} ${percent}%"

  # Swap info
  echo ""
  if is_macos; then
    local swap_usage
    swap_usage=$(sysctl vm.swapusage 2>/dev/null | awk '{print $7, $10, $13}')
    if [[ -n "${swap_usage}" ]]; then
      echo -e "${SC_CYAN}•${SC_RESET} Swap: ${SC_PINK}${swap_usage}${SC_RESET}"
    fi
  else
    local swap_info
    swap_info=$(free -h | grep "^Swap:")
    if [[ -n "${swap_info}" ]]; then
      local swap_total
      swap_total=$(echo "${swap_info}" | awk '{print $2}')
      local swap_used
      swap_used=$(echo "${swap_info}" | awk '{print $3}')
      echo -e "${SC_CYAN}•${SC_RESET} Swap: ${SC_PINK}${swap_used}${SC_RESET} / ${SC_YELLOW}${swap_total}${SC_RESET}"
    fi
  fi
}

# Disk usage with visual representation
function diskinfo() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Disk Usage${SC_RESET}"
  echo ""

  if is_macos; then
    df -h | grep -E "^/dev/" | while read -r line; do
      local size
      size=$(echo "${line}" | awk '{print $2}')
      local used
      used=$(echo "${line}" | awk '{print $3}')
      local avail
      avail=$(echo "${line}" | awk '{print $4}')
      local percent
      percent=$(echo "${line}" | awk '{print $5}' | sed 's/%//')
      local mount
      mount=$(echo "${line}" | awk '{print $9}')

      echo -e "${SC_CYAN}${SC_BOLD}• ${mount}${SC_RESET}"
      echo -e "  ${SC_GRAY}→${SC_RESET} Size: ${SC_YELLOW}${size}${SC_RESET}  Used: ${SC_RED}${used}${SC_RESET}  Free: ${SC_GREEN}${avail}${SC_RESET}"

      # Visual bar
      echo -ne "  ${SC_GRAY}→ [${SC_RESET}"
      local bar_length=20
      local filled=$(((percent * bar_length) / 100))
      local empty=$((bar_length - filled))

      # Color bar based on usage
      if [[ ${percent} -lt 60 ]]; then
        echo -ne "${SC_GREEN}"
      elif [[ ${percent} -lt 80 ]]; then
        echo -ne "${SC_YELLOW}"
      else
        echo -ne "${SC_RED}"
      fi

      for ((i = 0; i < filled; i++)); do echo -n "▰"; done
      echo -ne "${SC_GRAY}"
      for ((i = 0; i < empty; i++)); do echo -n "▱"; done
      echo -e "${SC_GRAY}]${SC_RESET} ${percent}%"
      echo ""
    done
  else
    df -h | grep -E "^/dev/" | grep -v "loop" | while read -r line; do
      local size
      size=$(echo "${line}" | awk '{print $2}')
      local used
      used=$(echo "${line}" | awk '{print $3}')
      local avail
      avail=$(echo "${line}" | awk '{print $4}')
      local percent
      percent=$(echo "${line}" | awk '{print $5}' | sed 's/%//')
      local mount
      mount=$(echo "${line}" | awk '{print $6}')

      echo -e "${SC_CYAN}${SC_BOLD}• ${mount}${SC_RESET}"
      echo -e "  ${SC_GRAY}→${SC_RESET} Size: ${SC_YELLOW}${size}${SC_RESET}  Used: ${SC_RED}${used}${SC_RESET}  Free: ${SC_GREEN}${avail}${SC_RESET}"

      # Visual bar
      echo -ne "  ${SC_GRAY}→ [${SC_RESET}"
      local bar_length=20
      local filled=$(((percent * bar_length) / 100))
      local empty=$((bar_length - filled))

      # Color bar based on usage
      if [[ ${percent} -lt 60 ]]; then
        echo -ne "${SC_GREEN}"
      elif [[ ${percent} -lt 80 ]]; then
        echo -ne "${SC_YELLOW}"
      else
        echo -ne "${SC_RED}"
      fi

      for ((i = 0; i < filled; i++)); do echo -n "▰"; done
      echo -ne "${SC_GRAY}"
      for ((i = 0; i < empty; i++)); do echo -n "▱"; done
      echo -e "${SC_GRAY}]${SC_RESET} ${percent}%"
      echo ""
    done
  fi
}

# GPU information (if available)
function gpuinfo() {
  echo "⚡ GPU Information"
  echo ""

  if is_macos; then
    # macOS GPU info
    local gpu_info
    gpu_info=$(system_profiler SPDisplaysDataType 2>/dev/null | grep -E "Chipset Model:|VRAM")
    if [[ -n "${gpu_info}" ]]; then
      echo "${gpu_info}" | while IFS=: read -r key value; do
        echo "• ${key}: ${value# }"
      done
    else
      echo "• No dedicated GPU found"
    fi
  else
    # Linux GPU info
    if has_command lspci; then
      local gpu_info
      gpu_info=$(lspci | grep -i vga)
      if [[ -n "${gpu_info}" ]]; then
        echo "• $(echo "${gpu_info}" | cut -d: -f3)"
      fi
    fi

    # NVIDIA specific
    if has_command nvidia-smi; then
      echo ""
      echo "→ NVIDIA GPU Status:"
      nvidia-smi --query-gpu=name,temperature.gpu,utilization.gpu,memory.used,memory.total --format=csv,noheader |
        awk -F', ' '{printf "  • %s\n    Temp: %s°C  Usage: %s  Memory: %s / %s\n", $1, $2, $3, $4, $5}'
    fi
  fi
}

# Battery status (laptops)
function battery() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Battery Status${SC_RESET}"
  echo ""

  if is_macos; then
    # macOS battery info
    local battery_info
    battery_info=$(pmset -g batt 2>/dev/null | grep -E "InternalBattery")
    if [[ -n "${battery_info}" ]]; then
      local percent
      percent=$(echo "${battery_info}" | grep -oE '[0-9]+%' | head -1 | sed 's/%//')
      local batt_status
      batt_status=$(echo "${battery_info}" | awk -F';' '{print $2}' | xargs)
      local time_remaining
      time_remaining=$(echo "${battery_info}" | grep -oE '[0-9]+:[0-9]+' | head -1)

      echo -e "${SC_CYAN}•${SC_RESET} Charge: ${SC_YELLOW}${percent}%${SC_RESET}"
      echo -e "${SC_CYAN}•${SC_RESET} Status: ${SC_GREEN}${batt_status}${SC_RESET}"
      [[ -n "${time_remaining}" ]] && echo -e "${SC_CYAN}•${SC_RESET} Time: ${SC_PINK}${time_remaining}${SC_RESET} remaining"

      # Visual bar
      echo -ne "${SC_CYAN}•${SC_RESET} ${SC_GRAY}[${SC_RESET}"
      local bar_length=20
      local filled=$(((percent * bar_length) / 100))
      local empty=$((bar_length - filled))

      # Color based on charge level
      if [[ ${percent} -gt 60 ]]; then
        echo -ne "${SC_GREEN}"
      elif [[ ${percent} -gt 20 ]]; then
        echo -ne "${SC_YELLOW}"
      else
        echo -ne "${SC_RED}"
      fi

      for ((i = 0; i < filled; i++)); do echo -n "▰"; done
      echo -ne "${SC_GRAY}"
      for ((i = 0; i < empty; i++)); do echo -n "▱"; done
      echo -e "${SC_GRAY}]${SC_RESET} ${percent}%"
    else
      echo -e "${SC_GRAY}• No battery found${SC_RESET}"
    fi
  else
    # Linux battery info
    if [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]]; then
      local bat_dir="/sys/class/power_supply/BAT0"
      [[ ! -d "${bat_dir}" ]] && bat_dir="/sys/class/power_supply/BAT1"

      if [[ -f "${bat_dir}/capacity" ]]; then
        local percent
        percent=$(cat "${bat_dir}/capacity")
        local batt_status
        batt_status=$(cat "${bat_dir}/status")

        echo "• Charge: ${percent}%"
        echo "• Status: ${batt_status}"

        # Visual bar
        echo -n "• ["
        local bar_length=20
        local filled=$(((percent * bar_length) / 100))
        local empty=$((bar_length - filled))

        for ((i = 0; i < filled; i++)); do echo -n "▰"; done
        for ((i = 0; i < empty; i++)); do echo -n "▱"; done
        echo "] ${percent}%"
      fi
    else
      echo -e "${SC_GRAY}• No battery found${SC_RESET}"
    fi
  fi
}

# Temperature monitoring
function temps() {
  echo "⚡ System Temperatures"
  echo ""

  if is_macos; then
    # macOS temperature
    if has_command osx-cpu-temp; then
      echo "• CPU: $(osx-cpu-temp)"
    fi

    # Try alternative methods
    if has_command istats; then
      istats cpu temp 2>/dev/null
      istats fan 2>/dev/null
    fi
  else
    # Linux temperature
    if has_command sensors; then
      sensors | grep -E "Core|temp" | while read -r line; do
        echo "• ${line}"
      done
    elif [[ -f /sys/class/thermal/thermal_zone0/temp ]]; then
      local temp
      temp=$(cat /sys/class/thermal/thermal_zone0/temp)
      echo "• CPU: $((temp / 1000))°C"
    else
      echo "• Temperature monitoring not available"
      echo "  → Install lm-sensors for temperature data"
    fi
  fi
}

# Service status checker
function services() {
  echo "⚡ Service Status"
  echo ""

  if is_macos; then
    # Check common macOS services
    echo "→ System Services:"

    # Check if common services are running
    local services=("com.apple.dock" "com.apple.Finder" "com.apple.WindowServer")
    for service in "${services[@]}"; do
      if launchctl list | grep -q "${service}"; then
        echo "  ✓ ${service##*.}"
      else
        echo "  ✗ ${service##*.}"
      fi
    done

    # Check brew services if available
    if has_command brew; then
      echo ""
      echo "→ Homebrew Services:"
      brew services list 2>/dev/null | tail -n +2 | while read -r line; do
        local name
        name=$(echo "${line}" | awk '{print $1}')
        local svc_status
        svc_status=$(echo "${line}" | awk '{print $2}')
        if [[ "${svc_status}" == "started" ]]; then
          echo "  ✓ ${name}"
        else
          echo "  ✗ ${name}"
        fi
      done
    fi
  else
    # Linux services
    if has_command systemctl; then
      echo "→ System Services:"

      # Check common services
      local services=("sshd" "nginx" "apache2" "mysql" "postgresql" "docker")
      for service in "${services[@]}"; do
        if systemctl is-active "${service}" >/dev/null 2>&1; then
          echo "  ✓ ${service}"
        elif systemctl list-units --all | grep -q "${service}"; then
          echo "  ✗ ${service}"
        fi
      done
    elif has_command service; then
      echo "→ Init Services:"
      service --status-all 2>/dev/null | while read -r line; do
        if [[ "${line}" == *"[ + ]"* ]]; then
          echo "  ✓ $(echo "${line}" | awk '{print $4}')"
        elif [[ "${line}" == *"[ - ]"* ]]; then
          echo "  ✗ $(echo "${line}" | awk '{print $4}')"
        fi
      done
    fi
  fi
}

# Quick system health check
function health() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ System Health Check${SC_RESET}"
  echo ""

  # CPU load check
  local load
  load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
  local cores
  cores=$(nproc 2>/dev/null || sysctl -n hw.ncpu 2>/dev/null || echo 1)

  echo -n "• CPU Load: "
  # Use awk for floating point comparison since bc might not be available
  local load_status
  load_status=$(echo "${load} ${cores}" | awk '{
    if ($2 == 0) $2 = 1;
    lpc = $1 / $2;
    if (lpc < 0.7) print "healthy";
    else if (lpc < 1.5) print "moderate";
    else print "high";
    printf " %.2f", lpc;
  }')

  if [[ "${load_status}" == *"healthy"* ]]; then
    echo -e "${SC_GREEN}✓ Healthy${SC_RESET} ${SC_GRAY}($(echo "${load_status}" | awk '{print $2}') per core)${SC_RESET}"
  elif [[ "${load_status}" == *"moderate"* ]]; then
    echo -e "${SC_YELLOW}⚠ Moderate${SC_RESET} ${SC_GRAY}($(echo "${load_status}" | awk '{print $2}') per core)${SC_RESET}"
  else
    echo -e "${SC_RED}! High${SC_RESET} ${SC_GRAY}($(echo "${load_status}" | awk '{print $2}') per core)${SC_RESET}"
  fi

  # Memory check
  if is_macos; then
    local total_mem=$(($(sysctl -n hw.memsize) / 1024 / 1024 / 1024))
    local page_size
    page_size=$(sysctl -n hw.pagesize)
    local vm_stat_output
    vm_stat_output=$(vm_stat)
    local free_pages
    free_pages=$(echo "$vm_stat_output" | grep "Pages free" | awk '{print $3}' | sed 's/\.//')
    local inactive_pages
    inactive_pages=$(echo "$vm_stat_output" | grep "Pages inactive" | awk '{print $3}' | sed 's/\.//')
    local speculative_pages
    speculative_pages=$(echo "$vm_stat_output" | grep "Pages speculative" | awk '{print $3}' | sed 's/\.//')

    # Available memory is free + inactive + speculative
    local available_mem=$(((free_pages + inactive_pages + speculative_pages) * page_size / 1024 / 1024 / 1024))
    local percent_free=$(((available_mem * 100) / total_mem))
  else
    local percent_free
    percent_free=$(free | grep "^Mem:" | awk '{printf "%d", ($7/$2)*100}')
  fi

  echo -ne "${SC_CYAN}•${SC_RESET} Memory: "
  if [[ ${percent_free} -gt 20 ]]; then
    echo -e "${SC_GREEN}✓ Healthy${SC_RESET} ${SC_GRAY}(${percent_free}% available)${SC_RESET}"
  elif [[ ${percent_free} -gt 10 ]]; then
    echo -e "${SC_YELLOW}⚠ Moderate${SC_RESET} ${SC_GRAY}(${percent_free}% available)${SC_RESET}"
  else
    echo -e "${SC_RED}! Low${SC_RESET} ${SC_GRAY}(${percent_free}% available)${SC_RESET}"
  fi

  # Disk check
  local root_usage
  root_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
  echo -ne "${SC_CYAN}•${SC_RESET} Disk: "
  if [[ ${root_usage} -lt 80 ]]; then
    echo -e "${SC_GREEN}✓ Healthy${SC_RESET} ${SC_GRAY}(${root_usage}% used)${SC_RESET}"
  elif [[ ${root_usage} -lt 90 ]]; then
    echo -e "${SC_YELLOW}⚠ Moderate${SC_RESET} ${SC_GRAY}(${root_usage}% used)${SC_RESET}"
  else
    echo -e "${SC_RED}! Critical${SC_RESET} ${SC_GRAY}(${root_usage}% used)${SC_RESET}"
  fi

  # Temperature check (if available)
  if is_macos && has_command osx-cpu-temp; then
    local temp
    temp=$(osx-cpu-temp | grep -oE '[0-9]+' | head -1)
    echo -n "• Temperature: "
    if [[ ${temp} -lt 70 ]]; then
      echo "✓ Normal (${temp}°C)"
    elif [[ ${temp} -lt 85 ]]; then
      echo "⚠ Warm (${temp}°C)"
    else
      echo "! Hot (${temp}°C)"
    fi
  elif has_command sensors; then
    local temp
    temp=$(sensors 2>/dev/null | grep "Core 0" | grep -oE '[0-9]+' | head -1)
    if [[ -n "${temp}" ]]; then
      echo -n "• Temperature: "
      if [[ ${temp} -lt 70 ]]; then
        echo "✓ Normal (${temp}°C)"
      elif [[ ${temp} -lt 85 ]]; then
        echo "⚠ Warm (${temp}°C)"
      else
        echo "! Hot (${temp}°C)"
      fi
    fi
  fi
}

# All system info at once
function sys() {
  sysinfo
  echo ""
  cpuinfo
  echo ""
  meminfo
  echo ""
  diskinfo

  if [[ -d /sys/class/power_supply/BAT0 ]] || [[ -d /sys/class/power_supply/BAT1 ]] || is_macos; then
    echo ""
    battery
  fi
}
