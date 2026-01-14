# Language Runtimes Guide

This guide covers the Node.js and Python runtime configuration in this dotfiles repository, using fnm (Fast Node Manager) and pyenv for version management.

## Overview

The repository manages programming language runtimes with:
- **fnm (Fast Node Manager)** - Fast, cross-platform Node.js version manager
- **pyenv** - Python version manager with virtualenv support
- **Automated installation** - `install.sh --lang` sets up everything
- **Shell integration** - Works seamlessly in both Zsh and Nushell
- **Project-specific environments** - Python virtual environments for Olivia projects

## Architecture

### Installation Flow

```
install.sh --lang
└── scripts/lang.sh
    ├── Install Node.js via fnm (LTS version)
    ├── Install Python via pyenv (3.12.1+)
    └── Set default versions
```

### Shell Integration

**Zsh**: `shell/zshrc/10-packages.zsh`
- Initializes fnm and pyenv
- Adds shims to PATH
- Enables auto-switching

**Nushell**: `config/nushell/env.nu`, `config/nushell/env.d/pyenv.nu`
- JSON-based environment loading
- Native Nushell integration

## Node.js with fnm

### What is fnm?

fnm (Fast Node Manager) is a modern, Rust-based Node.js version manager that's:
- **Fast** - Near-instant version switching
- **Cross-platform** - Works on macOS, Linux, Windows
- **Simple** - Minimal configuration
- **Compatible** - Respects `.node-version` and `.nvmrc` files

### Installation

fnm is installed automatically:

```bash
# Via dotfiles setup
./install.sh --lang

# Or manually via Homebrew
brew install fnm
```

### Configuration

**Zsh** (`shell/zshrc/10-packages.zsh`):
```bash
# fnm (Fast Node Manager) initialization
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi
```

**Nushell** (`config/nushell/env.nu`):
```nushell
# fnm (Fast Node Manager) - if installed
if (which fnm | is-not-empty) {
    ^fnm env --json | from json | load-env
}
```

The `--use-on-cd` flag enables automatic Node.js version switching based on `.node-version` or `.nvmrc` files in directories.

### Basic Usage

**Install Node.js versions:**
```bash
# Install latest LTS
fnm install --lts

# Install specific version
fnm install 20.10.0
fnm install 18

# Install from .node-version or .nvmrc
cd my-project/
fnm install  # Reads .node-version
```

**List installed versions:**
```bash
fnm list
```

**Switch versions:**
```bash
# Use specific version
fnm use 20

# Use LTS
fnm use --lts

# Set default version
fnm default 20
fnm default lts-latest
```

**Check current version:**
```bash
node --version
fnm current
```

### Auto-Switching

Create `.node-version` in project root:

```bash
# .node-version
20.10.0
```

Or `.nvmrc`:

```bash
# .nvmrc
lts/iron
```

When you `cd` into the directory, fnm automatically switches to that version.

### Troubleshooting fnm

**Node not found after installation:**
```bash
# Restart shell or source config
source ~/.zshrc  # Zsh
source ~/.config/nushell/env.nu  # Nushell

# Verify fnm in PATH
which fnm
fnm --version
```

**Auto-switching not working:**
```bash
# Verify --use-on-cd enabled in shell config
grep "use-on-cd" ~/Workday/MacSetup/dotfiles/shell/zshrc/10-packages.zsh

# Check .node-version exists
cat .node-version

# Manually install and use
fnm install
fnm use
```

**Switch from nvm to fnm:**
```bash
# List nvm versions
nvm list

# Install same versions in fnm
fnm install 18
fnm install 20

# Set default
fnm default 20

# Optional: Remove nvm
rm -rf ~/.nvm
# Remove nvm init from .zshrc if present
```

## Python with pyenv

### What is pyenv?

pyenv is a Python version manager that allows:
- **Multiple Python versions** - Install and switch between versions
- **Virtualenv integration** - Isolate project dependencies
- **Global and local versions** - Per-project or system-wide defaults
- **Build from source** - Install any Python version

