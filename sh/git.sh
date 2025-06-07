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
  git branch --show-current 2> /dev/null
}

# Interactive git add using fzf
function gadd() {
  local files
  files=$(git status -s | fzf -m --preview 'git diff --color=always {2}' | awk '{print $2}') || return 0
  if [[ -n "${files}" ]]; then
    echo "${files}" | xargs git add
    echo "Added files:"
    while IFS= read -r file; do
      echo "  ${file}"
    done <<< "${files}"
  fi
}

# Interactive git checkout branch
function gco() {
  local branches branch
  branches=$(git branch --all | grep -v HEAD) || return 0

  if [[ -n "${branches}" ]]; then
    branch=$(echo "${branches}" | fzf -d $((2 + $(wc -l <<< "${branches}"))) +m --preview 'git log --color=always {}') || return 0
    git checkout "$(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")"
  fi
}

# Interactive git log browser
function glog() {
  # Define PAGER if not set
  PAGER=${PAGER:-less}
  export PAGER

  git log --graph --color=always \
    --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" \
    | fzf --ansi --no-sort --reverse --tac --toggle-sort=\` \
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
  local email name

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
  git checkout -b main 2> /dev/null || true

  # Create initial .gitignore
  if [[ ! -f .gitignore ]]; then
    cat > .gitignore << 'EOF'
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
  git commit -m "Initial commit" 2> /dev/null || true
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
    local modified_files
    modified_files=$(echo "${status_output}" | grep "^.M" | cut -c4-)
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo "  ${file}"
    done <<< "${modified_files}"

    printf "\nStaged files:\n"
    local staged_files
    staged_files=$(echo "${status_output}" | grep "^M" | cut -c4-)
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo "  ${file}"
    done <<< "${staged_files}"

    printf "\nUntracked files:\n"
    local untracked_files
    untracked_files=$(echo "${status_output}" | grep "^??" | cut -c4-)
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo "  ${file}"
    done <<< "${untracked_files}"
  else
    echo "Working directory clean"
  fi
}

# Initialize git completion
if is_zsh; then
  # ZSH completion
  fpath=(~/.zsh/completion "${fpath[@]}")
elif is_bash; then
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

# ============================================================================
# Git Worktree Management System
# ============================================================================

# Simple, robust git worktree manager
function gwt() {
  case "$1" in
    ls | list)
      echo "📁 Git Worktrees"
      # Use porcelain format for reliable parsing
      local cur_pwd
      cur_pwd=$(pwd)
      git worktree list --porcelain | awk -v cur="${cur_pwd}" '
      /^worktree / {
        path=$2;
        getline; # skip HEAD line
        getline; # branch line
        branch=$2; sub("refs/heads/", "", branch);
        short=path;
        sub(/.*\//, "", short); # basename
        prefix=(path==cur)?"→":" ";
        printf "%s %s (%s) [%s]\n", prefix, short, branch, path;
      }'
      ;;

    cd | switch)
      local selection
      selection=$(git worktree list | fzf --header="Select worktree:" | awk '{print $1}')
      if [[ -n "${selection}" ]]; then
        cd "${selection}" || return 1
      fi
      ;;

    new | add)
      local branch="$2"
      local wt_path="$3"

      # If branch not provided, let user pick one interactively
      if [[ -z "${branch}" ]]; then
        branch=$(git for-each-ref --format='%(refname:short)' refs/heads | fzf --header="Select base branch:") || return 1
      fi

      # Compute default worktree path under /tmp/<repo>/<branch>
      if [[ -z "${wt_path}" ]]; then
        local repo_root repo_name
        repo_root=$(git rev-parse --show-toplevel)
        repo_name=$(basename "${repo_root}")
        wt_path="/tmp/${repo_name}/${branch}"
      fi

      mkdir -p "$(dirname "${wt_path}")"

      if git worktree add -b "${branch}" "${wt_path}"; then
        echo "✅ Created worktree: ${wt_path} (switching)"
        cd "${wt_path}" || return 1
      fi
      ;;

    rm | remove | del)
      # Use porcelain output for reliable parsing and exclude main worktree
      local main_path
      main_path=$(git rev-parse --show-toplevel)
      local pattern="$2"
      local candidates sel_count selection

      # Build candidate list: one path per worktree (excluding main)
      candidates=$(git worktree list --porcelain | awk '/^worktree /{path=$2;getline;getline;branch=$2;sub("refs/heads/","",branch);short=path;sub(/.*\//,"",short); if (path!="'"${main_path}"'") {printf "%s\t%s\t%s\n", path, short, branch}}')

      if [[ -n "${pattern}" ]]; then
        # Filter candidates by pattern match against path, short name, or branch
        selection=$(echo "${candidates}" | awk -v p="${pattern}" '$0 ~ p {print $1}')
        sel_count=$(echo "${selection}" | wc -l | tr -d ' ')
        if [[ ${sel_count} -gt 1 ]]; then
          # Ambiguous: let user choose
          selection=$(echo "${selection}" | fzf --header="Multiple matches, select worktree to remove:") || return 0
        fi
      else
        # No pattern supplied: interactive selection
        selection=$(echo "${candidates}" | awk '{print $1" ("$3")"}' | fzf --with-nth=1 --header="Select worktree to remove:" | awk '{print $1}') || return 0
      fi

      if [[ -z "${selection}" ]]; then
        echo "No worktree selected."
        return 0
      fi

      echo "🗑️  Removing worktree: ${selection}"
      git worktree remove "${selection}" || {
        echo "Failed to remove worktree ${selection}"
        return 1
      }
      ;;

    clean)
      echo "🧹 Cleaning worktrees..."
      git worktree prune
      ;;

    info)
      echo "📊 Current worktree: $(git rev-parse --show-toplevel)"
      echo "Branch: $(git branch --show-current)"
      echo "Commit: $(git rev-parse --short HEAD)"
      ;;

    help | *)
      echo "Git Worktree Manager"
      echo "Usage: gwt <command>"
      echo ""
      echo "Commands:"
      echo "  ls      List all worktrees"
      echo "  cd      Switch to a worktree"
      echo "  new     Create new worktree"
      echo "  rm      Remove a worktree"
      echo "  clean   Clean up stale worktrees"
      echo "  info    Show current worktree info"
      ;;
  esac
}
