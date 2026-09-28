#!/bin/sh
# Monta el pendrive del servidor en /mnt/pen, sin importar qué letra le haya
# dado Windows.
#
# Por qué no se fija una letra: Windows las asigna según el puerto y según qué
# más esté conectado. El mismo pendrive es D: en una PC y E: en otra, y puede
# cambiar de un día para el otro. Acá lo reconocemos por su contenido: es el
# que tiene adentro una carpeta `wow-server`.
#
# Se instala en /usr/local/bin/montar-pen.
# Ver docs/operacion/accesos-directos.md

DEST=/mnt/pen
mkdir -p "$DEST"

# ¿Ya está montado el correcto?
[ -d "$DEST/wow-server" ] && exit 0

# Si hay otra cosa montada ahí, soltarla
if mountpoint -q "$DEST"; then
    umount "$DEST" 2>/dev/null || true
fi

# Probar letra por letra. Se arranca en D: para no tocar C:, que es el sistema.
for L in D E F G H I J K; do
    mount -t drvfs "${L}:" "$DEST" 2>/dev/null || continue
    [ -d "$DEST/wow-server" ] && exit 0
    umount "$DEST" 2>/dev/null || true
done

echo "No encontre el pendrive." >&2
echo "Ninguna unidad entre D: y K: tiene una carpeta 'wow-server' adentro." >&2
echo "Esta enchufado? Creaste esa carpeta la primera vez?" >&2
exit 1
