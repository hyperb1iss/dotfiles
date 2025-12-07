# network.sh
# ⚡ Network utilities with SilkCircuit energy

# Skip on minimal installations
is_minimal && return 0

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2> /dev/null || true

# ─────────────────────────────────────────────────────────────
# Port & Connection Tools
# ─────────────────────────────────────────────────────────────

# Find what's using a specific port (cross-platform)
function port() {
  local port="${1}"

  if [[ -z "${port}" ]]; then
    echo -e "${SC_PURPLE}${SC_BOLD}⚡ Usage:${SC_RESET} ${SC_CYAN}port <port_number>${SC_RESET}"
    echo -e "   ${SC_GRAY}Shows what process is using the specified port${SC_RESET}"
    return 1
  fi

  echo -e "${SC_CYAN}→${SC_RESET} Checking port ${SC_YELLOW}${port}${SC_RESET}..."
  echo ""

  if is_macos; then
    # macOS version using lsof
    local result
    result=$(lsof -iTCP:"${port}" -sTCP:LISTEN 2> /dev/null)

    if [[ -n "${result}" ]]; then
      echo -e "${SC_RED}•${SC_RESET} Port ${SC_YELLOW}${port}${SC_RESET} is in use:"
      echo ""
      echo "${result}" | awk 'NR==1 || NR>1 {printf "%-15s %-8s %-8s %-20s\n", $1, $2, $3, $9}'
    else
      echo -e "${SC_GREEN}✓${SC_RESET} Port ${SC_YELLOW}${port}${SC_RESET} is ${SC_GREEN}available${SC_RESET}"
    fi
  else
    # Linux version using ss or netstat
    if has_command ss; then
      local result
      result=$(ss -tlnp 2> /dev/null | grep ":${port}\s")

      if [[ -n "${result}" ]]; then
        echo -e "${SC_RED}•${SC_RESET} Port ${SC_YELLOW}${port}${SC_RESET} is in use:"
        echo ""
        echo "${result}" | column -t
      else
        echo -e "${SC_GREEN}✓${SC_RESET} Port ${SC_YELLOW}${port}${SC_RESET} is ${SC_GREEN}available${SC_RESET}"
      fi
    elif has_command netstat; then
      local result
      result=$(netstat -tlnp 2> /dev/null | grep ":${port}\s")

      if [[ -n "${result}" ]]; then
        echo -e "${SC_RED}•${SC_RESET} Port ${SC_YELLOW}${port}${SC_RESET} is in use:"
        echo ""
        echo "${result}" | column -t
      else
        echo -e "${SC_GREEN}✓${SC_RESET} Port ${SC_YELLOW}${port}${SC_RESET} is ${SC_GREEN}available${SC_RESET}"
      fi
    else
      echo -e "${SC_RED}!${SC_RESET} Neither ss nor netstat available"
      return 1
    fi
  fi
}

# Show all listening ports with pretty output
function ports() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Active Listening Ports${SC_RESET}"
  echo ""

  if is_macos; then
    lsof -iTCP -sTCP:LISTEN -P -n 2> /dev/null \
      | awk 'NR==1 {printf "%-15s %-8s %-20s %-15s\n", "COMMAND", "PID", "USER", "PORT"} 
           NR>1 {split($9,a,":"); printf "%-15s %-8s %-20s %-15s\n", $1, $2, $3, a[length(a)]}' \
      | sort -k4 -n | uniq
  else
    if has_command ss; then
      ss -tlnp 2> /dev/null \
        | awk 'NR>1 {split($4,a,":"); printf "%-20s %-15s %-30s\n", $1, a[length(a)], $6}' \
        | sort -k2 -n
    elif has_command netstat; then
      netstat -tlnp 2> /dev/null \
        | awk '/^tcp/ {split($4,a,":"); printf "%-20s %-15s %-30s\n", $1, a[length(a)], $7}' \
        | sort -k2 -n
    fi
  fi
}

