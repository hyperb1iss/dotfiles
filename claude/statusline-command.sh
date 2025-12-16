#!/bin/bash

# SilkCircuit Native Status Line for Claude Code

# Read JSON input
input=$(cat)

# Extract data from JSON
model=$(echo "$input" | jq -r '.model.display_name // "Claude"')
current_dir=$(echo "$input" | jq -r '.workspace.current_dir // ""')
output_style=$(echo "$input" | jq -r '.output_style.name // "default"')

# Updated for Claude Code 2.0.70+ — context_window replaces conversation
current_tokens=$(echo "$input" | jq -r '(.context_window.current_usage.input_tokens // 0) + (.context_window.current_usage.cache_creation_input_tokens // 0) + (.context_window.current_usage.cache_read_input_tokens // 0)')
context_size=$(echo "$input" | jq -r '.context_window.context_window_size // 200000')
if [ "$current_tokens" != "null" ] && [ "$current_tokens" != "0" ] && [ "$context_size" != "0" ]; then
    token_count=$current_tokens
else
    token_count=""
fi

# Set current directory for operations
if [ -n "$current_dir" ]; then
    cd "$current_dir" 2>/dev/null || true
fi

# Get terminal width for spacing
terminal_width=$(tput cols 2>/dev/null || echo 80)

# SilkCircuit color palette - Using RGB values for direct ANSI codes
bg_deep=$'\033[48;2;15;15;31m'
bg_dark=$'\033[48;2;42;10;42m'
bg_mid=$'\033[48;2;74;26;74m'
bg_bright=$'\033[48;2;106;42;106m'
bg_vivid=$'\033[48;2;138;58;138m'
bg_hot=$'\033[48;2;170;74;170m'

fg_white=$'\033[38;2;255;255;255m'
reset=$'\033[0m'

# Powerline / Nerd Font separators (requires a Nerd Font-enabled terminal)
POWERLINE_SEP_RIGHT_FILLED=""  # from left segment to next (LTR)
POWERLINE_SEP_RIGHT_THIN=""
POWERLINE_SEP_LEFT_FILLED=""   # from right segment to previous (RTL)
POWERLINE_SEP_LEFT_THIN=""

# Choose default separator style based on output_style
SEP_RIGHT_DEFAULT="$POWERLINE_SEP_RIGHT_FILLED"
SEP_LEFT_DEFAULT="$POWERLINE_SEP_LEFT_FILLED"
if [ "$output_style" = "thin" ] || [ "$output_style" = "minimal" ]; then
    SEP_RIGHT_DEFAULT="$POWERLINE_SEP_RIGHT_THIN"
    SEP_LEFT_DEFAULT="$POWERLINE_SEP_LEFT_THIN"
fi

# Helper function to create colored segments
segment() {
    local bg_color="$1"
    local content="$2"
    printf "%s%s%s%s" "$bg_color" "$fg_white" "$content" "$reset"
}

# Helper function to get the visible length of text (without ANSI codes)
get_visible_length() {
    local text="$1"
    # Remove all ANSI escape sequences and count visible characters properly
    printf '%s' "$text" | sed 's/\x1b\[[0-9;]*m//g' | wc -m | tr -d ' '
}

# Helper function for powerline separators (left-to-right flow)
separator() {
    local prev_bg="$1"
    local next_bg="$2"
    local separator_char="${3:-$POWERLINE_SEP_RIGHT_FILLED}"
    # Extract RGB values from prev_bg and create foreground color
    local prev_fg
    prev_fg=$(printf '%s' "$prev_bg" | sed 's/48;2;/38;2;/')
    printf "%s%s%s" "$next_bg" "$prev_fg" "${separator_char:-$SEP_RIGHT_DEFAULT}"
}

# Helper function for right-side separators (flowing right-to-left)
right_separator() {
    local prev_bg="$1"
    local next_bg="$2"
    local separator_char="${3:-$POWERLINE_SEP_LEFT_FILLED}"
    # Extract RGB values from next_bg and create foreground color
    local next_fg
    next_fg=$(printf '%s' "$next_bg" | sed 's/48;2;/38;2;/')
    printf "%s%s%s" "$prev_bg" "$next_fg" "${separator_char:-$SEP_LEFT_DEFAULT}"
}

# Build status line components

# First, build the left side and capture both the visible content and the full output
left_output=""
left_visible_content=""

# Start segment (invisible transition)
left_output+="$bg_deep$bg_dark$reset"

# Empty space segment
left_segment_1=" "
left_output+=$(segment "$bg_dark" "$left_segment_1")
left_visible_content+="$left_segment_1"

