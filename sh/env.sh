# env.sh
# Environment variables and path configurations
# Shell-agnostic environment setup for both bash and zsh

# Ensure LS_COLORS is set if dircolors exists
if has_command dircolors; then
  eval "$(dircolors -b ~/.dircolors)" || true
fi

# Development tool configurations
export USE_CCACHE=1
export CCACHE_EXEC=/usr/bin/ccache

# Development paths
export GOPATH=~/dev/go

# Editor configuration
export VISUAL=nvim
export EDITOR="${VISUAL}"

# Set up bat/batcat aliases based on what's available
if has_command batcat; then
  alias bat="batcat"
elif has_command bat; then
  alias batcat="bat"
fi

# HOSTNAME
if [[ -n "${HOSTNAME:-}" ]]; then
  export HOSTNAME
elif [[ -n "${HOST:-}" ]]; then
  export HOSTNAME="${HOST}"
else
  HOSTNAME=$(hostname)
  export HOSTNAME
fi

# PATH configuration - separate declaration and assignment to avoid masking return values
PATH_COMPONENTS=""
PATH_COMPONENTS+="${HOME}/.cargo/bin:"
PATH_COMPONENTS+="${GOPATH}/bin:"
PATH_COMPONENTS+="${HOME}/.local/bin:"
PATH_COMPONENTS+="${HOME}/bin:"
# Add snap bin if it exists
[[ -d /snap/bin ]] && PATH_COMPONENTS+="/snap/bin:"
PATH_COMPONENTS+="${PATH}"

# Collapse repeated path separators without spawning subprocesses
PATH_TEMP="${PATH_COMPONENTS}"
while [[ "${PATH_TEMP}" == *::* ]]; do
  PATH_TEMP=${PATH_TEMP//::/:}
done
PATH_TEMP=${PATH_TEMP#:}
PATH_TEMP=${PATH_TEMP%:}
export PATH="${PATH_TEMP}"

# FZF configuration handled by sh/fzf.sh — no duplicate here

# Source private environment variables if they exist
# shellcheck source=/home/bliss/dev/dotfiles-private/env/private.sh
safe_source ~/dev/dotfiles-private/env/private.sh

# pnpm global bin
if [[ "$OSTYPE" == "darwin"* ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
else
  export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac

# Podman - set DOCKER_HOST so Docker Compose v2 talks to the Podman socket
if [ -z "$DOCKER_HOST" ] && [ -S "${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock" ]; then
  export DOCKER_HOST="unix://${XDG_RUNTIME_DIR:-/run/user/$(id -u)}/podman/podman.sock"
fi

# proto - multi-language version manager (last = highest priority, overrides homebrew/pnpm/system)
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# claude code
#export CLAUDE_CODE_EFFORT_LEVEL=max
#export CLAUDE_CODE_DISABLE_ADAPTIVE_THINKING=true

# npm global bin — proto shims don't cover `npm install -g` binaries,
# so resolve the active node version's bin dir without spawning node
if [[ -d "$PROTO_HOME/tools/node" ]]; then
  _dotfiles_cache_dir="${XDG_CACHE_HOME:-${HOME}/.cache}/dotfiles"
  _proto_node_cache="${_dotfiles_cache_dir}/proto-node-bin"
  mkdir -p "${_dotfiles_cache_dir}"

  if [[ ! -s "${_proto_node_cache}" ||
    "${PROTO_HOME}/shims/node" -nt "${_proto_node_cache}" ||
    "${PROTO_HOME}/tools/node" -nt "${_proto_node_cache}" ||
    "${PROTO_HOME}/.prototools" -nt "${_proto_node_cache}" ]]; then
    _node_ver="$(proto bin node 2> /dev/null)"
    _node_ver="${_node_ver%/bin/node}"
    if [[ -d "${_node_ver}/bin" ]]; then
      printf '%s\n' "${_node_ver}/bin" > "${_proto_node_cache}"
    else
      : > "${_proto_node_cache}"
    fi
    unset _node_ver
  fi

  if [[ -s "${_proto_node_cache}" ]]; then
    IFS= read -r _proto_node_bin < "${_proto_node_cache}"
    [[ -d "${_proto_node_bin}" ]] && export PATH="${_proto_node_bin}:$PATH"
    unset _proto_node_bin
  fi

  unset _proto_node_cache _dotfiles_cache_dir
fi

# Activate proto for version detection (respects .nvmrc, .prototools, etc.)
if command -v proto &> /dev/null; then
  if [[ -n "$ZSH_VERSION" ]]; then
    eval "$(proto activate zsh 2> /dev/null)"
  elif [[ -n "$BASH_VERSION" ]]; then
    eval "$(proto activate bash 2> /dev/null)"
  fi
fi
