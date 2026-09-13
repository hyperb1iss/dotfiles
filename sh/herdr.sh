# herdr.sh
# Herdr, the terminal workspace manager the coding agents run inside
# https://herdr.dev

# Skip entire module if not in full installation
is_minimal && return 0

has_command herdr || return 0

# Completions come from the binary, cached until it changes; the zsh
# script registers its own compdef when sourced.
if is_zsh; then
  cached_eval herdr herdr-completion.zsh herdr completion zsh
elif is_bash; then
  cached_eval herdr herdr-completion.bash herdr completion bash
fi
