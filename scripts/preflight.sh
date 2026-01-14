#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh" 2>/dev/null || true

info "Preflight checks (safe to re-run)"

ARCH="$(uname -m)"
MACOS_VER="$(sw_vers -productVersion || echo unknown)"
info "Architecture: $ARCH | macOS: $MACOS_VER"

# 1. Xcode Command Line Tools
if xcode-select -p >/dev/null 2>&1; then
  ok "Xcode Command Line Tools installed"
else
  warn "Xcode Command Line Tools missing. Installing (GUI prompt)..."
  xcode-select --install || warn "If prompt failed, run manually: xcode-select --install"
fi

# 2. Rosetta (Apple Silicon only)
if [ "$ARCH" = "arm64" ]; then
  if /usr/bin/pgrep oahd >/dev/null 2>&1 || pkgutil --pkg-info com.apple.pkg.RosettaUpdateAuto >/dev/null 2>&1; then
    ok "Rosetta present (for x86_64 compatibility)"
  else
    warn "Rosetta not installed. If you need x86 formulae: sudo softwareupdate --install-rosetta --agree-to-license"
  fi
fi

# 3. Homebrew presence / prefix expectation
BREW_EXPECTED_PREFIX="/opt/homebrew"
[ "$ARCH" = "x86_64" ] && BREW_EXPECTED_PREFIX="/usr/local"
if command -v brew >/dev/null 2>&1; then
  BREW_PREFIX="$(brew --prefix 2>/dev/null || true)"
  if [ "$BREW_PREFIX" != "$BREW_EXPECTED_PREFIX" ]; then
    warn "Homebrew prefix mismatch: expected $BREW_EXPECTED_PREFIX got $BREW_PREFIX (may be fine if intentional)"
  else
    ok "Homebrew prefix OK ($BREW_PREFIX)"
  fi
else
  warn "Homebrew not installed yet (will be installed during --brew phase)"
fi

# 4. Network reachability quick check
if curl -Is https://github.com >/dev/null 2>&1; then
  ok "Network / GitHub reachable"
else
  error "Cannot reach GitHub (check network or proxy)"
fi

# 5. Core directories
for d in "$HOME/.config" "$HOME/.local/bin"; do
  if [ -d "$d" ]; then ok "Dir exists: $d"; else mkdir -p "$d" && ok "Created: $d"; fi
done

# 6. Node manager preference (fnm vs nvm)
HAS_FNM=0; HAS_NVM=0
command -v fnm >/dev/null 2>&1 && HAS_FNM=1
'test -d "$HOME/.nvm"' && [ -d "$HOME/.nvm" ] && HAS_NVM=1 || true
if [ $HAS_FNM -eq 1 ] && [ $HAS_NVM -eq 1 ]; then
  warn "Both fnm and nvm present. Repo prefers fnm; consider pruning nvm to avoid confusion."
elif [ $HAS_FNM -eq 1 ]; then
  ok "fnm detected"
elif [ $HAS_NVM -eq 1 ]; then
  warn "Only nvm detected. Consider switching to fnm (faster). Brew: brew install fnm"
else
  warn "No Node version manager installed (fnm recommended)."
fi

# 7. Pending path warnings
for bin in fnm pyenv nvim code; do
  if command -v "$bin" >/dev/null 2>&1; then ok "$bin available"; else warn "$bin not yet available (will come from later phases or manual install)"; fi
done

ok "Preflight complete"
