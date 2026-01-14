# Kubernetes Workflows Guide

This guide covers the extensive Kubernetes tooling and workflows configured in this dotfiles repository, including 40+ kubectl aliases, environment-aware toolbox helpers, and interactive pod selection.

## Overview

The repository provides:
- **40+ kubectl aliases** - Common operations streamlined
- **Environment-aware toolbox** - `ktool` for accessing Olivia environments
- **Enterprise tenant shortcuts** - Quick access to production tenants
- **Interactive pod selection** - fzf-powered workflows (Nushell)
- **Help system** - Built-in command discovery
- **Namespace management** - Context and namespace switching helpers

## Prerequisites

Ensure these tools are installed:

```bash
# kubectl (Kubernetes CLI)
brew install kubectl

# Optional: kubectx/kubens for context switching
brew install kubectx

# Optional: Helm (Kubernetes package manager)
brew install helm

# Optional: eksctl (EKS cluster management)
brew install eksctl

# fzf (for interactive selection)
brew install fzf
```

## File Locations

**Zsh aliases**: `shell/kubectl/aliases.zsh`
**Nushell aliases**: `config/nushell/aliases/k8s.nu`

Both shells have feature parity with the same core functionality.

## Core Kubectl Aliases

### Basic Operations

| Alias | Command | Description |
|-------|---------|-------------|
| `k` | `kubectl` | Base command shortcut |
| `kgp` | `kubectl get pods` | List pods |
| `kga` | `kubectl get all` | List all resources |
| `kgs` | `kubectl get svc` | List services |
| `kgn` | `kubectl get nodes` | List nodes |
| `kgi` | `kubectl get ingress` | List ingress resources |
| `kgns` | `kubectl get namespaces` | List namespaces |

### Describe Resources

| Alias | Command | Description |
|-------|---------|-------------|
| `kdp` | `kubectl describe pod` | Describe pod |
| `kds` | `kubectl describe svc` | Describe service |

Usage:
```bash
kdp my-pod-name
kds my-service-name
```

### Logs

| Alias | Command | Description |
|-------|---------|-------------|
| `kl` | `kubectl logs` | View logs |
| `klf` | `kubectl logs -f` | Follow logs (tail -f) |
| `klp` | `kubectl logs --previous` | Logs from crashed container |

Usage:
```bash
kl my-pod
klf my-pod              # Follow logs
klp my-pod              # Previous crash logs
kl my-pod -c container  # Specific container
```

### Context & Namespace

| Alias/Function | Command | Description |
|----------------|---------|-------------|
| `kctx` | `kubectl config current-context` | Show current context |
| `kctxs` | `kubectl config get-contexts` | List all contexts |
| `kswitch` | `kubectl config use-context` | Switch context |
| `kns` | (awk parsing) | List namespaces from contexts |
| `knsset <ns>` | `kubectl config set-context --current --namespace` | Set namespace |

Usage:
```bash
kctx                      # Show current context
kctxs                     # List all contexts
kswitch my-cluster        # Switch to cluster
knsset paradox-dev        # Set namespace
```

### YAML/JSON Output

| Alias | Command | Description |
|-------|---------|-------------|
| `ky` | `kubectl get -o yaml` | YAML output |
| `kjson` | `kubectl get -o json` | JSON output |

Usage:
```bash
ky pod my-pod
kjson deployment my-deploy | jq .
```

### Wide Views

| Alias | Command | Description |
|-------|---------|-------------|
| `kgpw` | `kubectl get pods -o wide` | Pods with IPs and nodes |
| `kgsw` | `kubectl get svc -o wide` | Services with cluster IPs |

### Watch Mode

| Alias | Command | Description |
|-------|---------|-------------|
| `kwgp` | `watch -n2 kubectl get pods` | Watch pods (2s refresh) |
| `kwgs` | `watch -n2 kubectl get svc` | Watch services (2s refresh) |

### Resource Management

| Alias | Command | Description |
|-------|---------|-------------|
| `krun` | `kubectl run --image` | Create pod imperatively |
| `kimg` | `kubectl set image` | Update image |
| `kdiff` | `kubectl diff -f` | Server-side diff |

Usage:
```bash
krun test-pod nginx:latest
kimg deployment/app app=nginx:1.21
kdiff deployment.yaml
```

### Kustomize

| Alias | Command | Description |
|-------|---------|-------------|
| `kbuild` | `kubectl kustomize` | Render kustomize templates |
| `kapplyk` | `kubectl apply -k` | Apply kustomize directory |

