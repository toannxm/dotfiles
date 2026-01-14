# -------------------------------------------------------------------
# Starship Prompt Configuration
# -------------------------------------------------------------------
# Auto-initialize starship if not already done
# Note: STARSHIP_CONFIG is set in env.nu

const starship_cache = "~/.cache/starship/init.nu"
let starship_cache_path = ($starship_cache | path expand)

if not ($starship_cache_path | path exists) {
    mkdir ($starship_cache_path | path dirname)
    starship init nu | save -f $starship_cache_path
}

source ~/.cache/starship/init.nu