# Directory segment
left_output+=$(separator "$bg_dark" "$bg_mid" "")
left_visible_content+="$POWERLINE_SEP_RIGHT_FILLED"
if [ -n "$current_dir" ]; then
    # Truncate path similar to starship
    short_dir=$(basename "$current_dir")
    if [ ${#current_dir} -gt 30 ]; then
        parent=$(dirname "$current_dir" | sed 's|.*/\([^/]*\)$|…/\1|')
        dir_display="$parent/$short_dir"
    else
        dir_display="$current_dir"
    fi
    left_segment_2=" $dir_display "
else
    left_segment_2=" ~ "
fi
left_output+=$(segment "$bg_mid" "$left_segment_2")
left_visible_content+="$left_segment_2"

# Git segment
left_output+=$(separator "$bg_mid" "$bg_bright" "")
left_visible_content+="$POWERLINE_SEP_RIGHT_FILLED"
if git rev-parse --git-dir >/dev/null 2>&1; then
    branch=$(git branch --show-current 2>/dev/null || echo "detached")
    status_info=""
    
    # Check git status
    if ! git diff-index --quiet HEAD -- 2>/dev/null; then
        status_info="*"
    fi
    if [ -n "$(git ls-files --others --exclude-standard 2>/dev/null)" ]; then
        status_info="${status_info}?"
    fi
    
    left_segment_3="  $branch$status_info "
else
    left_segment_3=""
fi
left_output+=$(segment "$bg_bright" "$left_segment_3")
left_visible_content+="$left_segment_3"

# Tech stack segment
left_output+=$(separator "$bg_bright" "$bg_vivid" "")
left_visible_content+="$POWERLINE_SEP_RIGHT_FILLED"
tech_info=""

# Node.js version
if command -v node >/dev/null 2>&1; then
    node_version=$(node --version 2>/dev/null | sed 's/v//')
    tech_info="${tech_info}󰎙 $node_version "
fi

# Kubernetes context
if command -v kubectl >/dev/null 2>&1; then
    k8s_context=$(kubectl config current-context 2>/dev/null | sed 's/eks-us-west-2-//')
    if [ -n "$k8s_context" ]; then
        tech_info="${tech_info}󱃾 $k8s_context "
    fi
fi

# Docker context
if command -v docker >/dev/null 2>&1; then
    docker_context=$(docker context show 2>/dev/null)
    if [ -n "$docker_context" ] && [ "$docker_context" != "default" ]; then
        tech_info="${tech_info}󰡨 $docker_context "
    fi
fi

if [ -n "$tech_info" ]; then
    left_segment_4=" $tech_info"
else
    left_segment_4=""
fi
left_output+=$(segment "$bg_vivid" "$left_segment_4")
left_visible_content+="$left_segment_4"

# Now build the right side content
right_content=""
if [ -n "$model" ]; then
    right_content="󰭻 $model"
fi

# Token count
if [ -n "$token_count" ] && [ "$token_count" != "null" ]; then
    # Format token count with appropriate suffix (K for thousands)
    if [ "$token_count" -ge 1000 ]; then
        token_display=$(echo "$token_count" | awk '{printf "%.1fK", $1/1000}' | sed 's/\.0K/K/')
    else
        token_display="$token_count"
    fi
    
    if [ -n "$right_content" ]; then
        right_content="$right_content • 󰚩 $token_display"
    else
        right_content="󰚩 $token_display"
    fi
fi

if [ -n "$output_style" ] && [ "$output_style" != "default" ]; then
    if [ -n "$right_content" ]; then
        right_content="$right_content • $output_style"
    else
        right_content="$output_style"
    fi
fi

# Time
current_time=$(date "+%I:%M %p" | sed 's/ //g' | tr '[:upper:]' '[:lower:]')
if [ -n "$right_content" ]; then
    right_content="$right_content 󱑍 $current_time"
else
    right_content="󱑍 $current_time"
fi

# Calculate the visible lengths using proper character counting
left_length=$(get_visible_length "$left_visible_content")
right_segment_content=" $right_content "
right_length=$(get_visible_length "$right_segment_content")
separator_length=1  # Each powerline separator is 1 visible character
end_separator_length=1  # Trailing end separator on far right

# Calculate total space needed for right side (leading + trailing separators + content)
total_right_length=$((separator_length + end_separator_length + right_length))

# Calculate fill space
fill_spaces=$((terminal_width - left_length - total_right_length))
if [ $fill_spaces -lt 1 ]; then
    fill_spaces=1
fi

# Output the complete status line
printf "%s" "$left_output"

# Fill spaces with the current background color
printf "%s%*s%s" "$bg_vivid" $fill_spaces "" "$reset"

# Right side separator (from tech segment background to hot background)
printf "%s" "$(right_separator "$bg_vivid" "$bg_hot" "")"

# Model and time segment
printf "%s" "$(segment "$bg_hot" "$right_segment_content")"

# End segment
printf "%s" "$(right_separator "$bg_hot" "$bg_deep" "")"

# Reset colors
printf "%s" "$reset"

