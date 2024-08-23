# Environment variables and path configurations

# Ensure LS_COLORS is set
eval "$(dircolors -b ~/.dircolors)"

# Enable CCACHE and set its directory
export USE_CCACHE=1
export CCACHE_DIR=/b/.ccache
export CCACHE_EXEC=/usr/bin/ccache

# AWS and Kubernetes configurations
export AWS_DEFAULT_PROFILE=mason-devops
export KUBECONFIG=$HOME/.kube/eksctl/clusters/mason-devops

# Python, Go, and other development environment setups
export GOPATH=~/dev/go
export GO15VENDOREXPERIMENT=1
export ANDROID_NDK_HOME=~/Android/android-ndk-r21e
export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"

# HOSTNAME
export HOSTNAME=$(hostname)

# PATH
export PATH=~/.cargo/bin:$PATH:$GOPATH/bin

# Editor
export VISUAL=nvim
export EDITOR="$VISUAL"
