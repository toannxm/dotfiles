# 🏠 Dotfiles

Personal macOS development environment setup with automated installation of packages, configurations, and developer tools. Features a complete Nushell migration with enhanced productivity tools, Docker volume management, and comprehensive database utilities.

## 🚀 Quick Start

```bash
# Clone the repository
git clone https://github.com/yourusername/dotfiles.git ~/Workday/MacSetup/dotfiles
cd ~/Workday/MacSetup/dotfiles

# Run the full setup
make install
```

## 📦 What's Included

### Development Tools
- **Editors**: VS Code, Neovim (AstroNvim), DataGrip, PyCharm
- **Terminal**: Kitty, Nushell with custom configurations
- **AI Tools**: Claude Code CLI with cli-proxy integration

### DevOps & Cloud
- **Containers**: Docker Desktop, Docker Compose
- **Kubernetes**: kubectl, helm, eksctl, aws-iam-authenticator
- **Cloud**: AWS CLI, LocalStack, StrongDM

### Databases
- **MySQL 8.4** with custom utilities
- **Redis**, **MongoDB**, **Elasticsearch**
- Complete backup/restore system

### Modern CLI Tools
- **File operations**: `bat` (cat), `fd` (find), `rg` (ripgrep)
- **Shell**: Nushell, Zsh with Oh My Zsh, Tmux
- **Utilities**: `fzf`, `vivid`, `carapace`, `uv` (Python packages)

### macOS Apps
- **Productivity**: Raycast, CleanShot, Maccy, HiddenBar, Stats
- **Browsers**: Arc, Chrome, Firefox

## ⚡ Key Features

### 🎨 Visual Theme
- **Catppuccin Mocha** theme throughout all tools
- Color-coded status indicators (green=healthy, yellow=pending, red=error)
- Custom fzf integration with matching colors
- Starship prompt with beautiful formatting

### 🐳 Docker Volume Management

Complete backup and restore system for Docker volumes:

```bash
# Backup all Docker volumes to compressed archives
./docker/backup-volumes.sh

# Restore volumes from backups
./docker/restore-volumes.sh
```

**Managed Volumes:**
- MySQL data (`paradox-mysql.tar.gz`)
- MongoDB data (`paradox-mongo.tar.gz`)
- Redis data (`paradox-redis.tar.gz`)
- Elasticsearch data (`paradox-elasticsearch.tar.gz`)
- LocalStack data (`paradox-localstack.tar.gz`)
- ES snapshots (`paradox-es-snapshots.tar.gz`)

### 🗄️ Database Utilities

Powerful MySQL management commands in Nushell:

```bash
# Clone database schema (no data) for testing
clone_db_test applydb_prod test_applydb_prod

# Export database to timestamped SQL file
export_db my_database

# Import SQL file with optional DB creation
import_db my_database backup.sql --create

# Flush memcached
del_cache
```

Features:
- Schema-only cloning for safe testing
- Automatic Django migrations table copy
- Docker container support
- Progress bars with `pv`
- Secure credential handling

### ☸️ Enhanced Kubernetes Workflows

**`go2pod`** - Interactive pod access with intelligent caching:

```bash
go2pod          # Use 1-day cached data (fast)
go2pod --fresh  # Fetch fresh data
```

Features:
- 🎯 **Smart caching** (1-day TTL) for instant context/namespace/pod selection
- 🎨 **Color-coded status** indicators throughout
- 🔍 **Multi-step workflow**: Context → Namespace → Pod → Container
- 🚀 **Automatic shell detection** (bash/sh fallback)
- 📊 **Rich metadata display** (ready status, restarts, age, node info)
- 🧹 **Cache management**: `clear-k8s-cache` command

**Additional K8s Commands:**
```bash
kctx / ?ctx        # List contexts with current indicator
kns / ?ns          # List namespaces with status
kpods <ns>         # List pods with full metadata
help k8s           # Complete K8s help with color legend
```

### 💪 StrongDM Integration

Interactive SDM resource management:

```bash
go2sdm             # Interactive resource selection
go2http            # Quick HTTP resource access

# Daemon management
sdm is-running     # Check daemon status
sdm start-daemon   # Start daemon
sdm stop-daemon    # Stop daemon
sdm restart-daemon # Restart daemon
```

### 📚 Built-in Help System

