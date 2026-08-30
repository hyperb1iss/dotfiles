#!/usr/bin/env bash
#
# `make smoke`: the CI install matrix, run on this machine.
#
# The host dry run covers this OS's layers without touching the real home
# directory, then the container jobs run the same scripts CI runs. Every
# piece is shared with .github/workflows/install-smoke.yml, so a green run
# here means the same thing a green run there does.

set -euo pipefail

smoke_dir=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
repo_root=$(cd "${smoke_dir}/../.." && pwd)

failed=""

note() { printf '\n\033[1;35m▶ \033[1;36m%s\033[0m\n' "$*"; }
warn() { printf '\033[1;33m! %s\033[0m\n' "$*"; }
good() { printf '\033[1;32m✓ %s\033[0m\n' "$*"; }
bad() { printf '\033[1;31m✖ %s\033[0m\n' "$*"; }

run_step() {
  local name="$1"
  shift
  note "${name}"
  if "$@"; then
    good "${name}"
  else
    bad "${name}"
    failed="${failed} ${name}"
  fi
}

# Every lane, host and container alike, reads yaml through dotbot's vendored
# PyYAML, and the container jobs copy this tree rather than cloning it. A
# checkout that skipped the nested submodule fails in every lane at once,
# so say so here instead of after a container bootstrap.
if [ ! -d "${repo_root}/dotbot/lib/pyyaml/lib/yaml" ]; then
  bad "dotbot's vendored PyYAML is missing"
  echo "  run: git submodule update --init --recursive" >&2
  exit 1
fi

if [ "$(uname -s)" = "Darwin" ]; then
  lane="desktop-macos"
else
  lane="desktop-linux"
fi

host_layers=$("${smoke_dir}/layers.sh" list "${lane}")

run_step "layer composition" "${smoke_dir}/layers.sh" check-compose "${lane}"

# shellcheck disable=SC2086 # the layer list is deliberately word split
run_step "host dry link run" "${smoke_dir}/dry-link.sh" "${repo_root}" ${host_layers}

if [ -n "${SMOKE_RUNTIME:-}" ] || command -v docker > /dev/null 2>&1 || command -v podman > /dev/null 2>&1; then
  note "container matrix"
  set +e
  "${smoke_dir}/run-container.sh"
  rc=$?
  set -e
  # 127 is run-container.sh saying there is no usable runtime, which is a
  # skip rather than a failure. Anything else is a real result.
  if [ "${rc}" -eq 0 ]; then
    good "container matrix"
  elif [ "${rc}" -eq 127 ]; then
    warn "container jobs skipped, the Linux matrix still runs in CI"
  else
    bad "container matrix"
    failed="${failed} container-matrix"
  fi
else
  warn "no docker or podman on this machine, skipping the container jobs"
  warn "the Linux install matrix still runs in CI on every push"
fi

if [ -n "${failed}" ]; then
  printf '\n'
  bad "failed:${failed}"
  exit 1
fi

printf '\n'
good "smoke clean"
