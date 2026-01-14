# Docker & Container Setup Guide

This guide covers the Docker and container runtime configuration in this dotfiles repository, including Docker CLI, Colima, OrbStack, and 30+ aliases for streamlined workflows.

## Overview

The repository provides:
- **Docker CLI tools** - docker, docker-compose, docker-buildx
- **Container runtimes** - Colima (lightweight) and OrbStack (premium)
- **30+ Docker aliases** - Common operations streamlined
- **Interactive helpers** - dtool for container access
- **Volume management** - Comprehensive volume utilities
- **Cleanup tools** - System maintenance and pruning
- **Help system** - Built-in command discovery

## Architecture

### Components

```
Container Stack:
├── Docker CLI (brew install docker)
│   ├── docker              # Core CLI
│   ├── docker-compose      # Multi-container orchestration
│   ├── docker-buildx       # Build with BuildKit
│   └── docker-completion   # Shell completions
│
└── Container Runtime (choose one)
    ├── Colima              # Lightweight, Lima-based
    │   └── Lima (VM)       # Linux VM framework
    └── OrbStack           # Premium, fast alternative
```

### File Locations

**Nushell aliases**: `config/nushell/aliases/docker.nu`
**Zsh aliases**: `shell/zshrc/40-aliases-core.zsh` (basic aliases)

## Installation

### Via Brewfile

Everything installs automatically:

```bash
./install.sh --brew
```

This installs (from `Brewfile`):
- docker
- docker-compose
- docker-buildx
- docker-completion
- docker-credential-helper
- colima
- lima
- orbstack (cask)

### Manual Installation

```bash
# Docker CLI tools
brew install docker docker-compose docker-buildx

# Container runtime (choose one)
brew install colima       # Lightweight
brew install --cask orbstack  # Premium GUI
```

## Container Runtimes

### Colima (Recommended for CLI)

**What is Colima?**
- Lightweight container runtime for macOS
- Based on Lima (Linux Virtual Machine)
- Free and open source
- Lower resource usage than Docker Desktop
- CLI-focused

**Start Colima:**
```bash
# Start with defaults (2 CPU, 2GB RAM)
colima start

# Start with custom resources
colima start --cpu 4 --memory 8 --disk 100

# Start with specific architecture
colima start --arch aarch64  # ARM (M1/M2/M3)
colima start --arch x86_64   # Intel/Rosetta

# With Kubernetes (optional)
colima start --kubernetes
```

**Status & Management:**
```bash
# Check status
colima status

# Stop
colima stop

# Delete (removes VM)
colima delete

# SSH into VM
colima ssh

# List instances
colima list
```

**Configuration:**
```bash
# Edit config
colima template
# Creates ~/.colima/default/colima.yaml

# Common settings:
# cpu: 4
# memory: 8
# disk: 100
# runtime: docker
```

**Troubleshooting:**
```bash
# Restart Colima
colima stop
colima start

# Full reset
colima delete
colima start

# Check logs
colima log
```

### OrbStack (Alternative)

**What is OrbStack?**
- Premium container runtime for macOS
- Fast, lightweight, GUI + CLI
- Built-in Docker and Kubernetes
- Better performance than Docker Desktop
- Commercial product (free tier available)

**Start OrbStack:**
```bash
# Launch app (starts automatically)
open -a OrbStack

# Or via CLI
orb start
```

**Management:**
```bash
# Status
orb status

# Settings
orb settings
```

**Features:**
- GUI dashboard
- File sharing performance improvements
- Native Apple Silicon support
- Built-in Kubernetes
- Linux machine support

**Note**: The Brewfile includes both Colima and OrbStack. Choose one for your workflow.

## Basic Docker Aliases

### Core Commands

| Alias | Command | Description |
|-------|---------|-------------|
| `d` | `docker` | Base docker command |
| `dps` | `docker ps` | List running containers |
| `dpsa` | `docker ps -a` | List all containers |
| `di` | `docker images` | List images |
| `drmi` | `docker rmi` | Remove image |
| `drm` | `docker rm` | Remove container |

### Container Management

