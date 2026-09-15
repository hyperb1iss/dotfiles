# helix.sh
# Helix borrows Neovim's toolbox.
# https://helix-editor.com
#
# Mason installs every language server and formatter the Neovim config
# uses under ~/.local/share/nvim/mason/bin, and Helix resolves the same
# binaries by name on PATH. Appending that directory means ruff, ty, vtsls,
# marksman, taplo, prettier and friends light up in Helix with no second
# install, while brew, rustup and proto keep winning for anything they also
# ship. `hx --health <language>` shows what each language resolved to.
#
# No role guard: a box without Mason simply has nothing to append.

_mason_bin="${HOME}/.local/share/nvim/mason/bin"
if [[ -d "${_mason_bin}" ]]; then
  case ":${PATH}:" in
    *":${_mason_bin}:"*) ;;
    *) export PATH="${PATH}:${_mason_bin}" ;;
  esac
fi
unset _mason_bin
