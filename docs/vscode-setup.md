# VS Code Setup Guide

This guide covers the Visual Studio Code configuration in this dotfiles repository, including settings, extensions, and automated setup.

## Overview

The VS Code setup provides:
- **Curated settings** - Editor configuration, formatters, linters
- **Two-tier extensions** - Core (essential) + Optional (situational)
- **Automated installation** - Helper script for setup
- **Language support** - Python, TypeScript, Vue, YAML, Markdown
- **Development tools** - Git, Kubernetes, Docker integration
- **Code quality** - ESLint, Prettier, Ruff, SonarLint

## Architecture

```
config/vscode/
├── settings.json              # Editor settings
├── extensions.json            # Core extension recommendations (33)
├── extensions.optional.json   # Optional extensions (29)
└── snippets/                  # Custom code snippets (if any)

scripts/
└── vscode_apply.sh            # Setup automation script
```

## Installation

### Prerequisites

```bash
# Install VS Code
brew install --cask visual-studio-code

# Install code CLI (if not auto-installed)
# Open VS Code → Command Palette (Cmd+Shift+P) →
# "Shell Command: Install 'code' command in PATH"

# Verify
code --version
```

### Automated Setup

**Default (link config + core extensions):**
```bash
scripts/vscode_apply.sh
```

**Install everything (config + core + optional):**
```bash
scripts/vscode_apply.sh --all
```

**Dry run (preview without changes):**
```bash
scripts/vscode_apply.sh --all --dry-run
```

### Manual Setup

**Link configuration:**
```bash
ln -sf ~/Workday/MacSetup/dotfiles/config/vscode/settings.json \
  "$HOME/Library/Application Support/Code/User/settings.json"
```

**Install core extensions:**
```bash
jq -r '.recommendations[]' config/vscode/extensions.json | \
  xargs -L1 code --install-extension
```

**Install optional extensions:**
```bash
jq -r '.recommendations[]' config/vscode/extensions.optional.json | \
  xargs -L1 code --install-extension
```

### Via Makefile

```bash
# Link + core extensions
make vscode-core

# Optional extensions only
make vscode-optional

# Everything
make vscode-all
```

## Configuration

### Settings (settings.json)

Key configurations:

**Editor:**
- Minimap disabled (cleaner interface)
- Format on save disabled (manual formatting)
- Inline suggestions enabled (Copilot)

**Git:**
- Auto-fetch enabled (5-minute interval)
- GitLens integration

**Python:**
- Ruff for linting and formatting
- Pylance language server
- Debugpy for debugging

**TypeScript/JavaScript:**
- ESLint auto-fix on save
- 4GB max memory for TypeScript server
- PNPM node path integration

**Vue:**
- Volar formatter
- 4GB max memory for Vue server

**Kubernetes:**
- Helm, kubectl, minikube integration
- Custom tool paths for macOS ARM64

**File Exclusions:**
Hidden from explorer:
- `__pycache__`, `.mypy_cache`, `*.pyc`
- `node_modules`, `.git`, `.cache`
- `.idea`, `.editorconfig`, `nbproject`
- `tmp/`, `dist/`, `vendor/`

File watcher exclusions (performance):
- Build directories (`.nuxt`, `.output`, `.nx`)
- Dependencies (`node_modules`, `vendor`)
- Caches (`.eslintcache`, `.mypy_cache`)

### Customizing Settings

Edit `config/vscode/settings.json`:

```json
{
  // Example: Enable format on save
  "editor.formatOnSave": true,

  // Example: Change default formatter for Python
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff"
  },

  // Example: Increase font size
  "editor.fontSize": 14,

  // Example: Enable minimap
  "editor.minimap.enabled": true
}
```

Reload VS Code after changes:
```bash
# Command Palette → "Reload Window"
```

## Extensions

### Core Extensions (33)

**Linting & Formatting:**
- **ESLint** (`dbaeumer.vscode-eslint`) - JavaScript/TypeScript linter
- **Prettier** (`esbenp.prettier-vscode`) - Code formatter
- **Ruff** (`charliermarsh.ruff`) - Fast Python linter/formatter
- **Stylelint** (`stylelint.vscode-stylelint`) - CSS/SCSS linter

**Python:**
- **Python** (`ms-python.python`) - Python language support
- **Pylance** (`ms-python.vscode-pylance`) - Fast language server
- **Debugpy** (`ms-python.debugpy`) - Python debugger

