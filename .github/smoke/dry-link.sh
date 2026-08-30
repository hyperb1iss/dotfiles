#!/usr/bin/env bash
#
# Link-only composition check against a throwaway HOME.
#
# Runs the given layers through dotbot with `--only clean create link`,
# which skips every shell directive, so nothing is downloaded, no package
# manager runs, and the real home directory is never touched. What it
# proves is that the layers parse, compose, and produce the link set they
# declare. It is the whole macOS check and the desktop check on Linux,
# where installing the graphical stack in CI would cost far more than it
# tells us.
#
# Usage: dry-link.sh <repo> <layer.yaml>...

set -euo pipefail

repo="${1:?usage: dry-link.sh <repo> <layer.yaml>...}"
shift

if [ $# -eq 0 ]; then
  echo "error: no layers given" >&2
  exit 2
fi

repo=$(cd "${repo}" && pwd)

# dotbot and the expected-link derivation both read yaml through dotbot's
# vendored PyYAML, which arrives with the nested submodule.
if [ ! -d "${repo}/dotbot/lib/pyyaml/lib/yaml" ]; then
  echo "error: dotbot's vendored PyYAML is missing" >&2
  echo "  run: git submodule update --init --recursive" >&2
  exit 1
fi

tmp_root="${TMPDIR:-/tmp}"
fake_home=$(mktemp -d "${tmp_root%/}/dotfiles-smoke.XXXXXX")

# Belt and braces: a fake home that collides with the real one would let
# a link run rearrange somebody's actual dotfiles.
if [ -z "${fake_home}" ] || [ "${fake_home}" = "${HOME:-}" ] || [ "${fake_home}" = "/" ]; then
  echo "error: refusing to run against ${fake_home}" >&2
  exit 1
fi

cleanup() { rm -rf "${fake_home}"; }
trap cleanup EXIT

echo "▸ dry link run in ${fake_home}"
echo "  layers: $*"

layers=()
for layer in "$@"; do
  layers+=("${repo}/${layer}")
done

HOME="${fake_home}" "${repo}/dotbot/bin/dotbot" \
  -d "${repo}" --only clean create link -c "${layers[@]}"

"${repo}/.github/smoke/assert-links.sh" "${fake_home}" "${repo}" "${layers[@]}"
