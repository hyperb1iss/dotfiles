#!/usr/bin/env bash

# SilkCircuit Native Status Line for Claude Code

# Nerd Font glyphs are multi-byte. Without a UTF-8 locale bash measures strings
# in bytes, which overstates the visible width and drags the right-hand segment
# out of alignment. Windows shells routinely start with no locale set at all.
export LC_ALL=C.UTF-8
shopt -s extglob

# Read JSON input
input=$(cat)

# Extract a JSON string value: json_str <haystack> <key>, result in $REPLY.
# Parsing inline keeps the status line free of a jq dependency, which is absent
# on a stock Windows box, and avoids a subprocess per field on a hot path.
json_str() {
    local hay="$1" rest
    rest="${hay#*\"$2\":\"}"
    [ "$rest" = "$hay" ] && { REPLY=""; return 1; }
    REPLY="${rest%%\"*}"
    REPLY="${REPLY//\\\\/\\}"
    REPLY="${REPLY//\\\"/\"}"
    REPLY="${REPLY//\\\//\/}"
}

# Extract a JSON number as an integer: json_num <haystack> <key>, result in $REPLY
json_num() {
    local hay="$1" rest
    rest="${hay#*\"$2\":}"
    [ "$rest" = "$hay" ] && { REPLY=0; return 1; }
    rest="${rest%%,*}"
    rest="${rest%%\}*}"
    rest="${rest//[^0-9.-]/}"
    REPLY="${rest%%.*}"
    [ -n "$REPLY" ] || REPLY=0
}

json_str "$input" display_name && model="$REPLY" || model="Claude"
json_str "$input" current_dir && current_dir="$REPLY" || json_str "$input" cwd && current_dir="$REPLY"

scope="${input#*\"output_style\":}"
json_str "$scope" name && output_style="$REPLY" || output_style="default"

json_num "$input" total_input_tokens
token_count="$REPLY"
json_num "$input" context_window_size
context_size="$REPLY"
[ "$context_size" -gt 0 ] 2>/dev/null || context_size=200000

# Normalize to forward slashes so the path splits below work on Windows, where
# current_dir arrives as C:\Users\name\project
dir_norm="${current_dir//\\//}"
home_norm="${USERPROFILE:-$HOME}"
home_norm="${home_norm//\\//}"

# Set current directory for operations. Claude Code invokes the status line from
# an unrelated directory, so the git lookups below depend on this.
if [ -n "$dir_norm" ]; then
    cd "$dir_norm" 2>/dev/null || true
fi

# Get terminal width for spacing. Claude Code exports COLUMNS when it invokes
# the status line, so tput is only a fallback for other callers.
terminal_width="${COLUMNS:-}"
if [ -z "$terminal_width" ]; then
    terminal_width=$(tput cols 2>/dev/null || echo 80)
fi

# SilkCircuit color palette - Using RGB values for direct ANSI codes
bg_deep=$'\033[48;2;15;15;31m'
bg_dark=$'\033[48;2;42;10;42m'
bg_mid=$'\033[48;2;74;26;74m'
bg_bright=$'\033[48;2;106;42;106m'
bg_vivid=$'\033[48;2;138;58;138m'
bg_hot=$'\033[48;2;170;74;170m'

# Foreground twins of the backgrounds above, used to draw the separators
fg_deep=$'\033[38;2;15;15;31m'
fg_dark=$'\033[38;2;42;10;42m'
fg_mid=$'\033[38;2;74;26;74m'
fg_bright=$'\033[38;2;106;42;106m'
fg_hot=$'\033[38;2;170;74;170m'

fg_white=$'\033[38;2;255;255;255m'
reset=$'\033[0m'

# Glyphs are written as escapes rather than literal characters so that editors,
# patches, and copy-paste cannot silently strip them. These are raw UTF-8 bytes
# because \u and \U escapes need bash 4.2 and macOS ships 3.2, where they pass
# through as the literal text "\uE0B0".
POWERLINE_SEP_RIGHT_FILLED=$'\xee\x82\xb0'  # U+E0B0, left segment to next (LTR)
POWERLINE_SEP_RIGHT_THIN=$'\xee\x82\xb1'    # U+E0B1
POWERLINE_SEP_LEFT_FILLED=$'\xee\x82\xb2'   # U+E0B2, right segment to previous
POWERLINE_SEP_LEFT_THIN=$'\xee\x82\xb3'     # U+E0B3

