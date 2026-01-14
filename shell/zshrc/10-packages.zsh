# Package manager / language runtime initialization

# Homebrew environment (arm64 mac)
if command -v brew >/dev/null 2>&1; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
fi

# pyenv (guarded)
if command -v pyenv >/dev/null 2>&1; then
  export PATH="$HOME/.pyenv/bin:$PATH"
  eval "$(pyenv init -)"
  if command -v pyenv-virtualenv-init >/dev/null 2>&1; then
    eval "$(pyenv virtualenv-init -)"
  fi
fi

# Fast Node Manager (fnm)
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env)"
fi

# pnpm
export PNPM_HOME="$HOME/Library/pnpm"
if [ -d "$PNPM_HOME" ]; then
  case ":$PATH:" in
    *":$PNPM_HOME:"*) ;; 
    *) PATH="$PNPM_HOME:$PATH" ;; 
  esac
fi
export PATH
