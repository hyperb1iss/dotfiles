# zoxide.sh - Fast directory navigation using zoxide
# https://github.com/ajeetdsouza/zoxide

# Initialize zoxide for the current shell
if has_command zoxide; then
	# Initialize with 'z' as the command (compatible with previous z.sh)
	# shellcheck disable=SC1090
	if is_zsh; then
		eval "$(zoxide init zsh --cmd z)" || true
	elif is_bash; then
		eval "$(zoxide init bash --cmd z)" || true
	fi
fi
