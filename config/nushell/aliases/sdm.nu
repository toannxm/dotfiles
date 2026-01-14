# Nushell SDM File

# ============================================================================
# Color Theme Constants (Catppuccin Mocha)
# ============================================================================
use ../common.nu *

# ============================================================================
# SDM Daemon Management
# ============================================================================

# Check if SDM daemon is running
export def "sdm is-running" [] {
    let result = (do -i { sdm ready } | complete)
    return ($result.exit_code == 0)
}

# Start SDM daemon in background
export def "sdm start-daemon" [] {
    if (sdm is-running) {
        display-info "SDM daemon is already running"
        return true
    }

    display-info "Starting SDM daemon..."

    # Start daemon in background
    let result = (do -i {
        bash -c "nohup sdm listen --daemon > /tmp/sdm_daemon.log 2>&1 &"
    } | complete)

    if $result.exit_code != 0 {
        display-error "Failed to start SDM daemon"
        return false
    }

    # Wait a moment for daemon to start
    sleep 1sec

    # Verify it's running
    if (sdm is-running) {
        display-success "SDM daemon started successfully"
        return true
    } else {
        display-error "SDM daemon failed to start. Check /tmp/sdm_daemon.log for details"
        return false
    }
}

# Stop SDM daemon
export def "sdm stop-daemon" [] {
    if not (sdm is-running) {
        display-info "SDM daemon is not running"
        return true
    }

    display-info "Stopping SDM daemon..."

    # Find and kill the sdm listen process
    let pids = (do -i {
        ^ps aux | grep "sdm listen" | grep -v grep | awk '{print $2}'
    } | complete | get stdout | lines | where { |it| ($it | str length) > 0 })

    if ($pids | length) > 0 {
        for pid in $pids {
            do -i { kill $pid }
        }
        sleep 1sec
        display-success "SDM daemon stopped"
    } else {
        display-warning "No SDM daemon process found"
    }

    return true
}

# Restart SDM daemon
export def "sdm restart-daemon" [] {
    sdm stop-daemon
    sleep 1sec
    sdm start-daemon
}

# Get SDM daemon status
export def "sdm daemon-status" [] {
    if (sdm is-running) {
        display-success "SDM daemon is running ✓"

        # Show log tail if available
        if ("/tmp/sdm_daemon.log" | path exists) {
            print "\nRecent log entries:"
            do -i { tail -n 5 /tmp/sdm_daemon.log }
        }
    } else {
        display-error "SDM daemon is not running ✗"

        # Show log tail if available
        if ("/tmp/sdm_daemon.log" | path exists) {
            print "\nLast log entries:"
            do -i { tail -n 10 /tmp/sdm_daemon.log }
        }
    }
}

# ============================================================================
# Helper Functions
# ============================================================================

# Check if a TCP port is accessible
def check-port [
    host: string,
    port: string,
    timeout: float = 0.1  # timeout in seconds
] {
    let result = (do -i {
        bash -c $"timeout ($timeout) bash -c 'cat < /dev/null > /dev/tcp/($host)/($port)' 2>/dev/null"
    } | complete)

    # Exit code 0 or 124 (timeout) means port is accessible
    return (($result.exit_code == 0) or ($result.exit_code == 124))
}

# Check if a status string indicates connected state
def is-connected-status [
    status: string
] {
    let status_lower = ($status | str downcase)
    return (($status_lower == "connected") or ($status_lower == "connected (auto)"))
}

# ============================================================================
# Helper Functions for Visualization
# ============================================================================

# Colorize status based on connection state
def colorize-status [status: string] {
    if (is-connected-status $status) {
        $"($COLORS.green)($status)($COLORS.reset)"
    } else if ($status | str downcase) == "not connected" {
        $"($COLORS.red)($status)($COLORS.reset)"
    } else {
        $"($COLORS.gray)($status)($COLORS.reset)"
    }
}

