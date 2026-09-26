# Configuración compartida por sesion-guardar.sh y sesion-cargar.sh
#
# Copiá este archivo a `sesion-config.local.sh` y ajustá los valores.
# El .local.sh está en .gitignore: no se sube al repo.

# Carpeta sincronizada con la nube (Drive, Dropbox, OneDrive...).
# Es la ruta de WSL, así que la C: de Windows es /mnt/c/
WOW_SYNC_DIR="/mnt/c/Users/CAMBIAME/Google Drive/wow-server"

# Dónde está clonado AzerothCore
WOW_ACORE_DIR="$HOME/azerothcore-wotlk"

# Copias locales, por si la nube falla
WOW_LOCAL_BACKUP_DIR="$HOME/backups"

# Password de root de MySQL (la del .env de AzerothCore)
WOW_DB_PASS="${DOCKER_DB_ROOT_PASSWORD:-password}"

# Bases que viajan entre PCs.
# acore_world NO va acá: se reconstruye sola y tus cambios propios
# viven versionados en sql/, que es como corresponde.
WOW_SYNC_DBS="acore_characters acore_auth"

# ── Opcionales, para los accesos directos de Windows ──────────────

# Ejecutable del cliente de WoW, en ruta de WINDOWS.
# Si lo completás, sesion-cargar.sh abre el juego solo cuando el mundo
# terminó de cargar. Dejalo vacío para no abrirlo.
WOW_CLIENTE_EXE=""

# Comando para montar el pendrive si WOW_SYNC_DIR no está accesible.
# Requiere la regla de sudo sin contraseña (ver docs/operacion/accesos-directos.md).
# Ejemplo: WOW_MONTAR_CMD="sudo /usr/local/bin/montar-pen"
WOW_MONTAR_CMD=""
