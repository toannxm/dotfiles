# 🏠 Dotfiles

Personal macOS development environment setup with automated installation of packages, configurations, and developer tools.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/prd-toan-nguyen/dotfiles.git ~/Workday/MacSetup/dotfiles
cd ~/Workday/MacSetup/dotfiles

# Run the full setup
make install
```

## 📦 What's Included

- **Development Tools**: VS Code, Neovim, DataGrip, PyCharm
- **Terminal**: Kitty, Warp, Nushell with custom configurations
- **AI Tools**: Claude Code CLI with cli-proxy integration
- **DevOps**: Docker (OrbStack), Kubernetes tools, SDM
- **Utilities**: CleanShot, Maccy, HiddenBar, Stats

## ⚡ Key Features

### Interactive Shell Commands

- `go2pod` - Interactive Kubernetes pod access with fzf
- `go2sdm` - SDM resource selection and connection  
- `go2http` - Quick HTTP resource access
- `help k8s`, `help sdm` - Built-in help systems

### Smart Automation

- Automatic backup of existing dotfiles
- Homebrew package management via Brewfile
- macOS defaults configuration
- Language runtime setup (Node.js, Python)

## 📚 Documentation

### ⚠️ Special Notes

- **libxmlsec1**: Uses custom version 1.2.37 with openssl@3 compatibility. See [libxmlsec1-fix.md](docs/libxmlsec1-fix.md) for details.


Comprehensive guides for each component:

- **[Shell Configuration](docs/shell-configuration.md)** - Zsh and Nushell setup, aliases, functions, and customization
- **[Neovim Setup](docs/neovim-setup.md)** - AstroNvim configuration, plugins, LSP, and keybindings
- **[Kubernetes Workflows](docs/kubernetes-workflows.md)** - kubectl aliases, ktool, environment access, and K8s best practices
- **[Language Runtimes](docs/language-runtimes.md)** - Node.js (fnm) and Python (pyenv) version management
- **[VS Code Setup](docs/vscode-setup.md)** - Extensions, settings, and editor configuration
- **[Docker & Containers](docs/docker-setup.md)** - Docker, Colima, OrbStack, and container workflows
- **[Claude Code CLI](docs/claude-code-setup.md)** - CLI proxy setup, configuration, and usage

## 🛠️ Installation Options

| Command | Purpose |
|---------|---------|
| `make install` | Full setup (recommended) |
| `make brew` | Install packages only |
| `make link` | Link dotfiles only |
| `make macos` | Apply macOS defaults |
| `make doctor` | Check system health |

## 🔧 Customization

### Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

### Environment Variables

Create local config files (git-ignored):

- `config/nushell/.env` - Environment variables
- `~/.zshrc.local` - Local shell overrides

## 📖 Usage

### Shell Commands

```bash
# Kubernetes
go2pod          # Interactive pod access
kctx            # List contexts
kns             # List namespaces

# SDM
go2sdm          # Interactive resource connection  
go2http         # Quick HTTP resource access