Every module has comprehensive help:

```bash
help aliases       # Master list of all help topics
help core          # Core utilities and navigation
help git           # Git shortcuts and workflows
help docker        # Docker and compose commands
help database      # MySQL utilities
help k8s           # Kubernetes helpers
help olivia        # Project-specific commands
help sdm           # StrongDM CLI
help jetbrains     # IDE utilities
```

## 🔧 Configuration

### Environment Variables

Key environment variables in `config/nushell/env.nu`:

**Project Paths:**
```bash
OLIVIA_ROOT     # Project root directory
OLIVIA_CORE     # Backend (Django)
OLIVIA_UI       # Frontend (Nuxt)
OLIVIA_DOCKER   # Docker compose files
OLIVIA_FF       # Feature flags service
```

**MySQL Configuration:**
```bash
MYSQL_USER      # Default: "root"
MYSQL_HOST      # Default: "127.0.0.1"
MYSQL_PORT      # Default: "3306"
MYSQL_PASSWORD  # Default: "root"
```

**Security & Cloud:**
```bash
NODE_EXTRA_CA_CERTS  # Zscaler root CA certificate path
AWS_PROFILE          # AWS profile name (default: "default")
```

**Build Flags (libxmlsec1):**
```bash
XMLSEC_CFLAGS   # Custom libxmlsec1 1.2.37 include paths
XMLSEC_LIBS     # Custom libxmlsec1 library paths
PKG_CONFIG_PATH # pkg-config search paths
```

**Local Overrides:**
Create `config/nushell/.env` (git-ignored) for sensitive values:
```bash
export MYSQL_PASSWORD="your_password"
export SDM_EMAIL="your.email@company.com"
```

### Git Configuration

```bash
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"
```

**SSH Key Management:**
```bash
ssh_toannguyen_prd  # Switch to work SSH key
ssh_toannxm         # Switch to personal SSH key
```

## 🐚 Shell - Nushell

Complete Nushell migration with modular configuration:

### Configuration Structure

```
config/nushell/
├── env.nu              # Environment variables, PATH, tool initialization
├── config.nu           # Core config and module loading
├── common.nu           # Shared utilities (colors, fzf theme)
├── .env               # Local overrides (git-ignored)
├── aliases/
│   ├── core.nu        # System navigation and modern CLI tools
│   ├── docker.nu      # Docker and compose commands
│   ├── git.nu         # Git shortcuts and workflows
│   ├── k8s.nu         # Kubernetes helpers with caching
│   ├── database.nu    # MySQL utilities
│   ├── sdm.nu         # StrongDM management
│   ├── olivia.nu      # Project-specific commands
│   ├── jetbrains.nu   # IDE utilities
│   └── pyenv_wrapper.nu # Python environment management
├── env.d/
│   ├── carapace.nu    # Shell completion
│   ├── pyenv.nu       # Python environment
│   └── starship.nu    # Prompt initialization
└── style/
    ├── carapace.nu    # Completion styling
    └── ls_colors.nu   # Directory colors
```

### Core Aliases (`help core`)

**Navigation:**
```bash
ll, la, l       # ls variations (long, all, simple)
.., ..., ....   # Navigate up 1, 2, 3 directories
cls             # Clear screen
```

**Modern CLI Replacements:**
```bash
grep → rg       # Ripgrep (faster search)
cat → bat       # Syntax highlighting
find → fd       # Faster file finding
```

**Editors:**
```bash
vi, vim → nvim  # Neovim
nano → micro    # Micro editor
nuconfig        # Edit nushell config in VS Code
nuenv           # Edit nushell env in VS Code
```

**System:**
```bash
kill-port / kp  # Kill process on port
reload          # Reload Nushell config
restart         # Fresh Nushell session
dotfiles        # Git wrapper for dotfiles repo
```

### Docker Aliases (`help docker`)

**Basic Commands:**
```bash
d               # docker
dps             # ps
dpsa            # ps -a
di              # images
drmi            # rmi
drm             # rm
```

**Management:**
```bash
dstart          # start
dstop           # stop
drestart        # restart
dkill           # kill
dlogs           # logs
dlogsf          # logs -f (follow)
dexec           # exec -it
dsh             # exec -it <container> /bin/sh
dsha            # exec -it <container> /bin/bash
```

