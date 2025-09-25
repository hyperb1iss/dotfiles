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
    GWT_RESET=$'\033[0m'
    GWT_BOLD=$'\033[1m'
    GWT_DIM=$'\033[38;5;245m'
    GWT_MUTED=$'\033[38;5;244m'
    GWT_ACCENT=$'\033[38;5;213m'
    GWT_BRANCH=$'\033[38;5;147m'
    GWT_HASH=$'\033[38;5;117m'
    GWT_AGE=$'\033[38;5;180m'
    GWT_PATH=$'\033[38;5;159m'
    GWT_STATUS_WARN=$'\033[38;5;215m'
    GWT_STATUS_LOCKED=$'\033[38;5;203m'
    GWT_STATUS_OK=$'\033[38;5;120m'
  else
    GWT_RESET=""
    GWT_BOLD=""
    GWT_DIM=""
    GWT_MUTED=""
    GWT_ACCENT=""
    GWT_BRANCH=""
    GWT_HASH=""
    GWT_AGE=""
    GWT_PATH=""
    GWT_STATUS_WARN=""
    GWT_STATUS_LOCKED=""
    GWT_STATUS_OK=""
  fi

  GWT_COLORS_ENABLED=${colors_enabled}
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
    printf '~%s' "${input#${HOME}}"
  else
    printf '%s' "${input}"
  fi
}

