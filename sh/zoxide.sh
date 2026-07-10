# zoxide.sh
# Fast directory navigation using zoxide
# https://github.com/ajeetdsouza/zoxide

# Skip entire module if not in full installation
is_minimal && return 0

# Initialize zoxide for the current shell
# Initialize with 'z' as the command (compatible with previous z.sh)
if is_zsh; then
  cached_eval zoxide zoxide-init.zsh zoxide init zsh --cmd z
elif is_bash; then
  cached_eval zoxide zoxide-init.bash zoxide init bash --cmd z
fi
