# aosp.sh
# AOSP and Android OS build system utilities

# Skip entire module if not in full installation
is_minimal && return 0

# Android build environment setup
function set_android_env() {
  if [[ -f build/envsetup.sh ]]; then
    # Save current options
    if is_zsh; then
      local old_opts
      old_opts=$(setopt)
    fi

    # Source build environment
    source build/envsetup.sh

    # Restore options for zsh
    if is_zsh; then
      eval "${old_opts}"
      setopt SH_WORD_SPLIT
    fi

    echo "Android build environment initialized."
  else
    echo "Error: build/envsetup.sh not found. Are you in an AOSP directory?"
  fi
}
alias envsetup='set_android_env'

# Enhanced make command for Android
function mka() {
  local start_time cores make_args status
  start_time=$(date +%s)
  cores=$(grep -c ^processor /proc/cpuinfo)

  echo "Building with ${cores} cores..."

  # Combine all arguments into make_args
  make_args="$*"

  # Use command substitution safely
  if has_command schedtool; then
    # shellcheck disable=SC2086
    schedtool -B -n 10 -e ionice -n 7 make -j"${cores}" ${make_args}
  else
    # shellcheck disable=SC2086
    make -j"${cores}" ${make_args}
  fi
  status=$?

  local end_time tdiff hours mins secs
  end_time=$(date +%s)
  tdiff=$((end_time - start_time))
  hours=$((tdiff / 3600))
  mins=$(((tdiff % 3600) / 60))
  secs=$((tdiff % 60))

  echo
  if [[ ${status} -eq 0 ]]; then
    printf "\033[32m#### Build completed successfully "
  else
    printf "\033[31m#### Build failed "
  fi

  if [[ ${hours} -gt 0 ]]; then
    printf "(%02d:%02d:%02d)\033[0m\n" "${hours}" "${mins}" "${secs}"
  else
    printf "(%02d:%02d)\033[0m\n" "${mins}" "${secs}"
  fi

  return "${status}"
}

# Quick repo sync with auto retry
function reposync() {
  local max_retries=3
  local retry_count=0
  local sync_success=false
  local cores

  cores=$(nproc 2> /dev/null || echo "4")

  while [[ ${retry_count} -lt ${max_retries} ]] && [[ "${sync_success}" = false ]]; do
    echo "Attempt $((retry_count + 1)) of ${max_retries}"
    if repo sync -j"${cores}" --force-sync; then
      sync_success=true
    else
      retry_count=$((retry_count + 1))
      if [[ ${retry_count} -lt ${max_retries} ]]; then
        echo "Sync failed, retrying in 5 seconds..."
        sleep 5
      fi
    fi
  done

  if [[ "${sync_success}" = true ]]; then
    echo "Repo sync completed successfully"
  else
    echo "Repo sync failed after ${max_retries} attempts"
    return 1
  fi
}

# Enhanced repo status with portable sort
function rstat() {
  local repo_status
  repo_status=$(repo status) || true

  # Use consecutive pipes with || true to handle errors
  echo "${repo_status}" | grep -v "^$" | grep -v "project " | LC_ALL=C sort
}

# Quick device setup with shell-agnostic variable handling
function lunch_device() {
  if [[ -z "${1:-}" ]]; then
    lunch
  else
    lunch "$1-userdebug"
  fi
}
alias ld='lunch_device'

# Install boot image with proper variable handling
function installboot() {
  if [[ -z "${TARGET_PRODUCT:-}" ]]; then
    echo "No TARGET_PRODUCT specified."
    return 1
  fi
  if [[ ! -e "${OUT:-}/boot.img" ]]; then
    echo "No boot.img found. Run make bootimage first."
    return 1
  fi

  local device PARTITION
  if ! device=$(get_device); then
    return 1
  fi

  PARTITION="/dev/block/bootdevice/by-name/boot"
  adb -s "${device}" root
  sleep 1
  adb -s "${device}" wait-for-device
  adb -s "${device}" shell mount /system 2> /dev/null
  adb -s "${device}" remount

  local product_name
  product_name=$(adb -s "${device}" shell getprop ro.product.name) || true

  if echo "${product_name}" | grep -q "${TARGET_PRODUCT}"; then
    adb -s "${device}" push "${OUT}/boot.img" /data/local/tmp/
    for module in "${OUT}"/system/lib/modules/*; do
      [[ -f "${module}" ]] && adb -s "${device}" push "${module}" /system/lib/modules/
    done
    adb -s "${device}" shell "dd if=/data/local/tmp/boot.img of=${PARTITION}"
    adb -s "${device}" shell "chmod 644 /system/lib/modules/*"
    echo "Installation complete."
  else
    echo "The connected device does not appear to be ${TARGET_PRODUCT}, run away!"
  fi
}

# Remote management functions with proper error handling
function aospremote() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
    return 1
  fi

  git remote rm aosp 2> /dev/null
  local PROJECT PFX
  local current_dir
  current_dir=$(pwd -P) || true
  PROJECT=$(echo "${current_dir}" | sed -e "s#${ANDROID_BUILD_TOP:-}/##; s#-caf.*##; s#/default##")
  if echo "${PROJECT}" | grep -qv "^device"; then
    PFX="platform/"
  fi
  git remote add aosp "https://android.googlesource.com/${PFX}${PROJECT}"
  echo "Remote 'aosp' created"
}

function cafremote() {
  if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo ".git directory not found. Please run this from the root directory of the Android repository you wish to set up."
    return 1
  fi

  git remote rm caf 2> /dev/null
  local PROJECT PFX
  local current_dir
  current_dir=$(pwd -P) || true
  PROJECT=$(echo "${current_dir}" | sed -e "s#${ANDROID_BUILD_TOP:-}/##; s#-caf.*##; s#/default##")
  if echo "${PROJECT}" | grep -qv "^device"; then
    PFX="platform/"
  fi
  git remote add caf "https://source.codeaurora.org/quic/la/${PFX}${PROJECT}"
  echo "Remote 'caf' created"
}

# Quick navigation aliases (work in both shells)
alias croot='cd ${ANDROID_BUILD_TOP:-.}'
alias godefault='cd ${ANDROID_BUILD_TOP:-.}/default'
alias gokernel='cd ${ANDROID_BUILD_TOP:-.}/kernel'
alias govendor='cd ${ANDROID_BUILD_TOP:-.}/vendor'
alias godevice='cd ${ANDROID_BUILD_TOP:-.}/device'
alias goapps='cd ${ANDROID_BUILD_TOP:-.}/packages/apps'
alias goframework='cd ${ANDROID_BUILD_TOP:-.}/frameworks'
alias gosystem='cd ${ANDROID_BUILD_TOP:-.}/system'
alias gohw='cd ${ANDROID_BUILD_TOP:-.}/hardware'
alias goout='cd ${OUT:-.}'

# Environment variables
export ANDROID_JACK_VM_ARGS="-Dfile.encoding=UTF-8 -XX:+TieredCompilation -Xmx4g"

# Initialize repo completion for both shells
if [[ -f ~/bin/repo ]]; then
  repo_completion=$(~/bin/repo --help | grep -A 1 "Shell completion" | tail -1) || true

  if is_zsh; then
    autoload -Uz compinit && compinit
    eval "${repo_completion}"
  else
    eval "${repo_completion}"
  fi
fi