**Docker Compose:**
```bash
dc              # docker compose
dcup            # up
dcupd           # up -d
dcdown          # down
dcrestart       # restart
dcstop          # stop
dcstart         # start
dclogs          # logs
dclogsf         # logs -f
dcps            # ps
dcbuild         # build
dcpull          # pull
```

**System Maintenance:**
```bash
dprune          # system prune
dprunea         # system prune -a
ddf             # system df
dcleanall       # Remove all containers, images, volumes
dstopall        # Stop all running containers
drmall          # Remove all stopped containers
```

**Volume Management:**
```bash
dvls            # volume ls
dvinspect       # volume inspect
dvprune         # volume prune
dvremove        # volume rm
dvstats         # Show volume disk usage
```

### Git Aliases (`help git`)

**Status & Info:**
```bash
gst             # status
gss             # status -s (short)
gbr             # branch
gco / gck       # checkout
gci             # commit
gcia            # commit --amend
```

**Logs:**
```bash
glg             # log --graph --oneline
glga            # log --graph --all
gls             # log --stat
glast           # show last commit
gll             # log --pretty=format (detailed)
```

**Diff:**
```bash
gdf             # diff
gdc             # diff --cached
gdword          # diff --word-diff
gdw             # diff --word-diff=color
```

**Remote:**
```bash
gpll            # pull
gpln            # pull --no-rebase
gf              # fetch
gfa             # fetch --all
gpsh            # push
gpf             # push --force-with-lease
```

**Cleanup:**
```bash
gunstage        # restore --staged
grsh            # reset HEAD
grs1            # reset HEAD~1
del_branch [--all]  # Delete merged branches
gprune          # Prune remote tracking branches
```

### Olivia Project (`help olivia`)

**Navigation:**
```bash
olivia-core     # cd to core project
olivia-ui       # cd to UI project
paradox-docker  # cd to docker configs
```

**Setup:**
```bash
olivia-app-nuxt3      # Run Nuxt 3 dev server
olivia-app-nuxt2      # Run Nuxt 2 dev server
olivia-app-django     # Run Django dev server
olivia-celery         # Start Celery worker
```

**Virtual Environments:**
```bash
create-olivia-venvs [version]  # Create venvs for core & UI
activate-core                   # Activate core venv
activate-ui                     # Activate UI venv
deactivate-venv                # Deactivate venv
```

**Django Management:**
```bash
migrate                        # Run migrations
makemigrations                 # Create migrations
makemigrations_merge           # Merge migrations
```

**Logs:**
```bash
log_core        # Tail core logs
log_ui          # Tail UI logs
del_log         # Truncate all project logs
```

### JetBrains Utilities (`help jetbrains`)

```bash
reset-jetbrains-trial --name <product>  # Reset trial period
# Available: pycharm, datagrip, idea, webstorm, etc.
```

## 🛠️ Installation Options

| Command | Purpose |
|---------|---------|
| `make install` | Full setup (recommended for new machines) |
| `make brew` | Install/update Homebrew packages |
| `make link` | Symlink dotfiles to home directory |
| `make macos` | Apply macOS system defaults |
| `make lang` | Setup language runtimes (Node.js, Python) |
| `make doctor` | Run 23 health checks |
| `make update` | Update all packages and runtimes |
| `make vscode-core` | Install core VS Code extensions |
| `make vscode-all` | Install all VS Code extensions |

## 📚 Documentation

Comprehensive guides for each component:

- **[Shell Configuration](docs/shell-configuration.md)** - Zsh and Nushell setup, aliases, functions
- **[Neovim Setup](docs/neovim-setup.md)** - AstroNvim configuration, plugins, LSP, keybindings
- **[Kubernetes Workflows](docs/kubernetes-workflows.md)** - kubectl shortcuts, environment access
- **[Language Runtimes](docs/language-runtimes.md)** - Node.js (fnm) and Python (pyenv) management
- **[VS Code Setup](docs/vscode-setup.md)** - Extensions, settings, editor configuration
- **[Docker Setup](docs/docker-setup.md)** - Docker Desktop and container workflows
- **[libxmlsec1 Fix](docs/libxmlsec1-fix.md)** - Custom libxmlsec1 1.2.37 with openssl@3

## 🎯 Usage Examples