__gwt_collect_worktrees() {
  local repo_root
  repo_root=$(git rev-parse --show-toplevel) || return 1

  git worktree list --porcelain | awk -v repo_root="${repo_root}" '
    function flush() {
      if (path == "") {
        return
      }
      gsub("^refs/heads/", "", branch)
      printf "%s\t%s\t%s\t%s\t%s\t%s\n", path, branch, head, (path==repo_root?"1":"0"), (detached?"1":"0"), flags
      path=""; head=""; branch=""; detached=0; flags=""
    }
    /^worktree / { flush(); path=$2 }
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
  local data
  data=$(__gwt_collect_worktrees) || return 1
  if [[ -z "${data}" ]]; then
    echo "No worktrees found."
    return 0
  fi

  __gwt_init_styles

  local repo_root repo_name header
  repo_root=$(git rev-parse --show-toplevel 2>/dev/null)
  repo_name=$(basename "${repo_root}")

  printf '📁  %s%sWorktrees%s for %s%s%s\n' \
    "${GWT_ACCENT}" "${GWT_BOLD}" "${GWT_RESET}" \
    "${GWT_BRANCH}" "${repo_name}" "${GWT_RESET}"
  printf '\n'

  local idx=0
  while IFS=$'\t' read -r path branch head is_main detached flags; do
    ((idx++))
    local short age subject branch_label icon branch_style age_label subject_label status_text display_path
    short=$(git -C "${path}" rev-parse --short "${head}" 2>/dev/null)
    short=${short:-$(printf '%.7s' "${head}")}
    age=$(git -C "${path}" log -1 --format='%cr' 2>/dev/null)
    age=${age:--}
    subject=$(git -C "${path}" log -1 --format='%s' 2>/dev/null)
    subject=${subject:--}
    if [[ "${subject}" != "-" && ${#subject} -gt 70 ]]; then
      subject="${subject:0:67}…"
    fi
    display_path=$(__gwt_short_path "${path}")
    if [[ ${#display_path} -gt 60 ]]; then
      display_path="…${display_path: -57}"
    fi

    if [[ -z "${branch}" ]]; then
      if [[ "${detached}" == "1" ]]; then
        branch_label="detached@${short}"
      else
        branch_label="(no branch)"
      fi
    else
      branch_label="${branch}"
    fi

    status_text=$(__gwt_join_status_flags "${flags}")

    if [[ ${idx} -gt 1 ]]; then
      printf '\n'
    fi

    if [[ "${is_main}" == "1" ]]; then
      icon=$(printf '%s%s➤%s' "${GWT_ACCENT}" "${GWT_BOLD}" "${GWT_RESET}")
      branch_style="${GWT_ACCENT}${GWT_BOLD}"
    else
      icon=$(printf '%s•%s' "${GWT_DIM}" "${GWT_RESET}")
      branch_style="${GWT_BRANCH}${GWT_BOLD}"
    fi

    if [[ "${age}" == "-" ]]; then
      age_label="${GWT_MUTED}uncommitted${GWT_RESET}"
    else
      age_label=$(printf '%s%s%s' "${GWT_AGE}" "${age}" "${GWT_RESET}")
    fi

    if [[ "${subject}" == "-" ]]; then
      subject_label="${GWT_MUTED}no commits yet${GWT_RESET}"
    else
      subject_label=$(printf '%s%s%s' "${GWT_MUTED}" "${subject}" "${GWT_RESET}")
    fi

    local short_label
    short_label=$(printf '%s%s%s' "${GWT_HASH}" "${short}" "${GWT_RESET}")

    printf '%s %s%s%s %s@%s %s\n' \
      "${icon}" \
      "${branch_style}" "${branch_label}" "${GWT_RESET}" \
      "${GWT_DIM}" "${GWT_RESET}" \
      "${short_label}"

    printf '    %s%-7s%s %s%s\n' "${GWT_DIM}" "Updated" "${GWT_RESET}" "${age_label}" "${GWT_RESET}"
    printf '    %s%-7s%s %s%s%s\n' "${GWT_DIM}" "Path" "${GWT_RESET}" "${GWT_PATH}" "${display_path}" "${GWT_RESET}"
    printf '    %s%-7s%s %s%s\n' "${GWT_DIM}" "Commit" "${GWT_RESET}" "${subject_label}" "${GWT_RESET}"

    if [[ -n "${status_text}" ]]; then
      local status_color="${GWT_STATUS_OK}"
      if [[ "${status_text}" == *locked* ]]; then
        status_color="${GWT_STATUS_LOCKED}"
      elif [[ "${status_text}" == *prunable* ]]; then
        status_color="${GWT_STATUS_WARN}"
      fi
      printf '    %s%-7s%s %s%s%s\n' "${GWT_DIM}" "Status" "${GWT_RESET}" "${status_color}" "${status_text}" "${GWT_RESET}"
    fi
  done <<<"${data}"
}

__gwt_fzf_source() {
  local data
  data=$(__gwt_collect_worktrees) || return 1
  while IFS=$'\t' read -r path branch head is_main detached flags; do
    local short age subject branch_label marker
    short=$(git -C "${path}" rev-parse --short "${head}" 2>/dev/null)
    short=${short:-$(printf '%.7s' "${head}")}
    age=$(git -C "${path}" log -1 --format='%cr' 2>/dev/null)
    age=${age:--}
    subject=$(git -C "${path}" log -1 --format='%s' 2>/dev/null)
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
    printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\n' "${path}" "${marker}" "${branch_label}" "${short}" "${age}" "${subject}" "${is_main}"
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
  fi

  if [[ $? -eq 0 ]]; then
    printf '✅ worktree ready: %s\n' "${wt_path}"
    if [[ ${auto_switch} -eq 1 ]]; then
      cd "${wt_path}" || return 1
      printf 'Switched to %s\n' "${wt_path}"
    else
      printf 'Run: cd "%s"\n' "${wt_path}"
    fi
  fi
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

  while IFS= read -r path; do
    [[ -z "${path}" ]] && continue
    printf 'Removing %s…\n' "${path}"
    if [[ ${force} -eq 1 ]]; then
      git worktree remove -f "${path}"
    else
      git worktree remove "${path}"
    fi
  done <<<"${paths}"
}

function gwt() {
  local __gwt_restore_trace=0
  if [[ -n "${ZSH_VERSION:-}" ]]; then
    if [[ -o xtrace ]]; then
      set +x
      __gwt_restore_trace=1
    fi
  elif [[ -n "${BASH_VERSION:-}" ]]; then
    if [[ $(set -o | awk '$1=="xtrace" {print $2}') == on ]]; then
      set +x
      __gwt_restore_trace=1
    fi
  fi

  local action="$1" rc=0

  if [[ $# -eq 0 ]]; then
    if __gwt_have_fzf && git rev-parse --show-toplevel >/dev/null 2>&1; then
      action=$(printf '%s\n' "switch" "new" "list" "remove" "clean" "info" | fzf --prompt='gwt> ' --header='Select action' --height=60%)
      if [[ -z "${action}" ]]; then
        if [[ ${__gwt_restore_trace} -eq 1 ]]; then
          set -x
        fi
        return 0
      fi
      set -- "${action}"
    else
      __gwt_usage
      if [[ ${__gwt_restore_trace} -eq 1 ]]; then
        set -x
      fi
      return 0
    fi
  fi

  case "$1" in
    help | --help | -h | "")
      __gwt_usage
      if [[ ${__gwt_restore_trace} -eq 1 ]]; then
        set -x
      fi
      return 0
      ;;
  esac

  if ! __gwt_require_repo; then
    if [[ ${__gwt_restore_trace} -eq 1 ]]; then
      set -x
    fi
    return 1
  fi

  case "$1" in
    list | ls)
      __gwt_worktree_table || rc=$?
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

  if [[ ${__gwt_restore_trace} -eq 1 ]]; then
    set -x
  fi
  return ${rc}
}