Usage:
```bash
kbuild ./overlays/dev
kapplyk ./overlays/prod
```

### Resource Monitoring

| Alias/Function | Command | Description |
|----------------|---------|-------------|
| `ktopn` | `kubectl top nodes` | Node resource usage |
| `ktop` | `kubectl top pods` | Pod resource usage |
| `kcounts` | (custom) | Count pods/deployments/services |
| `kgevents` | `kubectl get events --sort-by=.lastTimestamp` | Recent events |

Usage:
```bash
ktop                      # All pods
ktop --namespace=default  # Specific namespace
ktopn                     # Node metrics
kcounts                   # Quick summary
kgevents                  # Recent cluster events
```

## Environment Toolbox (ktool)

The `ktool` function provides environment-aware access to Olivia toolbox pods across multiple environments and enterprise tenants.

### Architecture

**Pattern**: `namespace` → `statefulset pod-0` → `container`

**Supported Environments**:

| Environment Type | Environments | Namespace Pattern | Pod | Container |
|------------------|--------------|-------------------|-----|-----------|
| **Olivia Dev** | dev, dev2, dev3 | `paradox-dev*` | `olivia-api-dev-toolbox-statefulset-0` | `toolbox` |
| **Olivia Test** | test | `paradox-test` | `olivia-api-test-toolbox-statefulset-0` | `toolbox` |
| **Olivia Stage** | stg, ltsstg | `paradox-stg`, `lts-stg` | `olivia-api-stg-toolbox-statefulset-0` | `toolbox` |
| **Olivia Prod** | prod (alias paradox-prod) | `paradox-prod` | `olivia-api-prod-toolbox-statefulset-0` | `prod-toolbox` |
| **Enterprise Stage** | fedex-stg, lowes-stg, mchire-stg | `<tenant>-stg` | `olivia-api-stg-toolbox-statefulset-0` | `toolbox` |
| **Enterprise Prod** | See table below | `<tenant>-prod` | `olivia-api-prod-toolbox-statefulset-0` | `prod-toolbox` |

**Enterprise Production Tenants**:
- advantage-prod
- aramark-prod
- darden-prod
- fedex-prod
- lockheed-prod
- lowes-prod
- mchire-prod
- paradox-prod
- regis-prod
- smashfly-prod
- sodexo-prod
- unilever-prod

### Basic Usage

```bash
# Exec into toolbox (interactive bash)
ktool dev

# Run specific command
ktool dev 'ls -al'
ktool test 'python manage.py shell'

# Production environments
ktool prod
ktool lowes-prod
ktool fedex-prod 'cat /app/config.yaml'
```

### Pods Listing Mode

List pods in an environment without exec:

```bash
# List all pods in environment
ktool dev --pods
ktool lowes-prod --pods

# Filter pods by name (case-insensitive grep)
ktool dev --pods api
ktool prod --pods celery
ktool fedex-stg --pods worker

# List pods in current namespace
ktool --pods
ktool --pods nginx
```

### Environment Shortcuts

Quick access aliases for common environments:

```bash
# Olivia environments
kdev           # ktool dev
kdev2          # ktool dev2
kdev3          # ktool dev3
ktest          # ktool test
kstg           # ktool stg
kltsstg        # ktool ltsstg
kprod          # ktool prod (paradox-prod)

# Enterprise production tenants
kadv           # advantage-prod
karamark       # aramark-prod
kdarden        # darden-prod
kfedex         # fedex-prod
klockheed      # lockheed-prod
klowes         # lowes-prod
kmchire        # mchire-prod
kparadox       # paradox-prod
kregis         # regis-prod
ksmashfly      # smashfly-prod
ksodexo        # sodexo-prod
kunilever      # unilever-prod
```

Usage:
```bash
kdev                    # Bash in dev toolbox
klowes 'ls /app'        # Run command in Lowes prod
kfedex --pods           # List FedEx prod pods
```

### Help & Discovery

```bash
# Show ktool help (environment taxonomy and examples)
ktool --help
ktool -h
ktool help

# Show all kubectl aliases
khelp

# Filter help output
khelp pods
khelp logs
khelp namespace

# Alias for khelp
kaliases
kaliases context
```

## Common Workflows

### Debugging Pods

```bash
# 1. List pods
kgp

# 2. Describe pod to see events/status
kdp my-pod-name

# 3. Check logs
klf my-pod-name

# 4. Exec into pod
k exec -it my-pod-name -- /bin/bash

# 5. Check previous crash logs if restarting
klp my-pod-name
```

