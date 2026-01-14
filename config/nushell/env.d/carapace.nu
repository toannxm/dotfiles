# -------------------------------------------------------------------
# Carapace Completion Configuration
# -------------------------------------------------------------------
# Auto-initialize carapace if not already done
# NOTE: This must be sourced AFTER $env.config is set in config.nu
# NOTE: Environment variables are set in env.nu

const carapace_cache = "~/.cache/carapace/init.nu"
let carapace_cache_path = ($carapace_cache | path expand)

if not ($carapace_cache_path | path exists) {
    mkdir ($carapace_cache_path | path dirname)
    carapace _carapace nushell | save -f $carapace_cache_path
}

# Load carapace if available (it will merge with $env.config)
if (which carapace | is-not-empty) {
    source ~/.cache/carapace/init.nu
}

