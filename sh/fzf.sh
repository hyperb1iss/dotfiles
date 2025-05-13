# fzf.sh
# FZF configuration and custom functions shared between shells

# Skip on minimal installations
is_minimal && return 0

# Initialize fzf
if command -v fzf >/dev/null 2>&1; then
	# Set fd command name based on system
	if command -v fdfind >/dev/null 2>&1; then
		FD_COMMAND="fdfind" # Ubuntu/Debian systems
	else
		FD_COMMAND="fd" # Other systems
	fi

	# Default options
	export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"

	# Determine which bat command to use
	if command -v batcat >/dev/null 2>&1; then
		BAT_COMMAND="batcat"
	else
		BAT_COMMAND="bat"
	fi

	# Preview options for file operations
	# Using array for proper argument handling
	FZF_PREVIEW_CMD="${BAT_COMMAND} --color=always --style=numbers --line-range=:500 {}"
	# shellcheck disable=SC2016
	FZF_FILE_PREVIEW="--preview '${FZF_PREVIEW_CMD}'"

	export FZF_DEFAULT_COMMAND="${FD_COMMAND} --type f --hidden --follow --exclude .git"
	export FZF_CTRL_T_COMMAND="${FZF_DEFAULT_COMMAND}"
	export FZF_ALT_C_COMMAND="${FD_COMMAND} --type d --hidden --follow --exclude .git"

	# Initialize shell completion and key bindings
	if [[ -n "${BASH_VERSION}" ]]; then
		# shellcheck disable=SC1090
		eval "$(fzf --bash)" || true
	elif [[ -n "${ZSH_VERSION}" ]]; then
		# shellcheck disable=SC1090
		eval "$(fzf --zsh)" || true
	fi

	# Custom functions using fzf

	# Interactive cd
	function fcd() {
		local dir
		dir=$(${FD_COMMAND} --type d --hidden --follow --exclude .git | fzf +m --preview 'tree -C {} | head -200') || return
		if [[ -n "${dir}" ]]; then
			cd "${dir}" || return
		fi
	}

	# Interactive file open
	function fopen() {
		local out
		# Using preview command directly
		# shellcheck disable=SC2086
		out=$(fzf --preview "${FZF_PREVIEW_CMD}") || return
		if [[ -n "${out}" ]]; then
			${EDITOR:-vim} "${out}"
		fi
	}

	# Interactive process kill
	function fkill() {
		local pid
		if [[ "$(id -u)" -eq 0 ]]; then
			# If root, show all processes
			pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}') || return
		else
			# If normal user, only show own processes
			pid=$(ps -u "${USER}" -f | sed 1d | fzf -m | awk '{print $2}') || return
		fi
		if [[ -n "${pid}" ]]; then
			echo "Killing process(es): ${pid}"
			# shellcheck disable=SC2086
			echo "${pid}" | xargs kill -"${1:-9}"
		fi
	}

	# Interactive git add with multi-select support
	function gadd() {
		local files
		files=$(git status -s | fzf -m \
			--header 'Tab to select multiple files, Enter to add' \
			--preview 'git diff --color=always {2}' \
			--bind 'tab:toggle-out' \
			--bind 'shift-tab:toggle-in' |
			awk '{print $2}') || return
		if [[ -n "${files}" ]]; then
			# shellcheck disable=SC2086
			echo "${files}" | xargs git add && git status -s
		fi
	}

	# Interactive git checkout branch
	function gco() {
		local branches branch
		branches=$(git branch --all | grep -v HEAD) || return
		if [[ -n "${branches}" ]]; then
			# shellcheck disable=SC2086,SC2046
			branch=$(echo "${branches}" | fzf -d $((2 + $(wc -l <<<"${branches}"))) +m --preview 'git log --color=always {}') || return
			git checkout "$(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
		fi
	}

	# Interactive history search
	function fh() {
		local cmd
		if [[ -n "${ZSH_VERSION}" ]]; then
			cmd=$(history -n -r 1 | fzf +s --tac) || return
		else
			cmd=$(history | fzf +s --tac | sed 's/ *[0-9]* *//') || return
		fi
		if [[ -n "${cmd}" ]]; then
			# shellcheck disable=SC2154
			print -z "${cmd}"
		fi
	}

	# Interactive environment variable search
	function fenv() {
		local out
		out=$(env | fzf --preview 'echo {}') || return
		if [[ -n "${out}" ]]; then
			echo "${out}"
		fi
	}

	# Interactive ripgrep search
	function frg() {
		local file line
		# shellcheck disable=SC2162
		read -r file line <<<"$(rg --line-number --no-heading "$@" | fzf -0 -1 | awk -F: '{print $1, $2}')" || return
		if [[ -n "${file}" ]]; then
			${EDITOR:-vim} "${file}" +"${line}"
		fi
	}

	# Interactive docker container management
	function fdocker() {
		local container
		container=$(docker ps | fzf --header-lines=1 --preview 'docker logs --tail 50 {-1}' | awk '{print $1}') || return
		if [[ -n "${container}" ]]; then
			docker exec -it "${container}" /bin/bash
		fi
	}
fi
