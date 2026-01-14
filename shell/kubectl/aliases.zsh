# kubectl productivity aliases & functions
# Loaded via modular shell system. Adjust KCTX/KNS if using custom context manager.

# Short base command
alias k='kubectl'

# Common resource shortcuts
alias kgp='kubectl get pods'
alias kga='kubectl get all'
alias kgs='kubectl get svc'
alias kgn='kubectl get nodes'
alias kgi='kubectl get ingress'
alias kgns='kubectl get namespaces'

# Describe
alias kdp='kubectl describe pod'
alias kds='kubectl describe svc'

# Logs
alias kl='kubectl logs'
alias klf='kubectl logs -f'
# Logs of previous crashed container
alias klp='kubectl logs --previous'

# Context & namespace (if using kubectx/kubens tools)
alias kctx='kubectl config current-context'
alias kctxs='kubectl config get-contexts'
alias kswitch='kubectl config use-context'
alias kns='kubectl config get-contexts | awk "NR>1{print $5}" | sort -u'

# Set namespace for current context
knsset() { kubectl config set-context --current --namespace "$1"; }

# Imperative helpers
alias krun='kubectl run --image'
alias kimg='kubectl set image'

# Kustomize
alias kbuild='kubectl kustomize'
alias kapplyk='kubectl apply -k'

# Yaml output helpers
alias ky='kubectl get -o yaml'
alias kjson='kubectl get -o json'

# Wide views
alias kgpw='kubectl get pods -o wide'
alias kgsw='kubectl get svc -o wide'

# Watch variants
alias kwgp='watch -n2 kubectl get pods'
alias kwgs='watch -n2 kubectl get svc'

# Diff live vs local (requires server-side diff feature)
alias kdiff='kubectl diff -f'

# Top resource usage
alias ktopn='kubectl top nodes'
alias ktop='kubectl top pods'

# Resource counts summary
kcounts() { printf 'PODS\t'; kubectl get pods --no-headers | wc -l; printf 'DEPLOYMENTS\t'; kubectl get deploy --no-headers 2>/dev/null | wc -l; printf 'SVCS\t'; kubectl get svc --no-headers | wc -l; }

# Show events (sorted by timestamp)
kgevents() { kubectl get events --sort-by=.lastTimestamp; }

# Completion hint: ensure kubectl completion installed elsewhere if desired.

# ------------------------------------------------------------
# Toolbox access helpers
# Pattern: namespace -> statefulset pod 0 -> container (toolbox/prod-toolbox)
# Usage:
#   ktool <env> [cmd]
#     env examples: dev dev2 dev3 test stg prod advantage-prod lowes-prod
#     if cmd omitted, opens /bin/bash
#   Shortcut aliases provided for frequent ones (kdev, kdev2, kdev3, ktest, kstg, kprod)
# ------------------------------------------------------------

# Mapping rules inside function handle group expansions. Customize arrays if naming changes.
ktool() {
	local target="$1"; shift || true
	# Flag to list pods instead of exec
	local mode_pods=0 filter=""

	# If first remaining arg is pods flag capture optional filter
	if [[ "$1" == "--pods" || "$1" == "-P" ]]; then
		mode_pods=1; shift || true
		filter="${1:-}"
		[[ -n "$filter" ]] && shift || true
	fi

	# Command to exec (ignored in pods mode)
	local cmd=("${@:-/bin/bash}")

	# Group listings for help text
	local olivia_dev="dev dev2 dev3"
	local olivia_test="test"
	local olivia_stage="stg ltsstg"
	local olivia_prod="prod (alias paradox-prod)"
	local enterprise_stg_tenants="fedex-stg lowes-stg mchire-stg"
	local enterprise_prod_tenants="advantage-prod aramark-prod darden-prod fedex-prod lockheed-prod lowes-prod mchire-prod paradox-prod regis-prod smashfly-prod sodexo-prod unilever-prod"

	if [[ -z "$target" || "$target" == "--help" || "$target" == "-h" || "$target" == "help" ]]; then
		echo "Usage: ktool <env|namespace> [--pods [filter]] [command]" >&2
		echo "Olivia Environments:" >&2
		echo "  Dev:     $olivia_dev" >&2
		echo "  Test:    $olivia_test" >&2
		echo "  Stage:   $olivia_stage" >&2
		echo "  Prod:    $olivia_prod" >&2
		echo "Enterprise Tenants:" >&2
		echo "  Stage:   $enterprise_stg_tenants" >&2
		echo "  Prod:    $enterprise_prod_tenants" >&2
		echo "Generic Patterns:" >&2
		echo "  <tenant>-stg  (enterprise staging tenant)" >&2
		echo "  <tenant>-prod (enterprise production tenant)" >&2
		echo "Modes:" >&2
		echo "  Exec: default, launches toolbox shell or provided command." >&2
		echo "  Pods: --pods / -P lists pods; optional filter substring (case-insensitive)." >&2
		echo "Examples:" >&2
		echo "  ktool dev" >&2
		echo "  ktool dev --pods" >&2
		echo "  ktool dev --pods api" >&2
		echo "  ktool lowes-prod --pods" >&2
		echo "  ktool ltsstg 'ls -al'" >&2
		echo "  ktool lowes-stg" >&2
		echo "  ktool lowes-prod /bin/bash" >&2
		echo "  ktool paradox-prod" >&2
		if [[ -z "$target" ]]; then return 1; else return 0; fi
	fi

	local ns pod container

	case "$target" in
		# Olivia dev family
		dev|dev2|dev3)
			ns="paradox-${target}"; pod="olivia-api-dev-toolbox-statefulset-0"; container="toolbox" ;;
		# Test
		test)
			ns="paradox-test"; pod="olivia-api-test-toolbox-statefulset-0"; container="toolbox" ;;
		# Stage variants
		stg)
			ns="paradox-stg"; pod="olivia-api-stg-toolbox-statefulset-0"; container="toolbox" ;;
		ltsstg)
			ns="lts-stg"; pod="olivia-api-stg-toolbox-statefulset-0"; container="toolbox" ;;
		# Generic prod alias
		prod)
			ns="paradox-prod"; pod="olivia-api-prod-toolbox-statefulset-0"; container="prod-toolbox" ;;
		# Explicit enterprise prod tenant list (so help stays accurate even if pattern changes later)
		advantage-prod|aramark-prod|darden-prod|fedex-prod|lockheed-prod|lowes-prod|mchire-prod|paradox-prod|regis-prod|smashfly-prod|sodexo-prod|unilever-prod)
			ns="$target"; pod="olivia-api-prod-toolbox-statefulset-0"; container="prod-toolbox" ;;
		# Enterprise staging tenants explicit list
		fedex-stg|lowes-stg|mchire-stg)
			ns="$target"; pod="olivia-api-stg-toolbox-statefulset-0"; container="toolbox" ;;
		# Pattern fallback for <tenant>-prod or <tenant>-stg (lowercase alnum only)
		*[!-a-z0-9]* )
			# Contains disallowed chars -> reject early
			echo "Unknown environment: $target" >&2; return 2 ;;
		*)
			if [[ "$target" =~ ^([a-z0-9]+)-(prod|stg)$ ]]; then
				local tenant envtype
				tenant="${match[1]}"; envtype="${match[2]}"
				ns="$target"
				if [[ "$envtype" == prod ]]; then
					pod="olivia-api-prod-toolbox-statefulset-0"; container="prod-toolbox"
				else
					pod="olivia-api-stg-toolbox-statefulset-0"; container="toolbox"
				fi
			else
				echo "Unknown environment: $target" >&2; return 2
			fi
			;;
	esac

	if (( mode_pods )); then
		# List pods with optional case-insensitive grep
		if [[ -n "$filter" ]]; then
			kubectl -n "$ns" get pods | grep -i "$filter"
		else
			kubectl -n "$ns" get pods
		fi
		return $?
	fi

	echo "[ktool] ns=$ns pod=$pod container=$container cmd=${cmd[*]}" >&2
	kubectl -n "$ns" exec -it "$pod" -c "$container" -- "${cmd[@]}"
}

