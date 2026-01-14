# pyenv initialization for Nushell

# Check if pyenv is installed
if (which pyenv | is-not-empty) {
    # Set PYENV_ROOT - use hardcoded path for speed (avoid calling pyenv root)
    $env.PYENV_ROOT = $"($env.HOME)/.pyenv"
    
    # Add pyenv shims to PATH
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.PYENV_ROOT)/shims")
    
    # Set PYENV_SHELL for shell integration
    $env.PYENV_SHELL = "nu"
}