**Git:**
- **GitLens** (`eamodio.gitlens`) - Git supercharged
- **GitHub Copilot** (`github.copilot`) - AI pair programmer
- **Copilot Chat** (`github.copilot-chat`) - AI chat assistant

**Code Quality:**
- **Error Lens** (`usernamehw.errorlens`) - Inline error highlighting
- **SonarLint** (`sonarsource.sonarlint-vscode`) - Code quality and security
- **Code Spell Checker** (`streetsidesoftware.code-spell-checker`) - Spell checking

**Editor Enhancements:**
- **Indent Rainbow** (`oderwat.indent-rainbow`) - Colorize indentation
- **Auto Close Tag** (`formulahendry.auto-close-tag`) - Auto-close HTML/XML tags
- **Auto Rename Tag** (`formulahendry.auto-rename-tag`) - Sync tag renaming
- **Path Intellisense** (`christian-kohler.path-intellisense`) - File path autocomplete

**Language Support:**
- **Vue** (`vue.volar`) - Vue 3 language support
- **UnoCSS** (`antfu.unocss`) - UnoCSS intellisense
- **PostCSS** (`csstools.postcss`) - PostCSS support
- **SCSS** (`mrmlnc.vscode-scss`) - SCSS intellisense
- **YAML** (`redhat.vscode-yaml`) - YAML language support
- **XML** (`redhat.vscode-xml`) - XML language support
- **TOML** (`tamasfe.even-better-toml`) - TOML support

**Data/Config Files:**
- **DotENV** (`mikestead.dotenv`) - .env file highlighting
- **Rainbow CSV** (`mechatroner.rainbow-csv`) - CSV colorization

**Markdown:**
- **Markdown Mermaid** (`bierner.markdown-mermaid`) - Mermaid diagrams
- **Markdownlint** (`davidanson.vscode-markdownlint`) - Markdown linting
- **Mermaid Syntax** (`bpruitt-goddard.mermaid-markdown-syntax-highlighting`) - Syntax highlighting

**TypeScript:**
- **Pretty TypeScript Errors** (`yoavbls.pretty-ts-errors`) - Better error messages

**UI:**
- **Material Icon Theme** (`pkief.material-icon-theme`) - File icons

### Optional Extensions (29)

**Advanced Features:**
- **Kubernetes Tools** (`ms-kubernetes-tools.vscode-kubernetes-tools`) - K8s management
- **Redis** (`redis.redis-for-vscode`) - Redis client
- **Nushell** (`thenuprojectcontributors.vscode-nushell-lang`) - Nushell language

**Vue Ecosystem:**
- **Vue Peek** (`dariofuzinato.vue-peek`) - Jump to Vue components
- **Pinceau** (`yaelguilloux.pinceau-vscode`) - CSS-in-JS for Vue

**Python:**
- **Python Environments** (`ms-python.vscode-python-envs`) - Env manager
- **Python Snippets** (`frhtylcn.pythonsnippets`) - Code snippets
- **PyInit** (`diogonolasco.pyinit`) - __init__.py generator
- **Python Path** (`mgesbert.python-path`) - Python path utilities

**Productivity:**
- **Browse Lite** (`antfu.browse-lite`) - In-editor browser
- **Goto Alias** (`antfu.goto-alias`) - Jump to path aliases
- **Iconify** (`antfu.iconify`) - Icon search
- **Dashboard** (`kruemelkatze.vscode-dashboard`) - Start dashboard
- **TODO Highlight** (`wayou.vscode-todo-highlight`) - Highlight TODOs

**Git:**
- **Git Exclude** (`boukichi.git-exclude`) - Manage .git/info/exclude
- **Gitignore** (`codezombiech.gitignore`) - .gitignore templates

**Other:**
- **Atlassian** (`atlassian.atlascode`) - Jira/Bitbucket integration
- **XML Tools** (`dotjoshjohnson.xml`) - XML formatting
- **Lua Helper** (`yinfei.luahelper`) - Lua development
- **IntelliCode** (`visualstudioexptteam.vscodeintellicode`) - AI-assisted code
- **Angular Console** (`nrwl.angular-console`) - Nx/Angular tools
- **Mermaid Chart** (`mermaidchart.vscode-mermaid-chart`) - Mermaid editor

### Managing Extensions

**List installed:**
```bash
code --list-extensions
```

**Install manually:**
```bash
code --install-extension dbaeumer.vscode-eslint
```

**Uninstall:**
```bash
code --uninstall-extension <extension-id>
```