### Deployment Updates

```bash
# 1. Check current state
kgp
k get deployment

# 2. Update image
kimg deployment/api api=myimage:v2

# 3. Watch rollout
k rollout status deployment/api
kwgp  # Watch pods updating

# 4. Rollback if needed
k rollout undo deployment/api
```

### Namespace Operations

```bash
# 1. List namespaces
kgns

# 2. Switch namespace for session
knsset paradox-dev

# 3. Verify
kctx  # Shows current context
kgp   # Now shows pods in new namespace

# 4. Quick one-off queries in different namespace
k get pods -n other-namespace
```

### Kustomize Deployments

```bash
# 1. Preview changes
kbuild ./k8s/overlays/dev
kdiff -k ./k8s/overlays/dev

# 2. Apply
kapplyk ./k8s/overlays/dev

# 3. Verify
kgp
kgs
```

### Toolbox Access

```bash
# 1. Access dev toolbox
kdev

# 2. Inside toolbox - common tasks
cd /app
python manage.py shell
./manage.py migrate --list
psql $DATABASE_URL

# 3. Run one-off command without interactive shell
kdev 'python manage.py check'
ktest 'python manage.py test --failfast'
```

### Production Investigation

```bash
# 1. List pods in production environment
ktool lowes-prod --pods

# 2. Filter for specific service
ktool lowes-prod --pods api

# 3. Access toolbox
klowes

# 4. Inside prod toolbox - read-only investigations
tail -f /var/log/app/application.log
cat /app/current_config.yaml
python -c "import config; print(config.SETTING)"
```

### Resource Monitoring

```bash
# 1. Check node resources
ktopn

# 2. Check pod resources
ktop

# 3. Get counts
kcounts

# 4. Recent events
kgevents | tail -20

# 5. Watch specific pods
kwgp
```

## Interactive Workflows (Nushell)

The Nushell configuration includes enhanced interactive workflows with fzf integration:

### go2pod - Interactive Pod Selection

```nushell
# Select pod interactively with fzf, then exec
go2pod

# Filter namespace
go2pod dev
```

Features:
- Color-coded pod list (Catppuccin theme)
- Fuzzy search through pods
- Shows namespace, pod name, status
- Auto-exec into selected pod

### Cache Management

Nushell k8s module includes caching for performance:

```nushell
# Clear all k8s cache
clear-k8s-cache

# Clear specific cache
clear-k8s-cache "contexts"
```

Cache TTL: 24 hours (1440 minutes)

## Customization

### Adding New Aliases

**For Zsh** (`shell/kubectl/aliases.zsh`):

```bash
# Add after existing aliases
alias kmypods='kubectl get pods -l app=myapp'
alias kscale='kubectl scale deployment'
```

Reload:
```bash
source ~/.zshrc
```

**For Nushell** (`config/nushell/aliases/k8s.nu`):

```nushell
# Add to aliases section
export alias kmypods = kubectl get pods -l app=myapp
export alias kscale = kubectl scale deployment
```

Reload:
```bash
source ~/.config/nushell/config.nu
```

### Adding New Environments to ktool

Edit `shell/kubectl/aliases.zsh`, add to the `case` statement:

```bash
case "$target" in
  # ... existing cases ...

  # New environment
  newenv)
    ns="my-newenv-namespace"
    pod="my-toolbox-pod-0"
    container="toolbox"
    ;;

  # ... rest of cases ...
esac
```

Add shortcut alias:

```bash
alias knewenv='ktool newenv'
```

### Adding Custom Functions

**Example: Delete all evicted pods**

```bash
# Add to shell/kubectl/aliases.zsh
kcleanevicted() {
  kubectl get pods --all-namespaces \
    --field-selector='status.phase==Failed' \
    -o json | \
    jq -r '.items[] | "kubectl delete pod \(.metadata.name) -n \(.metadata.namespace)"' | \
    sh
}
```

**Example: Port-forward helper**

```bash
# Add to shell/kubectl/aliases.zsh
kpf() {
  local pod="$1" local_port="$2" remote_port="${3:-$2}"
  kubectl port-forward "$pod" "$local_port:$remote_port"
}

# Usage: kpf my-pod 8080 80
```

## Troubleshooting

### kubectl Not Found

```bash
# Verify installation
which kubectl

# Install if missing
brew install kubectl

# Verify version
kubectl version --client
```

### Context Not Switching

