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

# proto - multi-language version manager (last = highest priority, overrides homebrew/pnpm/system)
export PROTO_HOME="$HOME/.proto"
export PATH="$PROTO_HOME/shims:$PROTO_HOME/bin:$PATH"

# Activate proto for version detection (respects .nvmrc, .prototools, etc.)
if command -v proto &> /dev/null; then
  if [[ -n "$ZSH_VERSION" ]]; then
    eval "$(proto activate zsh 2> /dev/null)"
  elif [[ -n "$BASH_VERSION" ]]; then
    eval "$(proto activate bash 2> /dev/null)"
  fi
fi
