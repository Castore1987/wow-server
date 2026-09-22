#!/usr/bin/env bash
# Backup de las tres bases de AzerothCore.
#
#   ./scripts/backup.sh [destino]
#
# La contraseña sale de la variable de entorno MYSQL_PWD (no se pasa por
# línea de comandos: quedaría en el historial y en `ps`).
#
#   export MYSQL_PWD='...'
#   ./scripts/backup.sh /var/backups/acore

set -euo pipefail

DEST="${1:-./backups}"
USER="${MYSQL_USER:-acore}"
STAMP="$(date +%F_%H%M)"

: "${MYSQL_PWD:?Falta MYSQL_PWD. Exportala antes de correr este script.}"

mkdir -p "$DEST"

for DB in acore_characters acore_auth acore_world; do
  OUT="$DEST/${DB}_${STAMP}.sql.gz"
  echo ">>> $DB → $OUT"
  mysqldump -u "$USER" \
    --single-transaction --routines --triggers --quick \
    "$DB" | gzip > "$OUT"

  # Un dump vacío o truncado es peor que no tener dump: avisa y corta.
  if [ ! -s "$OUT" ] || [ "$(stat -c%s "$OUT")" -lt 1024 ]; then
    echo "!!! ERROR: $OUT quedó vacío o sospechosamente chico. Abortando." >&2
    exit 1
  fi
done

# Retención. acore_characters NO se borra automáticamente.
find "$DEST" -name 'acore_world_*.sql.gz' -mtime +7  -delete
find "$DEST" -name 'acore_auth_*.sql.gz'  -mtime +30 -delete

echo
echo "Listo. Contenido de $DEST:"
ls -lh "$DEST" | tail -n 10
echo
echo "Recordatorio: un backup que nunca restauraste no es un backup."
echo "Probá la restauración completa una vez por mes y anotala en"
echo "docs/operacion/backups.md."
