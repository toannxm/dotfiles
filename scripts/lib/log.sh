#!/usr/bin/env bash
# Logging & helper utilities
set -o pipefail

COLOR_RESET='\033[0m'
COLOR_INFO='\033[1;34m'
COLOR_WARN='\033[1;33m'
COLOR_ERR='\033[1;31m'
COLOR_OK='\033[1;32m'
LOG_LEVEL=${LOG_LEVEL:-INFO}

_timestamp() { date '+%Y-%m-%d %H:%M:%S'; }
_log() { local lvl="$1" col="$2"; shift 2; echo -e "[$(_timestamp)] ${col}${lvl}${COLOR_RESET} $*" >&2; }
info() { [ "$LOG_LEVEL" != "ERROR" ] && _log INFO "$COLOR_INFO" "$@"; }
warn() { _log WARN "$COLOR_WARN" "$@"; }
error() { _log ERROR "$COLOR_ERR" "$@"; }
ok() { _log OK "$COLOR_OK" "$@"; }

run() { info "→ $*"; if eval "$@"; then ok "✓ $*"; else error "✗ $*"; return 1; fi; }
