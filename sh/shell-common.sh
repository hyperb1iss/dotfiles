# Common shell configurations for both bash and zsh

# History Configuration
HISTSIZE=50000
HISTFILESIZE=50000
HISTCONTROL=ignoreboth:erasedups
HISTTIMEFORMAT="%F %T "
HISTIGNORE="ls:ll:cd:pwd:clear:history:fg:bg:jobs"

# Environment detection functions
function get_installation_type() {
	local install_state_file="${HOME}/dev/dotfiles/.install_state"
	if [[ -f "${install_state_file}" ]]; then
		cat "${install_state_file}"
	else
		echo "unknown"
	fi
}

function is_minimal() {
	[[ "$(get_installation_type)" = "minimal" ]]
}

function is_full() {
	[[ "$(get_installation_type)" = "full" ]]
}

# Make functions available in bash
# (zsh automatically makes functions available to subshells)
if [[ -z "${ZSH_VERSION}" ]]; then
	export -f get_installation_type
	export -f is_minimal
	export -f is_full
fi

# Source all utility scripts
# shellcheck disable=SC2066
for script in "${HOME}/dev/dotfiles/sh/"*.sh; do
	if [[ "${script}" != *"shell-common.sh" ]]; then
		# shellcheck source=/home/bliss/dev/dotfiles/sh
		# shellcheck disable=SC1090
		source "${script}" || echo "Failed to load ${script}"
	fi
done

# Load private configurations if they exist
# shellcheck disable=SC1090
[[ -f ~/.rc.local ]] && source ~/.rc.local

# Determine shell name
SHELL_NAME=$(if [[ -n "${ZSH_VERSION}" ]]; then echo "zsh"; else echo "bash"; fi)

# Initialize Starship prompt (suppress error output on older versions)
# shellcheck disable=SC1090
eval "$(starship init "${SHELL_NAME}" 2>/dev/null)" || true

# Show inspirational quote for interactive shells (only in full installation)
if [[ $- == *i* ]] && is_full; then
	# Check if Python and the script exist
	if command -v python3 >/dev/null 2>&1 && [[ -f ~/dev/dotfiles/inspiration/inspiration.py ]]; then
		python3 ~/dev/dotfiles/inspiration/inspiration.py
	fi
fi
