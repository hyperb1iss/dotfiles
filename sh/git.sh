# git.sh
# ⚡ Git utilities with SilkCircuit energy

# Source shared colors
source "${DOTFILES:-$HOME/.dotfiles}/sh/colors.sh" 2> /dev/null || true

# ─────────────────────────────────────────────────────────────
# Aliases
# ─────────────────────────────────────────────────────────────
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
alias gig='git iris gen -a --no-verify --preset conventional'

# ─────────────────────────────────────────────────────────────
# Core Functions
# ─────────────────────────────────────────────────────────────

# Get current branch name
function git_current_branch() {
  git branch --show-current 2> /dev/null
}

# ─────────────────────────────────────────────────────────────
# Interactive Functions
# ─────────────────────────────────────────────────────────────

# Interactive git add using fzf
function gadd() {
  __sc_init_colors
  local files

  files=$(git status -s \
    | fzf -m --height 60% --reverse \
      --header="⚡ Select files to stage (TAB to multi-select)" \
      --prompt="add ▸ " \
      --preview 'git diff --color=always {2}' \
      --preview-window=right:60% \
    | awk '{print $2}') || return 0

  if [[ -n "${files}" ]]; then
    echo "${files}" | xargs git add
    sc_header "Staged Files"
    echo ""
    while IFS= read -r file; do
      [[ -n "${file}" ]] && echo -e "  ${SC_GREEN}+${SC_RESET} ${file}"
    done <<< "${files}"
    echo ""
    sc_success "Files staged"
  fi
}

# Interactive git checkout branch
function gco() {
  __sc_init_colors
  local branches branch

  branches=$(git branch --all | grep -v HEAD) || return 0

  if [[ -n "${branches}" ]]; then
    branch=$(echo "${branches}" \
      | fzf --height 50% --reverse \
        --header="⚡ Select branch to checkout" \
        --prompt="branch ▸ " \
        --preview 'git log --oneline --color=always -20 {}' \
        --preview-window=right:50%) || return 0

    local target
    target=$(echo "${branch}" | sed "s/.* //" | sed "s#remotes/[^/]*/##")
    sc_info "Switching to ${SC_CYAN}${target}${SC_RESET}..."
    git checkout "${target}"
  fi
}

