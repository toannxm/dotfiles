#!/usr/bin/env bash
# Raycast Configuration Sync Script
# Backs up and restores Raycast settings and configurations

set -e
source "$(dirname "$0")/lib/log.sh"

RAYCAST_PREF="$HOME/Library/Preferences/com.raycast.macos.plist"
RAYCAST_APP_SUPPORT="$HOME/Library/Application Support/com.raycast.macos"
DOTFILES_RAYCAST="$HOME/Workday/MacSetup/dotfiles/config/raycast"

backup() {
    info "=== Backing up Raycast configuration ==="

    if [[ -f "$RAYCAST_PREF" ]]; then
        info "Backing up Raycast preferences..."
        cp "$RAYCAST_PREF" "$DOTFILES_RAYCAST/com.raycast.macos.plist"
        ok "Preferences backed up"
    else
        warn "Raycast preferences not found - is Raycast installed?"
    fi

    # Export Raycast settings as readable format
    if [[ -f "$RAYCAST_PREF" ]]; then
        info "Exporting preferences to JSON..."
        plutil -convert json "$RAYCAST_PREF" -o "$DOTFILES_RAYCAST/settings.json" 2>/dev/null || \
            warn "Could not convert to JSON (encrypted settings)"
    fi

    # Backup extensions list if directory exists
    if [[ -d "$RAYCAST_APP_SUPPORT/extensions" ]]; then
        info "Backing up extensions list..."
        ls "$RAYCAST_APP_SUPPORT/extensions" > "$DOTFILES_RAYCAST/extensions.txt" 2>/dev/null || true
        ok "Extensions list saved"
    fi

    ok "Raycast backup complete"
}

restore() {
    info "=== Restoring Raycast configuration ==="

    if [[ ! -f "$DOTFILES_RAYCAST/com.raycast.macos.plist" ]]; then
        error "No Raycast backup found in dotfiles"
        exit 1
    fi

    # Close Raycast if running
    if pgrep -x "Raycast" > /dev/null; then
        info "Closing Raycast..."
        osascript -e 'quit app "Raycast"' 2>/dev/null || killall Raycast 2>/dev/null || true
        sleep 2
    fi

    info "Restoring Raycast preferences..."
    cp "$DOTFILES_RAYCAST/com.raycast.macos.plist" "$RAYCAST_PREF"

    # Restart cfprefsd to reload preferences
    killall cfprefsd 2>/dev/null || true

    ok "Raycast configuration restored"
    info "Note: Extensions will need to be reinstalled manually from Raycast Store"
    info "      or via Raycast Cloud Sync if you have an account"
}

case "${1:-}" in
    backup)
        backup
        ;;
    restore)
        restore
        ;;
    *)
        log_info "Usage: $0 {backup|restore}"
        log_info ""
        log_info "  backup  - Save current Raycast settings to dotfiles"
        log_info "  restore - Apply dotfiles Raycast settings to system"
        exit 1
        ;;
esac