| Alias | Command | Description |
|-------|---------|-------------|
| `dstart` | `docker start` | Start container |
| `dstop` | `docker stop` | Stop container |
| `drestart` | `docker restart` | Restart container |
| `dkill` | `docker kill` | Kill container |
| `dlogs` | `docker logs` | View logs |
| `dlogsf` | `docker logs -f` | Follow logs (tail -f) |
| `dexec` | `docker exec -it` | Exec into container |
| `dinspect` | `docker inspect` | Inspect container/image |

### Docker Compose

| Alias | Command | Description |
|-------|---------|-------------|
| `dc` | `docker-compose` | Base compose command |
| `dcup` | `docker-compose up` | Start services |
| `dcupd` | `docker-compose up -d` | Start detached |
| `dcdown` | `docker-compose down` | Stop and remove |
| `dcrestart` | `docker-compose restart` | Restart services |
| `dclogs` | `docker-compose logs` | View logs |
| `dclogsf` | `docker-compose logs -f` | Follow logs |
| `dcps` | `docker-compose ps` | List services |
| `dcbuild` | `docker-compose build` | Build images |
| `dcpull` | `docker-compose pull` | Pull images |

### System & Cleanup

| Alias | Command | Description |
|-------|---------|-------------|
| `dprune` | `docker system prune` | Remove unused data |
| `dprunea` | `docker system prune -a` | Remove all unused |
| `ddf` | `docker system df` | Disk usage |

### Volume Management

| Alias | Command | Description |
|-------|---------|-------------|
| `dvls` | `docker volume ls` | List volumes |
| `dvinspect` | `docker volume inspect` | Inspect volume |
| `dvcreate` | `docker volume create` | Create volume |
| `dvrm` | `docker volume rm` | Remove volume |

## Advanced Functions (Nushell)

### Container Shell Access

**dsh** - Exec bash shell:
```bash
dsh my-container
# Equivalent to: docker exec -it my-container /bin/bash
```

**dsha** - Exec sh shell (for Alpine):
```bash
dsha my-alpine-container
# Equivalent to: docker exec -it my-alpine-container /bin/sh
```

### Bulk Operations

**dstopall** - Stop all running containers:
```nushell
dstopall
# Stops all running containers with confirmation
```

**drmall** - Remove all stopped containers:
```nushell
drmall
# Prompts for confirmation before removing
```

**drmdangling** - Remove dangling images:
```nushell
drmdangling
# Removes images tagged as <none>
```

**dcleanall** - Complete Docker cleanup:
```nushell
dcleanall
# Removes:
# - All stopped containers
# - All unused networks
# - All dangling images
# - All build cache
# Requires 'yes' confirmation
```

### Container Toolbox (dtool)

Interactive container access and management:

**Basic usage:**
```bash
# Interactive selection
dtool
# Shows list of running containers, select by number

# Direct access by name
dtool nginx
dtool web-1

# Custom command
dtool nginx /bin/sh
dtool api python manage.py shell
```

**List containers:**
```bash
# List all running
dtool --list
dtool -l

# Filter by name
dtool --list api
dtool -l nginx
```

**Features:**
- Partial name matching
- Interactive selection if no container specified
- Fallback to /bin/bash by default
- Multiple match detection

### Monitoring

**dstats** - Container resource usage:
```nushell
dstats
# Shows CPU, memory, network, and disk I/O for all containers
```

**dlogs-tail** - Tail logs with custom line count:
```nushell
dlogs-tail my-container --lines 50
# Show last 50 lines and follow
```

### Service Updates

**dupdate** - Pull and restart compose service:
```nushell
dupdate api
# 1. Pulls latest image for 'api' service
# 2. Restarts service with new image
```

### Volume Management

**dvlist** - List volumes with details:
```nushell
dvlist
# Table format with name, driver, mountpoint
```

**dvprune** - Remove unused volumes:
```nushell
dvprune
# Shows unused volumes, prompts for confirmation
```

**dvremove** - Remove volume by name:
```nushell
dvremove my-volume
# Supports partial matching, requires confirmation

dvremove my-volume --force
# Skip confirmation
```

**dvinfo** - Inspect volume details:
```nushell
dvinfo my-volume
# Shows JSON inspection in table format
```

**dvcreate-new** - Create volume with options:
```nushell
dvcreate-new my-volume --driver local --label env=prod
```

