# Nushell K8S File

# ============================================================================
# Color Theme Constants (Catppuccin Mocha)
# ============================================================================
use ../common.nu *

# Cache settings
const CACHE_TTL_MINUTES = 1440  # Cache validity in minutes (1 day)

# ============================================================================
# Cache Helper Functions
# ============================================================================

# Get cache directory
def get-cache-dir [] {
    $env.HOME | path join ".cache" "nushell" "k8s"
}

# Ensure cache directory exists
def ensure-cache-dir [] {
    let cache_dir = (get-cache-dir)
    if not ($cache_dir | path exists) {
        mkdir $cache_dir
    }
}

# Get cache file path for a key
def get-cache-path [key: string] {
    (get-cache-dir) | path join $"($key).json"
}

# Check if cache is valid (not expired)
def is-cache-valid [cache_path: string] {
    if not ($cache_path | path exists) {
        return false
    }

    let cache_data = (open $cache_path)
    let cached_time = ($cache_data.timestamp | into datetime)
    let now = (date now)
    let age_minutes = (($now - $cached_time) / 1min)

    $age_minutes < $CACHE_TTL_MINUTES
}

# Read from cache
def read-cache [key: string] {
    let cache_path = (get-cache-path $key)

    if (is-cache-valid $cache_path) {
        let cache_data = (open $cache_path)
        return $cache_data.data
    }

    return null
}

# Write to cache
def write-cache [key: string, data: any] {
    ensure-cache-dir
    let cache_path = (get-cache-path $key)

    {
        timestamp: (date now | format date "%Y-%m-%dT%H:%M:%S%.3fZ"),
        data: $data
    } | save -f $cache_path
}

# Clear cache for a specific key or all
export def clear-k8s-cache [key?: string] {
    let cache_dir = (get-cache-dir)
    if ($key | is-empty) {
        # Clear all cache
        if ($cache_dir | path exists) {
            rm -rf $cache_dir
            mkdir $cache_dir
            print "✓ All k8s cache cleared"
        }
    } else {
        let cache_path = (get-cache-path $key)
        if ($cache_path | path exists) {
            rm $cache_path
            print $"✓ Cache cleared for ($key)"
        }
    }
}

# ============================================================================
# Helper Functions for Visualization
# ============================================================================

# fzf selection helper with Catppuccin theme
def fzf-select [
    items: list,
    prompt: string,
    header: string = "",
    --tabstop: int = 40  # Tab stop width for column alignment
] {
    let fzf_available = (which fzf | length) > 0

    if not $fzf_available {
        display-warning "fzf not found, using built-in fuzzy search"
        return ($items | input list --fuzzy $prompt)
    }

    let header_text = if ($header | str length) > 0 {
        $"($header)\n↑↓: navigate │ Enter: select │ Esc: cancel"
    } else {
        "↑↓: navigate │ Enter: select │ Esc: cancel"
    }

    let selection = (
        $items
        | to text
        | fzf --ansi
            --prompt $"($prompt) "
            --pointer $FZF_POINTER
            --marker $FZF_MARKER
            --color $FZF_COLORS
            --border rounded
            --height "~50%"
            --reverse
            --header $header_text
            --header-first
            --tabstop $tabstop
    )

    if ($selection | is-empty) {
        return ""
    }

    $selection
}

# Convert age string to human-readable format
# Examples: "5m30s" -> "5m 30s", "2d5h" -> "2d 5h", "45d" -> "45d"
def format-age [age: string] {
    # If age contains 'd' (days), format with space
    if ($age | str contains 'd') {
        let parts = ($age | split row 'd')
        if ($parts | length) > 1 {
            let days = $parts.0
            let rest = $parts.1
            if ($rest | str length) > 0 {
                $"($days)d ($rest)"
            } else {
                $"($days)d"
            }
        } else {
            $age
        }
    } else if ($age | str contains 'h') {
        # Format hours with space
        let parts = ($age | split row 'h')
        if ($parts | length) > 1 {
            let hours = $parts.0
            let rest = $parts.1
            if ($rest | str length) > 0 {
                $"($hours)h ($rest)"
            } else {
                $"($hours)h"
            }
        } else {
            $age
        }
    } else if ($age | str contains 'm') {
        # Format minutes with space
        let parts = ($age | split row 'm')
        if ($parts | length) > 1 {
            let mins = $parts.0
            let rest = $parts.1
            if ($rest | str length) > 0 {
                $"($mins)m ($rest)"
            } else {
                $"($mins)m"
            }
        } else {
            $age
        }
    } else {
        $age
    }
}

