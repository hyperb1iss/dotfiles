#!/usr/bin/env bash
#
# One table of which layers each smoke lane composes, so the workflow,
# `make smoke`, and the container jobs cannot disagree about what is
# being tested. Everything else here takes its layer list from this.
#
# Usage:
#   layers.sh list <lane>            print the lane's layers, repo relative
#   layers.sh check-compose <lane>   assert `make -n install` composes them

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

lane_layers() {
  case "$1" in
    server)
      # role/server composes without an os layer; see the Makefile.
      echo "dotbot.d/base.yaml dotbot.d/role/server.yaml"
      ;;
    desktop-macos)
      echo "dotbot.d/base.yaml dotbot.d/os/macos.yaml dotbot.d/role/desktop.yaml"
      ;;
    desktop-linux)
      # hyperia rides along so the host layer stays parse and link valid.
      echo "dotbot.d/base.yaml dotbot.d/os/linux.yaml dotbot.d/role/desktop.yaml dotbot.d/host/hyperia.yaml"
      ;;
    *)
      echo "error: unknown lane '$1' (server, desktop-macos, desktop-linux)" >&2
      return 2
      ;;
  esac
}

# `make -n install` prints the dotbot invocation without running it, which
# is the only way to check the Makefile's own layer composition on a real
# host. Host layers are skipped: they appear only when the hostname
# matches, and the machine running this is usually not hyperia.
check_compose() {
  local lane="$1"
  case "${lane}" in
    desktop-macos | desktop-linux) ;;
    *)
      echo "error: check-compose wants a desktop lane, got '${lane}'" >&2
      return 2
      ;;
  esac

  local out
  out=$(cd "${repo_root}" && make -n install)
  printf '%s\n' "${out}"

  local missing=0
  for layer in $(lane_layers "${lane}"); do
    case "${layer}" in
      dotbot.d/host/*) continue ;;
    esac
    case "${out}" in
      *"${layer}"*) echo "  ✓ composes ${layer}" ;;
      *)
        echo "  ✖ make -n install did not compose ${layer}" >&2
        missing=1
        ;;
    esac
  done

  return "${missing}"
}

action="${1:?usage: layers.sh <list|check-compose> <lane>}"
lane="${2:?usage: layers.sh <list|check-compose> <lane>}"

case "${action}" in
  list) lane_layers "${lane}" ;;
  check-compose) check_compose "${lane}" ;;
  *)
    echo "error: unknown action '${action}'" >&2
    exit 2
    ;;
esac
