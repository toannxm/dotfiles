#!/usr/bin/env bash
# Helper: apply VS Code configuration (settings, keybindings, snippets) and install extensions.
# Usage:
#   vscode_apply.sh [--link] [--core] [--optional] [--all]
# Default (no flags): --link --core
# Flags:
#   --link       Symlink repo VS Code config into user directory
#   --core       Install core (workspace) extension recommendations
#   --optional   Install optional extensions list
#   --all        Do everything (link + core + optional)
#   --dry-run    Show actions without executing installs/links
#   -h|--help    Show help
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh"

VSCODE_USER_DEFAULT="$HOME/Library/Application Support/Code/User"
VSCODE_USER="${VSCODE_USER:-$VSCODE_USER_DEFAULT}"
CORE_EXT_FILE="$ROOT_DIR/config/vscode/extensions.json"
OPT_EXT_FILE="$ROOT_DIR/config/vscode/extensions.optional.json"
DRY_RUN=false
DO_LINK=false
DO_CORE=false
DO_OPT=false

usage() {
  cat <<EOF
Apply VS Code configuration from dotfiles.

$(basename "$0") [options]
  --link        Symlink settings/keybindings/snippets into VS Code User dir
  --core        Install core extensions from extensions.json
  --optional    Install optional extensions from extensions.optional.json
  --all         Equivalent to --link --core --optional
  --dry-run     Print actions only
  -h, --help    Show this help and exit

Environment:
  VSCODE_USER  Override target VS Code User directory (default: $VSCODE_USER_DEFAULT)
EOF
}

have_cmd() { command -v "$1" >/dev/null 2>&1; }

link_file() {
  local src="$1" dest="$2"
  if [ ! -e "$src" ]; then warn "Missing source $src"; return 0; fi
  mkdir -p "$(dirname "$dest")"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    ok "Already linked $(basename "$dest")"
    return 0
  fi
  if $DRY_RUN; then info "(dry-run) ln -sf '$src' '$dest'"; return 0; fi
  ln -sf "$src" "$dest"
  ok "Linked $(basename "$dest")"
}

link_config() {
  info "Linking VS Code user configuration -> $VSCODE_USER"
  mkdir -p "$VSCODE_USER/snippets"
  link_file "$ROOT_DIR/config/vscode/settings.json" "$VSCODE_USER/settings.json"
  [ -f "$ROOT_DIR/config/vscode/keybindings.json" ] && \
    link_file "$ROOT_DIR/config/vscode/keybindings.json" "$VSCODE_USER/keybindings.json"
  if [ -d "$ROOT_DIR/config/vscode/snippets" ]; then
    for f in "$ROOT_DIR"/config/vscode/snippets/*; do
      [ -f "$f" ] || continue
      link_file "$f" "$VSCODE_USER/snippets/$(basename "$f")"
    done
  fi
}

install_extensions_from() {
  local file="$1" label="$2"
  if [ ! -f "$file" ]; then warn "$label extensions file not found: $file"; return 0; fi
  if ! have_cmd code; then warn "'code' CLI not found. Open VS Code and run 'Shell Command: Install \"code\" command in PATH'"; return 0; fi
  if ! have_cmd jq; then warn "jq not installed; skipping $label extension auto-install"; return 0; fi
  local list
  list=$(jq -r '.recommendations[]' "$file" 2>/dev/null || true)
  [ -z "$list" ] && { warn "No extensions listed in $file"; return 0; }
  info "Installing $label extensions ($(echo "$list" | wc -l | tr -d ' '))"
  while IFS= read -r ext; do
    [ -z "$ext" ] && continue
    if code --list-extensions | grep -qi "^${ext}$"; then
      ok "$ext (already installed)"
    else
      if $DRY_RUN; then info "(dry-run) code --install-extension $ext"; else
        if code --install-extension "$ext" >/dev/null 2>&1; then ok "Installed $ext"; else error "Failed $ext"; fi
      fi
    fi
  done <<<"$list"
}

parse_args() {
  if [ $# -eq 0 ]; then DO_LINK=true; DO_CORE=true; fi
  while [ $# -gt 0 ]; do
    case "$1" in
      --link) DO_LINK=true ;;
      --core) DO_CORE=true ;;
      --optional) DO_OPT=true ;;
      --all) DO_LINK=true; DO_CORE=true; DO_OPT=true ;;
      --dry-run) DRY_RUN=true ;;
      -h|--help) usage; exit 0 ;;
      *) error "Unknown arg: $1"; usage; exit 1 ;;
    esac
    shift
  done
}

summary() {
  info "Summary:"; echo "  VS Code User: $VSCODE_USER"; echo "  Link: $DO_LINK"; echo "  Core: $DO_CORE"; echo "  Optional: $DO_OPT"; echo "  Dry-run: $DRY_RUN";
}

main() {
  parse_args "$@"
  summary
  $DO_LINK && link_config
  $DO_CORE && install_extensions_from "$CORE_EXT_FILE" core
  $DO_OPT && install_extensions_from "$OPT_EXT_FILE" optional
  ok "Done"
}

main "$@"
