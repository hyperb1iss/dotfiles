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
    while IFS= read -r file; do
      echo "  ${file}"
    done <<<"${files}"
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
    local modified_files
    modified_files=$(echo "${status_output}" | grep "^.M" | cut -c4-)
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo "  ${file}"
    done <<<"${modified_files}"

    printf "\nStaged files:\n"
    local staged_files
    staged_files=$(echo "${status_output}" | grep "^M" | cut -c4-)
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo "  ${file}"
    done <<<"${staged_files}"

    printf "\nUntracked files:\n"
    local untracked_files
    untracked_files=$(echo "${status_output}" | grep "^??" | cut -c4-)
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo "  ${file}"
    done <<<"${untracked_files}"
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

# Modern git worktree manager
__gwt_usage() {
  cat <<'EOF'
Git Worktree Manager

Commands:
  list          Show all worktrees with recent commit context
  switch        Fuzzy-find and switch (cd) into a worktree
  new           Create a worktree from a base branch (defaults to origin/main)
  remove        Remove one or more worktrees (fzf-aware, skips main checkout)
  clean         Prune stale worktrees
  info          Show details about the current worktree

Flags:
  gwt list [--date|-d]                        Sort by date instead of branch name
  gwt new [branch] [--from base] [--path dir]
  gwt remove [pattern] [--force]

Run `gwt` with no arguments for an interactive action picker (requires fzf).
Configure defaults with:
  GWT_ROOT          Base directory for new worktrees (default: ~/dev/worktrees)
  GWT_DEFAULT_BASE  Default base branch when creating (default: origin/main)
EOF
}

__gwt_init_styles() {
  if [[ -n "${__GWT_STYLES_READY:-}" ]]; then
    return
  fi

  local colors_enabled=1
  if [[ ! -t 1 ]] || [[ -n "${NO_COLOR:-}" ]] || [[ -n "${GWT_NO_COLOR:-}" ]] || [[ "${TERM:-}" == "dumb" ]]; then
    colors_enabled=0
  fi

  if [[ ${colors_enabled} -eq 1 ]]; then
    # SilkCircuit Neon color palette
    GWT_RESET=$'\033[0m'
    GWT_BOLD=$'\033[1m'
    GWT_MUTED=$'\033[38;2;98;92;122m'         # Muted purple
    GWT_ACCENT=$'\033[38;2;225;53;255m'       # Electric Purple #e135ff
    GWT_BRANCH=$'\033[38;2;128;255;234m'      # Neon Cyan #80ffea
    GWT_HASH=$'\033[38;2;255;106;193m'        # Coral #ff6ac1
    GWT_AGE=$'\033[38;2;241;250;140m'         # Electric Yellow #f1fa8c
    GWT_PATH=$'\033[38;2;128;255;234m'        # Neon Cyan #80ffea
    GWT_STATUS_WARN=$'\033[38;2;241;250;140m' # Electric Yellow #f1fa8c
  else
    GWT_RESET=""
    GWT_BOLD=""
    GWT_MUTED=""
    GWT_ACCENT=""
    GWT_BRANCH=""
    GWT_HASH=""
    GWT_AGE=""
    GWT_PATH=""
    GWT_STATUS_WARN=""
  fi

  __GWT_STYLES_READY=1
}

__gwt_join_status_flags() {
  local flags="$1" status_parts=() token

  if [[ -z "${flags}" ]]; then
    printf ''
    return 0
  fi

  for token in ${flags}; do
    case "${token}" in
      prunable)
        status_parts+=("prunable")
        ;;
      locked)
        status_parts+=("locked")
        ;;
      bare)
        status_parts+=("bare")
        ;;
      *)
        status_parts+=("${token}")
        ;;
    esac
  done

  printf '%s' "${status_parts[*]}"
}

__gwt_require_repo() {
  if ! git rev-parse --show-toplevel >/dev/null 2>&1; then
    echo "gwt: not inside a git repository" >&2
    return 1
  fi
}

__gwt_have_fzf() {
  command -v fzf >/dev/null 2>&1
}

__gwt_require_fzf() {
  if ! __gwt_have_fzf; then
    echo "gwt: fzf is required for this action" >&2
    return 1
  fi
}