```bash
# List contexts
kctxs

# Manually switch
kubectl config use-context my-cluster

# Verify
kctx

# Check kubeconfig
echo $KUBECONFIG
cat ~/.kube/config
```

### Aliases Not Working

**Zsh:**
```bash
# Check if aliases loaded
alias | grep kubectl

# Verify file sourced
grep kubectl ~/.zshrc

# Reload
source ~/.zshrc
```

**Nushell:**
```nushell
# Check aliases
alias | where name =~ kubectl

# Reload
source ~/.config/nushell/config.nu
```

### ktool Can't Find Pod

```bash
# Check namespace exists
k get ns | grep paradox-dev

# List pods in namespace
k get pods -n paradox-dev

# Verify pod name
k get pods -n paradox-dev | grep toolbox

# If pod name changed, update aliases.zsh case statement
```

### Permission Denied in Toolbox

```bash
# Check RBAC permissions
k auth can-i exec pods --namespace paradox-dev

# Check pod security
kdp toolbox-pod-name | grep -A5 securityContext

# Verify service account
k get sa
k describe sa default
```

### fzf Not Found (Nushell)

```bash
# Install fzf
brew install fzf

# Verify
which fzf

# Fallback: Nushell k8s module gracefully degrades without fzf
```

## Best Practices

1. **Use namespaces wisely** - Set default namespace with `knsset` for session
2. **Leverage wide views** - Use `kgpw` to see pod IPs and nodes
3. **Watch for updates** - Use `kwgp` during deployments
4. **Check events first** - Use `kgevents` when debugging
5. **Use toolbox for investigations** - Avoid exec into app containers
6. **Filter with grep** - All commands support piping: `kgp | grep api`
7. **Learn shortcuts** - Use `khelp` to discover aliases
8. **Use ktool --pods** - Preview environment before exec
9. **Leverage kustomize** - Use `kbuild` and `kdiff` before applying
10. **Context awareness** - Always verify with `kctx` before operations

## Security Considerations

### Production Access

1. **Read-only investigations** - Use toolbox, don't modify app state
2. **Audit logging** - All `kubectl` commands are logged
3. **RBAC enforcement** - Respect role boundaries
4. **No secrets in logs** - Avoid `ky secret` in shared terminals
5. **Use service accounts** - Don't use personal credentials in automation

### Toolbox Safety

```bash
# DO: Read logs, check config, run health checks
klowes 'tail /var/log/app/application.log'
klowes 'python manage.py check'

# DON'T: Modify data, restart services, change config
# (Toolbox container typically has limited write permissions)
```

### Context Awareness

```bash
# Always verify context before destructive operations
kctx  # Verify not in prod

# Use explicit namespace for safety
k delete pod my-pod -n dev  # Better than relying on default
```

## Advanced Usage

### Multi-Cluster Operations

```bash
# Loop through contexts
for ctx in $(kubectl config get-contexts -o name); do
  echo "=== $ctx ==="
  kubectl --context="$ctx" get nodes
done
```

### Complex Queries with jq

```bash
# Get pod IPs
kjson pods | jq -r '.items[] | .status.podIP'

# Get resource requests/limits
kjson pod my-pod | jq '.spec.containers[] | {name, resources}'

# Get all container images
kgp -o json | jq -r '.items[].spec.containers[].image' | sort -u
```

### Batch Operations

```bash
# Delete all completed jobs
k get jobs --field-selector=status.successful=1 -o name | xargs kubectl delete

# Restart all deployments (updates)
k get deployments -o name | xargs kubectl rollout restart
```

### Custom Output Formats

```bash
# Custom columns
k get pods -o custom-columns=NAME:.metadata.name,STATUS:.status.phase,IP:.status.podIP

# Go template
k get pods -o go-template='{{range .items}}{{.metadata.name}}{{"\n"}}{{end}}'
```

## Related Documentation

- [Shell Configuration Guide](./shell-configuration.md) - Zsh and Nushell setup
- [Docker Setup Guide](./docker-setup.md) - Container runtime configuration
- [Language Runtimes Guide](./language-runtimes.md) - Development environment setup

## Additional Resources

- [kubectl Cheat Sheet](https://kubernetes.io/docs/reference/kubectl/cheatsheet/)
- [kubectl Documentation](https://kubernetes.io/docs/reference/kubectl/)
- [Kustomize](https://kustomize.io/)
- [Helm Charts](https://helm.sh/docs/)
- [kubectx/kubens](https://github.com/ahmetb/kubectx)