**Check for updates:**
Open VS Code → Extensions view → ⋯ → "Check for Extension Updates"

## Language Setup

### Python

**Required extensions:**
- Python (`ms-python.python`)
- Pylance (`ms-python.vscode-pylance`)
- Ruff (`charliermarsh.ruff`)
- Debugpy (`ms-python.debugpy`)

**Configuration:**
```json
{
  "[python]": {
    "editor.defaultFormatter": "charliermarsh.ruff",
    "editor.codeActionsOnSave": {
      "source.organizeImports": "explicit"
    }
  }
}
```

**Select interpreter:**
1. Command Palette → "Python: Select Interpreter"
2. Choose pyenv virtualenv (e.g., `olivia-core-3117`)

**Debug configuration** (`.vscode/launch.json`):
```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Python: Django",
      "type": "debugpy",
      "request": "launch",
      "program": "${workspaceFolder}/manage.py",
      "args": ["runserver"],
      "django": true
    }
  ]
}
```

### TypeScript/JavaScript

**Required extensions:**
- ESLint (`dbaeumer.vscode-eslint`)
- Prettier (`esbenp.prettier-vscode`)

**Configuration:**
```json
{
  "[typescript]": {
    "editor.defaultFormatter": "vscode.typescript-language-features"
  },
  "[javascript]": {
    "editor.defaultFormatter": "esbenp.prettier-vscode"
  },
  "editor.codeActionsOnSave": {
    "source.fixAll.eslint": "explicit"
  }
}
```

**Increase memory for large projects:**
```json
{
  "typescript.tsserver.maxTsServerMemory": 4096
}
```

### Vue

**Required extensions:**
- Vue - Official (`vue.volar`)
- UnoCSS (`antfu.unocss`)

**Configuration:**
```json
{
  "[vue]": {
    "editor.defaultFormatter": "Vue.volar",
    "editor.tabSize": 2
  },
  "vue.server.maxOldSpaceSize": 4096,
  "vue.server.hybridMode": false
}
```

## Integrated Terminal

### Shell Configuration

The settings already configure terminal environment:

```json
{
  "terminal.integrated.env.osx": {
    "FIG_NEW_SESSION": "1"
  }
}
```

### Use Nushell in Terminal

1. Command Palette → "Terminal: Select Default Profile"
2. Choose "nu" (Nushell)

Or set in settings:
```json
{
  "terminal.integrated.defaultProfile.osx": "nu"
}
```

## GitHub Copilot

### Setup

1. Install extension: `github.copilot`
2. Sign in: Command Palette → "GitHub Copilot: Sign In"
3. Authenticate via browser

### Usage

**Inline suggestions:**
- Type code, Copilot suggests completions
- Accept: `Tab`
- Reject: `Esc`
- Next suggestion: `Option+]`
- Previous suggestion: `Option+[`

**Copilot Chat:**
- Open panel: Click Copilot icon in sidebar
- Ask questions about code
- Generate code from comments
- Explain code selections

**Slash commands in chat:**
- `/explain` - Explain selected code
- `/fix` - Fix problems in code
- `/tests` - Generate unit tests
- `/doc` - Generate documentation

### Disable Copilot (temporary)

Command Palette → "GitHub Copilot: Disable"

Or in settings:
```json
{
  "github.copilot.enable": {
    "*": false
  }
}
```

## Kubernetes Integration

### Setup

Install optional extension:
```bash
code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
```

**Configuration** (already in settings.json):
```json
{
  "vs-kubernetes": {
    "vscode-kubernetes.helm-path-mac": "~/.vs-kubernetes/tools/helm/darwin-arm64/helm",
    "vscode-kubernetes.kubectl-path-mac": "~/.vs-kubernetes/tools/kubectl/kubectl",
    "vscode-kubernetes.minikube-path-mac": "~/.vs-kubernetes/tools/minikube/darwin-arm64/minikube"
  }
}
```

### Usage

- View clusters: Kubernetes icon in sidebar
- Switch context: Right-click cluster → "Set as Current Cluster"
- View resources: Expand namespaces, pods, services
- Exec into pod: Right-click pod → "Terminal"
- View logs: Right-click pod → "Logs"
- Apply YAML: Right-click file → "Kubernetes: Apply"

## Troubleshooting

### Extensions Not Installing

