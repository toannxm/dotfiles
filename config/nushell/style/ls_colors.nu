# -------------------------------------------------------------------
# LS_COLORS Configuration using Vivid
# -------------------------------------------------------------------
# Vivid generates LS_COLORS from color schemes
# Available themes: https://github.com/sharkdp/vivid#themes
# Popular themes: dracula, molokai, snazzy, one-dark, nord, ayu, gruvbox-dark, solarized-dark

export def get_ls_colors [] {
    # Use vivid if available, otherwise fallback to basic colors
    if (which vivid | is-not-empty) {
        # Change 'dracula' to any theme you prefer
        vivid generate molokai
    } else {
        # Fallback: Basic LS_COLORS if vivid is not installed
        [
            "di=1;34"      # Directory - bold blue
            "ln=1;36"      # Symbolic link - bold cyan
            "ex=1;32"      # Executable - bold green
            "*.tar=1;31"   # Archives - bold red
            "*.zip=1;31"
            "*.gz=1;31"
            "*.py=0;33"    # Python - yellow
            "*.js=0;33"    # JavaScript - yellow
            "*.json=0;33"  # Config - yellow
            "*.md=0;37"    # Markdown - white
        ] | str join ":"
    }
}

# List available vivid themes (run: vivid-themes)
export def vivid-themes [] {
    if (which vivid | is-not-empty) {
        vivid themes
    } else {
        print "Vivid is not installed. Install with: brew install vivid"
    }
}

# Preview a vivid theme (run: vivid-preview dracula)
export def vivid-preview [theme: string] {
    if (which vivid | is-not-empty) {
        $env.LS_COLORS = (vivid generate $theme)
        print $"Preview of ($theme) theme - run 'ls' to see colors"
    } else {
        print "Vivid is not installed. Install with: brew install vivid"
    }
}