# Colorize status based on Kubernetes resource state
# Returns colored status string with ANSI codes
def colorize-status [status: string] {
    let status_lower = ($status | str downcase)

    # Determine color based on status
    let color = if ($status_lower in ["running", "active", "ready", "completed", "bound", "healthy"]) {
        $COLORS.green
    } else if ($status_lower in ["pending", "containercreating", "podinitializing", "waiting", "progressing"]) {
        $COLORS.yellow
    } else if ($status_lower in ["failed", "error", "crashloopbackoff", "imagepullbackoff", "errimagepull", "evicted"]) {
        $COLORS.red
    } else if ($status_lower in ["unknown", "terminating", "terminated"]) {
        $COLORS.gray
    } else {
        $COLORS.reset
    }

    $"($color)($status)($COLORS.reset)"
}

# Apply color to a cell value
def colorize-cell [value: string, color: string] {
    $"($color)($value)($COLORS.reset)"
}

# Format context indicator with color
def format-indicator [is_current: bool] {
    if $is_current {
        colorize-cell "✓" $COLORS.blue
    } else {
        "  "
    }
}

# Colorize restart count (highlight if >5)
def colorize-restarts [count: int] {
    if $count > 5 {
        colorize-cell $"($count)" $COLORS.red
    } else if $count > 0 {
        colorize-cell $"($count)" $COLORS.yellow
    } else {
        $"($count)"
    }
}

# Colorize ready count (highlight if not all ready)
def colorize-ready [ready: string] {
    let parts = ($ready | split row '/')
    if ($parts | length) == 2 {
        let current = ($parts.0 | str trim | into int)
        let total = ($parts.1 | str trim | into int)
        if $current == $total {
            colorize-cell $ready $COLORS.green
        } else if $current == 0 {
            colorize-cell $ready $COLORS.red
        } else {
            colorize-cell $ready $COLORS.yellow
        }
    } else {
        $ready
    }
}

# Get available Kubernetes contexts
# Alias for ?ctx
export def kctx [] {
    ?ctx
}

export def ?ctx [] {
    # Use complete to get raw stdout and handle errors properly
    let result = ((^kubectl config get-contexts) | complete)

    if $result.exit_code != 0 {
        print $"Error getting contexts: ($result.stderr)"
        return []
    }

    if ($result.stdout | str trim | is-empty) {
        print "No Kubernetes contexts found"
        return []
    }

    let contexts = ($result.stdout | from ssv -a)
    let cols = ($contexts | columns)

    # Build rename map dynamically based on existing columns
    mut rename_map = {
        "CURRENT": "indicator",
        "NAME": "context",
        "CLUSTER": "cluster"
    }

    if "AUTHINFO" in $cols {
        $rename_map = ($rename_map | insert "AUTHINFO" "auth_info")
    }

    if "NAMESPACE" in $cols {
        $rename_map = ($rename_map | insert "NAMESPACE" "namespace")
    }

    $contexts | rename -c $rename_map |
    update indicator {|row| if $row.indicator == "*" { "current" } else { "" }} |
    where context != ""
}

# Get namespaces in the current context
# Alias for ?ns
export def kns [] {
    ?ns
}

