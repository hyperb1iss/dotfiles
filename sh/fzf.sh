# fzf.sh
# FZF configuration and custom functions shared between shells

# Skip on minimal installations
is_minimal && return 0

# Initialize fzf
if command -v fzf >/dev/null 2>&1; then
    # Set fd command name based on system
    if command -v fdfind >/dev/null 2>&1; then
        FD_COMMAND="fdfind"  # Ubuntu/Debian systems
    else
        FD_COMMAND="fd"      # Other systems
    fi

    # Default options
    export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border"
    
    # Preview options for file operations
    FZF_FILE_PREVIEW="--preview 'batcat --color=always --style=numbers --line-range=:500 {}'"
    
    export FZF_DEFAULT_COMMAND="$FD_COMMAND --type f --hidden --follow --exclude .git"
    export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
    export FZF_ALT_C_COMMAND="$FD_COMMAND --type d --hidden --follow --exclude .git"
    
    # Initialize shell completion and key bindings
    if [ -n "$BASH_VERSION" ]; then
        eval "$(fzf --bash)"
    elif [ -n "$ZSH_VERSION" ]; then
        eval "$(fzf --zsh)"
    fi

    # Custom functions using fzf
    
    # Interactive cd
    function fcd() {
        local dir
        dir=$($FD_COMMAND --type d --hidden --follow --exclude .git | fzf +m --preview 'tree -C {} | head -200') &&
        cd "$dir"
    }

    # Interactive file open
    function fopen() {
        local out
        out=$(fzf $FZF_FILE_PREVIEW)
        [ -n "$out" ] && ${EDITOR:-vim} "$out"
    }

    # Interactive process kill
    function fkill() {
        local pid
        if [ "$(id -u)" -eq 0 ]; then
            # If root, show all processes
            pid=$(ps -ef | sed 1d | fzf -m | awk '{print $2}')
        else
            # If normal user, only show own processes
            pid=$(ps -u "$USER" -f | sed 1d | fzf -m | awk '{print $2}')
        fi
        if [ -n "$pid" ]; then
            echo "Killing process(es): $pid"
            echo "$pid" | xargs kill -${1:-9}
        fi
    }

    # Interactive git add with multi-select support
    function gadd() {
        local files
        files=$(git status -s | fzf -m \
            --header 'Tab to select multiple files, Enter to add' \
            --preview 'git diff --color=always {2}' \
            --bind 'tab:toggle-out' \
            --bind 'shift-tab:toggle-in' \
            | awk '{print $2}')
        [ -n "$files" ] && echo "$files" | xargs git add && git status -s
    }

    # Interactive git checkout branch
    function gco() {
        local branches branch
        branches=$(git branch --all | grep -v HEAD) &&
        branch=$(echo "$branches" | fzf -d $((2 + $(wc -l <<< "$branches"))) +m --preview 'git log --color=always {}') &&
        git checkout $(echo "$branch" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    }

    # Interactive history search
    function fh() {
        local cmd
        if [ -n "$ZSH_VERSION" ]; then
            cmd=$(history -n -r 1 | fzf +s --tac)
        else
            cmd=$(history | fzf +s --tac | sed 's/ *[0-9]* *//')
        fi
        [ -n "$cmd" ] && print -z "$cmd"
    }

    # Interactive environment variable search
    function fenv() {
        local out
        out=$(env | fzf --preview 'echo {}')
        [ -n "$out" ] && echo "$out"
    }

    # Interactive ripgrep search
    function frg() {
        local file line
        read -r file line <<<"$(rg --line-number --no-heading $@ | fzf -0 -1 | awk -F: '{print $1, $2}')"
        [ -n "$file" ] && ${EDITOR:-vim} "$file" +"$line"
    }

    # Interactive docker container management
    function fdocker() {
        local container
        container=$(docker ps | fzf --header-lines=1 --preview 'docker logs --tail 50 {-1}' | awk '{print $1}')
        [ -n "$container" ] && docker exec -it "$container" /bin/bash
    }
fi 