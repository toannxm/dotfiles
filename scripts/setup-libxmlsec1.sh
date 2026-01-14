#!/usr/bin/env bash
# Setup libxmlsec1 1.2.37 with openssl@3 compatibility
# This is required for python3-saml and other SAML libraries
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
FORMULA_FILE="$ROOT_DIR/homebrew/Formula/libxmlsec1.rb"
BREW_TAP_DIR="$(brew --repository)/Library/Taps/local/homebrew-tap"

info() { echo "[INFO] $*" >&2; }
ok() { echo "[OK] $*" >&2; }
warn() { echo "[WARN] $*" >&2; }
error() { echo "[ERROR] $*" >&2; exit 1; }

check_formula() {
    if [ ! -f "$FORMULA_FILE" ]; then
        error "Formula not found at $FORMULA_FILE"
    fi
    ok "Formula found"
}

setup_local_tap() {
    info "Setting up local Homebrew tap"
    
    # Create tap directory if it doesn't exist
    if [ ! -d "$BREW_TAP_DIR" ]; then
        mkdir -p "$BREW_TAP_DIR/Formula"
        info "Created local tap directory"
    fi
    
    # Copy formula to tap
    cp "$FORMULA_FILE" "$BREW_TAP_DIR/Formula/"
    ok "Formula copied to tap"
}

install_libxmlsec1() {
    info "Installing libxmlsec1 1.2.37"
    
    # Unlink if already installed
    brew unlink libxmlsec1 2>/dev/null || true
    
    # Install from local tap
    if brew list libxmlsec1 &>/dev/null; then
        current_version=$(brew list --versions libxmlsec1 | awk '{print $2}')
        if [ "$current_version" = "1.2.37" ]; then
            ok "libxmlsec1 1.2.37 already installed"
            brew link libxmlsec1 2>/dev/null || true
            return 0
        else
            warn "Uninstalling version $current_version"
            brew uninstall libxmlsec1 --force
        fi
    fi
    
    brew install local/tap/libxmlsec1
    ok "libxmlsec1 1.2.37 installed"
}

verify_installation() {
    info "Verifying installation"
    if ! brew list libxmlsec1 &>/dev/null; then
        error "libxmlsec1 not installed"
    fi
    
    version=$(brew list --versions libxmlsec1 | awk '{print $2}')
    if [ "$version" != "1.2.37" ]; then
        error "Wrong version installed: $version (expected 1.2.37)"
    fi
    
    ok "Verification passed: libxmlsec1 $version"
}

main() {
    info "Starting libxmlsec1 setup"
    check_formula
    setup_local_tap
    install_libxmlsec1
    verify_installation
    info "Setup complete"
}

main "$@"
