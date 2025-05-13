# 🛳️ Kubernetes Tools

This module adds streamlined support for Kubernetes cluster management to Stefanie's dotfiles, with a focus on using the interactive k9s tool rather than numerous aliases.

## 📦 Installed Tools

The module installs these powerful Kubernetes tools:

- **kubectl** - Kubernetes command-line tool
- **kubectx** - Tool to switch between kubectl contexts
- **kubens** - Tool to switch between Kubernetes namespaces
- **k9s** - Terminal UI to interact with Kubernetes (🌟 recommended primary tool)
- **helm** - Package manager for Kubernetes
- **kustomize** - Customization of Kubernetes YAML
- **kind** - Run local Kubernetes clusters using Docker
- **minikube** - Run Kubernetes locally

## 🚀 Intentionally Minimal Aliases

Instead of numerous aliases that you'll never remember, we provide just a few essential ones:

| Alias | Description |
|-------|-------------|
| `k` | Short for `kubectl` |
| `kx` | Short for `kubectx` |
| `kns` | Short for `kubens` |
| `kgp` | Get pods |
| `kaf` | Apply a YAML file |
| `keti` | Execute a command in a container |

## 🔍 Quick Reference 

We've included the `khelp` command to display a quick reference guide:

```bash
$ khelp
```

This shows common kubectl commands and tips for navigating Kubernetes resources.

## 🖥️ The k9s Advantage

For most Kubernetes operations, the terminal UI tool `k9s` is far more efficient than memorizing dozens of aliases:

- Navigate clusters, namespaces, pods, services, etc. with keyboard shortcuts
- View logs, describe resources, and edit YAML all from a single interface
- Port forwarding, shell access, and resource deletion with a few keystrokes
- Real-time updates and filtering

Simply run:

```bash
$ k9s
```

## 🔧 Core Functions

We've kept a few essential shell functions for common tasks:

### Config Management

```bash
# Switch between Kubernetes contexts
kconfig [config_name]

# Without arguments - list available configs
kconfig
```

### Log Access

```bash
# Get logs from a pod
klogs <pod> [container] [namespace]
```

## 📝 Example Workflow

```bash
# Switch to a specific kubeconfig
kconfig production

# See what's available in the cluster
k9s

# Or use kubectl directly for specific commands
kgp -n monitoring
klogs prometheus-server -n monitoring
keti debug-pod -- sh
kaf deployment.yaml
```

## 💼 Windows PowerShell Support

The same streamlined approach is available in PowerShell with equivalent commands.

## ⚙️ Configuration

Kubernetes configurations are stored in:

- `~/.kube/config` - Default Kubernetes configuration
- `~/.kube/configs/` - Directory for additional configurations

Use the `kconfig` command to switch between configurations.

## 🔍 Additional Resources

- [k9s Documentation](https://k9scli.io/)
- [Kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [Helm Documentation](https://helm.sh/docs/) 