**dvstats** - Volume usage statistics:
```nushell
dvstats
# Shows total, in-use, and unused volumes
```

## Common Workflows

### Starting a New Project

```bash
# 1. Create docker-compose.yml
cd my-project/
cat > docker-compose.yml <<EOF
version: '3.8'
services:
  web:
    image: nginx:latest
    ports:
      - "8080:80"
  db:
    image: postgres:15
    environment:
      POSTGRES_PASSWORD: password
EOF

# 2. Start services
dcup
# Or detached:
dcupd

# 3. Check status
dcps

# 4. View logs
dclogsf
```

### Debugging Containers

```bash
# 1. List running containers
dps

# 2. Check logs
dlogs my-container
dlogsf my-container  # Follow

# 3. Exec into container
dsh my-container

# 4. Inside container - debug
ls -la
ps aux
env
cat /app/config.yaml

# 5. Check resource usage
dstats

# 6. Inspect container details
dinspect my-container | jq .
```

### Cleanup & Maintenance

```bash
# 1. Stop unnecessary containers
dstop old-container

# 2. Remove stopped containers
drmall

# 3. Remove unused images
drmdangling

# 4. Prune system
dprune  # Conservative
dprunea  # Aggressive (removes all unused)

# 5. Clean volumes
dvprune

# 6. Complete cleanup (be careful!)
dcleanall

# 7. Check disk usage
ddf
```

### Multi-Service Updates

```bash
# 1. Pull latest images
dcpull

# 2. Rebuild if needed
dcbuild

# 3. Restart services
dcdown
dcupd

# Or update single service:
dupdate web
dupdate api
```

### Container Access Patterns

```bash
# Interactive toolbox selection
dtool
# Select from list

# Direct access
dtool web /bin/bash
dtool api python

# List and filter
dtool --list api
dtool -l postgres
```

## Docker Compose Examples

### Basic Web App

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build: .
    ports:
      - "3000:3000"
    environment:
      - NODE_ENV=development
    volumes:
      - .:/app
      - /app/node_modules
    command: npm run dev

  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: myapp
      POSTGRES_USER: user
      POSTGRES_PASSWORD: password
    volumes:
      - postgres_data:/var/lib/postgresql/data

volumes:
  postgres_data:
```

**Usage:**
```bash
dcup          # Start (foreground)
dcupd         # Start (background)
dclogs web    # View web logs
dsh web       # Shell into web container
dcdown        # Stop and remove
```

### Python/Django App

```yaml
version: '3.8'

