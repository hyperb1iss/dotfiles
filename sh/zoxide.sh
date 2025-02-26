#!/bin/bash
# zoxide.sh - Fast directory navigation using zoxide
# https://github.com/ajeetdsouza/zoxide

# Initialize zoxide for the current shell
if command -v zoxide >/dev/null 2>&1; then
  # Initialize with 'z' as the command (compatible with previous z.sh)
  eval "$(zoxide init ${SHELL_NAME:-$([[ -n "$ZSH_VERSION" ]] && echo "zsh" || echo "bash")} --cmd z)"
fi 