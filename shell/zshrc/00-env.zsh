# Base environment variables & paths
# Project roots
OLIVIA_ROOT="/Users/toan.nguyen2/Workday/Olivia/SourceCode"
export OLIVIA_CORE="$OLIVIA_ROOT/olivia-core"
export OLIVIA_UI="$OLIVIA_ROOT/olivia"
export OLIVIA_DOCKER="$OLIVIA_ROOT/paradox-docker"
export OLIVIA_FF="$OLIVIA_ROOT/paradox-feature-flag"

# Zsh framework location (Oh My Zsh)
export ZSH="/Users/toan.nguyen2/.oh-my-zsh"

# Add custom/overrides early if needed
export PATH=/opt/homebrew/bin:$PATH

export XMLSEC_CFLAGS="-I$(brew --cellar libxmlsec1)/1.2.37/include/xmlsec1"
export XMLSEC_LIBS="-L$(brew --cellar libxmlsec1)/1.2.37/lib"
export PKG_CONFIG_PATH="$(brew --cellar libxmlsec1)/1.2.37/lib/pkgconfig"
export LDFLAGS="-L$(brew --prefix openssl@3)/lib"
export CPPFLAGS="-I$(brew --prefix openssl@3)/include"
