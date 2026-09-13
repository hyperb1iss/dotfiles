# zoxide.sh
# Fast directory navigation using zoxide
# https://github.com/ajeetdsouza/zoxide
#
# Every role installs zoxide (packages.conf lists it for desktop and
# server alike), so this module carries no role guard: a box that has the
# binary gets z, whatever profile it was installed with. cached_eval
# already returns quietly when the binary is missing.

# Initialize with 'z' as the command (compatible with previous z.sh)
if is_zsh; then
  cached_eval zoxide zoxide-init.zsh zoxide init zsh --cmd z
elif is_bash; then
  cached_eval zoxide zoxide-init.bash zoxide init bash --cmd z
fi
