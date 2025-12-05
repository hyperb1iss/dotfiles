# Kubernetes

_Cluster control without the typing_

Managing Kubernetes shouldn't feel like you're programming in `kubectl`. These shortcuts make it tolerable.

## Core Aliases

| Alias | Command   | Description                  |
| ----- | --------- | ---------------------------- |
| `k`   | `kubectl` | Save 6 keystrokes every time |
| `kx`  | `kubectx` | Context switcher             |
| `kns` | `kubens`  | Namespace switcher           |

You'll type `k get pods` so much it'll become muscle memory.

## Common Operations

| Alias  | Command            | Description               |
| ------ | ------------------ | ------------------------- |
| `kgp`  | `kubectl get pods` | List pods                 |
| `kaf`  | `kubectl apply -f` | Apply manifest            |
| `keti` | `kubectl exec -ti` | Interactive exec into pod |

These cover 80% of daily kubectl usage.

## Functions

### `kconfig` — Switch Kubeconfig

Manage multiple kubeconfig files:

```bash
kconfig dev
# Switches to ~/.kube/configs/dev

kconfig prod
# Switches to ~/.kube/configs/prod
```

Store different cluster configs in `~/.kube/configs/` and switch between them easily.

### `klogs` — Quick Pod Logs

Tail logs from a pod:

```bash
klogs my-pod
# Shows last 100 lines with follow (-f)
```

Add `-c container-name` if the pod has multiple containers.

### `khelp` — Quick Reference

Forgot that kubectl command?

```bash
khelp
# Shows common kubectl commands
# Organized by category
```

Your personal kubectl cheatsheet.

## Context & Namespace Management

### kubectx

Switch between clusters:

```bash
kx              # List contexts (with fzf if available)
kx production   # Switch to production
kx staging      # Switch to staging
kx -            # Switch back to previous context
```

Critical for multi-cluster workflows. One command to switch environments.

### kubens

Switch between namespaces:

```bash
kns             # List namespaces (with fzf if available)
kns kube-system # Switch to kube-system
kns default     # Back to default
kns -           # Switch to previous namespace
```

Stop typing `-n namespace` on every command.

## Krew Plugin Manager

[Krew](https://krew.sigs.k8s.io/) extends kubectl with plugins. The path is already configured.

```bash
# Install plugins
kubectl krew install ctx ns

# Update krew
kubectl krew upgrade

# List installed
kubectl krew list
```

Recommended plugins:

- `ctx` / `ns` — Context/namespace management
- `tree` — Show resources in tree format
- `view-secret` — Decode secrets easily
- `tail` — Tail logs from multiple pods

## k9s Integration

[k9s](https://k9scli.io/) is the ultimate Kubernetes TUI. Works seamlessly with these configs.

```bash
k9s            # Open k9s in current context/namespace
k9s -n default # Open in specific namespace
k9s --context prod  # Open with specific context
```

Learn k9s keyboard shortcuts:

- `0` — Show all namespaces
- `:pod` — Jump to pods
- `:svc` — Jump to services
- `:deploy` — Jump to deployments
- `l` — View logs
- `d` — Describe resource
- `e` — Edit resource
- `s` — Shell into container

## Common Workflows

### Debug a Pod

```bash
# Find the pod
kgp

# Check logs
klogs my-pod-abc123

# Or shell into it
keti my-pod-abc123 -- bash
# or: keti my-pod-abc123 -- sh

# Describe it
k describe pod my-pod-abc123
```

### Apply Configuration Changes

```bash
# Apply single file
kaf deployment.yaml

# Apply directory
k apply -f ./manifests/

# Apply with kustomize
k apply -k ./overlays/production/
```

### Switch Environments

Multi-environment workflow:

```bash
# Check current context
kx

# Switch to staging
kx staging

# Switch namespace
kns my-app

# Verify you're in the right place
kgp

# Make changes
kaf deployment.yaml

# Switch back to dev
kx dev
kns default
```

### Port Forward for Local Access

```bash
# Forward pod port
k port-forward my-pod 8080:80

# Forward service port
k port-forward svc/my-service 8080:80

# Run in background
k port-forward my-pod 8080:80 &
```

Access the service at `localhost:8080`.

### Scale Deployments

```bash
# Scale up
k scale deployment/my-app --replicas=5

# Scale down
k scale deployment/my-app --replicas=1

# Scale to zero (careful!)
k scale deployment/my-app --replicas=0
```

### Check Resource Usage

```bash
# Node resources
k top nodes

# Pod resources
k top pods

# Specific namespace
k top pods -n production
```

Requires metrics-server installed in the cluster.

### Watch Resources

```bash
# Watch pods
k get pods -w

# Watch with timestamp
k get pods -w --show-labels

# Watch events
k get events -w
```

The `-w` flag watches for changes. Useful during deployments.

## Quick Debugging

### Pod Won't Start

```bash
kgp              # Check status
k describe pod <name>   # Look for events
klogs <name>     # Check logs
```

Usually: ImagePullBackOff (image doesn't exist) or CrashLoopBackOff (app crashes on start).

### Service Not Accessible

```bash
k get svc        # List services
k get ep         # List endpoints
k describe svc <name>  # Check selector
kgp -l app=myapp # Verify pods match selector
```

Often the service selector doesn't match pod labels.

### Config Not Applying

```bash
# Dry-run first
k apply -f config.yaml --dry-run=client

# Check diff
k diff -f config.yaml

# Then apply
kaf config.yaml
```

### Check Cluster Health

```bash
k get nodes      # Node status
k get pods -A    # All pods, all namespaces
k get events -A --sort-by='.lastTimestamp' | tail -20
```

## Pro Tips

**Always set context and namespace first**: Use `kx` and `kns` before running commands. Prevents accidents in
production.

**Use k9s for exploration**: Typing kubectl commands is fine for scripts, but k9s is faster for ad-hoc exploration.

**Label everything**: Use consistent labels on resources. Makes selectors and debugging easier.

**Dry-run before apply**: Always run `--dry-run=client` on changes to critical resources.

**Keep kube configs separate**: Use `kconfig` to manage different cluster credentials. Never accidentally apply dev
config to prod.

**Learn one good TUI**: Either k9s, or another like kdash/lens. GUIs are faster than kubectl for many tasks.

**Watch during deployments**: Use `-w` flag to watch rollout status in real-time.
