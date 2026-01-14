#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh" 2>/dev/null || true

usage() {
    cat <<EOF
Usage: $(basename "$0") [options]

Phases:
    --brew        Install Homebrew (if missing) and apply Brewfile
    --dotfiles    Create/update symlinks
    --macos       Apply macOS defaults (interactive confirm)
    --lang        Install / set up language runtimes
    --update      Update packages/runtimes
    --doctor      Run health checks
    --all         Run: brew, dotfiles, macos, lang

General:
    --dry-run     Show actions without executing (best-effort)
    -v, --verbose Verbose logging
    -h, --help    Show this help
EOF
}

DO_BREW=false; DO_DOTFILES=false; DO_MACOS=false; DO_LANG=false; DO_UPDATE=false; DO_DOCTOR=false; DRY_RUN=false

while [ $# -gt 0 ]; do
    case "$1" in
        --brew) DO_BREW=true ;;
        --dotfiles) DO_DOTFILES=true ;;
        --macos) DO_MACOS=true ;;
        --lang) DO_LANG=true ;;
        --update) DO_UPDATE=true ;;
        --doctor) DO_DOCTOR=true ;;
        --all) DO_BREW=true; DO_DOTFILES=true; DO_MACOS=true; DO_LANG=true ;;
        --dry-run) DRY_RUN=true ;;
        -v|--verbose) export LOG_LEVEL=DEBUG ;;
        -h|--help) usage; exit 0 ;;
        *) echo "Unknown argument: $1"; usage; exit 1 ;;
    esac
    shift
done

if ! $DO_BREW && ! $DO_DOTFILES && ! $DO_MACOS && ! $DO_LANG && ! $DO_UPDATE && ! $DO_DOCTOR; then
    echo "No phase specified; defaulting to --dotfiles"
    DO_DOTFILES=true
fi

run_script() {
    local script="$1"; shift || true
    if $DRY_RUN; then
        echo "DRY RUN: would run $script $*"
    else
        "$script" "$@"
    fi
}

echo "Starting bootstrap (root: $ROOT_DIR)"

$DO_BREW && run_script "$ROOT_DIR/scripts/brew.sh"
$DO_DOTFILES && run_script "$ROOT_DIR/scripts/link.sh"
$DO_LANG && run_script "$ROOT_DIR/scripts/lang.sh"
$DO_UPDATE && run_script "$ROOT_DIR/scripts/update.sh"
$DO_DOCTOR && run_script "$ROOT_DIR/scripts/doctor.sh"

echo "Done. Suggested next steps:" >&2
echo "  - Set git identity: git config --global user.name 'Your Name'" >&2
echo "  - Set git email:    git config --global user.email you@example.com" >&2
echo "  - Install Oh My Zsh (optional) or configure preferred prompt" >&2
echo "  - Open new terminal session" >&2
