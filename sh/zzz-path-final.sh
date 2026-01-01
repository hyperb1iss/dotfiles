# zzz-path-final.sh
# Final PATH ordering - runs last (zzz prefix for alphabetical order in bash)
# Ensures version managers like proto take precedence over system binaries

# Proto shims first for project-specific version detection
if [[ -d "$HOME/.proto/shims" ]]; then
  # Remove existing proto paths to avoid duplicates, then prepend
  PATH=$(echo "$PATH" | tr ':' '\n' | grep -v "\.proto" | tr '\n' ':' | sed 's/:$//')
  export PATH="$HOME/.proto/shims:$HOME/.proto/bin:$PATH"
fi
