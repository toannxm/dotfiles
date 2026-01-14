# Shell Configuration Guide

This guide covers the shell configuration setup in this dotfiles repository, including both Zsh and Nushell configurations.

## Overview

The repository supports two shell environments:
- **Zsh** - Primary shell with Powerlevel10k theme and modular configuration
- **Nushell** - Modern alternative shell with complete feature parity

Both shells are configured with:
- Custom aliases and functions
- Kubernetes workflow tools
- Project-specific shortcuts (Olivia)
- SDM integration
- Git enhancements
- Development utilities

## Zsh Configuration

### Architecture

The Zsh configuration uses a modular architecture where the main `.zshrc` file loads components from `shell/zshrc/` directory:

```
.zshrc                    # Main entry point
└── shell/zshrc/          # Modular configuration
    ├── 00-env.zsh        # Environment variables and PATH
    ├── 10-packages.zsh   # Package manager initialization (Homebrew)
    ├── 20-prompt.zsh     # Prompt configuration (Starship/P10k)
    ├── 30-ohmyzsh.zsh    # Oh-My-Zsh setup
    ├── 40-aliases-core.zsh    # Core aliases
    ├── 50-aliases-project.zsh # Project-specific aliases
    ├── 60-functions.zsh  # Custom functions
    └── 90-local.zsh      # Local overrides (gitignored)
```

### Loading Order

Files are loaded in numeric order (00, 10, 20, etc.):

1. **00-env.zsh** - Sets up environment variables, PATH, and language version managers (fnm, pyenv)
2. **10-packages.zsh** - Initializes Homebrew and package managers
3. **20-prompt.zsh** - Configures Starship or Powerlevel10k prompt
4. **30-ohmyzsh.zsh** - Loads Oh-My-Zsh framework and plugins
5. **40-aliases-core.zsh** - Core command aliases (ls, git, docker)
6. **50-aliases-project.zsh** - Project-specific shortcuts (Olivia, SDM)
7. **60-functions.zsh** - Custom shell functions
8. **90-local.zsh** - Machine-specific overrides (not tracked in git)

### Prompt Configuration

The setup supports two prompt themes:

**Powerlevel10k** (default):
- Instant prompt for fast shell startup
- Configured via `~/.p10k.zsh`
- Git status, command duration, virtualenv indicators

**Starship** (alternative):
- Cross-shell prompt (works with Nushell too)
- Configured via `config/starship.toml`
- Minimal, fast, customizable

To switch prompts, edit `shell/zshrc/20-prompt.zsh`.

### Environment Variables

Key environment paths set in `00-env.zsh`:

```bash
# Project roots
export OLIVIA_ROOT="${HOME}/work/olivia"
export OLIVIA_CORE="${OLIVIA_ROOT}/core"
export OLIVIA_UI="${OLIVIA_ROOT}/ui"
export OLIVIA_DOCKER="${OLIVIA_ROOT}/docker"

# Development tools
export EDITOR='nvim'
export VISUAL='nvim'

# Language version managers
export FNM_DIR="${HOME}/.local/share/fnm"  # Fast Node Manager
export PYENV_ROOT="${HOME}/.pyenv"          # Python version manager
```

### Core Aliases

Located in `40-aliases-core.zsh`:

```bash
# Navigation
alias ..='cd ..'
alias ...='cd ../..'

# File operations with color
alias ls='ls -G'
alias ll='ls -alF'
alias la='ls -A'

# Git shortcuts
alias g='git'
alias gs='git status'
alias ga='git add'
alias gc='git commit'
alias gp='git push'

# Docker
alias d='docker'
alias dc='docker-compose'
alias dps='docker ps'
alias di='docker images'
```

### Project Aliases

Located in `50-aliases-project.zsh`:

```bash
# Olivia project navigation
alias cdol='cd $OLIVIA_ROOT'
alias cdcore='cd $OLIVIA_CORE'
alias cdui='cd $OLIVIA_UI'

# Django management
alias djrun='python manage.py runserver'
alias djmake='python manage.py makemigrations'
alias djmig='python manage.py migrate'
alias djshell='python manage.py shell'

# SDM shortcuts
alias sdm='sdm status'
```

### Custom Functions

Located in `60-functions.zsh`:

**mkcd** - Create directory and cd into it:
```bash
mkcd() {
  mkdir -p "$1" && cd "$1"
}
```

**extract** - Universal archive extractor:
```bash
extract() {
  # Handles .tar.gz, .zip, .7z, etc.
}
```

### Local Overrides

Create `shell/zshrc/90-local.zsh` for machine-specific configuration:

```bash
# Example: custom PATH additions
export PATH="/usr/local/custom/bin:$PATH"

# Machine-specific aliases
alias work='cd ~/my-work-folder'

# Different editor preference
export EDITOR='code'
```

This file is gitignored and won't be committed to version control.

## Nushell Configuration

### Architecture

Nushell uses a different but parallel structure in `config/nushell/`:

```
config/nushell/
├── config.nu           # Main configuration (colors, keybindings, menus)
├── env.nu              # Environment variables and PATH
├── common.nu           # Common utilities and helpers
├── .env.example        # Environment variable template
├── aliases/            # Modular alias definitions
│   ├── core.nu         # Core command aliases
│   ├── docker.nu       # Docker shortcuts
│   ├── git.nu          # Git aliases
│   ├── ide.nu          # IDE/editor shortcuts
│   ├── k8s.nu          # Kubernetes workflows
│   ├── olivia.nu       # Olivia project aliases
│   ├── py.nu           # Python environment wrapper
│   └── sdm.nu          # SDM connection helpers
├── env.d/              # Environment modules
│   ├── olivia.nu       # Olivia-specific env vars
│   ├── pyenv.nu        # Python environment integration
│   └── fnm.nu          # Node version manager integration
└── style/              # Theme and styling
    └── default.nu      # Color scheme
```

### Configuration Files

**config.nu** - Main configuration:
- Color themes and syntax highlighting
- Keybindings (emacs/vi mode)
- Completion menus
- Shell behavior settings
- Loads all alias modules

**env.nu** - Environment setup:
- PATH configuration
- Tool initialization (fnm, pyenv, Starship)
- Environment variable exports
- Carapace completion

### Alias System

Nushell aliases are organized by category in `config/nushell/aliases/`:

**Core aliases** (`core.nu`):
```nushell
# File operations
export alias ls = ls --color
export alias ll = ls -la
export alias la = ls -a

# Navigation
export alias .. = cd ..
export alias ... = cd ../..

# Common tools
export alias cat = bat
export alias grep = rg
```

**Git aliases** (`git.nu`):
```nushell
export alias g = git
export alias gs = git status
export alias ga = git add
export alias gc = git commit
export alias gp = git push
export alias gl = git log --oneline --graph
export alias gco = git checkout
```

**Docker aliases** (`docker.nu`):
```nushell
export alias d = docker
export alias dc = docker compose
export alias dps = docker ps
export alias di = docker images
export alias dex = docker exec -it
```

**Kubernetes aliases** (`k8s.nu`):
```nushell
export alias k = kubectl
export alias kgp = kubectl get pods
export alias kgs = kubectl get services
export alias kgn = kubectl get nodes
export alias kd = kubectl describe
export alias kdel = kubectl delete
```

### Custom Commands

Nushell supports rich custom commands with typed parameters:

**go2pod** - Interactive pod selection:
```nushell
# Interactive Kubernetes pod access with fzf
export def go2pod [
    namespace?: string  # Optional namespace filter
] {
    kubectl get pods -A
    | fzf
    | kubectl exec -it (split row ' ' | get 1) -- /bin/bash
}
```

**go2sdm** - SDM resource connection:
```nushell
# Interactive SDM resource selection
export def go2sdm [] {
    sdm status
    | fzf
    | sdm connect (split row ' ' | get 0)
}
```

### Environment Variables

Configured in `env.nu` and `env.d/` modules:

```nushell
# Project paths
$env.OLIVIA_ROOT = $"($env.HOME)/work/olivia"
$env.OLIVIA_CORE = $"($env.OLIVIA_ROOT)/core"
$env.OLIVIA_UI = $"($env.OLIVIA_ROOT)/ui"

# Editor
$env.EDITOR = "nvim"
$env.VISUAL = "nvim"

# Language version managers loaded from env.d/
source ~/.config/nushell/env.d/fnm.nu    # Node
source ~/.config/nushell/env.d/pyenv.nu  # Python
```

### Local Overrides

Create `config/nushell/.env` for machine-specific variables:

```nushell
# Example .env (gitignored)
$env.CUSTOM_PATH = "/opt/custom/bin"
$env.API_KEY = "secret-key"
```

Load it from `env.nu`:
```nushell
if ('.env' | path exists) {
    source .env
}
```

## Switching Between Shells

### Using Zsh

Set as default shell:
```bash
chsh -s $(which zsh)
```

Launch interactively:
```bash
zsh
```

### Using Nushell

Set as default shell:
```bash
chsh -s $(which nu)
```

Launch interactively:
```bash
nu
```

### Testing Without Changing Default

You can test configurations without changing your default shell:

```bash
# Test Zsh config
zsh -c 'source ~/.zshrc && zsh'

# Test Nushell config
nu -c 'source ~/.config/nushell/config.nu'
```

## Comparison: Zsh vs Nushell

| Feature | Zsh | Nushell |
|---------|-----|---------|
| **Syntax** | POSIX-compatible bash-like | Structured, typed language |
| **Configuration** | Modular .zsh files | .nu files with imports |
| **Aliases** | Simple string substitution | Typed commands with parameters |
| **Piping** | Text streams | Structured data (tables) |
| **Completion** | Tab completion plugins | Built-in with Carapace |
| **Performance** | Fast, mature | Fast, modern Rust implementation |
| **Scripting** | Shell scripts | Structured programming |
| **Compatibility** | High (POSIX tools) | Lower (requires Nu-aware commands) |
| **Ecosystem** | Massive (Oh-My-Zsh, plugins) | Growing, modern tooling |

## Customization Guide

### Adding New Aliases

**For Zsh:**
1. Edit `shell/zshrc/40-aliases-core.zsh` (general) or `50-aliases-project.zsh` (project-specific)
2. Add alias: `alias myalias='command'`
3. Reload: `source ~/.zshrc`

**For Nushell:**
1. Edit appropriate file in `config/nushell/aliases/` (e.g., `core.nu`)
2. Add alias: `export alias myalias = command`
3. Reload: `source ~/.config/nushell/config.nu` or restart shell

### Adding New Functions

**For Zsh:**
1. Edit `shell/zshrc/60-functions.zsh`
2. Add function:
```bash
myfunction() {
    echo "Hello $1"
}
```
3. Reload: `source ~/.zshrc`

**For Nushell:**
1. Edit `config/nushell/common.nu` or create new module
2. Add command:
```nushell
export def myfunction [name: string] {
    print $"Hello ($name)"
}
```
3. Import in `config.nu`: `source common.nu`

### Adding Environment Variables

**For Zsh:**
1. Edit `shell/zshrc/00-env.zsh`
2. Add: `export MY_VAR="value"`
3. Reload shell

**For Nushell:**
1. Edit `config/nushell/env.nu` or create module in `env.d/`
2. Add: `$env.MY_VAR = "value"`
3. Reload shell

## Troubleshooting

### Zsh Issues

**Prompt not showing:**
- Check `20-prompt.zsh` is sourcing correctly
- Verify Powerlevel10k or Starship installed: `brew list | grep starship`

**Aliases not working:**
- Ensure module files have `.zsh` extension
- Check file permissions: `chmod +r shell/zshrc/*.zsh`
- Verify loading: `echo $SHELL_DIR`

**Slow startup:**
- Disable instant prompt in `.zshrc`
- Profile startup: `zsh -xv`
- Remove unnecessary plugins from `30-ohmyzsh.zsh`

### Nushell Issues

**Config not loading:**
- Check file location: `$nu.config-path`
- Verify syntax: `nu -c 'source ~/.config/nushell/config.nu'`

**Aliases not found:**
- Ensure `source` statements in `config.nu`
- Check export keyword: `export alias ...`

**Environment variables missing:**
- Check `env.nu` loaded before `config.nu`
- Verify `.env` exists if referenced

**Command not found:**
- Some POSIX tools need `^` prefix: `^ls` (external command)
- Or use Nu built-ins: `ls` (Nu's native ls)

## Best Practices

1. **Keep configurations modular** - One concern per file
2. **Use numeric prefixes** - Control load order (00, 10, 20...)
3. **Document complex functions** - Add comments explaining usage
4. **Test before committing** - Verify in clean shell: `zsh -f` or `nu --config /dev/null`
5. **Use local overrides** - Keep machine-specific changes in gitignored files
6. **Maintain parity** - Keep Zsh and Nushell configs functionally equivalent
7. **Version compatibility** - Document required shell versions

## Additional Resources

- [Zsh Documentation](https://zsh.sourceforge.io/Doc/)
- [Oh-My-Zsh](https://ohmyz.sh/)
- [Powerlevel10k](https://github.com/romkatv/powerlevel10k)
- [Nushell Book](https://www.nushell.sh/book/)
- [Starship Prompt](https://starship.rs/)
- [Carapace Completions](https://carapace-sh.github.io/carapace-bin/)

## Related Documentation

- [Kubernetes Workflows Guide](./kubernetes-workflows.md) - kubectl aliases and tools
- [Language Runtimes Guide](./language-runtimes.md) - fnm and pyenv setup
- [VS Code Setup Guide](./vscode-setup.md) - Editor configuration
