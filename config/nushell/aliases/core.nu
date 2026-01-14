# Core generic aliases & utilities
# Basic navigation and system commands

# -------------------------------------------------------------------
# Help function
# -------------------------------------------------------------------
export def "help core" [] {
    print "📚 Core Aliases & Utilities\n"
    print "Navigation:"
    print "  ll, la, l      - ls variations (long, all, simple)"
    print "  .., ..., ....  - Navigate up directories\n"
    print "Modern Tools:"
    print "  grep → rg      - Ripgrep (faster grep)"
    print "  cat → bat      - Bat (cat with syntax highlighting)"
    print "  find → fd      - Fd (faster find)\n"
    print "Editors:"
    print "  vi, vim → nvim - Neovim"
    print "  nuconfig       - Edit nushell config.nu in VSCode"
    print "  nuenv          - Edit nushell env.nu in VSCode\n"
    print "Config Management:"
    print "  reload         - Reload nushell configuration"
    print "  restart        - Restart nushell (fresh session)\n"
    print "Dotfiles:"
    print "  dotfiles       - Git commands for dotfiles repo"
}

# Kill port
export def kill-port [port: int] {
    let pids = (^sudo lsof -ti :($port) | lines)
    if ($pids | is-empty) {
        print $"No process found on port ($port)"
    } else {
        $pids | each { |pid|
            print $"Killing process ($pid) on port ($port)"
            ^sudo kill -9 $pid
        }
        null
    }
}
export alias kp = kill-port

# Directory navigation
export alias ll = ls -l
export alias la = ls -la
export alias l = ls
export alias cls = clear
export alias .. = cd ..
export alias ... = cd ../..
export alias .... = cd ../../..

# Modern CLI replacements
export alias grep = rg
export alias cat = bat
export alias find = fd

# Editor aliases
export alias vi = nvim
export alias vim = nvim
export alias nano = micro

# Dotfiles management
const DOTFILES_DIR = ("/Users/toan.nguyen2/Workday/MacSetup/.dotfiles" | path expand)
export alias dotfiles = git --git-dir=($DOTFILES_DIR)/.git/ --work-tree=($DOTFILES_DIR)

# Quick config editing
export def nuconfig [] {
    code ($nu.config-path)
}

export def nuenv [] {
    code ($nu.env-path)
}

# Reload nushell configuration
# Note: For full reload, use 'restart' to start a fresh session
export def reload [] {
    print "🔄 Reloading Nushell configuration..."
    print "⚠️  Note: Some changes may require a full restart. Use 'restart' for a fresh session."
    exec nu
}

# Restart nushell (fresh session)
export alias restart = exec nu

# -------------------------------------------------------------------
# Master help - List all available help topics
# -------------------------------------------------------------------
export def "help aliases" [] {
    print "📚 Nushell Custom Aliases - Help Topics\n"
    print "Available help commands:\n"
    print "  help core      - Core utilities, navigation, config management"
    print "  help git       - Git shortcuts and branch management"
    print "  help database  - MySQL commands and database utilities"
    print "  help docker    - Docker and Docker Compose shortcuts"
    print "  help kubectl   - Kubernetes/kubectl commands"
    print "  help k8s       - Kubernetes helpers (go2pod, contexts, namespaces)"
    print "  help olivia    - Olivia project-specific commands"
    print "  help sdm       - StrongDM CLI shortcuts\n"
    print "Usage: Run any help command above to see detailed information"
    print "Example: help git"
}
