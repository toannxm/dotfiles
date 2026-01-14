# Local overrides (not committed). Copy to 90-local.zsh and adjust.
# Example: email/SSH identity switching.

ssh_use_personal() {
  ssh-add -D
  ssh-add ~/.ssh/toannxm-GitHub 2>/dev/null || true
  git config --global user.email 'toannxm.itedu@gmail.com'
}

ssh_use_work() {
  ssh-add -D
  ssh-add ~/.ssh/id_rsa 2>/dev/null || true
  git config --global user.email 'toan.nguyen2@paradox.ai'
  git config --global user.name 'prd-toan-nguyen'
}

# Add any machine-specific exports/aliases/functions below
