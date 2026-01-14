# tap "homebrew/core"
# tap "homebrew/cask"
# tap "homebrew/cask-fonts"

############################################
# Core CLI & Build Toolchain
############################################
brew "abseil"
brew "autoconf"
brew "automake"
brew "ca-certificates"
brew "coreutils"
brew "gettext"            # Provides envsubst, msgfmt, etc.
brew "gmp"
brew "libcbor"
brew "libevent"
brew "libfido2"
brew "libgcrypt"
brew "libgpg-error"
brew "libidn2"
brew "libnghttp2"
brew "libtasn1"
brew "libtool"
brew "libunistring"
brew "libuv"
brew "libxml2"
# brew "libxmlsec1"  # Using custom 1.2.37 version - see scripts/setup-libxmlsec1.sh
brew "libxslt"
brew "lima"
brew "lpeg"
brew "luv"
brew "lz4"
brew "m4"
brew "mpdecimal"
brew "ncurses"
brew "nettle"
brew "openssl@3"
brew "p11-kit"
brew "pkgconf"
brew "protobuf@29"
brew "readline"
brew "sqlite"
brew "telnet"
brew "tree-sitter"
brew "unbound"
brew "unibilium"
brew "utf8proc"
brew "xz"
brew "zlib"
brew "zstd"

############################################
# Shells & Prompt
############################################
brew "carapace"
brew "fzf"                # Fuzzy finder for interactive selection
brew "nushell"
brew "powerlevel10k"
brew "starship"
brew "vivid"
brew "zsh"
brew "tmux"

############################################
# Languages / Runtimes & Version Managers
############################################
brew "fnm"
brew "go"
brew "icu4c@76"           # Old version still present locally (consider cleanup)
brew "icu4c@77"
brew "mas"
brew "mysql-client"
brew "mysql@8.4"
brew "neovim"
brew "gnutls"
brew "libmagic"
brew "pyenv"
brew "pyenv-virtualenv"
brew "python@3.13"
brew "redis"
# brew "sleepwatcher"
brew "uv"                 # Fast Python package installer and resolver

############################################
############################################
# Containers / Cloud / Orchestration
############################################
brew "aws-iam-authenticator"
brew "awscli"
# brew "colima"
brew "eksctl"
brew "helm"
brew "kubernetes-cli"
brew "localstack"
brew "vfkit"

############################################
# Casks: Core GUI Apps
############################################
cask "appcleaner"
# cask "arc"
cask "beekeeper-studio"
cask "claude-code"        # Claude CLI tool
cask "devtoys"
cask "font-meslo-lg-nerd-font"
# cask "hiddenbar"
cask "kitty"
cask "fork"               # Git GUI client
cask "lens"
cask "maccy"
# cask "ngrok"
cask "openkey"
cask "pycharm"
cask "raycast"
cask "redis-insight"
cask "sdm"                # Present locally (secure device mgr?)
cask "stats"
cask "sublime-text"
cask "visual-studio-code"
# cask "warp"

############################################
############################################
# Notes / Guidance (auto-generated from current state)
############################################
# - Duplicate/implicit libs (lib*, gettext, etc.) are often transient dependencies; you can prune from Brewfile to keep it lean.
# - icu4c@76 and icu4c@77 both installed: remove the older if nothing depends: brew uninstall icu4c@76 OR brew autoremove.
# - Using Docker Desktop for container workloads.
# - 'gnu-sed' was in prior Brewfile but not in `brew list`; add back if you depend on gsed-specific flags.
# - 'gh', 'ripgrep', 'fd', 'bat', 'fzf', 'jq', 'pre-commit' appeared previously but are not in current output: reinstall or drop intentionally.
# - Removed gnu-sed since it is not in the current installed list you provided (add back if you need gsed features).
# - Remove any casks you don't actively use to speed up future provisioning.

############################################
# Cleanup helpers
############################################
# Diff current vs Brewfile: brew bundle check --file=./Brewfile
# Prune unlisted (DANGEROUS – review first): brew bundle cleanup --force --file=./Brewfile