services:
  django:
    build:
      context: .
      dockerfile: Dockerfile
    command: python manage.py runserver 0.0.0.0:8000
    ports:
      - "8000:8000"
    env_file:
      - .env
    volumes:
      - .:/app
    depends_on:
      - db
      - redis

  db:
    image: postgres:15
    environment:
      POSTGRES_DB: ${DB_NAME}
      POSTGRES_USER: ${DB_USER}
      POSTGRES_PASSWORD: ${DB_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data

  redis:
    image: redis:7-alpine
    ports:
      - "6379:6379"

  celery:
    build: .
    command: celery -A myapp worker -l info
    depends_on:
      - db
      - redis
    env_file:
      - .env

volumes:
  postgres_data:
```

**Usage:**
```bash
dcupd
dclogsf django      # Follow Django logs
dsh django          # Shell into Django
dtool django python manage.py shell  # Django shell
dtool celery        # Celery worker
```

## Troubleshooting

### Colima Won't Start

```bash
# Check status
colima status

# Check for existing VM
colima list

# Delete and recreate
colima delete
colima start

# Check Docker socket
ls -la ~/.colima/default/docker.sock

# Set Docker host (if needed)
export DOCKER_HOST="unix://${HOME}/.colima/default/docker.sock"
```

### Docker Command Not Found

```bash
# Install Docker CLI
brew install docker

# Verify
which docker
docker --version

# If still not found, check PATH
echo $PATH | grep homebrew
```

### Permission Denied

```bash
# Ensure Colima running
colima status

# Check Docker socket permissions
ls -la ~/.colima/default/docker.sock

# Restart Colima
colima restart
```

### Containers Can't Connect to Each Other

```bash
# Check network
docker network ls

# Inspect network
docker network inspect bridge

# Use compose networks (automatic)
# Compose creates a default network for services

# Or create custom network
docker network create my-network
docker run --network my-network ...
```

### Image Pull Fails

```bash
# Check internet connection
ping docker.io

# Check disk space
ddf

# Clean up space
dprune

# Retry with explicit registry
docker pull docker.io/library/nginx:latest
```

### Volumes Not Persisting

```bash
# List volumes
dvls

# Inspect volume
dvinspect my-volume

# Check mount in container
dinspect my-container | jq '.[].Mounts'

# Create named volume in compose
# volumes:
#   - postgres_data:/var/lib/postgresql/data
```

## Best Practices

### Resource Management

1. **Set Colima limits** - Match your machine capacity
2. **Stop when not in use** - `colima stop` to free resources
3. **Regular cleanup** - Run `dprune` weekly
4. **Monitor usage** - Use `dstats` and `ddf`

### Security

1. **Don't use latest tag in production** - Pin versions
2. **Scan images** - Use `docker scan` or Trivy
3. **Minimal base images** - Prefer Alpine variants
4. **Don't run as root** - Use USER in Dockerfile
5. **Secrets management** - Use Docker secrets or env files (not in image)

### Development Workflow

1. **Use .dockerignore** - Exclude node_modules, .git, etc.
2. **Multi-stage builds** - Keep images small
3. **Compose for local dev** - docker-compose.yml for consistency
4. **Volume mounts for code** - Hot reload during development
5. **Named volumes for data** - Persist databases

### Performance

1. **BuildKit** - Already enabled via docker-buildx
2. **Layer caching** - Order Dockerfile to maximize cache hits
3. **Prune regularly** - Remove unused images/containers
4. **Colima resources** - Allocate adequate CPU/RAM
5. **VirtioFS** - Enabled by default in Colima for better file sharing

## Help & Discovery

### Docker Aliases Help (Nushell)

```nushell
help docker
# Shows full list of aliases and functions

help docker compose
# Filter for compose-related commands

help docker volume
# Filter for volume commands
```

### Docker Documentation

```bash
# Docker CLI help
docker --help
docker run --help
docker-compose --help

# Online docs
open https://docs.docker.com
```

## Advanced Topics

### Custom Networks

```bash
# Create network
docker network create --driver bridge my-network

# Run container on network
docker run --network my-network nginx

# Connect existing container
docker network connect my-network existing-container

# Inspect
docker network inspect my-network
```

### BuildKit Advanced Features

```bash
# Enable BuildKit (default in modern Docker)
export DOCKER_BUILDKIT=1

# Build with cache mounts
docker buildx build \
  --cache-from type=registry,ref=myrepo/myimage:cache \
  --cache-to type=registry,ref=myrepo/myimage:cache \
  -t myrepo/myimage:latest .

# Multi-platform builds
docker buildx build --platform linux/amd64,linux/arm64 -t myimage .
```

### Docker Contexts

```bash
# List contexts
docker context ls

# Create context for Colima
docker context create colima --docker "host=unix://${HOME}/.colima/default/docker.sock"

# Switch context
docker context use colima

# Use OrbStack context
docker context use orbstack
```

## Migration from Docker Desktop

If migrating from Docker Desktop to Colima:

```bash
# 1. Stop Docker Desktop
# Quit Docker Desktop app

# 2. Install Colima
brew install colima

# 3. Start Colima with similar resources
colima start --cpu 4 --memory 8 --disk 100

# 4. Verify
docker ps
docker run hello-world

# 5. Import images (optional)
# Docker Desktop images are typically in /var/lib/docker
# Colima stores in ~/.colima/default/docker
```

## Related Documentation

- [Kubernetes Workflows Guide](./kubernetes-workflows.md) - Container orchestration
- [Shell Configuration Guide](./shell-configuration.md) - Alias setup
- [VS Code Setup Guide](./vscode-setup.md) - Docker extension

## Additional Resources

- [Docker Documentation](https://docs.docker.com/)
- [Docker Compose](https://docs.docker.com/compose/)
- [Colima GitHub](https://github.com/abiosoft/colima)
- [OrbStack](https://orbstack.dev/)
- [BuildKit](https://github.com/moby/buildkit)
