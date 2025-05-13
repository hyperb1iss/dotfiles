#!/bin/bash
# kubernetes.sh
# Streamlined Kubernetes shell utilities with focus on k9s

# Essential aliases
alias k='kubectl'
alias kx='kubectx'
alias kns='kubens'

# Highly practical aliases worth remembering
alias kgp='kubectl get pods'
alias kaf='kubectl apply -f'
alias keti='kubectl exec -ti'

# Switch kube config
kconfig() {
  local config_dir="${KUBE_CONFIG_DIR:-$HOME/.kube/configs}"
  local config_file="$config_dir/$1"
  
  if [ -z "$1" ]; then
    echo "Current KUBECONFIG: $KUBECONFIG"
    echo "Available configs in $config_dir:"
    ls -1 "$config_dir" 2>/dev/null || echo "No configs found"
    return 0
  fi
  
  if [ -f "$config_file" ]; then
    export KUBECONFIG="$config_file"
    echo "Switched to $1 kubernetes config"
  else
    echo "Config $1 not found in $config_dir"
    return 1
  fi
}

# Quick pod logs (most common use case)
klogs() {
  local pod="$1"
  local container="$2"
  local namespace="${3:-default}"
  
  if [ -z "$pod" ]; then
    echo "Usage: klogs <pod> [container] [namespace]"
    return 1
  fi
  
  if [ -n "$container" ]; then
    kubectl logs -n "$namespace" "$pod" -c "$container" --tail=100 -f
  else
    kubectl logs -n "$namespace" "$pod" --tail=100 -f
  fi
}

# Kubernetes help/cheatsheet function
khelp() {
  cat << EOF
🛳️ Kubernetes Quick Reference 

📊 Interactive UI:
  k9s                      # Full-featured Kubernetes TUI (recommended)

🔑 Core Commands:
  k                        # Short for kubectl
  kx                       # Switch context (kubectx)
  kns                      # Switch namespace (kubens)
  kgp                      # Get pods
  kaf deployment.yaml      # Apply file
  klogs pod-name           # Stream logs
  keti pod-name -- sh      # Interactive shell
  kconfig                  # Switch kubeconfig file

📚 Useful kubectl commands:
  k get all                # List all resources
  k get pods -o wide       # Detailed pod view  
  k describe pod <name>    # Resource details
  k port-forward pod 8080:80    # Port forwarding
  k apply -k ./kustomize/  # Apply kustomize dir

⚡ Pro tip: Use k9s for almost everything - it's much faster than aliases!
EOF
}

# Create kubeconfig directory if it doesn't exist
mkdir -p "${KUBE_CONFIG_DIR:-$HOME/.kube/configs}"

# Add kubectl completion
if command -v kubectl >/dev/null 2>&1; then
  source <(kubectl completion bash)
  complete -o default -F __start_kubectl k
fi

# Initialize krew path if installed
if [ -d "${HOME}/.krew/bin" ]; then
  export PATH="${PATH}:${HOME}/.krew/bin"
fi

# Setup kubectx/kubens completion if available
if command -v kubectx >/dev/null 2>&1; then
  # Check if fzf is available for enhanced kubectx/kubens
  if command -v fzf >/dev/null 2>&1; then
    export KUBECTX_IGNORE_FZF=0
    export KUBENS_IGNORE_FZF=0
  fi
fi

# Set default KUBECONFIG if not set
if [ -z "$KUBECONFIG" ] && [ -f "$HOME/.kube/config" ]; then
  export KUBECONFIG="$HOME/.kube/config"
fi

echo "✨ Kubernetes utilities loaded - use 'khelp' for quick reference 🛳️" 