# fzf selection helper with Catppuccin theme
def fzf-select [
    items: list,
    prompt: string,
    header: string = "",
    --tabstop: int = 16
] {
    let fzf_available = (which fzf | length) > 0

    if not $fzf_available {
        print $"($COLORS.yellow)⚠ fzf not found, using built-in fuzzy search($COLORS.reset)"
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

# Display informational message
def display-info [message: string] {
    print $"($COLORS.blue)ℹ($COLORS.reset) ($message)"
}

# Display success message
def display-success [message: string] {
    print $"($COLORS.green)✓($COLORS.reset) ($message)"
}

# Display warning message
def display-warning [message: string] {
    print $"($COLORS.yellow)⚠($COLORS.reset) ($message)"
}

# Display error message
def display-error [message: string] {
    print $"($COLORS.red)✗($COLORS.reset) ($message)"
}

# Pad text with ANSI color codes properly
def pad-with-color [text: string, width: int] {
    # Remove ANSI codes to get visible length
    let visible_text = ($text | ansi strip)
    let visible_len = ($visible_text | str length)

    if $visible_len >= $width {
        return $text
    }

    let padding = ($width - $visible_len)
    let spaces = (seq 1 $padding | each { " " } | str join)
    $"($text)($spaces)"
}

# Debug: Show all properties of SDM resources
export def sdm-debug-resources [] {
    display-info "Fetching raw SDM status output..."

    let raw_lines = (sdm status | lines | where { |line|
        let trimmed = ($line | str trim)
        (not ($trimmed | is-empty)) and (not ($trimmed | str starts-with "CLUSTER")) and (not ($trimmed | str starts-with "DATASOURCE"))
    })

    print $"($COLORS.yellow)Total lines: ($raw_lines | length)($COLORS.reset)"
    print ""
    print $"($COLORS.blue)First 5 resource lines:($COLORS.reset)"

    $raw_lines | first 5 | each { |line|
        let parts = ($line | str trim | split row -r '\s{2,}')
        print $"($COLORS.green)━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━($COLORS.reset)"
        print $"Raw line: ($line)"
        print $"($COLORS.yellow)Parts count: ($parts | length)($COLORS.reset)"
        $parts | enumerate | each { |item|
            print $"  [($item.index)]: ($item.item)"
        }
    }
}

# ============================================================================
# StrongDM CLI Shortcuts & Authentication
# ============================================================================
export alias sdml = sdm status                        # List connected resources
export alias sdmc = sdm connect                       # Connect to a resource
export alias sdmd = sdm disconnect                    # Disconnect from a resource
export alias sdmda = sdm disconnect --all             # Disconnect from all resources
export alias sdmr = sdm admin resources list          # List all available resources
export alias sdmu = sdm admin users list              # List all users
export alias sdms = sdm admin ssh                     # SSH to a resource
export alias sdmlog = sdm logs                        # View SDM logs

# SDM login helper with status check
export def sdm-login [] {
    display-info "Checking SDM authentication status..."

    # Try to get current status to check if already logged in
    let status_result = (do -i { sdm status } | complete)

    if $status_result.exit_code == 0 {
        display-success "Already authenticated to SDM"

        # Show current user info if available
        let user_info = (do -i { sdm admin users whoami } | complete)
        if $user_info.exit_code == 0 {
            print $"($COLORS.blue)Current user:($COLORS.reset) ($user_info.stdout | str trim)"
        }
        return
    }

    # Not logged in, proceed with login
    display-info "Logging in to StrongDM..."

    # Get values from environment or use defaults
    let app_domain = ($env.SDM_APP_DOMAIN? | default "app.strongdm.com")
    let email = ($env.SDM_EMAIL? | default "")

    # Check if email is set
    if ($email | is-empty) {
        display-error "SDM_EMAIL environment variable is not set"
        print $"($COLORS.yellow)Please set SDM_EMAIL in ~/.config/nushell/.env($COLORS.reset)"
        print $"($COLORS.yellow)Example: SDM_EMAIL=your.email@example.com($COLORS.reset)"
        print ""
        print $"($COLORS.blue)💡 After setting, restart your terminal or run:($COLORS.reset)"
        print $"   source ~/.config/nushell/env.nu($COLORS.reset)"
        return
    }

    print $"($COLORS.blue)Using email: ($email)($COLORS.reset)"
    print $"($COLORS.blue)Using domain: ($app_domain)($COLORS.reset)"

    # Attempt login with predefined values using expect-like behavior
    # Create a temporary script to feed inputs to sdm login
    let login_script = $"($app_domain)\n($email)\n"

    # Use echo to pipe inputs to sdm login
    let login_result = (do -i {
        $login_script | sdm login
    } | complete)

    # Combine stdout and stderr to check for success messages
    let output = $"($login_result.stdout)($login_result.stderr)"

    # Check if login was successful
    if ($output | str contains "authentication successful") {
        display-success "Successfully logged in to SDM!"

        # Verify with status check
        let verify_result = (do -i { sdm status } | complete)
        if $verify_result.exit_code == 0 {
            print $"($COLORS.green)✓ SDM connection verified($COLORS.reset)"
        }
    } else {
        display-error "Login failed or incomplete"
        if ($login_result.stderr | str length) > 0 {
            print $"Error: ($login_result.stderr)"
        }
    }
}

# Connect to all available resources
export def sdm-connect-all [] {
    display-info "Fetching all available resources..."

    # Get all resources from sdm status
    let all_resources = (
        sdm status
        | lines
        | where {|line|
            let trimmed = ($line | str trim)
            # Skip empty lines, headers, and section labels
            (not ($trimmed | is-empty)) and (not ($trimmed | str starts-with "CLUSTER")) and (not ($trimmed | str starts-with "DATASOURCE")) and (not ($trimmed =~ "^[A-Z]+\\s+STATUS"))
        }
    )

    if ($all_resources | is-empty) {
        display-error "No resources found"
        return
    }

    # Parse resource names and connection status
    let resources = ($all_resources | each {|line|
        let parts = ($line | str trim | split row -r '\s{2,}')
        if ($parts | length) >= 2 {
            let name = ($parts | get 0 | str trim)
            let status = ($parts | get 1 | str trim | str downcase)

            # Additional check: skip if name is a section header (all caps single word)
            if not ($name =~ "^[A-Z]+$") {
                {
                    name: $name
                    status: $status
                }
            }
        }
    } | compact)

    # Filter out already connected resources
    let disconnected = ($resources | where {|r| not (is-connected-status $r.status) })
    let already_connected = ($resources | where {|r| is-connected-status $r.status })

    display-success $"Found ($resources | length) total resource\(s\)"
    if ($already_connected | length) > 0 {
        print $"($COLORS.green)  ✓ Already connected: ($already_connected | length)($COLORS.reset)"
    }
    if ($disconnected | length) > 0 {
        print $"($COLORS.yellow)  ⚠ Not connected: ($disconnected | length)($COLORS.reset)"
    }
    print ""

    if ($disconnected | is-empty) {
        display-success "All resources are already connected!"
        return
    }

    # Connect to each disconnected resource
    display-info $"Connecting to ($disconnected | length) resource\(s\)..."
    print ""

    let total = ($disconnected | length)
    mut current = 0

    for resource in $disconnected {
        $current = $current + 1
        print $"($COLORS.blue)[($current)/($total)]($COLORS.reset) Connecting to ($resource.name)..."

        let result = (do -i { sdm connect $resource.name } | complete)

        if $result.exit_code == 0 {
            print $"($COLORS.green)  ✓ Connected successfully($COLORS.reset)"
        } else {
            print $"($COLORS.red)  ✗ Failed to connect($COLORS.reset)"
            if ($result.stderr | str length) > 0 {
                print $"    Error: ($result.stderr | str trim)"
            }
        }
    }

    print ""
    display-success "Connection process completed!"
    print $"($COLORS.yellow)💡 Run 'sdml' to check all connection statuses($COLORS.reset)"
}

# Alias for convenience
export alias sdmca = sdm-connect-all

# ============================================================================
# Resource Connection Functions
# ============================================================================

# Helper function to get region patterns for filtering
def get-region-pattern [region: string] {
    match $region {
        "us" => "(use1|usw2)",
        "eu" => "(euw1|euc1)",
        _ => $region
    }
}

# Cache management for SDM status
const SDM_CACHE_FILE = "~/.cache/nushell/sdm_status_cache.txt"
const SDM_CACHE_TTL_SECONDS = 1440  # Cache validity in minutes (1 day)

# Get cached SDM status or fetch fresh if expired
def get-sdm-status-cached [--force-refresh] {
    let cache_file = ($SDM_CACHE_FILE | path expand)
    let cache_dir = ($cache_file | path dirname)

    # Create cache directory if it doesn't exist
    if not ($cache_dir | path exists) {
        mkdir $cache_dir
    }

    # Check if we should use cache
    let use_cache = if $force_refresh {
        false
    } else if not ($cache_file | path exists) {
        false
    } else {
        let file_stat = (ls $cache_file | get 0)
        let cache_age_seconds = ((date now) - $file_stat.modified) / 1sec
        $cache_age_seconds < $SDM_CACHE_TTL_SECONDS
    }

    if $use_cache {
        # Return cached data (fast - just read text file)
        open $cache_file
    } else {
        # Fetch fresh data
        let fresh_output = (sdm status)

        # Save to cache as plain text (fast - no serialization)
        $fresh_output | save --force $cache_file

        $fresh_output
    }
}

# Clear SDM status cache
export def sdm-clear-cache [] {
    let cache_file = ($SDM_CACHE_FILE | path expand)

    if ($cache_file | path exists) {
        rm $cache_file
        display-success "SDM status cache cleared"
    } else {
        display-info "No cache file found"
    }
}

# Show cache status and info
export def sdm-cache-info [] {
    let cache_file = ($SDM_CACHE_FILE | path expand)

    if not ($cache_file | path exists) {
        display-info "No cache file found"
        print $"($COLORS.yellow)Cache location: ($cache_file)($COLORS.reset)"
        print $"($COLORS.yellow)Cache TTL: ($SDM_CACHE_TTL_SECONDS) seconds($COLORS.reset)"
        return
    }

    let file_stat = (ls $cache_file | get 0)
    let cache_age_seconds = ((date now) - $file_stat.modified) / 1sec
    let is_valid = $cache_age_seconds < $SDM_CACHE_TTL_SECONDS

    print $"($COLORS.blue)╭─────────────────────────────────────────────╮($COLORS.reset)"
    print $"($COLORS.blue)│($COLORS.reset)  SDM Cache Information"
    print $"($COLORS.blue)╰─────────────────────────────────────────────╯($COLORS.reset)"
    print ""
    print $"Cache file: ($cache_file)"
    print $"File size: ($file_stat.size)"
    print $"Modified: ($file_stat.modified | format date '%Y-%m-%d %H:%M:%S')"
    print $"Age: ($cache_age_seconds | math round) seconds"
    print $"TTL: ($SDM_CACHE_TTL_SECONDS) seconds"

    if $is_valid {
        print $"Status: ($COLORS.green)✓ Valid \(fresh)($COLORS.reset)"
    } else {
        print $"Status: ($COLORS.yellow)⚠ Expired \(will refresh on next use)($COLORS.reset)"
    }
}

# Create local port forward for resource
def create-local-forward [
    resource_name: string,
    local_port: string
] {
    display-info $"Creating local port forward for ($resource_name) on localhost:($local_port)..."

    # Ensure SDM daemon is running
    if not (sdm is-running) {
        display-warning "SDM daemon is not running, starting it now..."
        if not (sdm start-daemon) {
            display-error "Failed to start SDM daemon"
            return false
        }
    }

    # Check if port is already in use (forward might already exist)
    if (check-port "localhost" $local_port) {
        display-info "Port ($local_port) is already active"
        return true
    }

    # Use sdm connect - it handles the local forwarding automatically via the daemon
    display-info "Connecting to resource (this will create the local forward)..."

    let connect_result = (do -i { sdm connect $resource_name } | complete)

    if $connect_result.exit_code != 0 {
        display-error "Failed to connect to resource"
        if ($connect_result.stderr | str length) > 0 {
            print $"Error: ($connect_result.stderr)"
        }
        return false
    }

    # Give SDM a moment to set up the local forward
    display-info "Waiting for local forward to be ready..."
    sleep 2sec

    # Verify port is now accessible
    if (check-port "localhost" $local_port 0.2) {
        display-success "Local port forward is ready"
        return true
    } else {
        display-warning "Local port forward may need more time to be ready"
        return false
    }
}

# Wait for proxy to be ready by polling the connection
def wait-for-proxy [
    host: string,
    port: string,
    max_attempts: int = 20,
    delay_ms: int = 500
] {
    display-info "Waiting for proxy to be ready..."

    mut attempts = 0
    while $attempts < $max_attempts {
        if (check-port $host $port) {
            display-success "Proxy is ready!"
            return true
        }

        $attempts = $attempts + 1
        if $attempts < $max_attempts {
            sleep ($delay_ms * 1ms)
        }
    }

    display-warning "Proxy may not be ready yet after connection"
    display-info "The proxy should become available shortly. You can try opening the browser again."
    return false
}

# Check if a resource is currently connected and connect if needed
def ensure-connected [
    resource_name: string,
    display_name?: string,  # Optional display name for messages (e.g., "MySQL resource")
    address?: string        # Optional address for proxy readiness check
] {
    # For local port forwarding approach
    if not ($address | is-empty) {
        let addr_parts = ($address | split row ":")
        if ($addr_parts | length) >= 2 {
            let host = ($addr_parts | get 0)
            let port = ($addr_parts | get 1)

            # Check if forward already exists and is responding
            if (check-port $host $port) {
                display-info "Port forward already active and ready"
                return {success: true, was_connected: true}
            }

            # Create local port forward
            let msg = if ($display_name | is-empty) {
                $"Creating local port forward for: ($resource_name)..."
            } else {
                $"Creating local port forward for ($display_name): ($resource_name)..."
            }
            display-info $msg

            let forward_created = (create-local-forward $resource_name $port)
            if not $forward_created {
                return {success: false, was_connected: false}
            }

            # Wait for forward to be ready
            let proxy = wait-for-proxy $host $port
            if not $proxy {
                return {success: false, was_connected: false}
            }

            return {success: true, was_connected: false}
        }
    }

    # Fallback to old behavior if no address provided
    let status_output = (sdm status | lines | where {|line| $line =~ $resource_name } | first)
    let current_status = ($status_output | str trim | split row -r '\s{2,}' | get 1 | str trim | str downcase)
    let currently_connected = (is-connected-status $current_status)

    if not $currently_connected {
        let msg = if ($display_name | is-empty) {
            $"Connecting to resource: ($resource_name)..."
        } else {
            $"Connecting to ($display_name): ($resource_name)..."
        }
        display-info $msg

        let connect_result = (do -i { sdm connect $resource_name } | complete)

        if $connect_result.exit_code != 0 {
            display-error $"Failed to connect to ($resource_name)"
            if ($connect_result.stderr | str length) > 0 {
                print $"Error: ($connect_result.stderr)"
            }
            return {success: false}
        }

        display-success $"Connected to ($resource_name)"
        sleep 1sec

        return {success: true, was_connected: false}
    }

    return {success: true, was_connected: true}
}

# Execute resource action (Connect, Exec Shell, Open in Browser)
def execute-resource-action [
    action: string,
    resource_name: string,
    address: string,
    resource_type: string,
    resource_url: string,
    display_name?: string,  # Optional display name for messages (e.g., "MySQL resource")
    client?: string         # Optional client command (e.g., "mysql")
    pattern?: string        # Optional type pattern for URL logic (e.g., "httpNoAuth", "amazones")
] {
    match $action {
        "Connect" => {
            let conn_result = (ensure-connected $resource_name $display_name $address)
            if not $conn_result.success {
                return
            }
            if $conn_result.was_connected {
                display-success $"Already connected to ($resource_name)"
            }
        }
        "Exec Shell" => {
            let conn_result = (ensure-connected $resource_name $display_name $address)
            if not $conn_result.success {
                return
            }

            let addr_parts = ($address | split row ":")
            let host = ($addr_parts | get 0)
            let port = ($addr_parts | get 1)

            # Use client if provided, otherwise determine from resource type
            let shell_client = if ($client | is-not-empty) {
                $client
            } else if ($resource_type =~ "mysql") or ($resource_type =~ "aurora") {
                "mysql"
            } else {
                ""
            }

            if ($shell_client | is-empty) {
                display-warning $"Shell mode not supported for ($resource_type) resources"
                return
            }

            display-success $"Opening ($shell_client) shell for ($resource_name) at ($address)"
            print $"($COLORS.yellow)💡 Tip: Use 'exit' or Ctrl+D to close the shell($COLORS.reset)"
            print ""

            match $shell_client {
                "mysql" => { mysql -h $host -P $port -A }
                _ => { display-error $"Unknown client: ($shell_client)" }
            }
        }
        "Open in Browser" => {
            # Determine URL based on pattern or resource type
            let check_pattern = if ($pattern | is-not-empty) {
                $pattern
            } else {
                $resource_type
            }

            # Skip connection for httpNoAuth resources (they have direct URLs)
            let is_http_no_auth = ($check_pattern == "httpNoAuth")
            let conn_result = (ensure-connected $resource_name $display_name $address)
            if not $conn_result.success {
                return
            }

            let url = if $is_http_no_auth and (not ($resource_url | is-empty)) {
                # Use the actual URL from SDM for httpNoAuth resources
                $resource_url
            } else if ($check_pattern == "amazones") or ($resource_type =~ "amazones") {
                # For Elasticsearch, use the proxy address with Kibana path
                let addr_parts = ($address | split row ":")
                let host = ($addr_parts | get 0)
                let port = ($addr_parts | get 1)
                $"http://($host):($port)/_plugin/kibana/app/dev_tools#/console"
            } else {
                # Fallback to proxy address
                let addr_parts = ($address | split row ":")
                let host = ($addr_parts | get 0)
                let port = ($addr_parts | get 1)
                $"http://($host):($port)"
            }

            display-info $"Opening ($resource_name) in browser at ($url)..."
            ^open $url
            display-success "Browser opened"
        }
        _ => {
            display-error $"Unknown action: ($action)"
        }
    }
}

# Check authentication and login if needed
def "sdm-auth-check" [--auto-login] {
    if $auto_login {
        let status_check = (do -i { sdm status } | complete)
        if $status_check.exit_code != 0 {
            display-warning "Not authenticated to SDM. Attempting login..."
            sdm-login

            # Verify login was successful
            let verify = (do -i { sdm status } | complete)
            if $verify.exit_code != 0 {
                display-error "Failed to authenticate to SDM. Please run 'sdm-login' manually."
                return false
            }
        }
    }
    return true
}

# Get type configuration for resource types
def "get-resource-type-config" [type: string] {
    match $type {
        "mysql" => { pattern: "mysql", display: "MySQL", exclude: "aurora", client: "mysql" }
        "aurora" => { pattern: "aurora-mysql", display: "Aurora MySQL", exclude: "", client: "mysql" }
        "es" | "elasticsearch" => { pattern: "amazones", display: "Elasticsearch", exclude: "", client: "" }
        "http" | "https" => { pattern: "httpNoAuth", display: "HTTP/HTTPS", exclude: "", client: "" }
        _ => {
            display-error $"Unknown resource type: ($type)"
            print $"($COLORS.yellow)Valid types: mysql, aurora, es, http($COLORS.reset)"
            return {}
        }
    }
}

# Parse SDM status output into structured resource data
def "parse-sdm-resources" [status_data: string, resource_pattern?: string, exclude_pattern?: string, region?: string] {
    let region_pattern = if ($region | is-empty) {
        ""
    } else {
        get-region-pattern $region
    }

    let output = if ($resource_pattern | is-empty) {
        # For all resources, apply general filtering
        let filtered = ($status_data
        | lines
        | where {|line|
            let trimmed = ($line | str trim)
            # Skip empty lines, headers, and section labels
            (not ($trimmed | is-empty)) and (not ($trimmed | str starts-with "CLUSTER")) and (not ($trimmed | str starts-with "DATASOURCE")) and (not ($trimmed =~ "^[A-Z]+\\s+STATUS"))
        })

        # Apply region filter if specified
        if ($region_pattern | is-empty) {
            $filtered
        } else {
            $filtered | where {|line| $line =~ $region_pattern }
        }
    } else {
        # For specific resource types
        let filtered = ($status_data
        | lines
        | where {|line| $line =~ $resource_pattern }
        | where {|line| not ($line =~ "DATASOURCE") }
        | where {|line|
            if ($exclude_pattern | is-empty) {
                true
            } else {
                not ($line =~ $exclude_pattern)
            }
        })

        # Apply region filter if specified
        if ($region_pattern | is-empty) {
            $filtered
        } else {
            $filtered | where {|line| $line =~ $region_pattern }
        }
    }

    # Parse the output with URL detection for httpNoAuth
    let output_lines = ($output | enumerate)
    let resources = (
        $output_lines | each {|item|
            let line = $item.item
            let index = $item.index
            let parts = ($line | str trim | split row -r '\s{2,}')
            if ($parts | length) >= 4 {
                let name = ($parts | get 0 | str trim)
                let status = ($parts | get 1 | str trim)
                let resource_type = ($parts | get 3 | str trim)
                if not ($name =~ "^[A-Z]+$") {
                    let url = if ($resource_type == "httpNoAuth") and (($parts | length) >= 6) {
                        let url_part = ($parts | get 5 | str trim)
                        if ($url_part | str starts-with "https://") or ($url_part | str starts-with "http://") {
                            $url_part
                        } else {
                            ""
                        }
                    } else {
                        ""
                    }
                    {
                        name: $name
                        status: (colorize-status $status)
                        status_raw: $status
                        address: ($parts | get 2 | str trim)
                        type: $resource_type
                        url: $url
                    }
                }
            }
        } | compact
        | where {|r| ($r.address | str downcase) != "n/a" }  # Exclude resources with N/A address
    )

    return $resources
}

# Filter resources by region
def "filter-resources-by-region" [resources: list, region: string] {
    if ($region | is-empty) {
        return $resources
    }

    let region_pattern = (get-region-pattern $region)
    return ($resources | where {|r| $r.address =~ $region_pattern })
}

# Sort resources by type and name
def "sort-resources" [resources: list] {
    $resources
    | sort-by name
    | sort-by {|r| match $r.type {
        "amazones" => 0
        "aurora-mysql" => 1
        "aurora" => 1
        "httpNoAuth" => 2
        "mysql" => 3
        _ => 4
    }}
}

# Format resources for fzf display
def "format-resources-for-fzf" [resources: list] {
    $resources | each { |res|
        let addr_parts = ($res.address | split row ":")
        let host = ($addr_parts | get 0)
        let port = if ($addr_parts | length) > 1 { $addr_parts | get 1 } else { "" }

        # Colorize status
        let status_colored = (colorize-status $res.status_raw)

        let name = if ($res.name | str length) > 55 {
            ($res.name | str substring 0..52) + "..."
        } else {
            $res.name | fill -a left -w 55
        }

        # Colorize type based on resource type (use exact match instead of regex for performance)
        let type_colored = if ($res.type | str contains "mysql") {
            $"($COLORS.blue)($res.type)($COLORS.reset)"
        } else if ($res.type | str contains "aurora") {
            $"($COLORS.blue)($res.type)($COLORS.reset)"
        } else if ($res.type | str contains "amazones") {
            $"($COLORS.yellow)($res.type)($COLORS.reset)"
        } else if ($res.type | str contains "httpNoAuth") {
            $"($COLORS.green)($res.type)($COLORS.reset)"
        } else {
            $res.type
        }

        $"($name)\t($type_colored)\t($host)\t($port)\t($status_colored)"
    }
}

# Handle resource selection and action
def "handle-resource-selection-and-action" [
    resources: list,
    resource_list: list,
    type_label?: string,
    shell_mode?: bool,
    type_config?: record
] {
    let prompt_suffix = if ($shell_mode | default false) { " for Shell" } else { "" }
    let selection_prompt = if ($type_label | is-empty) {
        $"Select Resource($prompt_suffix) ❯"
    } else {
        $"Select ($type_label) Resource($prompt_suffix) ❯"
    }

    let selection = (fzf-select
        $resource_list
        $selection_prompt
        "Name\tType\tHost\tPort\tStatus"
        --tabstop 40
    )

    if ($selection | is-empty) {
        display-warning "No resource selected"
        return
    }

    # Extract resource name from selection and find full resource object
    let parts = ($selection | split row "\t")
    let resource_name = ($parts | get 0 | str trim)

    # Find the full resource object to get all properties including URL
    let resource = ($resources | where name == $resource_name | first)
    let address = $resource.address
    let resource_type = $resource.type
    let resource_url = $resource.url

    # If --shell flag is set, skip action menu and go directly to shell
    if ($shell_mode | default false) {
        handle-shell-mode $resource_name $address $resource_type $type_config
        return
    }

    # Show action menu and handle selection
    show-resource-info $resource_name $resource_type $address $resource_url
    let actions = get-resource-actions $resource_type $type_config
    let action_selection = select-resource-action $actions

    if ($action_selection | is-empty) {
        display-warning "No action selected"
        return
    }

    # Execute the selected action using helper function
    if ($type_config | is-empty) {
        execute-resource-action $action_selection $resource_name $address $resource_type $resource_url
    } else {
        execute-resource-action $action_selection $resource_name $address $resource_type $resource_url $type_config.display $type_config.client $type_config.pattern
    }
}

# Handle shell mode execution
def "handle-shell-mode" [resource_name: string, address: string, resource_type: string, type_config?: record] {
    let display_name = if ($type_config | is-empty) { "" } else { $type_config.display }
    let conn_result = (ensure-connected $resource_name $display_name $address)
    if not $conn_result.success {
        return
    }

    if ($resource_type =~ "mysql") or ($resource_type =~ "aurora") {
        let addr_parts = ($address | split row ":")
        let host = ($addr_parts | get 0)
        let port = ($addr_parts | get 1)

        display-success $"Opening mysql shell for ($resource_name) at ($address)"
        print $"($COLORS.yellow)💡 Tip: Use 'exit' or Ctrl+D to close the shell($COLORS.reset)"
        print ""

        mysql -h $host -P $port -A
    } else if ($type_config | is-not-empty) and ($type_config.client | is-not-empty) {
        let addr_parts = ($address | split row ":")
        let host = ($addr_parts | get 0)
        let port = ($addr_parts | get 1)

        display-success $"Opening ($type_config.client) shell for ($resource_name) at ($address)"
        print $"($COLORS.yellow)💡 Tip: Use 'exit' or Ctrl+D to close the shell($COLORS.reset)"
        print ""

        match $type_config.client {
            "mysql" => { mysql -h $host -P $port -A }
            _ => { display-error $"Unknown client: ($type_config.client)" }
        }
    } else {
        display-warning $"Shell mode not supported for ($resource_type) resources"
    }
}

# Show resource information box
def "show-resource-info" [resource_name: string, resource_type: string, address: string, resource_url: string] {
    print ""
    print $"($COLORS.blue)╭─────────────────────────────────────────────────────────────╮($COLORS.reset)"
    print $"($COLORS.blue)│($COLORS.reset)  Selected: ($resource_name)"
    print $"($COLORS.blue)│($COLORS.reset)  Type: ($resource_type)"
    print $"($COLORS.blue)│($COLORS.reset)  Address: ($address)"
    print $"($COLORS.blue)│($COLORS.reset)  URL: ($resource_url)"
    print $"($COLORS.blue)╰─────────────────────────────────────────────────────────────╯($COLORS.reset)"
    print ""
}

# Get available actions for a resource type
def "get-resource-actions" [resource_type: string, type_config?: record] {
    if ($resource_type =~ "mysql") or ($resource_type =~ "aurora") {
        ["Connect", "Exec Shell"]
    } else if ($type_config | is-not-empty) and ($type_config.client | is-not-empty) {
        ["Connect", "Exec Shell"]
    } else {
        ["Connect", "Open in Browser"]
    }
}

# Select resource action using fzf
def "select-resource-action" [actions: list] {
    fzf-select $actions "Select Action ❯" "Choose what to do with this resource"
}

# Handle all resources (no specific type)
def "handle-all-resources" [region: string, fresh: bool, shell_mode: bool] {
    display-info $"Fetching ALL resources from SDM \(region: ($region)\)..."

    # Get SDM status (with optional cache refresh)
    let status_data = if $fresh {
        get-sdm-status-cached --force-refresh
    } else {
        get-sdm-status-cached
    }

    # Parse and filter resources
    let filtered_resources = (parse-sdm-resources $status_data "" "" $region)

    if ($filtered_resources | is-empty) {
        display-error $"No resources found in region: ($region)"
        return
    }

    let sorted_resources = (sort-resources $filtered_resources)
    display-success $"Found ($sorted_resources | length) resource\(s\) in ($region) region"

    # Format and handle selection
    let resource_list = (format-resources-for-fzf $sorted_resources)
    handle-resource-selection-and-action $sorted_resources $resource_list "" $shell_mode
}

# Handle specific resource type
def "handle-specific-resource-type" [type: string, region: string, fresh: bool, shell_mode: bool] {
    let type_config = (get-resource-type-config $type)
    if ($type_config | is-empty) {
        return
    }

    # Display info message based on region filter
    let region_info = if ($region | is-empty) {
        "all regions"
    } else {
        $"region: ($region)"
    }
    display-info $"Fetching ($type_config.display) resources from SDM ($region_info)..."

    # Get SDM status (with optional cache refresh)
    let status_data = if $fresh {
        get-sdm-status-cached --force-refresh
    } else {
        get-sdm-status-cached
    }

    # Parse and filter resources
    let filtered_resources = (parse-sdm-resources $status_data $type_config.pattern $type_config.exclude $region)

    if ($filtered_resources | is-empty) {
        display-error $"No ($type_config.display) resources found in SDM"
        return
    }

    display-success $"Found ($filtered_resources | length) ($type_config.display) resource\(s\)"

    # Format and handle selection
    let resource_list = (format-resources-for-fzf $filtered_resources)
    handle-resource-selection-and-action $filtered_resources $resource_list $type_config.display $shell_mode $type_config
}

# Unified interactive resource connection via SDM with fzf
export def go2sdm [
    type?: string@"sdm-resource-types"  # Resource type: mysql, aurora, es, http, or empty for all
    --region: string@"sdm-regions" = "us"  # Region filter: us, eu (default: us)
    --shell                             # Open client shell after connecting (mysql/aurora only)
    --fresh                             # Force refresh cache and fetch fresh data from SDM
    --login                             # Auto login if not authenticated
] {
    # Check authentication status first
    if not (sdm-auth-check --auto-login=$login) {
        return
    }

    # Route to appropriate handler based on whether type is specified
    if ($type | is-empty) {
        handle-all-resources $region $fresh $shell
    } else {
        handle-specific-resource-type $type $region $fresh $shell
    }
}

# Completion helper for resource types
def "sdm-resource-types" [] {
    ["mysql", "aurora", "es", "elasticsearch", "http", "https"]
}

# Completion helper for regions
def "sdm-regions" [] {
    ["us", "eu"]
}

# ============================================================================
# Convenience Aliases and Wrappers
# ============================================================================

# Backward compatibility aliases
export alias go2rds = go2sdm mysql --shell
export alias go2high-io = go2sdm aurora --shell
export alias go2es = go2sdm es
export alias go2http = go2sdm http

# ============================================================================
# Help Documentation
# ============================================================================
export def "help sdm" [] {
    let title = "📚 SDM (StrongDM) Aliases & Functions"

    print $"($COLORS.blue)╭─────────────────────────────────────────────╮($COLORS.reset)"
    print $"($COLORS.blue)│($COLORS.reset)  ($title)  ($COLORS.blue)│($COLORS.reset)"
    print $"($COLORS.blue)╰─────────────────────────────────────────────╯($COLORS.reset)"
    print ""

    print $"($COLORS.green)Authentication:($COLORS.reset)"
    print "  sdm-login      - Login to SDM with status check"
    print ""

    print $"($COLORS.green)Status & Connection:($COLORS.reset)"
    print "  sdml           - List connected resources (sdm status)"
    print "  sdmc           - Connect to a resource"
    print "  sdmd           - Disconnect from a resource"
    print "  sdmda          - Disconnect from all resources"
    print "  sdm-connect-all (sdmca) - Connect to all available resources"
    print ""

    print $"($COLORS.green)Admin Commands:($COLORS.reset)"
    print "  sdmr           - List all available resources (admin)"
    print "  sdmu           - List all users (admin)"
    print "  sdms           - SSH to a resource (admin)"
    print "  sdmlog         - View SDM logs"
    print ""

    print $"($COLORS.green)Resource Connection:($COLORS.reset)"
    print "  go2sdm [type]  - Interactive resource connection with fzf"
    print "    <empty>       - List ALL resource types (default)"
    print "    Types: mysql, aurora, es, http"
    print "    --region <region> - Filter by region: us, eu (default: us)"
    print "    --shell           - Open client shell after connecting (mysql/aurora only)"
    print ""
    print "  Aliases:"
    print "    go2rds      - Same as 'go2sdm mysql --shell'"
    print "    go2high-io  - Same as 'go2sdm aurora --shell'"
    print "    go2es       - Same as 'go2sdm es'"
    print "    go2http     - Same as 'go2sdm http'"
    print ""

    print $"($COLORS.green)Configuration:($COLORS.reset)"
    print "  Set credentials in ~/Workday/MacSetup/dotfiles/config/nushell/.env:"
    print "    SDM_EMAIL=your.email@example.com"
    print "    SDM_APP_DOMAIN=app.strongdm.com"
    print ""

    print $"($COLORS.yellow)Examples:($COLORS.reset)"
    print "  sdm-login               # Login to SDM (with auth check)"
    print "  sdml                    # Show all connected resources"
    print "  sdmca                   # Connect to ALL resources at once"
    print "  go2sdm                  # List ALL resources of all types (us region)"
    print "  go2sdm --region eu      # List ALL resources in EU region"
    print "  go2sdm mysql            # List MySQL databases (us region)"
    print "  go2sdm mysql --region eu # List MySQL databases in EU region"
    print "  go2sdm aurora --shell   # Connect to Aurora and open MySQL shell"
    print "  go2sdm es --region eu   # Connect to Elasticsearch in EU region"
    print "  go2sdm http             # Connect to HTTP resource (us region)"
    print "  go2rds                  # Quick MySQL shell access"
    print "  sdmc my-db-name         # Connect to specific resource by name"
    print "  sdmda                   # Disconnect all resources"
}
