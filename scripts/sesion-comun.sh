# Funciones compartidas. No se ejecuta directo.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# El .local.sh pisa al de ejemplo
if [ -f "$SCRIPT_DIR/sesion-config.local.sh" ]; then
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/sesion-config.local.sh"
else
  # shellcheck source=/dev/null
  . "$SCRIPT_DIR/sesion-config.sh"
  echo "AVISO: usando sesion-config.sh de ejemplo."
  echo "       Copialo a sesion-config.local.sh y ajustá las rutas."
  echo
fi

LOCK_FILE="$WOW_SYNC_DIR/sesion.lock"
LATEST_FILE="$WOW_SYNC_DIR/ultimo.txt"
ESTA_PC="$(hostname)"

rojo()  { printf '\033[31m%s\033[0m\n' "$*"; }
verde() { printf '\033[32m%s\033[0m\n' "$*"; }
amar()  { printf '\033[33m%s\033[0m\n' "$*"; }

morir() { rojo "ERROR: $*"; exit 1; }

verificar_entorno() {
  [ -d "$WOW_ACORE_DIR" ] || morir "No encuentro AzerothCore en $WOW_ACORE_DIR"

  # Si el destino no está y hay un comando de montaje configurado, probarlo.
  # Es el caso del pendrive: WSL no monta los removibles solo.
  if [ ! -d "$WOW_SYNC_DIR" ] && [ -n "${WOW_MONTAR_CMD:-}" ]; then
    echo "Montando el destino..."
    $WOW_MONTAR_CMD || true
  fi

  [ -d "$WOW_SYNC_DIR" ] || morir "No encuentro el destino en $WOW_SYNC_DIR
       ¿Está enchufado el pendrive? ¿Sincronizó la nube?
       ¿La ruta de sesion-config.local.sh es correcta?"
  mkdir -p "$WOW_LOCAL_BACKUP_DIR"
  command -v docker >/dev/null || morir "docker no está disponible"
}

# Espera a que MySQL responda. Sin esto, el restore falla por arrancar antes de tiempo.
esperar_db() {
  local intentos=60
  printf 'Esperando a MySQL'
  while [ $intentos -gt 0 ]; do
    if docker compose exec -T ac-database \
         mysqladmin ping -uroot -p"$WOW_DB_PASS" --silent >/dev/null 2>&1; then
      printf ' listo\n'
      return 0
    fi
    printf '.'
    sleep 2
    intentos=$((intentos - 1))
  done
  printf '\n'
  morir "MySQL no respondió en 2 minutos"
}

# Espera a que el worldserver termine de cargar el mundo.
# Usa StartedAt del contenedor para no leer un "World Initialized" de una
# sesión anterior que quedó en el log.
esperar_mundo() {
  local inicio intentos=200
  inicio=$(docker inspect -f '{{.State.StartedAt}}' ac-worldserver 2>/dev/null) || {
    amar "No pude consultar el worldserver."; return 1; }

  printf 'Cargando el mundo'
  while [ $intentos -gt 0 ]; do
    if docker compose logs ac-worldserver --since "$inicio" 2>/dev/null \
         | grep -qi "World Initialized"; then
      printf ' listo\n'
      return 0
    fi
    printf '.'
    sleep 3
    intentos=$((intentos - 1))
  done

  printf '\n'
  amar "El mundo tardó más de 10 minutos. Revisá:"
  amar "    docker compose logs -f ac-worldserver"
  return 1
}

# Abre el cliente de WoW si está configurado.
abrir_cliente() {
  [ -n "${WOW_CLIENTE_EXE:-}" ] || return 0
  verde "Abriendo WoW..."
  # cmd.exe se queja si el directorio actual es una ruta de Linux,
  # así que lo llamamos parado en el disco de Windows.
  ( cd /mnt/c 2>/dev/null || cd /; cmd.exe /c start "" "$WOW_CLIENTE_EXE" ) >/dev/null 2>&1 \
    || amar "No pude abrir el cliente. Revisá WOW_CLIENTE_EXE."
}

# ── Mantener WSL despierto ────────────────────────────────────────
#
# Con Docker Engine dentro de Ubuntu (en vez de Docker Desktop), WSL apaga
# la distro cuando no le queda ningún proceso corriendo — y se lleva puesto
# el demonio de Docker y todos los contenedores.
#
# Docker Desktop evitaba esto porque mantenía sus propias distros vivas.
# Acá lo resolvemos dejando un proceso testigo: mientras exista, WSL no
# apaga nada. `setsid` lo separa de la terminal para que sobreviva al
# cierre de la ventana que lo lanzó.
#
# Se rastrea por archivo de PID, no por nombre: buscar el proceso por su
# nombre con pgrep/pkill también matchea a este mismo script (el nombre
# aparece en su texto) y termina matando la sesión que lo invocó.

KEEPALIVE_PID_FILE="/tmp/wow-keepalive.pid"

keepalive_activo() {
  local pid
  [ -f "$KEEPALIVE_PID_FILE" ] || return 1
  pid=$(cat "$KEEPALIVE_PID_FILE" 2>/dev/null) || return 1
  [ -n "$pid" ] || return 1
  kill -0 "$pid" 2>/dev/null || return 1
  # Que el PID no haya sido reciclado por otro proceso cualquiera
  [ "$(ps -o comm= -p "$pid" 2>/dev/null)" = "sleep" ]
}

iniciar_keepalive() {
  keepalive_activo && return 0

  # El hijo anota su propio PID y después se convierte en el sleep,
  # así el PID del archivo es exactamente el del proceso que queda vivo.
  setsid bash -c "echo \$\$ > '$KEEPALIVE_PID_FILE'; exec sleep infinity" \
    >/dev/null 2>&1 </dev/null &
  disown 2>/dev/null || true
  sleep 1

  if keepalive_activo; then
    echo "WSL quedará despierto mientras juegues."
  else
    amar "No pude dejar el proceso que mantiene WSL despierto."
    amar "El servidor puede apagarse solo al cerrar la ventana."
  fi
}

detener_keepalive() {
  if keepalive_activo; then
    kill "$(cat "$KEEPALIVE_PID_FILE")" 2>/dev/null || true
    echo "WSL liberado."
  fi
  rm -f "$KEEPALIVE_PID_FILE"
}