### Installation

pyenv is installed automatically:

```bash
# Via dotfiles setup
./install.sh --lang

# Or manually via Homebrew
brew install pyenv
brew install pyenv-virtualenv
```

### Configuration

**Zsh** (`shell/zshrc/10-packages.zsh`):
```bash
# pyenv (guarded)
if command -v pyenv >/dev/null 2>&1; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi
```

**Nushell** (`config/nushell/env.d/pyenv.nu`):
```nushell
# pyenv initialization for Nushell
if (which pyenv | is-not-empty) {
    # Set PYENV_ROOT
    $env.PYENV_ROOT = (^pyenv root)

    # Add pyenv shims to PATH
    $env.PATH = ($env.PATH | split row (char esep) | prepend $"($env.PYENV_ROOT)/shims")

    # Set PYENV_SHELL for shell integration
    $env.PYENV_SHELL = "nu"
}
```

### Basic Usage

**Install Python versions:**
```bash
# Install specific version
pyenv install 3.12.1
pyenv install 3.11.7
pyenv install 3.13.0

# List available versions
pyenv install --list
pyenv install --list | grep " 3\."
```

**List installed versions:**
```bash
pyenv versions
```

**Set default (global) version:**
```bash
pyenv global 3.12.1

# Verify
python --version
which python
```

**Set project-specific version:**
```bash
cd my-project/
pyenv local 3.11.7

# Creates .python-version file
cat .python-version
# 3.11.7
```

**Check current version:**
```bash
pyenv version
python --version
```

### Virtual Environments

pyenv-virtualenv plugin manages virtual environments:

**Create virtualenv:**
```bash
# Format: pyenv virtualenv <python-version> <env-name>
pyenv virtualenv 3.12.1 my-project

# Or use current global version
pyenv virtualenv my-project
```

**Activate virtualenv:**
```bash
pyenv activate my-project

# Verify
which python
pip list
```

**Deactivate:**
```bash
pyenv deactivate
```

**Auto-activation:**
```bash
cd my-project/
pyenv local my-project  # Creates .python-version with virtualenv name

# Now automatically activates when entering directory
cd my-project/  # Auto-activates
cd ..           # Auto-deactivates
```

**List virtualenvs:**
```bash
pyenv virtualenvs
```

**Delete virtualenv:**
```bash
pyenv uninstall my-project
```

### Olivia Project Environments

The dotfiles pre-configure Python virtual environments for Olivia projects:

**Project-specific environments** (from `shell/zshrc/50-aliases-project.zsh`):

```bash
# Olivia Core (Python 3.11.7)
alias active_core_3117='source ~/.pyenv/versions/olivia-core-3117/bin/activate'

# Olivia UI (Python 3.11.7)
alias active_ui_3117='source ~/.pyenv/versions/olivia-ui-3117/bin/activate'

# Paradox Dev Dependencies
alias active_pydevdeps='source ~/.pyenv/versions/paradox-pydevdeps/bin/activate'
```

**Create these environments:**
```bash
# Install Python 3.11.7 if not present
pyenv install 3.11.7

# Create Olivia Core environment
pyenv virtualenv 3.11.7 olivia-core-3117
pyenv activate olivia-core-3117
cd $OLIVIA_CORE
pip install -r requirements.txt
pyenv deactivate

# Create Olivia UI environment
pyenv virtualenv 3.11.7 olivia-ui-3117
pyenv activate olivia-ui-3117
cd $OLIVIA_UI
pip install -r requirements.txt
pyenv deactivate

# Create shared dev dependencies environment
pyenv virtualenv 3.11.7 paradox-pydevdeps
pyenv activate paradox-pydevdeps
pip install ipython ipdb pytest black ruff mypy
pyenv deactivate
```

**Usage:**
```bash
# Activate Olivia Core environment
active_core_3117

# Now in virtualenv
python manage.py runserver

# Deactivate
deactivate  # Or exit shell
```

