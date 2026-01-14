# Raycast Configuration

This directory contains Raycast settings and configuration backups.

## Files

- `com.raycast.macos.plist` - Raycast preferences (hotkeys, appearance, etc.)
- `settings.json` - Human-readable export of settings (if not encrypted)
- `extensions.txt` - List of installed extensions

## Syncing Configuration

### Backup Current Settings
```bash
./scripts/raycast_sync.sh backup
```

### Restore Settings
```bash
./scripts/raycast_sync.sh restore
```

## Extensions

Raycast extensions are not automatically synced via dotfiles. You have two options:

1. **Raycast Cloud Sync** (Recommended)
   - Sign in to Raycast with your account
   - Extensions, snippets, and quicklinks will sync automatically
   - Go to Raycast Settings → Advanced → Sync

2. **Manual Installation**
   - Check `extensions.txt` for a list of previously installed extensions
   - Install from Raycast Store (`⌘,` → Extensions → Store)

## Notes

- Settings include hotkeys, appearance, and search preferences
- Some settings may be encrypted and won't export to JSON
- Extension data and scripts are stored locally but can sync via Raycast Cloud
- Always backup before making major changes
