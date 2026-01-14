#!/usr/bin/env bash
set -euo pipefail
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ROOT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
source "$ROOT_DIR/scripts/lib/log.sh"

pass=0; fail=0
check() { local name="$1"; shift; if eval "$@" >/dev/null 2>&1; then ok "[PASS] $name"; pass=$((pass+1)); else error "[FAIL] $name"; fail=$((fail+1)); fi; }

info "Health checks"
check "Homebrew" "command -v brew"
check "Git" "command -v git"
check "Zsh" "command -v zsh"
check "Neovim" "command -v nvim"
check "VS Code CLI (code)" "command -v code"
check "fzf" "command -v fzf"
check "ripgrep (rg)" "command -v rg"
check "fd" "command -v fd"
check "delta" "command -v delta"
check "fnm" "command -v fnm"
check "Node LTS (node)" "command -v node"
check "pyenv" "command -v pyenv"
check "Python (python3)" "command -v python3"

info "Summary: $pass passed, $fail failed"
if [ $fail -ne 0 ]; then
	warn "Some checks failed. Common remediation commands:"
	cat <<'HINT'
- Install VS Code CLI: Launch VS Code → Command Palette → 'Shell Command: Install code command'
- Install fnm: brew install fnm && echo 'eval "$(fnm env --use-on-cd)"' >> ~/.zshrc.local
- Install pyenv: brew install pyenv
- Apply Node LTS (fnm): fnm install --lts && fnm default lts-latest
- Sync Neovim plugins: nvim +Lazy sync
HINT
	exit 1
fi
