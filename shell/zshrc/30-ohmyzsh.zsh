# Oh My Zsh core config
plugins=(
  git
  zsh-autosuggestions
  zsh-syntax-highlighting
)

if [ -d "$ZSH" ]; then
  source "$ZSH/oh-my-zsh.sh"
fi
