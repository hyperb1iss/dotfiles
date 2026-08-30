#!/usr/bin/env bash
#
# Host side of the container smoke run. CI calls this with a job name and
# so does `make smoke`, which is the whole point: there is one definition
# of what the smoke matrix does and both callers get it.
#
# The repo is mounted read-only and copied inside the container, so a run
# can never write back into the checkout it is testing.
#
# Usage: run-container.sh [job...]     (default: every job)
#   jobs: ubuntu-server, arch-server, ubuntu-desktop-links

set -euo pipefail

repo_root=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd)

# job|image|mode|platform
#
# The Arch image is published for amd64 only, so an Apple Silicon machine
# has to emulate it. CI runners are amd64 and ignore the flag; pinning it
# here means `make smoke` runs the same image CI does instead of a
# different distro that happens to have an arm build.
jobs_all=(
  "ubuntu-server|ubuntu:24.04|server|"
  "arch-server|archlinux:latest|server|linux/amd64"
  "ubuntu-desktop-links|ubuntu:24.04|desktop-links|"
)

pick_runtime() {
  if [ -n "${SMOKE_RUNTIME:-}" ]; then
    printf '%s\n' "${SMOKE_RUNTIME}"
    return 0
  fi
  for candidate in docker podman; do
    if command -v "${candidate}" > /dev/null 2>&1; then
      printf '%s\n' "${candidate}"
      return 0
    fi
  done
  return 1
}

# Extra flags come in as arguments so an empty platform does not have to
# be smuggled through an array; bash 3.2 on macOS refuses to expand an
# empty one under `set -u`.
run_one() {
  "${runtime}" run --rm "$@" \
    --volume "${repo_root}:/src:ro" \
    --env "SMOKE_INTERACTIVE=${SMOKE_INTERACTIVE:-1}" \
    "${image}" \
    /bin/bash /src/.github/smoke/container.sh root "${mode}"
}

spec_for() {
  local wanted="$1"
  for spec in "${jobs_all[@]}"; do
    if [ "${spec%%|*}" = "${wanted}" ]; then
      printf '%s\n' "${spec}"
      return 0
    fi
  done
  return 1
}

runtime=$(pick_runtime) || {
  echo "✖ neither docker nor podman found; cannot run the container smoke jobs" >&2
  echo "  install one, or set SMOKE_RUNTIME to the binary you want used" >&2
  exit 127
}

# No argument means the whole matrix. Positional parameters rather than an
# array: bash 3.2 on macOS treats an empty array expansion under `set -u`
# as an unbound variable.
if [ $# -eq 0 ]; then
  for spec in "${jobs_all[@]}"; do
    set -- "$@" "${spec%%|*}"
  done
fi

for job in "$@"; do
  spec=$(spec_for "${job}") || {
    echo "✖ unknown job '${job}'" >&2
    exit 2
  }
  rest="${spec#*|}"
  image="${rest%%|*}"
  rest="${rest#*|}"
  mode="${rest%%|*}"
  platform="${SMOKE_PLATFORM:-${rest#*|}}"

  printf '\n\033[1;35m▶ \033[1;36m%s\033[0m \033[0;90m(%s, %s, %s%s)\033[0m\n' \
    "${job}" "${image}" "${mode}" "${runtime}" "${platform:+, ${platform}}"

  if [ -n "${platform}" ]; then
    run_one --platform "${platform}"
  else
    run_one
  fi
done
