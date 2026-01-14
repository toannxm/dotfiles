# pyenv wrapper for shell integration
# Handles 'pyenv shell' command to set PYENV_VERSION environment variable

# Main pyenv wrapper that handles all commands
export def --env pyenv [
    command?: string    # pyenv subcommand
    ...args: string     # additional arguments
] {
    # Handle 'pyenv shell' command specially
    if $command == "shell" {
        if ($args | length) > 0 {
            # pyenv shell <version> - set PYENV_VERSION
            let version = ($args | first)
            $env.PYENV_VERSION = $version
        } else {
            # pyenv shell - show current version
            if ("PYENV_VERSION" in $env) {
                print $env.PYENV_VERSION
            } else {
                print "pyenv: no shell-specific version configured"
            }
        }
    } else if ($command | is-empty) {
        # pyenv with no args - pass through
        ^pyenv
    } else {
        # Pass through all other pyenv commands
        ^pyenv $command ...$args
    }
}