# Convenience wrappers
alias kdev='ktool dev'
alias kdev2='ktool dev2'
alias kdev3='ktool dev3'
alias ktest='ktool test'
alias kstg='ktool stg'
alias kltsstg='ktool ltsstg'
alias kprod='ktool prod'

# Extended production tenant shortcuts (call ktool with tenant-prod)
alias kadv='ktool advantage-prod'
alias karamark='ktool aramark-prod'
alias kdarden='ktool darden-prod'
alias kfedex='ktool fedex-prod'
alias klockheed='ktool lockheed-prod'
alias klowes='ktool lowes-prod'
alias kmchire='ktool mchire-prod'
alias kparadox='ktool paradox-prod'
alias kregis='ktool regis-prod'
alias ksmashfly='ktool smashfly-prod'
alias ksodexo='ktool sodexo-prod'
alias kunilever='ktool unilever-prod'

# ------------------------------------------------------------
# Help / discovery for kubectl shortcuts
# Usage:
#   khelp            # list all
#   khelp pods       # filter lines containing 'pods' (case-insensitive)
#   kaliases         # alias to khelp
# ------------------------------------------------------------
khelp() {
	local filter="$1"
	local help_dump
	help_dump=$(cat <<'EOF'
NAME          TYPE      SUMMARY
------------- --------- -----------------------------------------------
k             alias     kubectl (base command)
kgp           alias     kubectl get pods
kga           alias     kubectl get all
kgs           alias     kubectl get svc
kgn           alias     kubectl get nodes
kgi           alias     kubectl get ingress
kgns          alias     kubectl get namespaces
kdp           alias     kubectl describe pod
kds           alias     kubectl describe svc
kl            alias     kubectl logs
klf           alias     kubectl logs -f (follow)
klp           alias     kubectl logs --previous (prior crash)
kctx          alias     current context
kctxs         alias     list contexts
kswitch       alias     switch context (kubectl config use-context)
kns           alias     list namespaces (via contexts parsing)
knsset <ns>   func      set namespace for current context
krun          alias     kubectl run --image (imperative pod)
kimg          alias     kubectl set image
kbuild        alias     kubectl kustomize (render kustomize)
kapplyk       alias     kubectl apply -k (apply kustomize)
ky            alias     kubectl get -o yaml (append resource)
kjson         alias     kubectl get -o json (append resource)
kgpw          alias     get pods -o wide
kgsw          alias     get svc -o wide
kwgp          alias     watch get pods (2s interval)
kwgs          alias     watch get svc (2s interval)
kdiff         alias     server-side diff (-f path)
ktopn         alias     top nodes
ktop          alias     top pods
kcounts       func      summary counts (pods/deployments/services)
kgevents       func     get events sorted by lastTimestamp
khelp          func     this help summary
kaliases       alias    same as khelp
EOF
)
	if [[ -n "$filter" ]]; then
		echo "$help_dump" | grep -i "$filter"
	else
		echo "$help_dump"
	fi
	return 0
}

alias kaliases='khelp'