### Kubernetes Workflow
```bash
# Interactive pod access with caching
go2pod

# Force fresh data
go2pod --fresh

# Quick commands
kctx                    # List contexts
kns                     # List namespaces
kpods olivia-dev        # List pods in namespace

# Clear cache if needed
clear-k8s-cache
```

### Database Operations
```bash
# Clone production schema for testing
clone_db_test prod_db test_db

# Export database
export_db my_database ./backups/backup.sql

# Import with DB creation
import_db new_database backup.sql --create

# Work with Docker containers
export_db my_db --container paradox_mysql
```

### Docker Management
```bash
# Backup all volumes
./docker/backup-volumes.sh

# View running containers
dps

# Follow logs
dclogsf service_name

# Clean up system
dprune
```

### Git Workflow
```bash
# Status
gst

# Stage and commit
git add .
gci -m "feat: add new feature"

# View log
glg

# Push
gpsh

# Clean merged branches
del_branch
```

## 🔍 Health Checks

Run comprehensive system validation:

```bash
make doctor
```

**Checks 23 items including:**
- Homebrew installation and health
- Shell configurations (Zsh, Nushell)
- Language runtimes (Node.js, Python, Go, Rust)
- Development tools (Git, Docker, VS Code, Neovim)
- Cloud tools (AWS CLI, kubectl, SDM)
- Database clients (MySQL, Redis)
- Symlink integrity

## 🎨 Customization

### Starship Prompt

Custom prompt configuration at `config/starship.toml`:

Features:
- Clean two-line format with Catppuccin Mocha colors
- OS icon, username, directory path
- Git branch and status indicators
- Language runtime display (Node.js, Python)
- Execution time for long commands
- Fast performance (optimized file detection)

Enable in Nushell:
```nushell
# Already enabled in config/nushell/env.d/starship.nu
source ($DOTFILES_ENV | path join "starship.nu")
```

### Raycast Configuration

Backup and restore Raycast settings:

```bash
scripts/raycast_sync.sh backup   # Export current config
scripts/raycast_sync.sh restore  # Import from repo
scripts/raycast_sync.sh diff     # Show differences
```

### DataGrip Sync

Store sanitized DataGrip datasource configs:

```bash
scripts/datagrip_sync.sh export  # Export (strips passwords)
scripts/datagrip_sync.sh import  # Import (backs up originals)
scripts/datagrip_sync.sh diff    # Show differences
```

Files stored in `config/datagrip/*.example` with passwords removed.

## 🔐 Security Notes

### Before Making Public

1. **Remove `.env` file from git**:
   ```bash
   git rm --cached config/nushell/.env
   ```

2. **Check git history** for sensitive data:
   ```bash
   git log --all --full-history -- config/nushell/.env
   ```

3. **Sanitize company references** (optional):
   - `OLIVIA_*` project variables
   - Company email addresses
   - Project-specific naming

### What's Safe
- ✅ Environment variable references (no actual passwords)
- ✅ Default values (all generic)
- ✅ Configuration structure
- ✅ Tool versions and setup scripts

### .gitignore Coverage
```gitignore
# Sensitive files
config/nushell/.env
config/nushell/.env.local
.env
.env.local

# Backups
*.tar.gz
*.sql
*.dump

# Cache
.cache/
```

## 📦 Brewfile Packages

Key packages installed via Homebrew:

**Shells & Terminal:**
- Nushell, Zsh, Tmux, Kitty

**Languages:**
- Python 3.13, Node.js (via fnm), Go, Rust

**Databases:**
- MySQL 8.4, Redis

**Kubernetes:**
- kubectl, helm, eksctl, aws-iam-authenticator

**Cloud:**
- AWS CLI, LocalStack

**Modern CLI:**
- bat, fd, ripgrep, fzf, vivid, carapace, eza, jq, yq

**Custom:**
- libxmlsec1 1.2.37 (OpenSSL@3 compatible)

## 🚀 Advanced Features

### Catppuccin Mocha Theme

Consistent color scheme across all tools:

**Colors:**
- 🟢 Green (`#a6e3a1`) - Healthy/Running/Active
- 🟡 Yellow (`#f9e2af`) - Pending/Warning/Progressing
- 🔴 Red (`#f38ba8`) - Failed/Error/Crashed
- 🔵 Blue (`#89b4fa`) - Info/Current/Selected
- ⚫ Gray (`#585b70`) - Unknown/Terminating