# Check network connectivity with style
function netcheck() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Network Connectivity Check${SC_RESET}"
  echo ""

  # DNS check
  echo -ne "${SC_CYAN}→${SC_RESET} DNS Resolution: "
  if nslookup google.com > /dev/null 2>&1; then
    echo -e "${SC_GREEN}✓ Working${SC_RESET}"
  else
    echo -e "${SC_RED}✗ Failed${SC_RESET}"
  fi

  # Gateway check
  echo -ne "${SC_CYAN}→${SC_RESET} Gateway: "
  local gateway
  if is_macos; then
    gateway=$(route -n get default 2> /dev/null | grep gateway | awk '{print $2}')
  else
    gateway=$(ip route 2> /dev/null | grep default | awk '{print $3}')
  fi

  if [[ -n "${gateway}" ]]; then
    echo -e "${SC_YELLOW}${gateway}${SC_RESET}"
    echo -ne "  ${SC_GRAY}•${SC_RESET} Ping: "
    if ping -c 1 -W 2 "${gateway}" > /dev/null 2>&1; then
      echo -e "${SC_GREEN}✓ Reachable${SC_RESET}"
    else
      echo -e "${SC_RED}✗ Unreachable${SC_RESET}"
    fi
  else
    echo -e "${SC_RED}✗ Not found${SC_RESET}"
  fi

  # Internet check
  echo -ne "${SC_CYAN}→${SC_RESET} Internet: "
  if ping -c 1 -W 2 8.8.8.8 > /dev/null 2>&1; then
    echo -e "${SC_GREEN}✓ Connected${SC_RESET}"
  else
    echo -e "${SC_RED}✗ Disconnected${SC_RESET}"
  fi

  # Speed test hint
  echo ""
  echo -e "${SC_GRAY}• Run 'speedtest' for bandwidth testing (if installed)${SC_RESET}"
}

# Show network interfaces with pretty formatting
function netif() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Network Interfaces${SC_RESET}"
  echo ""

  if is_macos; then
    # macOS version
    for interface in $(ifconfig -l); do
      local if_status
      if_status=$(ifconfig "${interface}" 2> /dev/null | grep "status:" | awk '{print $2}')
      local ip
      ip=$(ifconfig "${interface}" 2> /dev/null | grep "inet " | awk '{print $2}')

      if [[ -n "${ip}" ]] || [[ "${if_status}" == "active" ]]; then
        echo -e "${SC_CYAN}${SC_BOLD}• ${interface}${SC_RESET}"
        [[ -n "${ip}" ]] && echo -e "  ${SC_GRAY}→${SC_RESET} IPv4: ${SC_YELLOW}${ip}${SC_RESET}"

        local ip6
        ip6=$(ifconfig "${interface}" 2> /dev/null | grep "inet6" | grep -v "fe80" | awk '{print $2}')
        [[ -n "${ip6}" ]] && echo -e "  ${SC_GRAY}→${SC_RESET} IPv6: ${SC_PINK}${ip6}${SC_RESET}"

        [[ -n "${if_status}" ]] && echo -e "  ${SC_GRAY}→${SC_RESET} Status: ${SC_GREEN}${if_status}${SC_RESET}"
        echo ""
      fi
    done
  else
    # Linux version
    for interface in $(ip -o link show | awk -F': ' '{print $2}'); do
      local state
      state=$(ip link show "${interface}" 2> /dev/null | grep -oP '(?<=state )\w+')
      local ip
      ip=$(ip -4 addr show "${interface}" 2> /dev/null | grep -oP '(?<=inet )\S+')

      if [[ -n "${ip}" ]] || [[ "${state}" == "UP" ]]; then
        echo -e "${SC_CYAN}${SC_BOLD}• ${interface}${SC_RESET}"
        [[ -n "${ip}" ]] && echo -e "  ${SC_GRAY}→${SC_RESET} IPv4: ${SC_YELLOW}${ip}${SC_RESET}"

        local ip6
        ip6=$(ip -6 addr show "${interface}" 2> /dev/null | grep -oP '(?<=inet6 )\S+' | grep -v "fe80")
        [[ -n "${ip6}" ]] && echo -e "  ${SC_GRAY}→${SC_RESET} IPv6: ${SC_PINK}${ip6}${SC_RESET}"

        [[ -n "${state}" ]] && echo -e "  ${SC_GRAY}→${SC_RESET} State: ${SC_GREEN}${state}${SC_RESET}"
        echo ""
      fi
    done
  fi
}

# Show active network connections
function connections() {
  local filter="${1:-all}"

  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Active Network Connections${SC_RESET}"
  echo ""

  if is_macos; then
    case "${filter}" in
      tcp)
        lsof -iTCP -P -n | grep ESTABLISHED
        ;;
      udp)
        lsof -iUDP -P -n
        ;;
      *)
        lsof -i -P -n | grep -E "(ESTABLISHED|LISTEN)"
        ;;
    esac
  else
    case "${filter}" in
      tcp)
        ss -tnp 2> /dev/null | grep ESTAB
        ;;
      udp)
        ss -unp 2> /dev/null
        ;;
      *)
        ss -tunp 2> /dev/null | grep -E "(ESTAB|LISTEN)"
        ;;
    esac
  fi | column -t
  echo ""
  echo -e "${SC_GRAY}• Usage: connections [tcp|udp|all]${SC_RESET}"
}

