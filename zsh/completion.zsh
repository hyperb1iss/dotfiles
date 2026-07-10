# Completion settings

# Use modern completion system with a daily staleness window: the fast
# -C path (skip the security scan) only while the dump is under 24h old,
# a full compinit otherwise — so newly installed tools' completions show
# up within a day instead of never. `refresh-completions` forces it now.
autoload -Uz compinit
zcompdump_path="${ZDOTDIR:-${HOME}}/.zcompdump"
if [[ -n "${zcompdump_path}"(#qN.mh-24) ]]; then
  compinit -C -d "${zcompdump_path}"
else
  compinit -d "${zcompdump_path}"
fi

# Bytecode-compile the dump in the background when it changed
{
  if [[ -s "${zcompdump_path}" && (! -s "${zcompdump_path}.zwc" || "${zcompdump_path}" -nt "${zcompdump_path}.zwc") ]]; then
    zcompile "${zcompdump_path}"
  fi
} &!
unset zcompdump_path

function refresh-completions() {
  local dump="${ZDOTDIR:-${HOME}}/.zcompdump"
  rm -f "${dump}" "${dump}.zwc"
  compinit -d "${dump}"
  echo "✓ completions rebuilt"
}

# Basic completion settings with enhanced colors
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*' group-name ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s

# Case-insensitive completion plus substring/separator matching
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=* l:|=*'
zstyle ':completion:*' menu select=long
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command "ps -u ${USER} -o pid,%cpu,tty,cputime,cmd"

# SSH Hostname completion based on ~/.ssh/config
if [[ -e "${HOME}/.ssh/config" ]]; then
  zstyle ':completion:*:*:ssh:*' hosts "$(awk '/^Host / {print $2}' ~/.ssh/config | grep -v '[*?]')"
fi

# Enable extended globbing for more powerful pattern matching
setopt extended_glob

# Enable path expansion (e.g., ~/ expands to the home directory)
zstyle ':completion:*' expand 'yes'
zstyle ':completion:*' squeeze-slashes 'yes'

# Use color output for completions
# shellcheck disable=SC2296,SC2086
zstyle ':completion:*:default' list-colors ${(s.:.)LS_COLORS}

# Additional color customization for different types of completions
# shellcheck disable=SC2296,SC2086
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}: \
  'fi=00' 'di=01;34' 'ln=01;36' 'pi=33' 'so=01;35' \
  'bd=33;01' 'cd=33;01' 'or=01;31' 'mi=05;37;41' \
  'ex=01;32' 'su=37;41' 'sg=30;43' 'tw=30;42' \
  'ow=34;42' 'st=37;44'

# Descriptions/messages/warnings formats live in the fzf-tab section
# below with SilkCircuit colors

# Enable automatic correction of commands (but not arguments)
setopt correct
# setopt correctall  # Disabled: too aggressive for arguments

# Customize the correction prompt
# shellcheck disable=SC2034
SPROMPT="Correct '%R' to '%r'? [Yes/No/Edit/Abort] "

# Make correction more precise for commands
zstyle ':completion:*:correct:*' original true
zstyle ':completion:*:correct:*' insert-unambiguous true
zstyle ':completion:*:approximate:*' max-errors 1 numeric  # Less aggressive correction

# Enhance filename correction
zstyle ':completion:*' completer _complete _match _approximate
zstyle ':completion:*:match:*' original only
zstyle ':completion:*:approximate:*' max-errors 1 numeric

# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
# fzf-tab configuration (SilkCircuit theme)
# ━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

# Disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false

# Set descriptions format with SilkCircuit colors
zstyle ':completion:*:descriptions' format $'\e[38;2;128;255;234m── %d ──\e[0m'
zstyle ':completion:*:messages' format $'\e[38;2;241;250;140m%d\e[0m'
zstyle ':completion:*:warnings' format $'\e[38;2;255;99;99mNo matches for: %d\e[0m'

# Preview directory contents with eza (fallback to ls)
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'eza -1 --color=always --icons $realpath 2>/dev/null || ls -1 $realpath'

# Preview files with bat (fallback to cat)
zstyle ':fzf-tab:complete:*:*' fzf-preview 'bat --color=always --style=numbers --line-range=:100 $realpath 2>/dev/null || cat $realpath 2>/dev/null || eza -1 --color=always $realpath 2>/dev/null'

# Switch groups with < and >
zstyle ':fzf-tab:*' switch-group '<' '>'

# SilkCircuit colors for fzf-tab
zstyle ':fzf-tab:*' fzf-flags \
  '--color=fg:#c0caf5,fg+:#ffffff,bg:-1,bg+:#2a2139' \
  '--color=hl:#e135ff,hl+:#ff79c6,info:#f1fa8c,marker:#50fa7b' \
  '--color=prompt:#80ffea,spinner:#80ffea,pointer:#e135ff,header:#ff6ac1' \
  '--color=border:#e135ff,scrollbar:#e135ff'

# Use tmux popup if available (comment out if not using tmux)
# zstyle ':fzf-tab:*' fzf-command ftb-tmux-popup