# Interactive git log browser
function glog() {
  __sc_init_colors
  PAGER=${PAGER:-less}
  export PAGER

  sc_info "Browse commits (Enter to view, \` to toggle sort)"
  echo ""

  git log --graph --color=always \
    --format="%C(#ff6ac1)%h%C(reset) %C(#80ffea)%d%C(reset) %s %C(#8b91b1)%cr%C(reset)" "$@" \
    | fzf --ansi --no-sort --reverse --tac --toggle-sort=\` \
      --header="⚡ Git Log Browser" \
      --prompt="commit ▸ " \
      --bind "ctrl-m:execute:
                (grep -o '[a-f0-9]\{7\}' | head -1 |
                xargs -I % sh -c 'git show --color=always % | ${PAGER}') << 'FZF-EOF'
                {}
FZF-EOF"
}

# Interactive git stash operations
function gstash() {
  __sc_init_colors
  local cmd="git stash list"
  local preview="git stash show -p {1} --color=always"
  local selection stash_id

  selection=$(eval "${cmd}" \
    | fzf --height 60% --reverse \
      --header="⚡ Select stash entry" \
      --prompt="stash ▸ " \
      --preview "${preview}" \
      --preview-window=right:60%) || return 0

  if [[ -n "${selection}" ]]; then
    stash_id=$(echo "${selection}" | cut -d: -f1)

    echo ""
    sc_header "Stash Actions"
    echo ""
    echo -e "  ${SC_PURPLE}a${SC_RESET} → Apply stash"
    echo -e "  ${SC_PURPLE}p${SC_RESET} → Pop stash"
    echo -e "  ${SC_PURPLE}d${SC_RESET} → Drop stash"
    echo -e "  ${SC_PURPLE}s${SC_RESET} → Show stash"
    echo -e "  ${SC_PURPLE}b${SC_RESET} → Create branch from stash"
    echo ""
    echo -ne "Select action: "
    read -r action

    case "${action}" in
      a)
        sc_info "Applying stash..."
        git stash apply "${stash_id}"
        sc_success "Stash applied"
        ;;
      p)
        sc_info "Popping stash..."
        git stash pop "${stash_id}"
        sc_success "Stash popped"
        ;;
      d)
        sc_warn "Dropping stash..."
        git stash drop "${stash_id}"
        sc_success "Stash dropped"
        ;;
      s)
        git stash show -p "${stash_id}" | ${PAGER:-less}
        ;;
      b)
        local branch_name
        branch_name="stash-branch-$(date +%Y%m%d-%H%M)"
        sc_info "Creating branch ${SC_CYAN}${branch_name}${SC_RESET}..."
        git stash branch "${branch_name}" "${stash_id}"
        sc_success "Branch created"
        ;;
      *)
        sc_muted "Cancelled"
        ;;
    esac
  fi
}

# Interactive git rebase
function grebase() {
  __sc_init_colors
  local commits

  sc_info "Select commit to rebase from (multi-select with TAB)"
  echo ""

  commits=$(git log --oneline -n 50 --color=always \
    | fzf --ansi --multi --height 60% --reverse \
      --header="⚡ Interactive Rebase" \
      --prompt="rebase ▸ " \
      --preview 'git show --color=always {1}' \
      --preview-window=right:50% \
    | cut -d' ' -f1) || return 0

  if [[ -n "${commits}" ]]; then
    local target
    target=$(echo "${commits}" | tail -n1)
    sc_warn "Rebasing from ${SC_CORAL}${target}${SC_RESET}..."
    git rebase -i "${target}^"
  fi
}

# ─────────────────────────────────────────────────────────────
# Repository Setup & Maintenance
# ─────────────────────────────────────────────────────────────

# Setup git repository with common configurations
function gsetup() {
  __sc_init_colors
  local email name

  sc_header "Git Repository Setup"
  echo ""

  # Configure common settings
  sc_info "Configuring repository defaults..."
  git config pull.rebase true
  git config push.default current
  git config core.autocrlf input
  git config core.fileMode true

  echo -e "  ${SC_GREEN}✓${SC_RESET} pull.rebase = true"
  echo -e "  ${SC_GREEN}✓${SC_RESET} push.default = current"
  echo -e "  ${SC_GREEN}✓${SC_RESET} core.autocrlf = input"
  echo ""

  # Ask for user details if not set
  if [[ -z "$(git config --global user.email)" ]]; then
    echo -ne "${SC_CYAN}Git email:${SC_RESET} "
    read -r email
    git config --global user.email "${email}"
  fi
  if [[ -z "$(git config --global user.name)" ]]; then
    echo -ne "${SC_CYAN}Git name:${SC_RESET} "
    read -r name
    git config --global user.name "${name}"
  fi

  # Initialize main branch
  git checkout -b main 2> /dev/null && echo -e "  ${SC_GREEN}✓${SC_RESET} Created main branch" || true

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
    echo -e "  ${SC_GREEN}✓${SC_RESET} Created .gitignore"
  fi

  git add .gitignore
  git commit -m "Initial commit" 2> /dev/null && echo -e "  ${SC_GREEN}✓${SC_RESET} Initial commit created" || true

  echo ""
  sc_success "Repository setup complete"
}

# Clean git branches
function gclean() {
  __sc_init_colors

  sc_header "Git Branch Cleanup"
  echo ""

  # Count branches before
  local before_count
  before_count=$(git branch | wc -l | tr -d ' ')

  # Remove merged local branches
  sc_info "Removing merged branches..."
  local removed
  removed=$(git branch --merged | grep -v "\*" | grep -v "main" | grep -v "master" | xargs -n 1 git branch -d 2>&1 || true)

  if [[ -n "${removed}" ]]; then
    echo "${removed}" | while read -r line; do
      if [[ "${line}" == *"Deleted branch"* ]]; then
        local branch_name
        branch_name=$(echo "${line}" | sed 's/Deleted branch //' | sed 's/ (was.*//')
        echo -e "  ${SC_RED}−${SC_RESET} ${branch_name}"
      fi
    done
  fi

  # Remove remote tracking branches that no longer exist
  echo ""
  sc_info "Pruning stale remote tracking branches..."
  git fetch --prune 2>&1 | grep -E "^\s*-\s*\[deleted\]" | while read -r line; do
    local ref
    ref=$(echo "${line}" | awk '{print $NF}')
    echo -e "  ${SC_RED}−${SC_RESET} ${ref}"
  done

  # Count branches after
  local after_count
  after_count=$(git branch | wc -l | tr -d ' ')
  local removed_count=$((before_count - after_count))

  echo ""
  if [[ ${removed_count} -gt 0 ]]; then
    sc_success "Cleaned ${removed_count} branch(es)"
  else
    sc_muted "No branches to clean"
  fi
}

# Show git repository status with enhanced output
function gstatus() {
  __sc_init_colors
  local status_output
  status_output=$(git status --porcelain) || return 0

  # Get current branch
  local branch
  branch=$(git branch --show-current 2> /dev/null)

  sc_header "Repository Status"
  echo ""
  sc_label "Branch" "${branch:-detached}"

  # Ahead/behind info
  local upstream
  upstream=$(git rev-parse --abbrev-ref "@{upstream}" 2> /dev/null)
  if [[ -n "${upstream}" ]]; then
    local ahead behind
    ahead=$(git rev-list --count "@{upstream}..HEAD" 2> /dev/null)
    behind=$(git rev-list --count "HEAD..@{upstream}" 2> /dev/null)
    if [[ ${ahead} -gt 0 ]] || [[ ${behind} -gt 0 ]]; then
      echo -e "${SC_CYAN}•${SC_RESET} Upstream: ${SC_GRAY}${upstream}${SC_RESET} ${SC_GREEN}↑${ahead}${SC_RESET} ${SC_RED}↓${behind}${SC_RESET}"
    fi
  fi
  echo ""

  if [[ -n "${status_output}" ]]; then
    # Staged files
    local staged_files
    staged_files=$(echo "${status_output}" | grep -E "^[MADRC]" | cut -c4-)
    if [[ -n "${staged_files}" ]]; then
      echo -e "${SC_GREEN}Staged:${SC_RESET}"
      while IFS= read -r file; do
        [[ -n "${file}" ]] && echo -e "  ${SC_GREEN}+${SC_RESET} ${file}"
      done <<< "${staged_files}"
      echo ""
    fi

    # Modified files (unstaged)
    local modified_files
    modified_files=$(echo "${status_output}" | grep -E "^.[MD]" | cut -c4-)
    if [[ -n "${modified_files}" ]]; then
      echo -e "${SC_YELLOW}Modified:${SC_RESET}"
      while IFS= read -r file; do
        [[ -n "${file}" ]] && echo -e "  ${SC_YELLOW}~${SC_RESET} ${file}"
      done <<< "${modified_files}"
      echo ""
    fi

    # Untracked files
    local untracked_files
    untracked_files=$(echo "${status_output}" | grep "^??" | cut -c4-)
    if [[ -n "${untracked_files}" ]]; then
      echo -e "${SC_GRAY}Untracked:${SC_RESET}"
      while IFS= read -r file; do
        [[ -n "${file}" ]] && echo -e "  ${SC_GRAY}?${SC_RESET} ${file}"
      done <<< "${untracked_files}"
    fi
  else
    sc_success "Working directory clean"
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
  cat << 'EOF'
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

  # Use shared SilkCircuit colors
  __sc_init_colors

  # Map GWT-specific aliases to shared colors for compatibility
  GWT_RESET="${SC_RESET}"
  GWT_BOLD="${SC_BOLD}"
  GWT_MUTED="${SC_DIM}"
  GWT_ACCENT="${SC_PURPLE}"
  GWT_BRANCH="${SC_CYAN}"
  GWT_HASH="${SC_CORAL}"
  GWT_AGE="${SC_YELLOW}"
  GWT_PATH="${SC_CYAN}"
  GWT_STATUS_WARN="${SC_YELLOW}"

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
  if ! git rev-parse --show-toplevel > /dev/null 2>&1; then
    echo "gwt: not inside a git repository" >&2
    return 1
  fi
}

__gwt_have_fzf() {
  command -v fzf > /dev/null 2>&1
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
  emulate -L zsh 2> /dev/null || true
  setopt LOCAL_OPTIONS 2> /dev/null || true

  local data current_root WIDTH_MARK WIDTH_BRANCH WIDTH_HEAD WIDTH_UPDATED WIDTH_PATH sort_by
  sort_by="${1:-branch}" # Default to branch sorting

  data=$(__gwt_collect_worktrees) || return 1

  if [[ -z "${data}" ]]; then
    echo "No worktrees found."
    return 0
  fi

  __gwt_init_styles
  current_root=$(git rev-parse --show-toplevel 2> /dev/null)

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
    short=$(git -C "${wt_path}" rev-parse --short "${head}" 2> /dev/null)
    short=${short:-$(printf '%.7s' "${head}")}
    age=$(git -C "${wt_path}" log -1 --format='%cr' 2> /dev/null)
    age=${age:--}
    subject=$(git -C "${wt_path}" log -1 --format='%s' 2> /dev/null)
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
  done <<< "${data}"
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

  base_list=$(git for-each-ref --sort=-committerdate --format='%(refname:short)\t%(committerdate:relative)\t%(objectname:short)\t%(contents:subject)' refs/heads refs/remotes 2> /dev/null \
    | awk -F'\t' '($1 !~ /^(HEAD|.*\/HEAD)$/) && !seen[$1]++ {print}')

  if ! __gwt_have_fzf || [[ -z "${base_list}" ]]; then
    printf '%s\n' "${default_base}"
    return 0
  fi

  selection=$({
    printf '%s\t(default)\t\t\n' "${default_base}"
    printf '%s\n' "${base_list}"
  } \
    | fzf --ansi --height=80% --prompt='base> ' --header="Select base branch (Enter for ${default_base})" --with-nth=1,2,4 --preview 'git log --oneline -5 {1}')

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
  mkdir -p "${default_root}/${repo_name}" 2> /dev/null || true

  if [[ -z "${wt_path}" ]]; then
    wt_path="${default_root}/${repo_name}/${branch}"
  fi

  wt_path=$(__gwt_expand_path "${wt_path}")

  if [[ -d "${wt_path}" && -n "$(command ls -A "${wt_path}" 2> /dev/null)" ]]; then
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
  done <<< "${paths}"
}

function gwt() {
  set +x 2> /dev/null # Disable xtrace for clean output

  local action="$1" rc=0

  if [[ $# -eq 0 ]]; then
    if __gwt_have_fzf && git rev-parse --show-toplevel > /dev/null 2>&1; then
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
      branch=$(git branch --show-current 2> /dev/null)
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
}