export def ?ns [] {
    # Use complete to get raw stdout and handle errors properly
    let result = ((^kubectl get namespaces -o wide) | complete)

    if $result.exit_code != 0 {
        print $"Error getting namespaces: ($result.stderr)"
        return []
    }

    if ($result.stdout | str trim | is-empty) {
        print "No namespaces found in current context"
        return []
    }

    $result.stdout | from ssv -a |
    rename -c {
        "NAME": "name",
        "STATUS": "status",
        "AGE": "age"
    }
}

# Get pods in a namespace
# Alias for ?pods
export def kpods [namespace: string] {
    ?pods $namespace
}

export def ?pods [namespace: string] {
    # Use complete to get raw stdout and handle errors properly
    let result = ((^kubectl get pods -n $namespace -o wide) | complete)

    if $result.exit_code != 0 {
        if ($result.stderr | str contains "No resources found") {
            print $"No pods found in namespace '($namespace)'"
        } else {
            print $"Error getting pods: ($result.stderr)"
        }
        return []
    }

    if ($result.stdout | str trim | is-empty) {
        print $"No pods found in namespace '($namespace)'"
        return []
    }

    let pods = ($result.stdout | from ssv -a)
    let cols = ($pods | columns)

    # Build rename map dynamically based on existing columns
    mut rename_map = {
        "NAME": "name",
        "READY": "ready",
        "STATUS": "status",
        "RESTARTS": "restarts",
        "AGE": "age"
    }

    if "NODE" in $cols {
        $rename_map = ($rename_map | insert "NODE" "node")
    }

    if "IP" in $cols {
        $rename_map = ($rename_map | insert "IP" "ip")
    }

    let renamed = $pods | rename -c $rename_map

    # Select only the columns we care about, ignoring extras like NOMINATED NODE, READINESS GATES
    let selected_cols = ($renamed | columns | where { $in in ["name", "ready", "status", "restarts", "age", "node", "ip"] })

    $renamed | select ...$selected_cols |
    update restarts {|row|
        try {
            # Handle restart format like "64 (2d ago)" - extract first number
            let restart_str = ($row.restarts | str trim)
            if ($restart_str | str contains '(') {
                $restart_str | split row ' ' | first | into int
            } else if ($restart_str | describe) == "string" {
                $restart_str | into int
            } else {
                $row.restarts
            }
        } catch {
            0
        }
    }
}

# Execute shell in a pod container
def exec-pod [namespace: string, pod: string, container: string = "", shell: string = "/bin/bash"] {
    print $"Connecting to pod ($pod) in namespace ($namespace)..."

    # Build the kubectl command properly
    if $container == "" {
        # No container specified
        kubectl exec -it -n $namespace $pod -- $shell
    } else {
        # Container specified
        kubectl exec -it -n $namespace $pod -c $container -- $shell

        # If bash fails, try sh as fallback
        if ($env.LAST_EXIT_CODE != 0) and ($shell == "/bin/bash") {
            print "Failed to connect with /bin/bash, trying /bin/sh..."
            kubectl exec -it -n $namespace $pod -c $container -- /bin/sh
        }
    }
}

# ============================================================================
# Display Functions for Enhanced Visualization
# ============================================================================

# Display contexts as a rich formatted table
def display-contexts-table [contexts: list] {
    $contexts | each {|ctx|
        {
            indicator: (format-indicator ($ctx.indicator == "current")),
            context: $ctx.context,
            cluster: $ctx.cluster,
            namespace: ($ctx.namespace? | default "default")
        }
    } | table -e | print
}

# Display namespaces as a formatted table with color-coded status
def display-namespaces-table [namespaces: list] {
    $namespaces | each {|ns|
        {
            name: $ns.name,
            status: (colorize-status $ns.status),
            age: (format-age $ns.age)
        }
    } | sort-by status name | table -e | print
}

# Display pods as a formatted table with comprehensive metadata
def display-pods-table [pods: list] {
    $pods | each {|pod|
        {
            name: $pod.name,
            ready: (colorize-ready $pod.ready),
            status: (colorize-status $pod.status),
            restarts: (colorize-restarts $pod.restarts),
            age: (format-age $pod.age),
            node: ($pod.node? | default "N/A" | str substring 0..20)  # Truncate long node names
        }
    } | sort-by status name | table -e | print
}