# Network bandwidth usage (if tools available)
function bandwidth() {
  echo -e "${SC_PURPLE}${SC_BOLD}⚡ Network Bandwidth Monitor${SC_RESET}"
  echo ""

  if has_command nload; then
    echo "Starting nload... (Press 'q' to quit)"
    sleep 1
    nload
  elif has_command iftop; then
    echo "Starting iftop... (Press 'q' to quit)"
    echo "Note: May require sudo"
    sleep 1
    sudo iftop
  elif has_command nethogs; then
    echo "Starting nethogs... (Press 'q' to quit)"
    echo "Note: Requires sudo"
    sleep 1
    sudo nethogs
  else
    echo -e "${SC_RED}!${SC_RESET} No bandwidth monitoring tool found"
    echo ""
    echo -e "${SC_YELLOW}Install one of these tools:${SC_RESET}"
    echo -e "  ${SC_CYAN}• nload${SC_RESET}  - Real-time bandwidth graphs"
    echo -e "  ${SC_CYAN}• iftop${SC_RESET}  - Connection-based bandwidth"
    echo -e "  ${SC_CYAN}• nethogs${SC_RESET} - Process-based bandwidth"

    if is_macos; then
      echo ""
      echo -e "  ${SC_GRAY}→ Install with:${SC_RESET} ${SC_PINK}brew install nload iftop nethogs${SC_RESET}"
    else
      echo ""
      echo -e "  ${SC_GRAY}→ Install with:${SC_RESET} ${SC_PINK}sudo apt install nload iftop nethogs${SC_RESET}"
    fi
  fi
}

# Show WiFi information (macOS specific)
if is_macos; then
  function wifi() {
    echo -e "${SC_PURPLE}${SC_BOLD}⚡ WiFi Information${SC_RESET}"
    echo ""

    local ssid
    ssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep " SSID" | awk '{print $2}')
    local bssid
    bssid=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep " BSSID" | awk '{print $2}')
    local channel
    channel=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep "channel" | awk '{print $2}')
    local signal
    signal=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep "agrCtlRSSI" | awk '{print $2}')
    local noise
    noise=$(/System/Library/PrivateFrameworks/Apple80211.framework/Versions/Current/Resources/airport -I | grep "agrCtlNoise" | awk '{print $2}')

    [[ -n "${ssid}" ]] && echo -e "${SC_CYAN}•${SC_RESET} Network: ${SC_YELLOW}${ssid}${SC_RESET}"
    [[ -n "${bssid}" ]] && echo -e "${SC_CYAN}•${SC_RESET} BSSID: ${SC_GRAY}${bssid}${SC_RESET}"
    [[ -n "${channel}" ]] && echo -e "${SC_CYAN}•${SC_RESET} Channel: ${SC_PINK}${channel}${SC_RESET}"

    if [[ -n "${signal}" ]]; then
      local signal_quality=""
      if [[ ${signal} -ge -50 ]]; then
        signal_quality="Excellent ▰▰▰▰▰▰▰▰"
      elif [[ ${signal} -ge -60 ]]; then
        signal_quality="Good ▰▰▰▰▰▰▱▱"
      elif [[ ${signal} -ge -70 ]]; then
        signal_quality="Fair ▰▰▰▰▱▱▱▱"
      else
        signal_quality="Poor ▰▰▱▱▱▱▱▱"
      fi
      echo -e "${SC_CYAN}•${SC_RESET} Signal: ${SC_YELLOW}${signal} dBm${SC_RESET} (${signal_quality})"
    fi

    [[ -n "${noise}" ]] && echo -e "${SC_CYAN}•${SC_RESET} Noise: ${SC_GRAY}${noise} dBm${SC_RESET}"

    # If no info was printed, show a message
    if [[ -z "${ssid}" ]] && [[ -z "${bssid}" ]] && [[ -z "${channel}" ]]; then
      echo -e "${SC_GRAY}• No WiFi connection detected or unable to access WiFi info${SC_RESET}"
      echo -e "  ${SC_GRAY}→ Try:${SC_RESET} ${SC_PINK}networksetup -getairportnetwork en0${SC_RESET}"
    fi
  }
fi

# Alias for common tools
alias lsof-net='lsof -i -P -n'
alias netstat-listen='netstat -tlnp 2>/dev/null || netstat -tln'
alias ss-listen='ss -tlnp'
