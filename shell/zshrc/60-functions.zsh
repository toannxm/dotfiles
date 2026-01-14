# Custom shell functions

# Truncate project logs safely
truncate_project_logs() {
  for f in \
    "$OLIVIA_UI/logs/aipublic.log" \
    "$OLIVIA_UI/logs/django.log" \
    "$OLIVIA_CORE/logs/django.log" \
    "$OLIVIA_CORE/logs/aicore.log" \
    "$OLIVIA_CORE/logs/query.log" \
    "$OLIVIA_CORE/logs/queries.log" \
    "$OLIVIA_CORE/logs/queue_jobs.log"; do
    [ -f "$f" ] && : > "$f"
  done
  echo "Logs truncated"
}
alias del_log='truncate_project_logs'

# Clone production schema to a test DB
clone_db_test() {
  emulate -L zsh
  set -euo pipefail
  local PRODUCTION_DB="${1:-applydb_prod}"
  local COPY_DB="${2:-test_applydb_prod}"
  local USER="${MYSQL_USER:-root}"
  local HOST="${MYSQL_HOST:-127.0.0.1}"
  local PORT="${MYSQL_PORT:-3306}"
  local PASS="${MYSQL_PASSWORD:-root}"
  local ERROR_LOG="${ERROR_LOG:-/tmp/duplicate_mysql_error.log}"

  echo "Dropping '$COPY_DB' and generating from '$PRODUCTION_DB' schema"
  mysql -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" --force -e "DROP DATABASE IF EXISTS \`$COPY_DB\`;"
  mysql -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" -e "CREATE DATABASE \`$COPY_DB\`;"

  mysqldump --force --protocol=tcp --no-data --log-error="$ERROR_LOG" \
    -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" "$PRODUCTION_DB" | \
    mysql -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" "$COPY_DB"

  echo "Clone '$COPY_DB' successful"

  mysql -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" -e "SET GLOBAL FOREIGN_KEY_CHECKS=0;"
  mysql -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" -e "INSERT $COPY_DB.django_migrations SELECT * FROM $PRODUCTION_DB.django_migrations;"
  mysql -h"$HOST" -P"$PORT" -u"$USER" -p"$PASS" -e "SET GLOBAL FOREIGN_KEY_CHECKS=1;"
}
