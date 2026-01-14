#!/usr/bin/env bash
set -euo pipefail

# datagrip_sync.sh
# Export/import sanitized DataGrip data source & schema configuration.
# Subcommands: export | import | diff | backup | help
# Passwords/secrets are stripped; re-enter them in the UI.

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
OPTIONS_DIR=""
TIMESTAMP="$(date +%Y%m%d%H%M%S)"
REPO_CFG_DIR="$ROOT_DIR/config/datagrip"

log() { printf "[datagrip-sync] %s\n" "$*"; }
err() { printf "[datagrip-sync][ERROR] %s\n" "$*" >&2; }

find_datagrip_options() {
  local base="$HOME/Library/Application Support/JetBrains"
  local latest=""
  shopt -s nullglob
  for d in "$base"/DataGrip*; do
    [[ -d "$d/options" ]] || continue
    latest="$d/options"
  done
  shopt -u nullglob
  if [[ -z "$latest" ]]; then
    err "Could not locate DataGrip options directory under $base"; return 1
  fi
  OPTIONS_DIR="$latest"
}

sanitize() {
  # Remove password lines and secret tags from a file
  local infile="$1" outfile="$2"
  awk 'BEGIN{removed=0} {
    if ($0 ~ /password/ || $0 ~ /PWD=/ || $0 ~ /secretStorage/ ) {removed=1; next}
    print
  } END{ if(removed) print "<!-- password removed; set inside DataGrip UI -->" }' < "$infile" > "$outfile"
}

cmd_export() {
  find_datagrip_options || return 1
  local ds="$OPTIONS_DIR/dataSources.xml"
  local dsl="$OPTIONS_DIR/dataSources.local.xml"
  [[ -f "$ds" ]] || err "Missing $ds" || return 2
  [[ -f "$dsl" ]] || err "Missing $dsl" || return 2
  mkdir -p "$REPO_CFG_DIR"
  sanitize "$ds" "$REPO_CFG_DIR/dataSources.xml.example"
  sanitize "$dsl" "$REPO_CFG_DIR/dataSources.local.xml.example"
  log "Exported sanitized configs to $REPO_CFG_DIR"
}

cmd_import() {
  find_datagrip_options || return 1
  local ds_repo="$REPO_CFG_DIR/dataSources.xml.example"
  local dsl_repo="$REPO_CFG_DIR/dataSources.local.xml.example"
  [[ -f "$ds_repo" ]] || err "Repo example missing: $ds_repo" || return 2
  [[ -f "$dsl_repo" ]] || err "Repo example missing: $dsl_repo" || return 2
  mkdir -p "$OPTIONS_DIR/backup-$TIMESTAMP"
  for f in dataSources.xml dataSources.local.xml; do
    if [[ -f "$OPTIONS_DIR/$f" ]]; then
      cp "$OPTIONS_DIR/$f" "$OPTIONS_DIR/backup-$TIMESTAMP/$f"
      log "Backed up $f -> backup-$TIMESTAMP"
    fi
  done
  cp "$ds_repo" "$OPTIONS_DIR/dataSources.xml"
  cp "$dsl_repo" "$OPTIONS_DIR/dataSources.local.xml"
  log "Imported configs. Re-open DataGrip or use File > Synchronize."
  log "Passwords need to be re-added inside DataGrip UI."
}

cmd_diff() {
  find_datagrip_options || return 1
  local ds="$OPTIONS_DIR/dataSources.xml" dsl="$OPTIONS_DIR/dataSources.local.xml"
  local rds="$REPO_CFG_DIR/dataSources.xml.example" rdsl="$REPO_CFG_DIR/dataSources.local.xml.example"
  for f in "$ds" "$dsl" "$rds" "$rdsl"; do [[ -f "$f" ]] || { err "Missing file for diff: $f"; return 2; }; done
  log "Diff dataSources.xml (left: current, right: repo)"
  diff -u "$ds" "$rds" || true
  log "Diff dataSources.local.xml (left: current, right: repo)"
  diff -u "$dsl" "$rdsl" || true
}

cmd_backup() {
  find_datagrip_options || return 1
  local dest="$OPTIONS_DIR/backup-$TIMESTAMP"
  mkdir -p "$dest"
  cp "$OPTIONS_DIR"/dataSources*.xml "$dest" 2>/dev/null || true
  log "Backed up current dataSources*.xml to $dest"
}

cmd_help() {
  cat <<EOF
Usage: $0 <command>
Commands:
  export   Sanitize and copy DataGrip XML into repo examples
  import   Backup then copy repo examples into DataGrip config
  diff     Show diffs between current DataGrip and repo examples
  backup   Just backup current DataGrip dataSources XML files
  help     Show this help message

Examples:
  $0 export
  git diff
  $0 import
  $0 diff
EOF
}

main() {
  local cmd="${1:-help}"; shift || true
  case "$cmd" in
    export) cmd_export ;;
    import) cmd_import ;;
    diff) cmd_diff ;;
    backup) cmd_backup ;;
    help|*) cmd_help ;;
  esac
}

main "$@"
