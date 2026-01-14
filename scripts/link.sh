#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh"

BACKUP_SUFFIX=".backup"

link() {
  local src="$1" dest="$2"
  if [ -L "$dest" ] && [ "$(readlink "$dest")" = "$src" ]; then
    ok "Already linked: $dest"
    return
  fi
  if [ -e "$dest" ] && [ ! -L "$dest" ]; then
    local backup="${dest}${BACKUP_SUFFIX}"
    warn "Backing up $dest -> $backup"
    mv "$dest" "$backup"
  elif [ -L "$dest" ]; then
    warn "Replacing existing symlink $dest"
    rm "$dest"
  fi
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  ok "Linked $src -> $dest"
}

main() {
  # Core dotfiles
  link "$ROOT_DIR/.zshrc" "$HOME/.zshrc"
  link "$ROOT_DIR/.gitconfig" "$HOME/.gitconfig"
  link "$ROOT_DIR/.gitignore_global" "$HOME/.gitignore_global"

  # SSH
  link "$ROOT_DIR/.ssh/config" "$HOME/.ssh/config"

  # Editors
  link "$ROOT_DIR/config/nvim" "$HOME/.config/nvim"
  
  # Claude settings
  link "$ROOT_DIR/config/claude/settings.json" "$HOME/.claude/settings.json"
  
  # Nushell (macOS uses ~/Library/Application Support/nushell)
  if [[ "$OSTYPE" == "darwin"* ]]; then
    local nushell_config="$HOME/Library/Application Support/nushell"
    link "$ROOT_DIR/config/nushell/env.nu" "$nushell_config/env.nu"
    link "$ROOT_DIR/config/nushell/config.nu" "$nushell_config/config.nu"
    link "$ROOT_DIR/config/nushell/kubectl-aliases.nu" "$nushell_config/kubectl-aliases.nu"
  else
    link "$ROOT_DIR/config/nushell" "$HOME/.config/nushell"
  fi
}

main "$@"
