# Terminal title management functions

# Get the last component of the current directory
function normalize_path() {
	local path=${PWD/#$HOME/\~}
	echo "${path##*/}"
}

# Set the terminal title with optional prefix
function set_terminal_title() {
	local title_prefix=""
	local normalized_path
	normalized_path=$(normalize_path)

	# Add target product prefix for Android development if applicable
	[[ -n "${TARGET_PRODUCT}" ]] && title_prefix="[${TARGET_PRODUCT}-${TARGET_BUILD_VARIANT}] "

	# Set the terminal title, including debian chroot if present
	# shellcheck disable=SC1090
	echo -ne "\033]0;${title_prefix}${debian_chroot:+($debian_chroot)}${USER}@${HOSTNAME}: ${normalized_path}\007"
}

# Setup terminal title updating based on shell
function setup_terminal_title() {
	if [[ -n "${ZSH_VERSION}" ]]; then
		# For zsh, use precmd
		# shellcheck disable=SC2154,SC2034
		precmd() { set_terminal_title; }
	elif [[ -n "${BASH_VERSION}" ]]; then
		# For bash, use PROMPT_COMMAND
		PROMPT_COMMAND="set_terminal_title"
	fi
}

# Initialize terminal title updating
setup_terminal_title
