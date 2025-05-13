# directory.sh
# Directory navigation and listing utilities

# Enhanced ls commands using lsd
alias ls='lsd'
alias ll='ls -l'
alias la='ls -la'
alias lla='ls -la'
alias lt='ls --tree'

# Directory navigation
function mkcd() {
	mkdir -p "$1" && cd "$1" || return
}

# Quick directory creation and navigation
function take() {
	mkdir -p "$@" && cd "${@:$#}" || return
}

# Interactive directory navigation using fzf
function fcd() {
	local dir
	dir=$(find "${1:-.}" -path '*/\.*' -prune -o -type d -print 2> /dev/null | fzf +m) || return
	if [[ -n "${dir}" ]]; then
		cd "${dir}" || return
	fi
}

# Show directory size in human readable format
function duh() {
	du -h --max-depth=1 "${1:-.}" | sort -hr
}

# Quick find files in current directory
function ff() {
	find . -type f -iname "*$1*"
}

# Go up N directories
function up() {
	local d=""
	local limit="$1"

	# Default to 1 level if no number specified
	if [[ -z "${limit}" ]] || [[ "${limit}" -le 0 ]]; then
		limit=1
	fi

	for ((i = 1; i <= limit; i++)); do
		d="../${d}"
	done

	cd "${d}" || return
}

# Create a directory tree
function mktree() {
	mkdir -p "$@" && tree "$@"
}

# Interactive directory size visualization
function dv() {
	du -d 1 -h "${1:-.}" | sort -hr | fzf --preview 'tree -C {2}' --preview-window=right:60%
}

# Bookmark management for directories
export BOOKMARKS_FILE="${HOME}/.bookmarks"

function mark() {
	local mark_name="$1"
	if [[ -z "${mark_name}" ]]; then
		echo "Usage: mark <bookmark_name>"
		return 1
	fi
	echo "${mark_name}:${PWD}" >> "${BOOKMARKS_FILE}"
	sort -u -o "${BOOKMARKS_FILE}" "${BOOKMARKS_FILE}"
	echo "Bookmark '${mark_name}' created for ${PWD}"
}

function unmark() {
	local mark_name="$1"
	if [[ -z "${mark_name}" ]]; then
		echo "Usage: unmark <bookmark_name>"
		return 1
	fi
	# shellcheck disable=SC2016
	sed -i.bak "/^${mark_name}:/d" "${BOOKMARKS_FILE}" && rm -f "${BOOKMARKS_FILE}.bak"
	echo "Bookmark '${mark_name}' removed"
}

function marks() {
	if [[ ! -f "${BOOKMARKS_FILE}" ]]; then
		echo "No bookmarks found"
		return
	fi
	column -t -s ':' < "${BOOKMARKS_FILE}"
}

function jump() {
	local mark_name="$1"
	if [[ -z "${mark_name}" ]]; then
		# Interactive selection if no bookmark specified
		local selection
		selection=$(< "${BOOKMARKS_FILE}" fzf --preview "tree -C \$(echo {2})" | cut -d ':' -f2) || return
		if [[ -n "${selection}" ]]; then
			cd "${selection}" || return
		fi
	else
		local dir
		dir=$(grep "^${mark_name}:" "${BOOKMARKS_FILE}" | cut -d ':' -f2)
		if [[ -n "${dir}" ]]; then
			cd "${dir}" || return
		else
			echo "Bookmark '${mark_name}' not found"
			return 1
		fi
	fi
}

# Initialize bookmarks file if it doesn't exist
[[ -f "${BOOKMARKS_FILE}" ]] || touch "${BOOKMARKS_FILE}" 2> /dev/null