### Troubleshooting pyenv

**Python version not switching:**
```bash
# Check pyenv shims in PATH
echo $PATH | grep pyenv

# Restart shell
exec $SHELL

# Verify shims
pyenv which python
```

**Build failures during install:**
```bash
# Install build dependencies (macOS)
brew install openssl readline sqlite3 xz zlib

# Set compiler flags (already in shell/zshrc/00-env.zsh)
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"

# Retry installation
pyenv install 3.12.1
```

**Virtualenv not activating:**
```bash
# Check virtualenv plugin installed
brew list | grep pyenv-virtualenv

# Reinstall if missing
brew install pyenv-virtualenv

# Verify init in shell config
grep virtualenv-init ~/Workday/MacSetup/dotfiles/shell/zshrc/10-packages.zsh
```

**pip install fails:**
```bash
# Ensure pip is up to date
python -m pip install --upgrade pip

# Check SSL certificates
pip config list
# If cert errors, may need to update certifi:
pip install --upgrade certifi
```

## Package Managers

### npm (Node.js)

npm is included with Node.js:

```bash
# Verify npm
npm --version

# Install packages globally
npm install -g typescript
npm install -g eslint

# Project-level packages
cd my-project/
npm install
npm install --save-dev jest
```

### pnpm (Alternative to npm)

pnpm is available via Homebrew (check Brewfile):

```bash
# Install
brew install pnpm

# Usage (same as npm)
pnpm install
pnpm add typescript
pnpm run build
```

### pip (Python)

pip is included with Python via pyenv:

```bash
# Verify pip
pip --version

# Install packages (in active virtualenv)
pip install requests
pip install -r requirements.txt

# Freeze dependencies
pip freeze > requirements.txt

# Upgrade pip
python -m pip install --upgrade pip
```

## Workflow Examples

### Starting a New Node.js Project

```bash
# 1. Create project directory
mkdir my-node-project
cd my-node-project

# 2. Specify Node.js version
echo "20" > .node-version

# 3. Install Node.js (if needed)
fnm install

# 4. Verify version
node --version

# 5. Initialize project
npm init -y
npm install express

# 6. Start coding
nvim index.js
```

### Starting a New Python Project

```bash
# 1. Create project directory
mkdir my-python-project
cd my-python-project

# 2. Create virtualenv
pyenv virtualenv 3.12.1 my-python-project

# 3. Set local version (auto-activates)
pyenv local my-python-project

# 4. Install dependencies
pip install flask pytest

# 5. Freeze requirements
pip freeze > requirements.txt

# 6. Start coding
nvim app.py
```

### Working on Olivia Projects

```bash
# 1. Navigate to project
cd $OLIVIA_CORE

# 2. Activate environment
active_core_3117

# 3. Verify environment
which python
python --version

# 4. Run Django commands
python manage.py check
python manage.py runserver

# 5. Deactivate when done
deactivate
```

### Switching Between Projects

**Node.js:**
```bash
cd project-a/  # .node-version: 18
node --version  # v18.x.x (auto-switched)

cd ../project-b/  # .node-version: 20
node --version  # v20.x.x (auto-switched)
```

**Python:**
```bash
cd project-a/  # .python-version: my-project-a
pyenv version  # my-project-a (auto-activated)

cd ../project-b/  # .python-version: my-project-b
pyenv version  # my-project-b (auto-activated)
```

## Updating Runtimes

### Update Node.js

```bash
# Check for new LTS
fnm install --lts

# List versions
fnm list

# Switch to new version
fnm use <new-version>
fnm default <new-version>

# Remove old versions
fnm uninstall <old-version>
```

### Update Python

```bash
# Install new version
pyenv install 3.13.0

# Set as global default
pyenv global 3.13.0

# Recreate virtualenvs (recommended for major updates)
pyenv virtualenv 3.13.0 my-project-new
pyenv activate my-project-new
pip install -r requirements.txt
```

### Update via Dotfiles

