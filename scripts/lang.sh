#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh"

install_node() {
  if command -v fnm >/dev/null 2>&1; then
    info "Installing Node LTS via fnm"
    fnm install --lts >/dev/null 2>&1 || true
    # set default to latest installed LTS
    LATEST_LTS=$(fnm list | grep -E 'v[0-9]+\.[0-9]+\.[0-9]+' | tail -1 | tr -d ' *')
    [ -n "${LATEST_LTS:-}" ] && fnm default "$LATEST_LTS" || true
  elif [ -d "$HOME/.nvm" ]; then
    # shellcheck source=/dev/null
    . "$HOME/.nvm/nvm.sh"
    info "Installing Node LTS via nvm (consider migrating to fnm for speed)"
    nvm install --lts
    nvm alias default 'lts/*'
  else
    warn "No Node version manager found (brew install fnm)"
  fi
}

install_python() {
  if command -v pyenv >/dev/null 2>&1; then
    local ver="3.12.1"
    if ! pyenv versions --bare | grep -q "$ver"; then
      info "Installing Python $ver"
      pyenv install "$ver"
    fi
    pyenv global "$ver"
  else
    warn "pyenv not installed"
  fi
}


main() {
  install_node
#  install_python
  ok "Language runtimes ready (Node, Python)"
}

main "$@"
