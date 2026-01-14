# Project-specific aliases (Olivia)

alias migrate='python "$OLIVIA_CORE"/src/manage.py migrate'
alias makemigrations='python "$OLIVIA_CORE"/src/manage.py makemigrations'
alias makemigrations_merge='python "$OLIVIA_CORE"/src/manage.py makemigrations --merge'

alias log_core='tail -500f "$OLIVIA_CORE"/logs/aicore.log'
alias log_ui='tail -500f "$OLIVIA_UI"/logs/aipublic.log'

# Virtualenv activators (fixed typo)
alias active_core_3117='source ~/.pyenv/versions/olivia-core-3117/bin/activate'
alias active_ui_3117='source ~/.pyenv/versions/olivia-ui-3117/bin/activate'
alias active_pydevdeps='source ~/.pyenv/versions/paradox-pydevdeps/bin/activate'

# Git branch cleaning (DANGEROUS): confirm before mass delete
confirm_delete_branches() {
  echo "This will delete ALL local branches except current. Continue? (y/N)" >&2
  read -r ans
  if [[ "$ans" == 'y' || "$ans" == 'Y' ]]; then
    git branch | grep -v "^*" | xargs git branch -D
  else
    echo "Aborted" >&2
  fi
}
alias del_branch='confirm_delete_branches'