```bash
# Check code CLI available
which code
code --version

# Install code CLI
# VS Code → Command Palette →
# "Shell Command: Install 'code' command in PATH"

# Check extension marketplace connectivity
code --list-extensions

# Retry with verbose output
code --install-extension dbaeumer.vscode-eslint --force
```

### Settings Not Applied

```bash
# Verify symlink
ls -l "$HOME/Library/Application Support/Code/User/settings.json"

# Should point to: ~/Workday/MacSetup/dotfiles/config/vscode/settings.json

# Re-link
scripts/vscode_apply.sh --link

# Reload window
# Command Palette → "Reload Window"
```

### Python Interpreter Not Found

```bash
# Verify pyenv installed
which pyenv
pyenv versions

# Create virtualenv if needed
pyenv virtualenv 3.12.1 my-project
pyenv local my-project

# Restart VS Code
# Command Palette → "Reload Window"

# Select interpreter
# Command Palette → "Python: Select Interpreter"
```

### ESLint Not Working

```bash
# Install eslint in project
npm install --save-dev eslint

# Create .eslintrc.js
npx eslint --init

# Restart ESLint server
# Command Palette → "ESLint: Restart ESLint Server"

# Check output
# Output panel → "ESLint"
```

### Format on Save Not Working

```json
{
  // Enable globally
  "editor.formatOnSave": true,

  // Or per-language
  "[python]": {
    "editor.formatOnSave": true,
    "editor.defaultFormatter": "charliermarsh.ruff"
  }
}
```

Verify formatter installed:
```bash
# Python: Ruff
code --list-extensions | grep ruff

# JavaScript: Prettier
npm list -g prettier
```

## Customization

### Keybindings

Create `config/vscode/keybindings.json`:

```json
[
  {
    "key": "cmd+k cmd+t",
    "command": "workbench.action.terminal.toggleTerminal"
  },
  {
    "key": "cmd+shift+f",
    "command": "workbench.action.findInFiles"
  }
]
```

Link via setup script (automatically included).

### Snippets

Create snippets in `config/vscode/snippets/`:

**Python example** (`python.json`):
```json
{
  "Django Model": {
    "prefix": "djmodel",
    "body": [
      "class ${1:ModelName}(models.Model):",
      "    ${2:field} = models.${3:CharField}(max_length=${4:100})",
      "    ",
      "    def __str__(self):",
      "        return self.${2:field}"
    ]
  }
}
```

Link via setup script (automatically included).

### Workspace Settings

Create `.vscode/settings.json` in project root:

```json
{
  "python.defaultInterpreterPath": "${workspaceFolder}/.venv/bin/python",
  "editor.rulers": [88],
  "files.exclude": {
    "**/*.pyc": true
  }
}
```

Workspace settings override user settings.

## Best Practices

1. **Use core extensions** - Install all core recommendations
2. **Selective optional** - Only install optional extensions you need
3. **Regular updates** - Update extensions monthly
4. **Workspace configs** - Use for project-specific settings
5. **Commit .vscode/** - Share launch configs, tasks with team
6. **Don't commit .vscode/settings.json** - Unless team-wide standards
7. **Test extensions** - Disable and test if encountering issues
8. **Review settings** - Periodically audit `settings.json` for obsolete config

## Sync Between Machines

### Via Dotfiles

```bash
# Machine 1: Update settings
cd ~/Workday/MacSetup/dotfiles
# Edit config/vscode/settings.json
git add config/vscode/
git commit -m "Update VS Code config"
git push

# Machine 2: Pull changes
cd ~/Workday/MacSetup/dotfiles
git pull
scripts/vscode_apply.sh --link
```

### VS Code Settings Sync

Alternative: Use VS Code's built-in Settings Sync:

1. Sign in with GitHub/Microsoft account
2. Enable: Settings → Turn on Settings Sync
3. Select what to sync (settings, keybindings, extensions)

**Note**: Dotfiles approach is preferred for version control and team sharing.

## Related Documentation

- [Neovim Setup Guide](./neovim-setup.md) - Alternative editor
- [Language Runtimes Guide](./language-runtimes.md) - Python/Node.js setup
- [Shell Configuration Guide](./shell-configuration.md) - Terminal integration

## Additional Resources

- [VS Code Documentation](https://code.visualstudio.com/docs)
- [Extension Marketplace](https://marketplace.visualstudio.com/vscode)
- [VS Code Tips & Tricks](https://code.visualstudio.com/docs/getstarted/tips-and-tricks)
- [GitHub Copilot Docs](https://docs.github.com/en/copilot)
