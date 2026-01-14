#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh"

info "Updating Homebrew packages"
if command -v brew >/dev/null 2>&1; then
  brew update && brew upgrade && brew cleanup
  [ -f "$ROOT_DIR/Brewfile" ] && brew bundle --file="$ROOT_DIR/Brewfile"
else
  warn "Homebrew not installed"
fi

info "Updating Node (nvm)"
if [ -d "$HOME/.nvm" ]; then
  # shellcheck source=/dev/null
  . "$HOME/.nvm/nvm.sh"
  nvm install --lts >/dev/null 2>&1 || true
  nvm use --lts >/dev/null 2>&1 || true
  npm update -g || true
fi

info "Refreshing pyenv shims"
if command -v pyenv >/dev/null 2>&1; then
  pyenv rehash || true
fi

ok "Update complete"