# Display containers as a formatted table
def display-containers-table [containers: list] {
    $containers | each {|container|
        let state = if ($container.state? | is-empty) { "Running" } else { $container.state }
        {
            name: $container.name,
            image: $container.image,
            state: (colorize-status $state),
            restarts: ($container.restarts | default 0)
        }
    } | table -e | print
}

# Display connection summary with visual hierarchy
def display-connection-summary [context: string, namespace: string, pod: string, container: string] {
    print ""
    let header = colorize-cell "▸ Connection Summary" $COLORS.blue
    print $header

    let bullet = colorize-cell "•" $COLORS.green
    print $"  ($bullet) Context:   ($context)"
    print $"  ($bullet) Namespace: ($namespace)"
    print $"  ($bullet) Pod:       ($pod)"
    print $"  ($bullet) Container: ($container)"
    print ""
}

# Display error message with color coding
def display-error [message: string, suggestion: string = ""] {
    let prefix = colorize-cell "✗ Error:" $COLORS.red
    print $"($prefix) ($message)"
    if ($suggestion | str length) > 0 {
        let arrow = colorize-cell "→" $COLORS.yellow
        print $"  ($arrow) ($suggestion)"
    }
}

# Display warning message
def display-warning [message: string] {
    let prefix = colorize-cell "⚠ Warning:" $COLORS.yellow
    print $"($prefix) ($message)"
}

# Display info message
def display-info [message: string] {
    let prefix = colorize-cell "ℹ Info:" $COLORS.blue
    print $"($prefix) ($message)"
}

