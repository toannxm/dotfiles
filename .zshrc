#############################################
# Powerlevel10k Instant Prompt (keep first) #
#############################################
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# Load modular shell configuration (moved to shell/zshrc)
SHELL_DIR="${HOME}/Workday/MacSetup/dotfiles/shell/zshrc"
[ -d "$SHELL_DIR" ] || SHELL_DIR="$(cd "$(dirname "$0")" && pwd)/shell/zshrc"

for file in "$SHELL_DIR"/*.zsh; do
  [ -f "$file" ] || continue
  case "$file" in *local.zsh.example) continue ;; esac
  source "$file"
done

# Load kubectl aliases if present
KUBE_DIR="${HOME}/dotfiles/shell/kubectl"
if [ -d "$KUBE_DIR" ]; then
  for file in "$KUBE_DIR"/*.zsh; do
    [ -f "$file" ] || continue
    source "$file"
  done
fi

# Local overrides (gitignored) - optional 90-local.zsh
[ -f "${SHELL_DIR%/zshrc}/90-local.zsh" ] && source "${SHELL_DIR%/zshrc}/90-local.zsh"

# Ensure prompt config loaded (some themes expect after other sourcing)
[[ -f "$HOME/.p10k.zsh" ]] && source "$HOME/.p10k.zsh"

# End of modular .zshrc


# Added by Antigravity
# export PATH="/Users/toan.nguyen2/.antigravity/antigravity/bin:$PATH"

# bun completions
# [ -s "/Users/toan.nguyen2/.bun/_bun" ] && source "/Users/toan.nguyen2/.bun/_bun"

# bun
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh
