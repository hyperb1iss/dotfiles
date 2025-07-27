# rust.sh
#
# Rust development helper functions for both bash and zsh
# Provides aliases and functions to streamline your Cargo workflow

# Skip entire module if not in full installation
is_minimal && return 0

# Initialize Rust environment for Homebrew rustup
function rust_env_init() {
  if has_command rustup; then
    # Get the active toolchain and ensure it's in PATH
    local active_toolchain
    active_toolchain=$(rustup show active-toolchain 2>/dev/null | cut -d' ' -f1) || true

    if [[ -n "${active_toolchain}" ]]; then
      local toolchain_bin="${HOME}/.rustup/toolchains/${active_toolchain}/bin"
      if [[ -d "${toolchain_bin}" ]]; then
        # Add toolchain bin to PATH if not already present
        case ":${PATH}:" in
          *":${toolchain_bin}:"*) ;;
          *) export PATH="${toolchain_bin}:${PATH}" ;;
        esac
      fi
    fi

    # Ensure ~/.cargo/bin is in PATH for installed packages
    if [[ -d "${HOME}/.cargo/bin" ]]; then
      case ":${PATH}:" in
        *":${HOME}/.cargo/bin:"*) ;;
        *) export PATH="${HOME}/.cargo/bin:${PATH}" ;;
      esac
    fi
  fi
}

# Initialize Rust environment on module load
rust_env_init

# Aliases for common Cargo commands
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cf='cargo fmt'
alias cc='cargo clippy'
alias cbench='cargo bench'

# Helper to add dependencies using cargo-add (from cargo-edit)
function cadd() {
  if has_command cargo-add; then
    cargo add "$@"
  else
    echo "cargo-add is not installed. Try 'cargo install cargo-edit'"
  fi
}

# Run cargo-watch to automatically rebuild/test on file changes.
function cwatch() {
  if has_command cargo-watch; then
    cargo watch "$@"
  else
    echo "cargo-watch is not installed. Try 'cargo install cargo-watch'"
  fi
}

# Interactive toolchain switcher using rustup and fzf.
function rswitch() {
  if has_command rustup && has_command fzf; then
    local toolchain
    toolchain=$(rustup toolchain list | fzf --height 40% --reverse --prompt="Select Rust toolchain: ")
    if [[ -n "${toolchain}" ]]; then
      # Extract the toolchain name (the first word)
      toolchain=$(echo "${toolchain}" | awk '{print $1}')
      rustup override set "${toolchain}" && echo "Switched to ${toolchain}"
    fi
  else
    echo "Required tooling (rustup, fzf) not installed."
  fi
}

# Interactive Cargo dependency tree viewer using fzf.
function crtree() {
  if cargo tree --help >/dev/null 2>&1; then
    cargo tree | fzf --height 40% --reverse --prompt="Cargo dependency tree > " --preview 'echo {}'
  else
    echo "Cargo tree subcommand not found. Try 'cargo install cargo-tree'"
  fi
}
