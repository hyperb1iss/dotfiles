#!/usr/bin/env bash
#
# The smoke run, from inside the container. Two phases in one file so CI
# and `make smoke` execute the exact same prep.
#
#   root: install the handful of packages a bare image lacks, make an
#         unprivileged user with passwordless sudo, and stage the repo at
#         ~/dev/dotfiles (the rc files hardcode that path)
#   user: run the install and assert what it produced
#
# Running as a normal user rather than root is deliberate: it matches how
# anyone actually installs these dotfiles and it catches HOME assumptions
# that root would paper over.
#
# Usage: container.sh <root|user> <server|desktop-links>

set -euo pipefail

phase="${1:-root}"
mode="${2:-server}"

smoke_user="smoke"
smoke_home="/home/${smoke_user}"
repo="${smoke_home}/dev/dotfiles"
src="${SMOKE_SRC:-/src}"

# The interactive shell check pulls zinit and its plugins over the
# network. Set SMOKE_INTERACTIVE=0 to run everything else without it.
smoke_interactive="${SMOKE_INTERACTIVE:-1}"

banner() {
  printf '\n\033[1;35m▶ \033[1;36m%s\033[0m\n' "$*"
}

install_bootstrap_packages() {
  if command -v pacman > /dev/null 2>&1; then
    banner "Bootstrapping Arch"
    # pacman 7 drops privileges into a seccomp sandbox to download, and
    # installing that filter fails with EINVAL inside a container running
    # under emulation. The image already ships DisableSandboxFilesystem
    # for the landlock half of the same problem; this turns off the other
    # half. It goes in pacman.conf rather than on one command line
    # because role/server.yaml runs its own pacman.
    sed -i "s/^#DisableSandboxSyscalls/DisableSandboxSyscalls/" /etc/pacman.conf
    pacman -Syu --noconfirm --needed sudo git curl ca-certificates python make
  elif command -v apt-get > /dev/null 2>&1; then
    banner "Bootstrapping Debian/Ubuntu"
    export DEBIAN_FRONTEND=noninteractive
    apt-get update
    apt-get install -y --no-install-recommends \
      sudo git curl ca-certificates python3 make
  else
    echo "error: no supported package manager in this image" >&2
    exit 1
  fi
}

create_smoke_user() {
  banner "Creating the ${smoke_user} user"
  if ! id "${smoke_user}" > /dev/null 2>&1; then
    useradd --create-home --shell /bin/bash "${smoke_user}"
  fi
  printf '%s ALL=(ALL) NOPASSWD: ALL\n' "${smoke_user}" > "/etc/sudoers.d/${smoke_user}"
  chmod 0440 "/etc/sudoers.d/${smoke_user}"

  # The repo links ~/.bashrc.local but nothing on Linux sources it (macOS
  # gets there through bash/bash_profile), so wire it the way a person
  # would before checking that an interactive bash loads clean.
  if [ ! -f "${smoke_home}/.bashrc" ]; then
    : > "${smoke_home}/.bashrc"
  fi
  printf '\n[ -f ~/.bashrc.local ] && . ~/.bashrc.local\n' >> "${smoke_home}/.bashrc"
}

stage_repo() {
  banner "Staging the repo at ${repo}"
  mkdir -p "$(dirname "${repo}")"
  cp -a "${src}" "${repo}"

  # Drop every .git so the copy cannot reach back at the host checkout,
  # then re-init. `make install` depends on `make update`, which runs
  # `git submodule update --init --recursive`; with no gitlinks in a fresh
  # index that is a clean no-op, and the submodule contents came along in
  # the copy. Cloning instead would not work from a git worktree, whose
  # .git is a file pointing outside the tree.
  find "${repo}" -name .git -prune -exec rm -rf {} +
  git init -q -b smoke "${repo}"

  chown -R "${smoke_user}:${smoke_user}" "${smoke_home}/dev"
}

phase_root() {
  install_bootstrap_packages
  create_smoke_user
  stage_repo

  # Hand off to the staged copy, not the mount: the copy is the tree
  # under test, and running it there needs no assumption about whether an
  # unprivileged user can read /src.
  banner "Handing off to ${smoke_user}"
  exec su - "${smoke_user}" -c \
    "SMOKE_INTERACTIVE=${smoke_interactive} bash ${repo}/.github/smoke/container.sh user ${mode}"
}

# What this proves: the shell starts interactively, sources its rc files,
# and reaches the command. It does not prove the rc file ran without
# errors along the way, since -c runs either way.
#
# Matching is a grep over the whole transcript rather than an equality
# test on the last line, because zsh emits terminal control bytes even
# with no tty and the rc files log as they load.
assert_shell_ok() {
  local label="$1"
  shift
  local out
  if out=$("$@" < /dev/null 2>&1) && printf '%s\n' "${out}" | grep -q "smoke-shell-ok"; then
    echo "  ✓ ${label}"
    return 0
  fi
  echo "✖ ${label} never reached the end of its rc file" >&2
  printf '%s\n' "${out}" | tail -n 30 >&2
  return 1
}

assert_interactive_shells() {
  if [ "${smoke_interactive}" = "0" ]; then
    banner "Skipping the interactive shell check (SMOKE_INTERACTIVE=0)"
    return 0
  fi

  banner "Interactive shells"
  # zsh pulls zinit and its plugins on this first run, so it is the one
  # step that still needs the network after the packages land.
  assert_shell_ok "zsh -ic" zsh -ic "echo smoke-shell-ok"
  assert_shell_ok "bash -ic" bash -ic "echo smoke-shell-ok"
}

phase_user_server() {
  banner "make server"
  make -C "${repo}" server

  banner "Link assertions"
  local layers=""
  for layer in $("${repo}/.github/smoke/layers.sh" list server); do
    layers="${layers} ${repo}/${layer}"
  done
  # shellcheck disable=SC2086 # the layer list is deliberately word split
  "${repo}/.github/smoke/assert-links.sh" "${HOME}" "${repo}" ${layers}

  assert_interactive_shells

  banner "Role file"
  role=$(cat "${repo}/.dotfiles_role")
  if [ "${role}" != "server" ]; then
    echo "✖ .dotfiles_role says '${role}', expected 'server'" >&2
    exit 1
  fi
  echo "  ✓ .dotfiles_role = server"
}

phase_user_desktop_links() {
  # shellcheck disable=SC2046 # the layer list is deliberately word split
  "${repo}/.github/smoke/dry-link.sh" "${repo}" \
    $("${repo}/.github/smoke/layers.sh" list desktop-linux)
}

phase_user() {
  # dotbot's own messages go to stderr while the commands it runs write to
  # stdout; without this the two interleave wrongly in a redirected log and
  # a failure looks like it happened somewhere it did not.
  export PYTHONUNBUFFERED=1

  # No tty means no TERM, and the shell modules call tput. A sane value
  # keeps the log about the install instead of about terminfo.
  export TERM="${TERM:-xterm-256color}"

  case "${mode}" in
    server) phase_user_server ;;
    desktop-links) phase_user_desktop_links ;;
    *)
      echo "error: unknown mode '${mode}'" >&2
      exit 2
      ;;
  esac
  banner "Smoke passed: ${mode}"
}

case "${phase}" in
  root) phase_root ;;
  user) phase_user ;;
  *)
    echo "error: unknown phase '${phase}'" >&2
    exit 2
    ;;
esac
