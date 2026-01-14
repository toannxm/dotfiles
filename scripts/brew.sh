#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh"

BREWFILE="$ROOT_DIR/Brewfile"

ensure_homebrew() {
  if ! command -v brew >/dev/null 2>&1; then
    info "Installing Homebrew"
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    if [ -d /opt/homebrew/bin ]; then
      eval "$(/opt/homebrew/bin/brew shellenv)"
    fi
  else
    ok "Homebrew present"
  fi
}

bundle() {
  if [ -f "$BREWFILE" ]; then
    info "Running brew bundle"
    brew bundle --file="$BREWFILE"
  else
    warn "Brewfile not found at $BREWFILE"
  fi
}

setup_libxmlsec1() {
  info "Setting up libxmlsec1 1.2.37"
  if [ -f "$SCRIPT_DIR/setup-libxmlsec1.sh" ]; then
    "$SCRIPT_DIR/setup-libxmlsec1.sh"
  else
    warn "setup-libxmlsec1.sh not found, skipping"
  fi
}

cleanup() { info "brew cleanup"; brew cleanup || true; }

main() {
  ensure_homebrew
  brew update
  bundle
  setup_libxmlsec1
  info "Optionally prune unlisted packages with: brew bundle cleanup --force --file=$BREWFILE"
  cleanup
}

main "$@"
