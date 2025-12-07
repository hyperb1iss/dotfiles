# zp.sh
# zoxide with pushd/popd semantics - combines smart directory jumping with navigation stack
# Requires: zoxide

# Skip if zoxide is not available
has_command zoxide || return 0

# Initialize the directory stack file
ZP_STACK_FILE="${ZP_STACK_FILE:-$HOME/.zp_stack}"
touch "$ZP_STACK_FILE"

function zp() {
  case "$1" in
    -p | --pop)
      # Pop from stack and go to previous directory
      if [[ -s "$ZP_STACK_FILE" ]]; then
        local prev_dir
        prev_dir=$(tail -n 1 "$ZP_STACK_FILE")
        if is_macos; then
          sed -i '' -e '$ d' "$ZP_STACK_FILE"
        else
          sed -i '$ d' "$ZP_STACK_FILE"
        fi
        if [[ -n "$prev_dir" ]]; then
          cd "$prev_dir" || return 1
          echo "→ $prev_dir"
        else
          echo "zp: stack empty" >&2
          return 1
        fi
      else
        echo "zp: stack empty" >&2
        return 1
      fi
      ;;
    -l | --list)
      # List the stack
      if [[ -s "$ZP_STACK_FILE" ]]; then
        echo "Directory stack:"
        nl -b a "$ZP_STACK_FILE" | tac
      else
        echo "zp: stack empty"
      fi
      ;;
    -c | --clear)
      # Clear the stack
      : > "$ZP_STACK_FILE"
      echo "zp: stack cleared"
      ;;
    -h | --help)
      cat << EOF
zp - zoxide with pushd/popd semantics

Usage:
  zp [QUERY...]     Jump to directory using zoxide (saves current dir to stack)
  zp -p, --pop      Pop from stack and return to previous directory
  zp -l, --list     List the directory stack
  zp -c, --clear    Clear the directory stack
  zp -h, --help     Show this help message

Examples:
  zp foo           Jump to a directory matching 'foo' (pushes current dir)
  zp -p            Return to previous directory (pops from stack)
  zp proj src      Jump to directory matching 'proj' and 'src'

Environment:
  ZP_STACK_FILE    Location of stack file (default: ~/.zp_stack)
EOF
      ;;
    *)
      # Push current directory to stack and use zoxide to jump
      if [[ -n "$1" ]]; then
        local current_dir
        current_dir=$(pwd)

        # Always push current directory before jumping
        echo "$current_dir" >> "$ZP_STACK_FILE"

        # Use z to jump (let zoxide handle the query internally)
        z "$@"
      else
        # No arguments - just show help
        zp --help
      fi
      ;;
  esac
}

# Optional: Add alias for quick pop
alias zpp='zp --pop'