# System
make doctor     # Check system health
make update     # Update packages
```

## 📝 License

MIT License - feel free to use and modify!

```bash
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"
```

Suggested plugins:

```bash
git clone https://github.com/zsh-users/zsh-autosuggestions ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-syntax-highlighting
```

## Features

### Shells

**Zsh** (primary): Modular `.zshrc` composition under `shell/zshrc/*` (environment, aliases, functions, prompt). Create `~/.zshrc.local` for host overrides.

**Nushell** (fully migrated): Complete configuration in `config/nushell/`:

- `env.nu` - Environment variables, PATH setup, tool initialization (fnm, pyenv, Go, Rust)
- `config.nu` - Core configuration and module loading
- `aliases/` - Modular alias files:
  - `core.nu` - Core system aliases
  - `docker.nu` - Docker and container commands
  - `git.nu` - Git shortcuts and workflows
  - `k8s.nu` - Complete kubectl productivity suite (ktool, khelp, all aliases)
  - `sdm.nu` - SDM resource management
  - `olivia.nu` - Project-specific aliases (Django, virtualenv activation/deactivation)
  - `database.nu` - Database utilities
  - `jetbrains.nu` - JetBrains IDE helpers
  - `pyenv_wrapper.nu` - Python environment management

All Zsh functionality has been migrated to Nushell-native syntax. See [NUSHELL_MIGRATION.md](docs/NUSHELL_MIGRATION.md) for migration guide and usage.

Launch Nushell: `nu` (or set as default shell with `chsh -s $(which nu)`)

Enable Starship prompt by uncommenting the hook in `env.nu` after installing `starship`.

### Symlink Management

Backs up existing files with `.backup` suffix before linking.

### macOS Defaults

Applies a conservative set (Finder, Dock, keyboard, screenshots).

### Language Tooling

Installs and/or updates Node LTS (fnm) and Python (pyenv).

### Health & Updates

`doctor.sh` validates key tools; `update.sh` reconciles packages.

### Neovim (AstroNvim)

The Neovim setup uses AstroNvim + community modules via `lazy.nvim` (see `config/nvim`). The link step symlinks the entire directory to `~/.config/nvim`.

Common operations:

```bash
nvim +Lazy sync   # Install / update plugins
nvim              # Launch
```

Extend plugins: add/modify specs under `config/nvim/lua/plugins/`.

Optional host tweaks: create `config/nvim/lua/user_local.lua` (git-ignored) and source it from `polish.lua`.

Sync/diff convenience:

```bash
scripts/nvim_sync.sh --diff   # Show differences
scripts/nvim_sync.sh --pull   # Repo -> local
scripts/nvim_sync.sh --push   # Local -> repo
```

### Nushell Configuration Sync

Sync Nushell configs between dotfiles and active Nushell directory:

```bash
scripts/nushell_sync.sh       # Sync all Nushell configs to active directory
```

Creates timestamped backups in `~/Library/Application Support/nushell/backups/` before syncing.

### Starship Prompt

Custom Starship prompt configuration at `config/starship.toml` with:

- Clean two-line format
- Git branch and status indicators
- Python environment display
- Directory path
- Fast performance (1000ms command timeout for pyenv)

Enable in Nushell by uncommenting the Starship hook in `config/nushell/env.nu`.

### Raycast Configuration

Backup and restore Raycast settings:

```bash
scripts/raycast_sync.sh backup   # Export current Raycast config
scripts/raycast_sync.sh restore  # Import repo config to Raycast
scripts/raycast_sync.sh diff     # Show differences
```

Files backed up:
- `config/raycast/com.raycast.macos.plist` - Preferences
- `config/raycast/extensions.txt` - Installed extensions

### Kubernetes (kubectl) Productivity

Kubectl productivity aliases & the `ktool` environment toolbox are defined in `shell/kubectl/aliases.zsh` and auto‑sourced by `.zshrc`.

Core aliases:

```text
k              # kubectl
kgp            # get pods
kgs            # get services
kgn            # get nodes
kgi            # get ingress
kl / klf / klp # logs / follow / previous crash
kapply / kdel  # apply -f / delete -f
kbuild / kapplyk # kustomize build / apply -k
kgpw / kgsw    # wide views
ktop / ktopn   # top pods / nodes
kdiff          # server-side diff
kgevents       # events sorted
kcounts        # summary counts
```

Pods mode:

```bash
ktool <env> --pods [filter]  # list pods (case-insensitive filter optional)
ktool --pods [filter]        # list pods in current context namespace
```

Discovery / help:

```bash
ktool --help     # show env taxonomy & examples
khelp            # tabular list of all kubectl shortcuts
khelp pods       # filter help table for 'pods'
kaliases         # alias of khelp
```

Cleanup / utilities:

```bash
kcleanpods                     # delete succeeded/failed pods
kpf <pod> 8080:80              # port-forward local:remote
kcounts                        # counts (pods/deployments/services)
kgl app=my-label               # get pods by label selector
```

To modify pod/container mapping open `shell/kubectl/aliases.zsh` and edit the `ktool()` case blocks. Add new tenants by following existing patterns (ensure naming consistency).

### VS Code Integration

Two-tier extension recommendation set (core vs optional) plus automation.

Files:

```text
config/vscode/settings.json            # Editor & formatting defaults
config/vscode/extensions.json          # Core extension recommendations
config/vscode/extensions.optional.json # Optional / situational tools
scripts/vscode_apply.sh                # Helper to link + install
```

Helper script usage:

```bash
# Default (link config + core extensions)
scripts/vscode_apply.sh

# Everything (link + core + optional)
scripts/vscode_apply.sh --all

# Dry run
scripts/vscode_apply.sh --all --dry-run
```

Make targets:

```bash
make vscode-core      # link + core
make vscode-optional  # optional only
make vscode-all       # link + core + optional
```

Optional bulk optional install (without helper script):

```bash
jq -r '.recommendations[]' config/vscode/extensions.optional.json | xargs -L1 code --install-extension
```

If the `code` CLI is missing: open VS Code → Command Palette → "Shell Command: Install 'code' command in PATH".

## Make Targets

| Target | Action |
|--------|--------|
| install | Full bootstrap (`./install.sh --all`) |
| brew | Apply Brewfile |
| dotfiles | Create/update symlinks |
| macos | Apply macOS defaults |
| lang | Language runtimes (fnm, pyenv) |
| update | Update packages & runtimes |
| doctor | Health checks |
| vscode-core | Link + core VS Code extensions |
| vscode-optional | Install optional VS Code extensions |
| vscode-all | Link + core + optional extensions |
| clean-backups | Delete created `.backup` files |

## Customization

- Zsh theme: edit `ZSH_THEME` in `.zshrc`.
- Local overrides: create `~/.zshrc.local` (ignored) for machine-specific changes.
- Aliases / functions: extend future `shell/aliases.zsh` etc.
- Git identity: set via `git config --global` after bootstrap.
- Brew packages: edit `Brewfile` then run `./install.sh --brew`.

## Backups & Restore

Original files renamed with `.backup`. Restore example:

```bash
mv ~/.zshrc.backup ~/.zshrc
```

List backups:

```bash
find ~ -maxdepth 3 -name '*.backup'
```

## Troubleshooting

| Symptom | Fix |
|---------|-----|
| `command not found: code` | Launch VS Code → Command Palette → Install 'code' command |
| Node not found after lang step | Open a new shell so fnm PATH initialization runs |
| Pyenv shims not active | Ensure `pyenv` installed (check Brewfile) and restart shell |
| Neovim missing plugins | Run `nvim +Lazy sync` |
| Extensions drift in VS Code | Re-run `scripts/vscode_apply.sh --all` |
| Backups clutter home | Run `make clean-backups` after verifying symlinks |

## Roadmap

- Extension prune command (remove non-declared extensions)
- SSH + GPG key generation helper
- Optional Starship / p10k prompt config
- Shellcheck + CI pipeline
- Timestamped backup / restore tool
- Nushell & Neovim sync/diff helper script (partially implemented via `nvim_sync.sh`)

## License

MIT

## DataGrip Sync

Store sanitized JetBrains DataGrip data source & schema configs for reproducible IDE setup. Passwords and secrets are stripped; re-enter them inside DataGrip.

Files:

```text
config/datagrip/dataSources.xml.example        # Sanitized dataSources.xml
config/datagrip/dataSources.local.xml.example  # Sanitized schema selection
scripts/datagrip_sync.sh                       # Export / import / diff / backup
```

Usage:

```bash
# Export current DataGrip configs (strips passwords) into repo examples
scripts/datagrip_sync.sh export
git diff  # review changes

# Import repo examples into DataGrip (backs up originals)
scripts/datagrip_sync.sh import

# Show differences between IDE and repo
scripts/datagrip_sync.sh diff

# Backup only
scripts/datagrip_sync.sh backup
```

How it works:

- Locates latest DataGrip options directory under `~/Library/Application Support/JetBrains/DataGrip*/options`.
- Exports `dataSources.xml` and `dataSources.local.xml` to `config/datagrip/*.example` removing password/secret lines.
- Import backs up existing IDE files to a timestamped directory, then copies examples in place.
- Does not store passwords; placeholders must be set inside DataGrip UI after import.

Recommended workflow:

1. Configure / update data sources in DataGrip.
2. Run `export` and commit diff.
3. On a new machine, run `import` then fill credentials.

Future enhancements (optional):

- Secret encryption using `age` or `gpg` for a separate encrypted file.
- `doctor.sh` check ensuring DataGrip config matches repo.
- JSON summary extraction of data source names.
- Integration with other JetBrains IDEs sharing data sources.

## Claude Code CLI Integration

Claude Code CLI is integrated with a local proxy server (cli-proxy) for unified AI model access.

### Setup

**Files:**

```text
config/claude/settings.json  # Claude Code configuration
config/claude/cli-proxy      # Local proxy binary
config/claude/.env           # Environment variables (git-ignored)
~/.cli-proxy/config.json     # Proxy configuration
```

**Configuration:**

The cli-proxy provides an OpenAI-compatible API endpoint that aggregates multiple AI providers (GitHub Copilot, Anthropic, etc.) into a single interface.

1. **Remove quarantine** (if downloaded from external source):
```bash
xattr -d com.apple.quarantine config/claude/cli-proxy
```

2. **Configure providers** in `~/.cli-proxy/config.json`:
```json
{
  "port": 6979,
  "providers": [
    {
      "name": "copilot",
      "enabled": true,
      "githubToken": "",
      "accountType": "individual"
    },
    {
      "name": "anthropic",
      "enabled": true,
      "apiKey": "YOUR_API_KEY_HERE"
    }
  ],
  "apiKeys": ["proxypal-local"]
}
```

3. **Set tier mappings** (optional) in `config/claude/.env`:
```bash
TIER_MAPPINGS_URL=https://gist.githubusercontent.com/PhuongTMR/bcf7947b6cea4bfaf620b142b9b6eefe/raw
```

**Usage:**

```bash
# Start the proxy
./config/claude/cli-proxy

# Or run as daemon
./config/claude/cli-proxy -d

# Install as startup service
./config/claude/cli-proxy -install

# Check status
./config/claude/cli-proxy -status

# View logs
./config/claude/cli-proxy -logs

# Stop service
./config/claude/cli-proxy -stop
```

**Features:**

- **Unified API**: Single endpoint for multiple AI providers
- **Model tier mappings**: Automatic classification (fast/balanced/advanced)
- **Auto-mode**: Intelligent model selection based on task complexity
- **Web dashboard**: Monitor usage and manage providers at `http://localhost:6979`
- **Service management**: Run as background daemon or startup service

**Environment Variables** (in `config/claude/settings.json`):

- `ANTHROPIC_BASE_URL`: Proxy endpoint (http://127.0.0.1:6979)
- `ANTHROPIC_MODEL`: Model to use (e.g., cli-proxy-automode, gpt-4)
- `CLAUDE_CODE_MAX_OUTPUT_TOKENS`: Maximum response tokens (128000)

For more details, run `./config/claude/cli-proxy --help`