# Interactive pod selection and access with enhanced visualization
export def go2pod [
    --fresh  # Skip cache and fetch fresh data
] {
    let use_cache = not $fresh

    # Step 1: Select context
    display-info "Getting Kubernetes contexts..."

    let contexts = if $use_cache {
        let cached = (read-cache "contexts")
        if ($cached != null) {
            display-info "📦 Using cached contexts"
            $cached
        } else {
            let fresh_data = (?ctx)
            write-cache "contexts" $fresh_data
            $fresh_data
        }
    } else {
        let fresh_data = (?ctx)
        write-cache "contexts" $fresh_data
        $fresh_data
    }

    if ($contexts | is-empty) {
        display-error "No Kubernetes contexts available" "Check kubectl configuration or install kubectl"
        return
    }

    # Create fzf-compatible display lines
    let context_display_lines = $contexts | each {|ctx|
        let indicator = if ($ctx.indicator == "current") { (colorize-cell "✓" $COLORS.blue) } else { " " }
        let context = $ctx.context | fill -a left -w 30
        let cluster = $ctx.cluster | fill -a left -w 30
        $"($indicator) ($context)\t($cluster)"
    }

    let selected_ctx_line = (fzf-select $context_display_lines "📋 Select context:" "")

    if ($selected_ctx_line | is-empty) {
        display-warning "Context selection cancelled"
        return
    }

    # Extract context name - split on tab first, then clean up the context part
    let parts = ($selected_ctx_line | split row "\t")
    let context_part = ($parts | get 0)  # Get part before tab
    # Use regex to extract just the context name, removing any ANSI codes and indicators
    let selected_context_name = ($context_part | str replace -r '^\s*[^\w-]*\s*' '' | str trim)

    # Get current context before switching
    let current_context = ((^kubectl config current-context) | complete | get stdout | str trim)

    # Switch context if different from current
    if $selected_context_name != $current_context {
        display-info $"Switching context to ($selected_context_name)"
        let switch_result = ((^kubectl config use-context $selected_context_name) | complete)
        
        if $switch_result.exit_code == 0 {
            display-info $"✓ Successfully switched to context: ($selected_context_name)"
        } else {
            display-error $"Failed to switch context: ($switch_result.stderr)"
            return
        }
    } else {
        display-info $"✓ Already using context: ($selected_context_name)"
    }

    # Step 2: Select namespace
    display-info "Getting namespaces..."

    let cache_key = $"namespaces-($selected_context_name)"
    let namespaces = if $use_cache {
        let cached = (read-cache $cache_key)
        if ($cached != null) {
            display-info "📦 Using cached namespaces"
            $cached
        } else {
            let fresh_data = (?ns)
            write-cache $cache_key $fresh_data
            $fresh_data
        }
    } else {
        let fresh_data = (?ns)
        write-cache $cache_key $fresh_data
        $fresh_data
    }

    if ($namespaces | is-empty) {
        display-error "No namespaces available in this context" "Check cluster connectivity and permissions"
        return
    }

    # Create fzf-compatible display lines
    let ns_display_lines = $namespaces | each {|ns|
        let name = $ns.name | fill -a left -w 30
        let status = (colorize-status $ns.status) | fill -a left -w 15
        let age = (format-age $ns.age) | fill -a right -w 10
        $"($name)\t($status)\t($age)"
    }

    let selected_ns_line = (fzf-select $ns_display_lines "📦 Select namespace:" $"Context: ($selected_context_name)" --tabstop 40)

    if ($selected_ns_line | is-empty) {
        display-warning "Namespace selection cancelled"
        return
    }

    # Extract namespace name (first column)
    let namespace_name = ($selected_ns_line | split row ' ' | first | str trim)

    # Step 3: Select pod
    display-info $"Fetching pods in namespace ($namespace_name)..."

    let cache_key = $"pods-($selected_context_name)-($namespace_name)"
    let pods = if $use_cache {
        let cached = (read-cache $cache_key)
        if ($cached != null) {
            display-info "📦 Using cached pods"
            $cached
        } else {
            let fresh_data = (?pods $namespace_name)
            write-cache $cache_key $fresh_data
            $fresh_data
        }
    } else {
        let fresh_data = (?pods $namespace_name)
        write-cache $cache_key $fresh_data
        $fresh_data
    }

    if ($pods | is-empty) {
        display-error $"No pods available in namespace '($namespace_name)'" "Try a different namespace or check if pods are running"
        return
    }

    # Create fzf-compatible display lines with colors
    let pod_display_lines = $pods | each {|pod|
        # Truncate long pod names to prevent misalignment
        let name = if ($pod.name | str length) > 55 {
            ($pod.name | str substring 0..52) + "..."
        } else {
            $pod.name | fill -a left -w 55
        }
        let ready = (colorize-ready $pod.ready)
        let status = (colorize-status $pod.status)
        let restarts = (colorize-restarts $pod.restarts)
        let age = (format-age $pod.age)
        # Use tab-separated format for better alignment
        $"($name)\t($ready)\t($status)\t($restarts)\t($age)"
    }

    let selected_pod_line = (fzf-select $pod_display_lines "🚀 Select pod:" $"Namespace: ($namespace_name)" --tabstop 40)

    if ($selected_pod_line | is-empty) {
        display-warning "Pod selection cancelled"
        return
    }

    # Extract pod name from the selected line (first column before tab)
    let pod_name = ($selected_pod_line | split row "\t" | first | str trim)

    # Step 4: Get containers and select one
    display-info $"Getting containers for pod ($pod_name)..."

    let containers_data = ((^kubectl get pod $pod_name -n $namespace_name -o json) | complete)

    if $containers_data.exit_code != 0 {
        display-error $"Failed to get container information for pod '($pod_name)'" "Check pod status and permissions"
        return
    }

    let containers = ($containers_data.stdout | from json | get spec.containers | each {|c|
        {
            name: $c.name,
            image: $c.image,
            state: "Running",
            restarts: 0
        }
    })

    if ($containers | is-empty) {
        display-error $"No containers found in pod '($pod_name)'" "This should not happen - pod may be corrupted"
        return
    }

    let selected_container = if ($containers | length) > 1 {
        # Create fzf-compatible display lines
        let container_display_lines = $containers | each {|c|
            let name = $c.name | fill -a left -w 25
            let image = if ($c.image | str length) > 50 {
                ($c.image | str substring 0..47) + "..."
            } else {
                $c.image | fill -a left -w 50
            }
            let state = (colorize-status $c.state)
            # Use tab-separated format
            $"($name)\t($image)\t($state)"
        }

        let selected_container_line = (fzf-select $container_display_lines "📦 Select container:" $"Pod: ($pod_name)" --tabstop 40)

        if ($selected_container_line | is-empty) {
            display-warning "Container selection cancelled"
            return
        }

        # Extract container name (first column before tab)
        $selected_container_line | split row "\t" | first | str trim
    } else {
        let single_container = $containers | first | get name
        display-info $"Only one container '($single_container)' found, using it automatically"
        $single_container
    }

    # Step 5: Connect to the pod
    display-connection-summary $selected_context_name $namespace_name $pod_name $selected_container

    display-info "Connecting to container..."
    exec-pod $namespace_name $pod_name $selected_container
}

