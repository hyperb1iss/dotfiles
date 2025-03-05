# Process management utilities and enhancements

# Enhanced procs functions - colorful process management
if command -v procs >/dev/null 2>&1; then
    # Show processes for current user
    pme() {
        procs "$(whoami)" "$@"
    }

    # Show process tree
    ptree() {
        procs --tree "$@"
    }

    # Watch processes (like top)
    pwatch() {
        procs --watch "$@"
    }

    # Find processes by keyword
    pfind() {
        if [ $# -eq 0 ]; then
            echo "Usage: pfind <keyword>"
            return 1
        fi
        procs "$@"
    }

    # Kill processes matching pattern
    pk() {
        if [ $# -eq 0 ]; then
            echo "Usage: pk <pattern>"
            return 1
        fi

        local pattern="$1"
        local pids=$(procs "$pattern" --only pid --no-header | tr -d '\n')

        if [ -z "$pids" ]; then
            echo "No processes matching '$pattern' found."
            return 0
        fi

        echo "The following processes will be terminated:"
        procs "$pattern"

        kill $pids
    }
fi

# Traditional process utilities (fallbacks and additional tools)
# Find process by name
pgrep_custom() {
    if [ $# -eq 0 ]; then
        echo "Usage: pgrep_custom <pattern>"
        return 1
    fi

    ps aux | grep -i "$1" | grep -v grep
}

# Memory usage by process (sorted)
pmem() {
    ps aux | sort -nrk 4 | head -n "${1:-10}"
}

# CPU usage by process (sorted)
pcpu() {
    ps aux | sort -nrk 3 | head -n "${1:-10}"
}