__gwt_expand_path() {
  local input="$1"
  if [[ -z "${input}" ]]; then
    return 1
  fi
  case "${input}" in
    ~)
      printf '%s\n' "${HOME}"
      ;;
    ~/*)
      printf '%s/%s\n' "${HOME}" "${input#~/}"
      ;;
    *)
      printf '%s\n' "${input}"
      ;;
  esac
}

__gwt_default_root() {
  local root
  root="${GWT_ROOT:-${GWT_DEFAULT_ROOT:-${HOME}/dev/worktrees}}"
  __gwt_expand_path "${root}"
}

__gwt_short_path() {
  local input="$1"
  if [[ -z "${input}" ]]; then
    printf ''
    return 0
  fi
  if [[ -n "${HOME}" && "${input}" == "${HOME}"* ]]; then
    printf '~%s' "${input#"${HOME}"}"
  else
    printf '%s' "${input}"
  fi
}

__gwt_collect_worktrees() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel) || return 1

  git worktree list --porcelain | awk -v repo_root="${repo_root}" '
    function flush() {
      if (wt_path == "") {
        return
      }
      gsub("^refs/heads/", "", branch)
      printf "%s\t%s\t%s\t%s\t%s\t%s\n", wt_path, branch, head, (wt_path==repo_root?"1":"0"), (detached?"1":"0"), flags
      wt_path=""; head=""; branch=""; detached=0; flags=""
    }
    /^worktree / { flush(); wt_path=$2 }
    /^HEAD / { head=$2 }
    /^branch / { branch=$2 }
    /^detached$/ { detached=1 }
    /^bare$/ { flags = (flags==""?"bare":flags" bare") }
    /^locked$/ { flags = (flags==""?"locked":flags" locked") }
    /^prunable / { flags = (flags==""?"prunable":flags" prunable") }
    /^$/ { flush() }
    END { flush() }
  '
}

__gwt_worktree_table() {
  emulate -L zsh 2>/dev/null || true
  setopt LOCAL_OPTIONS 2>/dev/null || true

  local data current_root WIDTH_MARK WIDTH_BRANCH WIDTH_HEAD WIDTH_UPDATED WIDTH_PATH sort_by
  sort_by="${1:-branch}" # Default to branch sorting

  data=$(__gwt_collect_worktrees) || return 1

  if [[ -z "${data}" ]]; then
    echo "No worktrees found."
    return 0
  fi

  __gwt_init_styles
  current_root=$(git rev-parse --show-toplevel 2>/dev/null)

  # Column widths
  WIDTH_MARK=2
  WIDTH_BRANCH=30
  WIDTH_HEAD=10
  WIDTH_UPDATED=16
  WIDTH_PATH=50

  # Print header and separator
  printf "${GWT_BOLD}%-2s %-30s %-10s %-16s %-50s %s${GWT_RESET}\n" "" \
    "BRANCH" "HEAD" "UPDATED" "PATH" "SUBJECT"
  printf -- '%.0s─' {1..160}
  printf '\n'

  # Print rows - using awk for cleaner processing with colors
  printf '%s\n' "${data}" | awk -F'\t' -v current="${current_root}" \
    -v w_mark="${WIDTH_MARK}" -v w_branch="${WIDTH_BRANCH}" \
    -v w_head="${WIDTH_HEAD}" -v w_updated="${WIDTH_UPDATED}" -v w_path="${WIDTH_PATH}" \
    -v sort_by="${sort_by}" \
    -v reset="${GWT_RESET}" -v branch_col="${GWT_BRANCH}" -v hash_col="${GWT_HASH}" \
    -v age_col="${GWT_AGE}" -v path_col="${GWT_PATH}" -v warn_col="${GWT_STATUS_WARN}" \
    -v accent_col="${GWT_ACCENT}" -v muted_col="${GWT_MUTED}" '
  function shorten(str, maxlen) {
    if (length(str) > maxlen) return substr(str, 1, maxlen-1) "…"
    return str
  }
  function short_path(p) {
    if (index(p, ENVIRON["HOME"]) == 1)
      return "~" substr(p, length(ENVIRON["HOME"])+1)
    return p
  }
  function get_timestamp(wt) {
    cmd = "git -C '\''" wt "'\'' log -1 --format='\''%ct'\'' 2>/dev/null"
    if ((cmd | getline ts) <= 0) ts = 0
    close(cmd)
    return ts
  }
  {
    wt_path=$1; branch=$2; head=$3; is_main=$4; detached=$5; flags=$6

    # Get commit info - clear variables first
    short = ""; age = ""; subject = ""

    cmd_short = "git -C '\''" wt_path "'\'' rev-parse --short '\''" head "'\'' 2>/dev/null"
    if ((cmd_short | getline short) <= 0) short = ""
    close(cmd_short)
    if (short == "") short = substr(head, 1, 7)

    cmd_age = "git -C '\''" wt_path "'\'' log -1 --format='\''%cr'\'' 2>/dev/null"
    if ((cmd_age | getline age) <= 0) age = ""
    close(cmd_age)
    if (age == "") age = "-"

    cmd_subj = "git -C '\''" wt_path "'\'' log -1 --format='\''%s'\'' 2>/dev/null"
    if ((cmd_subj | getline subject) <= 0) subject = ""
    close(cmd_subj)
    if (subject == "") subject = "-"

    # Detect if prunable
    is_prunable = (index(flags, "prunable") > 0) ? 1 : 0

    # Branch label
    if (branch == "") {
      branch_label = (detached == "1") ? "detached@" short : "(no branch)"
    } else {
      branch_label = branch
    }
    if (flags != "") branch_label = branch_label " [" flags "]"

    # Marker
    marker = (wt_path == current) ? "*" : " "

    # Display path
    display_path = short_path(wt_path)

    # Truncate fields
    branch_disp = shorten(branch_label, w_branch)
    subject_disp = shorten(subject, 100)
    display_path_short = shorten(display_path, w_path)

    # Get timestamp for sorting
    timestamp = get_timestamp(wt_path)

    # Build sort key and output line
    sort_key = ""
    if (sort_by == "date") {
      sort_key = sprintf("%d|%010d|%s", is_prunable, 9999999999-timestamp, branch_label)
    } else {
      sort_key = sprintf("%d|%s", is_prunable, tolower(branch_label))
    }

    # Pad fields to fixed widths BEFORE adding colors
    marker_padded = sprintf("%-2s", marker)
    branch_padded = sprintf("%-30s", branch_disp)
    hash_padded = sprintf("%-10s", short)
    age_padded = sprintf("%-16s", age)
    path_padded = sprintf("%-50s", display_path_short)

    # Apply colors to padded strings
    marker_colored = (marker == "*") ? accent_col marker_padded reset : muted_col marker_padded reset
    branch_colored = (is_prunable) ? warn_col branch_padded reset : branch_col branch_padded reset
    hash_colored = hash_col hash_padded reset
    age_colored = (age == "-") ? muted_col age_padded reset : age_col age_padded reset
    path_colored = path_col path_padded reset

    # Output with sort key prefix (will be removed after sorting)
    printf "%s\t%s%s%s%s%s%s\n",
      sort_key,
      marker_colored,
      branch_colored,
      hash_colored,
      age_colored,
      path_colored,
      subject_disp
  }' | sort -t$'\t' -k1,1 | cut -f2-
}

__gwt_fzf_source() {
  local data
  data=$(__gwt_collect_worktrees) || return 1
  while IFS=$'\t' read -r wt_path branch head is_main detached flags; do
    local short age subject branch_label marker
    short=$(git -C "${wt_path}" rev-parse --short "${head}" 2>/dev/null)
    short=${short:-$(printf '%.7s' "${head}")}
    age=$(git -C "${wt_path}" log -1 --format='%cr' 2>/dev/null)
    age=${age:--}
    subject=$(git -C "${wt_path}" log -1 --format='%s' 2>/dev/null)
    subject=${subject:--}

    if [[ -z "${branch}" ]]; then
      if [[ "${detached}" == "1" ]]; then
        branch_label="detached@${short}"
      else
        branch_label="(no branch)"
      fi
    else
      branch_label="${branch}"
    fi

    if [[ -n "${flags}" ]]; then
      branch_label+=" [${flags}]"
    fi

    marker=$([[ "${is_main}" == "1" ]] && printf '*' || printf ' ')
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "${wt_path}" "${marker}" "${branch_label}" "${short}" "${age}" "${subject}" "${is_main}"
  done <<<"${data}"
}

__gwt_select_paths() {
  local allow_main="$1" pattern="$2" multi="$3"
  local source filtered
  source=$(__gwt_fzf_source) || return 1

  if [[ "${allow_main}" != "1" ]]; then
    source=$(printf '%s\n' "${source}" | awk -F'\t' '$NF == "0"')
  fi

  if [[ -n "${pattern}" ]]; then
    filtered=$(printf '%s\n' "${source}" | grep -iF -- "${pattern}" || true)
  else
    filtered="${source}"
  fi

  if [[ -z "${filtered}" ]]; then
    return 1
  fi

  if [[ "${multi}" == "1" ]]; then
    __gwt_require_fzf || return 1
    printf '%s\n' "${filtered}" | fzf --multi --ansi --height=80% --prompt='worktree> ' --header='Select worktree(s)' --with-nth=2,3,4,5 --preview 'git -C {1} status --short --branch' | cut -f1
  else
    if __gwt_have_fzf; then
      printf '%s\n' "${filtered}" | fzf --ansi --height=80% --prompt='worktree> ' --header='Select worktree' --with-nth=2,3,4,5 --preview 'git -C {1} status --short --branch' | cut -f1
    else
      printf '%s\n' "${filtered}" | head -n1 | cut -f1
    fi
  fi
}

__gwt_select_base() {
  local default_base base_list selection
  default_base="${GWT_DEFAULT_BASE:-origin/main}"

  base_list=$(git for-each-ref --sort=-committerdate --format='%(refname:short)\t%(committerdate:relative)\t%(objectname:short)\t%(contents:subject)' refs/heads refs/remotes 2>/dev/null |
    awk -F'\t' '($1 !~ /^(HEAD|.*\/HEAD)$/) && !seen[$1]++ {print}')

  if ! __gwt_have_fzf || [[ -z "${base_list}" ]]; then
    printf '%s\n' "${default_base}"
    return 0
  fi

  selection=$({
    printf '%s\t(default)\t\t\n' "${default_base}"
    printf '%s\n' "${base_list}"
  } |
    fzf --ansi --height=80% --prompt='base> ' --header="Select base branch (Enter for ${default_base})" --with-nth=1,2,4 --preview 'git log --oneline -5 {1}')

  if [[ -z "${selection}" ]]; then
    printf '%s\n' "${default_base}"
  else
    printf '%s\n' "${selection%%$'\t'*}"
  fi
}

__gwt_new_worktree() {
  local branch="" base="" wt_path="" fetch=1 auto_switch=1

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --from | --base | -f)
        shift
        base="$1"
        ;;
      --path | -p)
        shift
        wt_path="$1"
        ;;
      --no-fetch)
        fetch=0
        ;;
      --no-switch)
        auto_switch=0
        ;;
      --help | -h)
        __gwt_usage
        return 0
        ;;
      --*)
        echo "gwt new: unknown flag $1" >&2
        return 1
        ;;
      *)
        if [[ -z "${branch}" ]]; then
          branch="$1"
        elif [[ -z "${base}" ]]; then
          base="$1"
        else
          wt_path="$1"
        fi
        ;;
    esac
    shift
  done

  if [[ -z "${branch}" ]]; then
    if [[ -n "${ZSH_VERSION:-}" ]]; then
      read -r "branch?New branch name: "
    else
      read -rp "New branch name: " branch
    fi
  fi

  if [[ -z "${branch}" ]]; then
    echo "gwt: branch name required" >&2
    return 1
  fi

  if [[ -z "${base}" ]]; then
    base=$(__gwt_select_base) || return 1
  fi

  local repo_root repo_name default_root
  repo_root=$(git rev-parse --show-toplevel) || return 1
  repo_name=$(basename "${repo_root}")
  default_root=$(__gwt_default_root)
  mkdir -p "${default_root}/${repo_name}" 2>/dev/null || true

  if [[ -z "${wt_path}" ]]; then
    wt_path="${default_root}/${repo_name}/${branch}"
  fi

  wt_path=$(__gwt_expand_path "${wt_path}")

  if [[ -d "${wt_path}" && -n "$(command ls -A "${wt_path}" 2>/dev/null)" ]]; then
    echo "gwt: target path ${wt_path} already exists and is not empty" >&2
    return 1
  fi

  mkdir -p "$(dirname "${wt_path}")"

  local remote_candidate
  remote_candidate="${base%%/*}"
  if [[ ${fetch} -eq 1 && -n "${remote_candidate}" ]] && git remote | grep -qx "${remote_candidate}"; then
    printf 'Fetching %s…\n' "${remote_candidate}"
    git fetch "${remote_candidate}" --prune
  fi

  printf 'Creating worktree %s from %s…\n' "${wt_path}" "${base}"
  local existing_branch=0
  if git show-ref --verify --quiet "refs/heads/${branch}"; then
    existing_branch=1
    printf 'Branch %s already exists locally – reusing it.\n' "${branch}"
  fi

  if [[ ${existing_branch} -eq 1 ]]; then
    git worktree add "${wt_path}" "${branch}"
  else
    git worktree add -b "${branch}" "${wt_path}" "${base}"
  fi && {
    printf '✅ worktree ready: %s\n' "${wt_path}"
    if [[ ${auto_switch} -eq 1 ]]; then
      cd "${wt_path}" || return 1
      printf 'Switched to %s\n' "${wt_path}"
    else
      printf 'Run: cd "%s"\n' "${wt_path}"
    fi
  }
}

__gwt_remove_worktrees() {
  local pattern="" force=0

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --force | -f)
        force=1
        ;;
      --help | -h)
        __gwt_usage
        return 0
        ;;
      --*)
        echo "gwt remove: unknown flag $1" >&2
        return 1
        ;;
      *)
        pattern="$1"
        ;;
    esac
    shift
  done

  local paths
  paths=$(__gwt_select_paths "0" "${pattern}" "1") || {
    echo "gwt: no matching worktrees" >&2
    return 1
  }

  if [[ -z "${paths}" ]]; then
    echo "No worktrees selected."
    return 0
  fi

  while IFS= read -r wt_path; do
    [[ -z "${wt_path}" ]] && continue
    printf 'Removing %s…\n' "${wt_path}"
    if [[ ${force} -eq 1 ]]; then
      git worktree remove -f "${wt_path}"
    else
      git worktree remove "${wt_path}"
    fi
  done <<<"${paths}"
}

function gwt() {
  ( # Run in subshell to isolate from xtrace
    set +x 2>/dev/null # Disable xtrace for clean output

    local action="$1" rc=0

    if [[ $# -eq 0 ]]; then
      if __gwt_have_fzf && git rev-parse --show-toplevel >/dev/null 2>&1; then
        action=$(printf '%s\n' "switch" "new" "list" "remove" "clean" "info" | fzf --prompt='gwt> ' --header='Select action' --height=60%)
        [[ -z "${action}" ]] && return 0
        set -- "${action}"
      else
        __gwt_usage
        return 0
      fi
    fi

    case "$1" in
      help | --help | -h | "")
        __gwt_usage
        return 0
        ;;
    esac

    __gwt_require_repo || return 1

    case "$1" in
      list | ls)
        shift
        local sort_mode="branch"
        while [[ $# -gt 0 ]]; do
          case "$1" in
            --date | -d)
              sort_mode="date"
              shift
              ;;
            *)
              shift
              ;;
          esac
        done
        __gwt_worktree_table "${sort_mode}" || rc=$?
        ;;
      switch | cd | open)
        local target sel_rc pattern="${2:-}"
        target=$(__gwt_select_paths "1" "${pattern}" "0")
        sel_rc=$?
        if [[ ${sel_rc} -ne 0 ]]; then
          if [[ -n "${pattern}" ]]; then
            echo "gwt: unable to find worktree matching '${pattern}'" >&2
            rc=${sel_rc}
          fi
        elif [[ -n "${target}" ]]; then
          if cd "${target}"; then
            printf 'Switched to %s\n' "${target}"
          else
            rc=1
          fi
        fi
        ;;
      new | add)
        shift
        __gwt_new_worktree "$@" || rc=$?
        ;;
      remove | rm | del)
        shift
        __gwt_remove_worktrees "$@" || rc=$?
        ;;
      clean | prune)
        printf 'Pruning stale worktrees…\n'
        git worktree prune || rc=$?
        ;;
      info)
        local root branch head
        root=$(git rev-parse --show-toplevel)
        branch=$(git branch --show-current 2>/dev/null)
        head=$(git rev-parse --short HEAD)
        printf 'Worktree: %s\n' "${root}"
        printf 'Branch:   %s\n' "${branch:-(detached)}"
        printf 'Commit:   %s\n' "${head}"
        ;;
      *)
        echo "gwt: unknown command '$1'" >&2
        __gwt_usage
        rc=1
        ;;
    esac

    return ${rc}
  )
}
