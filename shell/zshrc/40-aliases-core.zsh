# Core generic aliases & utilities

# Colorized ls via colorls if available
if command -v colorls >/dev/null 2>&1; then
  alias ls='colorls'
  alias la='colorls -al'
fi

alias dyldinfo='/usr/lib/system/libdyld.dylib/Tools/dyldinfo'

# MySQL (prefer one version: 8.4)
MYSQL_PREFIX="/opt/homebrew/opt/mysql@8.4"
if [ -d "$MYSQL_PREFIX" ]; then
  alias mysql="$MYSQL_PREFIX/bin/mysql"
  alias mysqldump="$MYSQL_PREFIX/bin/mysqldump"
  export PATH="$MYSQL_PREFIX/bin:$PATH"
fi

# Cache flush (memcached) - using straight quotes
alias del_cache="echo 'flush_all' | netcat 127.0.0.1 11211"
