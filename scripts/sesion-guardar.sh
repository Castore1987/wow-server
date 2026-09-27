#!/usr/bin/env bash
#
# Terminar de jugar en ESTA PC y liberar la sesión.
#
#   ./scripts/sesion-guardar.sh
#
# 1. Apaga el worldserver ordenadamente (así guarda a los jugadores)
# 2. Exporta tus personajes
# 3. Los deja en la carpeta de la nube
# 4. Suelta el candado

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sesion-comun.sh"

verificar_entorno
cd "$WOW_ACORE_DIR"

# --- Avisar si el candado es de otra PC ------------------------------
if [ -f "$LOCK_FILE" ]; then
  DUENO="$(head -1 "$LOCK_FILE" 2>/dev/null || echo '?')"
  if [ "$DUENO" != "$ESTA_PC" ]; then
    amar "Atención: el candado figura a nombre de '$DUENO', no de esta PC."
    amar "Voy a guardar igual lo que hay acá y a tomar el candado."
    amar "Revisá que no estés pisando el progreso de la otra máquina."
    echo
  fi
fi

# --- Apagar el worldserver con tiempo --------------------------------
# -t 120 le da margen para guardar a los jugadores antes de cerrarse.
echo "Apagando el worldserver (puede tardar hasta 2 minutos)..."
docker compose stop -t 120 ac-worldserver

# --- Exportar --------------------------------------------------------
esperar_db

STAMP="$(date +%F_%H%M%S)"
NOMBRE="sesion_${ESTA_PC}_${STAMP}.sql.gz"
DESTINO="$WOW_SYNC_DIR/$NOMBRE"
LOCAL="$WOW_LOCAL_BACKUP_DIR/$NOMBRE"

echo "Exportando: $WOW_SYNC_DBS"
docker compose exec -T ac-database mysqldump -uroot -p"$WOW_DB_PASS" \
  --single-transaction --routines --triggers \
  --databases $WOW_SYNC_DBS | gzip > "$LOCAL"

# Un dump vacío o truncado es peor que no tener dump.
if [ ! -s "$LOCAL" ] || [ "$(stat -c%s "$LOCAL")" -lt 1024 ]; then
  rm -f "$LOCAL"
  morir "El dump salió vacío. NO toqué la nube ni el candado.
       El servidor sigue como estaba. Revisá que ac-database esté arriba."
fi

cp "$LOCAL" "$DESTINO"
echo "$NOMBRE" > "$LATEST_FILE"

# --- Soltar el candado -----------------------------------------------
rm -f "$LOCK_FILE"

# --- Apagar el resto --------------------------------------------------
docker compose stop
detener_keepalive

# --- Limpieza de sesiones viejas en la nube (dejamos las últimas 10) --
ls -1t "$WOW_SYNC_DIR"/sesion_*.sql.gz 2>/dev/null | tail -n +11 | while read -r v; do
  rm -f "$v"
done

echo
verde "═══════════════════════════════════════════════════════"
verde " Sesión guardada y liberada."
verde "  Destino: $NOMBRE  ($(du -h "$DESTINO" | cut -f1))"
verde "  Local:   $LOCAL"
verde "═══════════════════════════════════════════════════════"
echo
case "$WOW_SYNC_DIR" in
  /mnt/[d-z]/*)
    amar "Antes de desenchufar el pendrive, expulsalo desde Windows"
    amar "para que Windows termine de escribir."
    ;;
  *)
    amar "Esperá a que termine de sincronizar antes de arrancar"
    amar "en la otra PC (mirá el ícono de tu cliente de nube)."
    ;;
esac
