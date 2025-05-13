# Process management utilities and enhancements

# Enhanced procs functions - colorful process management
if has_command procs; then
	# Show processes for current user
	function pme() {
		procs "$(whoami)" "$@"
	}

	# Show process tree
	function ptree() {
		procs --tree "$@"
	}

	# Watch processes (like top)
	function pwatch() {
		procs --watch "$@"
	}

	# Find processes by keyword
	function pfind() {
		if [[ $# -eq 0 ]]; then
			echo "Usage: pfind <keyword>"
			return 1
		fi
		procs "$@"
	}

	# Kill processes matching pattern
	function pk() {
		if [[ $# -eq 0 ]]; then
			echo "Usage: pk <pattern>"
			return 1
		fi

		local pattern="$1"
		local pids
		pids=$(procs "${pattern}" --only pid --no-header | tr -d '\n')

		if [[ -z "${pids}" ]]; then
			echo "No processes matching '${pattern}' found."
			return 0
		fi

		echo "The following processes will be terminated:"
		procs "${pattern}"

		# shellcheck disable=SC2086
		kill ${pids}
	}
fi

# Traditional process utilities (fallbacks and additional tools)
# Find process by name
function pgrep_custom() {
	if [[ $# -eq 0 ]]; then
		echo "Usage: pgrep_custom <pattern>"
		return 1
	fi

	pgrep -f -a "$1"
}

# Memory usage by process (sorted)
function pmem() {
	ps aux | sort -nrk 4 | head -n "${1:-10}"
}

# CPU usage by process (sorted)
function pcpu() {
	ps aux | sort -nrk 3 | head -n "${1:-10}"
}
