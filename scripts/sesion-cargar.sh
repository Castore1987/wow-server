#!/usr/bin/env bash
#
# Empezar a jugar en ESTA PC.
#
#   ./scripts/sesion-cargar.sh          arranca normalmente
#   ./scripts/sesion-cargar.sh --forzar ignora el candado (ver abajo)
#
# 1. Verifica que ninguna otra PC tenga la sesión tomada
# 2. Levanta MySQL solo
# 3. Restaura tus personajes desde la nube
# 4. Levanta el resto del servidor
# 5. Toma el candado a nombre de esta PC

. "$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)/sesion-comun.sh"

FORZAR=0
[ "${1:-}" = "--forzar" ] && FORZAR=1

verificar_entorno

# --- El candado -----------------------------------------------------
if [ -f "$LOCK_FILE" ]; then
  DUENO="$(head -1 "$LOCK_FILE" 2>/dev/null || echo desconocida)"
  CUANDO="$(sed -n 2p "$LOCK_FILE" 2>/dev/null || echo '?')"

  if [ "$DUENO" = "$ESTA_PC" ]; then
    amar "El candado ya es de esta PC (tomado el $CUANDO)."
    amar "Seguramente no cerraste la sesión la última vez. Continúo."
  elif [ $FORZAR -eq 1 ]; then
    rojo "Forzando sobre el candado de '$DUENO' (tomado el $CUANDO)."
    rojo "Si en esa PC jugaste y no guardaste, ese progreso SE PIERDE."
  else
    rojo "═══════════════════════════════════════════════════════"
    rojo " La sesión la tiene tomada: $DUENO"
    rojo " Desde: $CUANDO"
    rojo "═══════════════════════════════════════════════════════"
    echo
    echo "Andá a esa PC y corré ./scripts/sesion-guardar.sh"
    echo
    echo "Si esa PC no está disponible y estás seguro de que no"
    echo "quedó progreso sin guardar, podés forzar:"
    echo
    echo "    ./scripts/sesion-cargar.sh --forzar"
    echo
    exit 1
  fi
fi

# --- Qué backup restaurar -------------------------------------------
if [ ! -f "$LATEST_FILE" ]; then
  amar "No hay ninguna sesión previa en la nube."
  amar "Arranco el servidor tal cual está en esta PC."
  DUMP=""
else
  DUMP_NOMBRE="$(cat "$LATEST_FILE")"
  DUMP="$WOW_SYNC_DIR/$DUMP_NOMBRE"
  [ -f "$DUMP" ] || morir "ultimo.txt apunta a '$DUMP_NOMBRE' pero ese archivo no está.
       ¿Terminó de sincronizar la nube?"
  verde "Última sesión: $DUMP_NOMBRE"
fi

cd "$WOW_ACORE_DIR"

# --- Levantar solo la base ------------------------------------------
echo "Levantando MySQL..."
docker compose up -d ac-database
esperar_db

# --- Restaurar -------------------------------------------------------
if [ -n "$DUMP" ]; then
  # Copia de seguridad de lo que había acá, por las dudas
  PREV="$WOW_LOCAL_BACKUP_DIR/antes-de-restaurar_$(date +%F_%H%M).sql.gz"
  echo "Guardando el estado actual de esta PC en $PREV"
  docker compose exec -T ac-database mysqldump -uroot -p"$WOW_DB_PASS" \
    --single-transaction --databases $WOW_SYNC_DBS 2>/dev/null | gzip > "$PREV" || true

  echo "Restaurando..."
  gunzip < "$DUMP" | docker compose exec -T ac-database mysql -uroot -p"$WOW_DB_PASS"
  verde "Personajes restaurados."
fi

# --- Levantar el resto ----------------------------------------------
echo "Levantando el servidor..."
docker compose up -d

# --- Tomar el candado -----------------------------------------------
{ echo "$ESTA_PC"; date '+%F %H:%M:%S'; } > "$LOCK_FILE"

echo
esperar_mundo || true

echo
verde "═══════════════════════════════════════════════════════"
verde " Listo. La sesión es de esta PC ($ESTA_PC)."
verde "═══════════════════════════════════════════════════════"
echo

abrir_cliente

echo
amar "Cuando termines de jugar, NO te olvides de cerrar la sesión:"
amar "    ./scripts/sesion-guardar.sh    (o el acceso directo TERMINAR)"