**Applied to:**
- Starship prompt
- Nushell completions (Carapace)
- fzf interface
- K8s status indicators
- All help text
- Git branch displays

### FZF Integration

Custom fzf configuration in `config/nushell/common.nu`:

```nushell
$FZF_COLORS     # Catppuccin Mocha colors
$FZF_POINTER    # 👉🏼 emoji
$FZF_MARKER     # ✓ symbol
```

Used in:
- `go2pod` - Context/namespace/pod selection
- `go2sdm` - Resource selection
- Any interactive selection

### Cache System

Intelligent caching in `go2pod`:

```nushell
CACHE_TTL_MINUTES = 1440  # 24 hours
```

**Cache location:** `~/.cache/nushell/k8s/`

**Cached data:**
- Kubernetes contexts
- Namespaces per context
- Pods per namespace

**Management:**
```bash
clear-k8s-cache           # Clear all
clear-k8s-cache contexts  # Clear specific key
go2pod --fresh           # Bypass cache
```

## 🔄 Maintenance

### Update All Packages
```bash
make update
```

Updates:
- Homebrew packages
- Homebrew cask apps
- Node.js LTS (via fnm)
- Python packages (via pyenv)
- Neovim plugins (via Lazy)

### Cleanup
```bash
make clean-backups  # Remove .backup files
dcleanall          # Docker cleanup
dprune             # Docker system prune
```

### Backup Your Config
```bash
# Dotfiles
git add .
git commit -m "backup: $(date +%Y-%m-%d)"
git push

# Docker volumes
./docker/backup-volumes.sh

# DataGrip settings
scripts/datagrip_sync.sh export

# Raycast settings
scripts/raycast_sync.sh backup
```

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| `command not found: code` | VS Code → Command Palette → "Install 'code' command" |
| Node not found after install | Open new shell for fnm initialization |
| Pyenv shims not working | Check Brewfile has pyenv, restart shell |
| Neovim plugins missing | Run `nvim +Lazy sync` |
| Docker volume restore fails | Check Docker is running, volumes don't exist |
| K8s context not switching | Run `go2pod --fresh` to bypass cache |
| Database import fails | Verify MySQL running, check credentials |
| fzf not found | Run `make brew` to install |

## 📝 Scripts Reference

| Script | Purpose |
|--------|---------|
| `install.sh` | Main installation orchestrator |
| `scripts/brew.sh` | Homebrew setup and bundle |
| `scripts/doctor.sh` | System health checks (23 tests) |
| `scripts/lang.sh` | Language runtime setup |
| `scripts/link.sh` | Symlink dotfiles |
| `scripts/update.sh` | Update packages |
| `scripts/preflight.sh` | Pre-installation checks |
| `scripts/datagrip_sync.sh` | DataGrip config management |
| `scripts/raycast_sync.sh` | Raycast backup/restore |
| `scripts/vscode_apply.sh` | VS Code config and extensions |
| `scripts/setup-libxmlsec1.sh` | Custom libxmlsec1 install |
| `docker/backup-volumes.sh` | Backup Docker volumes |
| `docker/restore-volumes.sh` | Restore Docker volumes |

## 🎓 Learning Resources

### Nushell
- [Official Book](https://www.nushell.sh/book/)
- [Cookbook](https://www.nushell.sh/cookbook/)
- Run `help aliases` for built-in help

### Starship
- [Configuration](https://starship.rs/config/)
- Edit: `config/starship.toml`

### Neovim
- [AstroNvim Docs](https://docs.astronvim.com/)
- Config: `config/nvim/`
- Run `:checkhealth` in Neovim

## 🗺️ Roadmap

- [ ] Automated security scanning for sensitive data
- [ ] CI/CD pipeline for validation
- [ ] Additional shell themes
- [ ] PostgreSQL utilities
- [ ] Kubernetes resource templates
- [ ] Extension pruning for VS Code
- [ ] SSH/GPG key generation helpers
- [ ] Automated backup scheduling

## 📄 License

MIT License - Feel free to use and modify!

## 🙏 Acknowledgments

- **Catppuccin** - Beautiful color themes
- **AstroNvim** - Amazing Neovim distribution
- **Nushell** - Modern shell for the modern age
- **Starship** - Fast, customizable prompt
- **Homebrew** - Package management for macOS