ICON_GIT=$'\xee\x9c\xa5'      # U+E725
ICON_BULLET=$'\xe2\x80\xa2'   # U+2022
ICON_ELLIPSIS=$'\xe2\x80\xa6' # U+2026
ICON_MIDDOT=$'\xc2\xb7'       # U+00B7

# These five sit above U+FFFF. Bash on Windows stores strings as UTF-16 and so
# measures each as two units, while the terminal draws a single cell.
ICON_NODE=$'\xf3\xb0\x8e\x99'  # U+F0399
ICON_K8S=$'\xf3\xb1\x83\xbe'   # U+F10FE
ICON_MODEL=$'\xf3\xb0\xad\xbb' # U+F0B7B
ICON_TOKEN=$'\xf3\xb0\x9a\xa9' # U+F06A9
ICON_CLOCK=$'\xf3\xb1\x91\x8d' # U+F144D

ASTRAL_ICONS="@($ICON_NODE|$ICON_K8S|$ICON_MODEL|$ICON_TOKEN|$ICON_CLOCK)"
astral_probe="$ICON_NODE"
astral_units=${#astral_probe}

# Format the current time, result in $REPLY. printf's %()T needs bash 4.2, which
# rules it out on macOS, so bind the cheap builtin once where it exists and pay
# for date(1) only where it does not.
if [ "${BASH_VERSINFO[0]:-0}" -gt 4 ] ||
    { [ "${BASH_VERSINFO[0]:-0}" -eq 4 ] && [ "${BASH_VERSINFO[1]:-0}" -ge 2 ]; }; then
    now_fmt() { printf -v REPLY "%($1)T" -1; }
else
    now_fmt() { REPLY=$(date "+$1"); }
fi

# Visible cell width of a string, result in $REPLY. Off Windows ${#s} is already
# correct and the astral discount below is a no-op.
vwidth() {
    local s="$1" bare
    REPLY=${#s}
    [ "$astral_units" -gt 1 ] || return 0
    bare="${s//$ASTRAL_ICONS/}"
    REPLY=$(( ${#bare} + (${#s} - ${#bare}) / astral_units ))
}

# Choose default separator style based on output_style
SEP_RIGHT="$POWERLINE_SEP_RIGHT_FILLED"
SEP_LEFT="$POWERLINE_SEP_LEFT_FILLED"
if [ "$output_style" = "thin" ] || [ "$output_style" = "minimal" ]; then
    SEP_RIGHT="$POWERLINE_SEP_RIGHT_THIN"
    SEP_LEFT="$POWERLINE_SEP_LEFT_THIN"
fi

# Build status line components
#
# left_output carries the escape codes, left_visible tracks only the printable
# characters so the fill width below can be computed without stripping ANSI.
left_output="$bg_deep$bg_dark$reset"
left_visible=""

# Empty space segment
left_output+="$bg_dark$fg_white $reset"
left_visible+=" "

# Directory segment
left_output+="$bg_mid$fg_dark$SEP_RIGHT"
left_visible+="$SEP_RIGHT"
if [ -n "$dir_norm" ]; then
    dir_display="$dir_norm"
    if [ -n "$home_norm" ] && [ "${dir_display#"$home_norm"}" != "$dir_display" ]; then
        dir_display="~${dir_display#"$home_norm"}"
    fi
    if [ ${#dir_display} -gt 30 ]; then
        leaf="${dir_display##*/}"
        parent="${dir_display%/*}"
        parent="${parent##*/}"
        if [ -n "$parent" ]; then
            dir_display="$ICON_ELLIPSIS/$parent/$leaf"
        else
            dir_display="/$leaf"
        fi
    fi
    dir_segment=" $dir_display "
else
    dir_segment=" ~ "
fi
left_output+="$bg_mid$fg_white$dir_segment$reset"
left_visible+="$dir_segment"

# Git segment
left_output+="$bg_bright$fg_mid$SEP_RIGHT"
left_visible+="$SEP_RIGHT"
git_segment=""
if branch=$(git rev-parse --abbrev-ref HEAD 2>/dev/null); then
    [ "$branch" = "HEAD" ] && branch="detached"
    status_info=""
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        status_info="*"
    fi
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null | head -1)" ]; then
        status_info="${status_info}?"
    fi
    git_segment=" $ICON_GIT $branch$status_info "
fi
left_output+="$bg_bright$fg_white$git_segment$reset"
left_visible+="$git_segment"

# Tech stack segment
left_output+="$bg_vivid$fg_bright$SEP_RIGHT"
left_visible+="$SEP_RIGHT"
tech_info=""

# Probing node and kubectl costs hundreds of milliseconds on Windows, where
# spawning a process is expensive, and the answers change far more slowly than
# the status line redraws. Cache the rendered segment per directory, since the
# node version is the one part that varies with location.
TECH_TTL=60
now_fmt %s
now="$REPLY"
cache_dir="${XDG_CACHE_HOME:-$HOME/.cache}/silkcircuit"
cache_key="${dir_norm//[^a-zA-Z0-9]/_}"
[ ${#cache_key} -gt 60 ] && cache_key="${cache_key: -60}"
cache_file="$cache_dir/statusline-tech-${#dir_norm}-$cache_key"

tech_fresh=0
if [ -r "$cache_file" ]; then
    IFS=$'\t' read -r cached_at cached_tech < "$cache_file"
    if [ $(( now - ${cached_at:-0} )) -lt "$TECH_TTL" ] 2>/dev/null; then
        tech_info="$cached_tech"
        tech_fresh=1
    fi
fi

if [ "$tech_fresh" -eq 0 ]; then
    # Node.js version
    if command -v node >/dev/null 2>&1; then
        node_version=$(node --version 2>/dev/null)
        tech_info="${tech_info}$ICON_NODE ${node_version#v} "
    fi

    # Kubernetes context
    if command -v kubectl >/dev/null 2>&1; then
        k8s_context=$(kubectl config current-context 2>/dev/null)
        k8s_context="${k8s_context#eks-us-west-2-}"
        if [ -n "$k8s_context" ]; then
            tech_info="${tech_info}$ICON_K8S $k8s_context "
        fi
    fi

    [ -d "$cache_dir" ] || mkdir -p "$cache_dir" 2>/dev/null
    printf '%s\t%s\n' "$now" "$tech_info" > "$cache_file" 2>/dev/null || true
fi

if [ -n "$tech_info" ]; then
    tech_segment=" $tech_info"
else
    tech_segment=""
fi
left_output+="$bg_vivid$fg_white$tech_segment$reset"
left_visible+="$tech_segment"

# Now build the right side content
right_content=""
if [ -n "$model" ]; then
    right_content="$ICON_MODEL $model"
fi

# Token count, with the share of the context window it occupies
if [ "$token_count" -gt 0 ] 2>/dev/null; then
    if [ "$token_count" -ge 1000 ]; then
        whole=$((token_count / 1000))
        tenth=$(((token_count % 1000) / 100))
        if [ "$whole" -lt 100 ] && [ "$tenth" -gt 0 ]; then
            token_display="${whole}.${tenth}K"
        else
            token_display="${whole}K"
        fi
    else
        token_display="$token_count"
    fi
    token_display="$token_display$ICON_MIDDOT$((token_count * 100 / context_size))%"

    if [ -n "$right_content" ]; then
        right_content="$right_content $ICON_BULLET $ICON_TOKEN $token_display"
    else
        right_content="$ICON_TOKEN $token_display"
    fi
fi

if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    if [ -n "$right_content" ]; then
        right_content="$right_content $ICON_BULLET $output_style"
    else
        right_content="$output_style"
    fi
fi

# Time
now_fmt '%I:%M%p'
current_time="$REPLY"
current_time="${current_time/AM/am}"
current_time="${current_time/PM/pm}"
current_time="${current_time#0}"
if [ -n "$right_content" ]; then
    right_content="$right_content $ICON_CLOCK $current_time"
else
    right_content="$ICON_CLOCK $current_time"
fi

# Calculate fill so the right segment lands against the terminal edge. The two
# separators framing it are one visible cell each.
right_segment=" $right_content "
vwidth "$left_visible"; left_width=$REPLY
vwidth "$right_segment"; right_width=$REPLY
fill_spaces=$((terminal_width - left_width - right_width - 2))
if [ $fill_spaces -lt 1 ]; then
    fill_spaces=1
fi

# Output the complete status line
printf '%s' "$left_output"

# Fill spaces with the current background color
printf '%s%*s%s' "$bg_vivid" $fill_spaces "" "$reset"

# Right side separator (from tech segment background to hot background)
printf '%s%s%s' "$bg_vivid" "$fg_hot" "$SEP_LEFT"

# Model and time segment
printf '%s%s%s%s' "$bg_hot" "$fg_white" "$right_segment" "$reset"

# End segment
printf '%s%s%s%s' "$bg_hot" "$fg_deep" "$SEP_LEFT" "$reset"