# ============================================================================
# Help Documentation
# ============================================================================
export def "help k8s" [] {
    let title = "🎱 Kubernetes Helper Commands"

    print $"($COLORS.blue)╭─────────────────────────────────────╮($COLORS.reset)"
    print $"($COLORS.blue)│($COLORS.reset)  ($title)  ($COLORS.blue)│($COLORS.reset)"
    print $"($COLORS.blue)╰─────────────────────────────────────╯($COLORS.reset)"
    print ""

    let kctx = colorize-cell "kctx" $COLORS.green
    print $"  ($kctx) \(or ?ctx\)       : List Kubernetes contexts with color-coded display"

    let kns = colorize-cell "kns" $COLORS.green
    print $"  ($kns) \(or ?ns\)         : List namespaces with status and age"

    let kpods = colorize-cell "kpods" $COLORS.green
    print $"  ($kpods) <namespace>      : List pods with ready status, restarts, and node info"

    let go2pod = colorize-cell "go2pod" $COLORS.green
    let bullet = colorize-cell "•" $COLORS.yellow
    print $"  ($go2pod)                 : Interactive pod navigation with rich visualization"
    print $"                                ($bullet) Color-coded status indicators"
    print $"                                ($bullet) Enhanced metadata display"
    print $"                                ($bullet) Smart sorting by status priority"
    print $"                                ($bullet) Cached results for speed \(1 day TTL\)"

    let go2pod_fresh = colorize-cell "go2pod --fresh" $COLORS.green
    print $"  ($go2pod_fresh)           : Force refresh cache and fetch latest data"

    let clear_cache = colorize-cell "clear-k8s-cache" $COLORS.green
    print $"  ($clear_cache)            : Clear all cached k8s data"

    let exec = colorize-cell "exec-pod" $COLORS.green
    print $"  ($exec)                   : Direct access to pod \(namespace, pod, container, shell\)"
    print ""

    let legend = colorize-cell "Color Legend:" $COLORS.blue
    print $"($legend)"

    let running = colorize-status "Running"
    let active = colorize-status "Active"
    print $"  ($running) / ($active)        : Healthy resources"

    let pending = colorize-status "Pending"
    print $"  ($pending)                    : Resources starting up"

    let failed = colorize-status "Failed"
    let crash = colorize-status "CrashLoopBackOff"
    print $"  ($failed) / ($crash)          : Error states"

    let unknown = colorize-status "Unknown"
    print $"  ($unknown)                    : Unknown or terminating"
    print ""

    let cache_info = colorize-cell "Cache Info:" $COLORS.blue
    print $"($cache_info)"
    print $"  • Cache location: ~/.cache/nushell/k8s/"
    print $"  • Cache TTL: 1 day"
    print $"  • Cached: contexts, namespaces, pods"
    print $"  • Use --fresh flag to bypass cache"
    print ""
}

# ============================================================================
# Aliases for Compatibility
# ============================================================================

# Alias for go2pod (alternative name)
export def go2pods [] {
    go2pod
}