```bash
# Run update script
./install.sh --update

# Or manually
cd ~/Workday/MacSetup/dotfiles
scripts/lang.sh
```

## Best Practices

### Node.js

1. **Use .node-version files** - Commit to version control for consistency
2. **Lock dependencies** - Use `package-lock.json` or `pnpm-lock.yaml`
3. **Global packages sparingly** - Prefer project-local installs
4. **Use LTS versions** - For production projects
5. **Update regularly** - Keep Node.js and npm up to date

### Python

1. **Always use virtualenvs** - Isolate project dependencies
2. **Pin Python versions** - Use `.python-version` files
3. **Freeze requirements** - `pip freeze > requirements.txt`
4. **Separate dev/prod deps** - Use `requirements-dev.txt` for development tools
5. **Update pip first** - `python -m pip install --upgrade pip` before installing packages

### General

1. **Document versions** - Include `.node-version` and `.python-version` in repos
2. **Test upgrades** - Create new virtualenv/install new version before switching
3. **Clean old versions** - Remove unused versions to save disk space
4. **Use doctor script** - Run `scripts/doctor.sh` to verify setup
5. **Commit lock files** - Ensure reproducible builds

## Environment Variables

Key environment variables set in `shell/zshrc/00-env.zsh`:

```bash
# Olivia project roots
export OLIVIA_CORE="/Users/username/Workday/Olivia/SourceCode/olivia-core"
export OLIVIA_UI="/Users/username/Workday/Olivia/SourceCode/olivia"

# Compiler flags for Python builds
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"

# XML security library (for Python saml packages)
export XMLSEC_CFLAGS="-I$(brew --cellar libxmlsec1)/1.2.37/include/xmlsec1"
export XMLSEC_LIBS="-L$(brew --cellar libxmlsec1)/1.2.37/lib"
export PKG_CONFIG_PATH="$(brew --cellar libxmlsec1)/1.2.37/lib/pkgconfig"
```

## Additional Tools

### Language Servers (for Neovim)

Installed via Mason (see [Neovim Setup Guide](./neovim-setup.md)):

- **typescript-language-server** - TypeScript/JavaScript LSP
- **pyright** - Python LSP
- **ruff** - Python linter/formatter

### Formatters & Linters

**Node.js:**
- prettier (code formatter)
- eslint_d (linter)

**Python:**
- ruff (linter + formatter)
- black (formatter)
- mypy (type checker)

## Migration Guides

### From nvm to fnm

```bash
# 1. List nvm versions
nvm list

# 2. Install equivalents in fnm
fnm install 18
fnm install 20
fnm default 20

# 3. Update .nvmrc to .node-version
for dir in ~/projects/*; do
  if [ -f "$dir/.nvmrc" ]; then
    cp "$dir/.nvmrc" "$dir/.node-version"
  fi
done

# 4. Remove nvm (optional)
rm -rf ~/.nvm
# Remove nvm init from .zshrc
```

### From system Python to pyenv

```bash
# 1. Install Python via pyenv
pyenv install 3.12.1

# 2. Set global
pyenv global 3.12.1

# 3. Create virtualenvs for existing projects
cd my-project/
pyenv virtualenv 3.12.1 my-project
pyenv local my-project
pip install -r requirements.txt

# 4. Update scripts to use `python` instead of `python3`
# (pyenv shims handle this)
```

## Related Documentation

- [Shell Configuration Guide](./shell-configuration.md) - Environment setup
- [Neovim Setup Guide](./neovim-setup.md) - LSP and language support
- [VS Code Setup Guide](./vscode-setup.md) - Editor language integration

## Additional Resources

- [fnm Documentation](https://github.com/Schniz/fnm)
- [pyenv Documentation](https://github.com/pyenv/pyenv)
- [pyenv-virtualenv](https://github.com/pyenv/pyenv-virtualenv)
- [Node.js Documentation](https://nodejs.org/docs/latest/api/)
- [Python Documentation](https://docs.python.org/3/)
