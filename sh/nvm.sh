# nvm.sh
# Node Version Manager (NVM) setup and utilities
# Supports Homebrew installations on macOS and standard installations on Linux

# Skip entire module if not in full installation
is_minimal && return 0

# NVM environment setup
function setup_nvm() {
  # Create NVM directory if it doesn't exist
  if [[ ! -d "${HOME}/.nvm" ]]; then
    mkdir -p "${HOME}/.nvm"
  fi

  # Set NVM_DIR if not already set
  export NVM_DIR="${NVM_DIR:-${HOME}/.nvm}"

  # Platform-specific NVM setup
  if is_macos && has_command brew; then
    # macOS Homebrew installation
    local brew_prefix
    brew_prefix=$(brew --prefix) || return 1
    local nvm_script="${brew_prefix}/opt/nvm/nvm.sh"
    local nvm_completion="${brew_prefix}/opt/nvm/etc/bash_completion.d/nvm"

    if [[ -s "${nvm_script}" ]]; then
      # shellcheck disable=SC1090
      source "${nvm_script}"

      # Load bash completion if available
      if [[ -s "${nvm_completion}" ]]; then
        # shellcheck disable=SC1090
        source "${nvm_completion}"
      fi

      return 0
    fi
  fi

  # Standard NVM installation (Linux, manual macOS install)
  local nvm_script="${NVM_DIR}/nvm.sh"
  local nvm_completion="${NVM_DIR}/bash_completion"

  if [[ -s "${nvm_script}" ]]; then
    # shellcheck disable=SC1090
    source "${nvm_script}"

    # Load bash completion if available
    if [[ -s "${nvm_completion}" ]]; then
      # shellcheck disable=SC1090
      source "${nvm_completion}"
    fi

    return 0
  fi

  # If no NVM installation found, provide helpful guidance
  if ! has_command nvm; then
    echo "NVM not found. Install options:" >&2
    if is_macos; then
      echo "  macOS: brew install nvm" >&2
    fi
    echo "  Standard: curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.40.3/install.sh | bash" >&2
    return 1
  fi
}

# Initialize NVM
setup_nvm

# NVM utility functions (only available if NVM is loaded)
if has_command nvm; then
  # Quick install and use latest LTS Node.js
  function node-lts() {
    echo "Installing and using latest LTS Node.js..."
    nvm install --lts
    nvm use --lts
    nvm alias default node
    echo "Node.js LTS installed and set as default"
  }

  # Quick install and use latest stable Node.js
  function node-latest() {
    echo "Installing and using latest stable Node.js..."
    nvm install node
    nvm use node
    nvm alias default node
    echo "Latest Node.js installed and set as default"
  }

  # Interactive Node.js version switcher using fzf
  function node-switch() {
    if ! has_command fzf; then
      echo "fzf not available, falling back to standard nvm list"
      nvm list
      return 0
    fi

    local versions
    versions=$(nvm list | grep -v "^->" | sed 's/^[ *]*//' | grep -v "^$")

    if [[ -z "${versions}" ]]; then
      echo "No Node.js versions installed. Use 'node-lts' or 'node-latest' to install."
      return 1
    fi

    local selected
    selected=$(echo "${versions}" | fzf --height 40% --reverse --prompt="Select Node.js version > ") || return 0

    if [[ -n "${selected}" ]]; then
      # Extract version number, removing any extra characters
      local version
      version=$(echo "${selected}" | awk '{print $1}' | sed 's/^v//')
      nvm use "${version}"
    fi
  }

  # List installed Node.js versions with current highlighted
  function node-list() {
    nvm list
  }

  # Install specific Node.js version
  function node-install() {
    if [[ -z "$1" ]]; then
      echo "Usage: node-install <version>"
      echo "Examples:"
      echo "  node-install 18.17.0"
      echo "  node-install lts/hydrogen"
      echo "  node-install node  # latest stable"
      return 1
    fi

    nvm install "$1"
  }

  # Uninstall specific Node.js version
  function node-uninstall() {
    if [[ -z "$1" ]]; then
      echo "Usage: node-uninstall <version>"
      return 1
    fi

    nvm uninstall "$1"
  }

  # Show current Node.js and npm versions
  function node-info() {
    echo "Current Node.js version:"
    node --version
    echo "Current npm version:"
    npm --version
    echo "NVM version:"
    nvm --version
    echo "Default alias:"
    nvm alias default
  }

  # Automatically use .nvmrc file in current directory
  function auto-nvm() {
    if [[ -f ".nvmrc" ]]; then
      local nvmrc_version
      nvmrc_version=$(cat .nvmrc)
      echo "Found .nvmrc specifying Node.js ${nvmrc_version}"

      if nvm list | grep -q "${nvmrc_version}"; then
        nvm use
      else
        echo "Node.js ${nvmrc_version} not installed. Installing..."
        nvm install
        nvm use
      fi
    else
      echo "No .nvmrc file found in current directory"
    fi
  }

  # Create .nvmrc file with current Node.js version
  function nvmrc-create() {
    local current_version
    current_version=$(node --version)
    echo "${current_version}" >.nvmrc
    echo "Created .nvmrc with Node.js ${current_version}"
  }

  # Aliases for common operations
  alias n='node'
  alias npm-global='npm list -g --depth=0'
  alias npm-outdated='npm outdated'
  alias npm-update='npm update'
fi

# Auto-switch Node versions when entering directories with .nvmrc (optional)
# This can be enabled by setting NVM_AUTO_SWITCH=true in your environment
# shellcheck disable=SC2154  # NVM_AUTO_SWITCH is an optional user-defined environment variable
if [[ "${NVM_AUTO_SWITCH}" = "true" ]] && has_command nvm; then
  function nvm_auto_switch() {
    if [[ -f ".nvmrc" ]]; then
      local nvmrc_version
      nvmrc_version=$(tr -d '\r\n' <.nvmrc)
      local current_version
      current_version=$(nvm current)

      if [[ "v${nvmrc_version}" != "${current_version}" ]]; then
        if nvm list | grep -q "${nvmrc_version}"; then
          nvm use "${nvmrc_version}"
        else
          echo "Node.js ${nvmrc_version} not installed. Run 'nvm install ${nvmrc_version}' to install."
        fi
      fi
    fi
  }

  # Setup auto-switching based on shell
  if is_zsh; then
    autoload -Uz add-zsh-hook
    add-zsh-hook chpwd nvm_auto_switch
  elif is_bash; then
    # For bash, we'll add it to PROMPT_COMMAND
    if [[ "${PROMPT_COMMAND}" != *"nvm_auto_switch"* ]]; then
      PROMPT_COMMAND="nvm_auto_switch; ${PROMPT_COMMAND}"
    fi
  fi
fi
