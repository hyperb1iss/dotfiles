#!/usr/bin/env bash
#
# Assert that a dotbot run actually produced what its layers declare.
#
# Every link the layers name has to exist as a symlink and resolve to
# something real, and every `create` directory has to be there. The
# expected set is derived from the yaml at run time (see
# expected_links.py), so the floor list below is what stops a layer that
# lost its links from passing with an empty expectation.
#
# Usage: assert-links.sh <home> <repo> <layer.yaml>...

set -euo pipefail

home="${1:?usage: assert-links.sh <home> <repo> <layer.yaml>...}"
repo="${2:?usage: assert-links.sh <home> <repo> <layer.yaml>...}"
shift 2

if [ $# -eq 0 ]; then
  echo "error: no layers given" >&2
  exit 2
fi

derive="${repo}/.github/smoke/expected_links.py"

# Core links from base.yaml. Present in every composition, so their
# absence from the derived set means the yaml lost them, not that this
# profile skips them.
floor=(
  "${home}/.bashrc.local"
  "${home}/.gitconfig"
  "${home}/.tmux.conf"
  "${home}/.zshrc"
  "${home}/.config/nvim"
  "${home}/bin"
  "${home}/.tmux/plugins/tpm"
)

failures=0
checked=0

echo "▸ asserting links under ${home}"

links=$(python3 "${derive}" --home "${home}" --kind link "$@")
while IFS= read -r path; do
  [ -n "${path}" ] || continue
  checked=$((checked + 1))
  if [ ! -L "${path}" ]; then
    echo "  ✖ not a symlink: ${path}"
    failures=$((failures + 1))
  elif [ ! -e "${path}" ]; then
    echo "  ✖ dangling symlink: ${path} -> $(readlink "${path}")"
    failures=$((failures + 1))
  else
    echo "  ✓ ${path} -> $(readlink "${path}")"
  fi
done <<< "${links}"

creates=$(python3 "${derive}" --home "${home}" --kind create "$@")
while IFS= read -r path; do
  [ -n "${path}" ] || continue
  checked=$((checked + 1))
  if [ ! -d "${path}" ]; then
    echo "  ✖ missing directory: ${path}"
    failures=$((failures + 1))
  else
    echo "  ✓ ${path}/"
  fi
done <<< "${creates}"

for path in "${floor[@]}"; do
  case $'\n'"${links}"$'\n' in
    *$'\n'"${path}"$'\n'*) ;;
    *)
      echo "  ✖ core link missing from the composed layers: ${path}"
      failures=$((failures + 1))
      ;;
  esac
done

if [ "${failures}" -ne 0 ]; then
  echo "✖ ${failures} assertion(s) failed across ${checked} path(s)" >&2
  exit 1
fi

echo "✓ ${checked} path(s) verified"
