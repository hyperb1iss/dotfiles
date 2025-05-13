# git.sh
# Comprehensive Git utilities for bash and zsh

# Git Aliases
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gb='git branch'
alias gba='git branch -a'
alias gc='git cherry-pick'
alias gcom='git commit -v'
alias gcom!='git commit -v --amend'
alias gcomn!='git commit -v --no-edit --amend'
alias gcoma='git commit -v -a'
alias gcoma!='git commit -v -a --amend'
alias gcomm='git commit -m'
alias gcoman!='git commit -v -a --no-edit --amend'
alias gcomans!='git commit -v -a -s --no-edit --amend'
alias gd='git diff'
alias gdca='git diff --cached'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gfo='git fetch origin'
alias gl='git pull'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpsup='git push --set-upstream origin $(git_current_branch)'
alias gst='git status'
alias gsw='git switch'
alias gswc='git switch -c'

# Enhanced Git Functions

# Get current branch name
function git_current_branch() {
    git branch --show-current 2>/dev/null
}

# Interactive git add using fzf
function gadd() {
    local files
    files=$(git status -s | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}') || return 0
    if [[ -n "${files}" ]]; then
        echo "${files}" | xargs git add
        echo "Added files:"
        echo "${files}" | sed 's/^/  /'
    fi
}

# Interactive git checkout branch
function gco() {
    local branches branch
    branches=$(git branch --all | grep -v HEAD) || return 0
    
    if [[ -n "${branches}" ]]; then
        branch=$(echo "${branches}" | fzf -d $((2 + $(wc -l <<<"${branches}"))) +m --preview 'git log --color=always {}') || return 0
        git checkout "$(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
    fi
}

# Interactive git log browser
function glog() {
    # Define PAGER if not set
    PAGER=${PAGER:-less}
    export PAGER
    
    git log --graph --color=always \
        --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" |
        fzf --ansi --no-sort --reverse --tac --toggle-sort=\` \
            --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | ${PAGER}') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Interactive git stash operations
function gstash() {
    local cmd="git stash list"
    local preview="git stash show -p {1} --color=always"
    local selection stash_id
    
    selection=$(eval "${cmd}" | fzf --preview "${preview}" --height 80%) || return 0
    
    if [[ -n "${selection}" ]]; then
        stash_id=$(echo "${selection}" | cut -d: -f1)
        echo "Actions: [a]pply, [p]op, [d]rop, [s]how, [b]ranch"
        read -r action
        
        case "${action}" in
        a) git stash apply "${stash_id}" ;;
        p) git stash pop "${stash_id}" ;;
        d) git stash drop "${stash_id}" ;;
        s) git stash show -p "${stash_id}" | ${PAGER:-less} ;;
        b) git stash branch "stash-branch-$(date +%Y%m%d)" "${stash_id}" ;;
        *) echo "Invalid action" ;;
        esac
    fi
}

# Interactive git rebase
function grebase() {
    local commits
    commits=$(git log --oneline -n 50 --color=always | fzf --ansi --multi --preview 'git show --color=always {1}' | cut -d' ' -f1) || return 0
    
    if [[ -n "${commits}" ]]; then
        git rebase -i "$(echo "${commits}" | tail -n1)^"
    fi
}

# Setup git repository with common configurations
function gsetup() {
    # Configure common settings
    git config pull.rebase true
    git config push.default current
    git config core.autocrlf input
    git config core.fileMode true

    # Ask for user details if not set
    if [[ -z "$(git config --global user.email)" ]]; then
        read -r email?"Git email: "
        git config --global user.email "${email}"
    fi
    if [[ -z "$(git config --global user.name)" ]]; then
        read -r name?"Git name: "
        git config --global user.name "${name}"
    fi

    # Initialize main branch
    git checkout -b main 2>/dev/null || true

    # Create initial .gitignore
    if [[ ! -f .gitignore ]]; then
        cat >.gitignore <<'EOF'
# OS generated files
.DS_Store
.DS_Store?
._*
.Spotlight-V100
.Trashes
ehthumbs.db
Thumbs.db

# Editor files
.idea/
.vscode/
*.swp
*.swo
*~

# Build output
/build/
/dist/
/out/

# Dependencies
/node_modules/
/vendor/
EOF
    fi

    git add .gitignore
    git commit -m "Initial commit" 2>/dev/null || true
}

# Clean git branches
function gclean() {
    # Remove merged local branches
    git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d || true

    # Remove remote tracking branches that no longer exist
    git fetch --prune

    echo "Branches cleaned"
}

# Show git repository status with enhanced output
function gstatus() {
    local status_output
    status_output=$(git status --porcelain) || return 0
    
    if [[ -n "${status_output}" ]]; then
        echo "Modified files:"
        echo "${status_output}" | grep "^.M" | cut -c4- | sed 's/^/  /'
        printf "\nStaged files:\n"
        echo "${status_output}" | grep "^M" | cut -c4- | sed 's/^/  /'
        printf "\nUntracked files:\n"
        echo "${status_output}" | grep "^??" | cut -c4- | sed 's/^/  /'
    else
        echo "Working directory clean"
    fi
}

# Initialize git completion
if [[ -n "${ZSH_VERSION}" ]]; then
    # ZSH completion
    fpath=(~/.zsh/completion "${fpath[@]}")
    autoload -Uz compinit && compinit
elif [[ -n "${BASH_VERSION}" ]]; then
    # Bash completion
    if [[ -f /usr/share/bash-completion/completions/git ]]; then
        source /usr/share/bash-completion/completions/git
    fi
fi

# Git prompt configuration
export GIT_PS1_SHOWDIRTYSTATE=1
export GIT_PS1_SHOWSTASHSTATE=1
export GIT_PS1_SHOWUNTRACKEDFILES=1
export GIT_PS1_SHOWUPSTREAM="verbose"
