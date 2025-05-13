#!/bin/bash
# rust.sh
#
# Rust development helper functions for both bash and zsh
# Provides aliases and functions to streamline your Cargo workflow

# Skip entire module if not in full installation
is_minimal && return 0

# Aliases for common Cargo commands
alias cr='cargo run'
alias cb='cargo build'
alias ct='cargo test'
alias cf='cargo fmt'
alias cc='cargo clippy'
alias cbench='cargo bench'

# Helper to add dependencies using cargo-add (from cargo-edit)
function cadd() {
	if command -v cargo-add >/dev/null 2>&1; then
		cargo add "$@"
	else
		echo "cargo-add is not installed. Try 'cargo install cargo-edit'"
	fi
}

# Run cargo-watch to automatically rebuild/test on file changes.
function cwatch() {
	if command -v cargo-watch >/dev/null 2>&1; then
		cargo watch "$@"
	else
		echo "cargo-watch is not installed. Try 'cargo install cargo-watch'"
	fi
}

# Interactive toolchain switcher using rustup and fzf.
function rswitch() {
	if command -v rustup >/dev/null 2>&1 && command -v fzf >/dev/null 2>&1; then
		local toolchain
		toolchain=$(rustup toolchain list | fzf --height 40% --reverse --prompt="Select Rust toolchain: ")
		if [[ -n "${toolchain}" ]]; then
			# Extract the toolchain name (the first word)
			# shellcheck disable=SC2086
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
