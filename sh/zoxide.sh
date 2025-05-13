#!/bin/bash
# zoxide.sh - Fast directory navigation using zoxide
# https://github.com/ajeetdsouza/zoxide

# Initialize zoxide for the current shell
if command -v zoxide > /dev/null 2>&1; then
	# Determine shell name if not already set
	SHELL_NAME=${SHELL_NAME:-$(if [[ -n "${ZSH_VERSION}" ]]; then echo "zsh"; else echo "bash"; fi)}

	# Initialize with 'z' as the command (compatible with previous z.sh)
	# shellcheck disable=SC1090
	eval "$(zoxide init "${SHELL_NAME}" --cmd z)" || true
fi
