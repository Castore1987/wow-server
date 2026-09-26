# Accesos directos: jugar con un doble clic

Tres archivos `.bat` en `windows/` que hacen todo desde el escritorio de
Windows, sin abrir una terminal.

| Archivo | Qué hace |
|---|---|
| **JUGAR.bat** | Monta el pendrive, verifica el candado, levanta el servidor, restaura tu progreso, espera a que cargue el mundo y abre el WoW |
| **TERMINAR.bat** | Guarda tu progreso al destino, libera el candado y apaga todo |
| **ESTADO.bat** | Muestra cómo están los contenedores y las últimas líneas del log |

## Instalación

### 1. Copiar los `.bat` al escritorio

Desde Ubuntu (cambiá `jmaur` por tu usuario de Windows):

```bash
cp ~/wow-server/windows/*.bat "/mnt/c/Users/jmaur/Desktop/"
```

### 2. Completar la configuración

En `scripts/sesion-config.local.sh`, agregá las dos líneas opcionales:

```bash
# Ruta del Wow.exe, en formato de WINDOWS, con doble barra invertida
WOW_CLIENTE_EXE="C:\\Games\\WoWPatagonia-esMX\\Wow.exe"

# Solo si el destino es un pendrive
WOW_MONTAR_CMD="sudo /usr/local/bin/montar-pen"
```

Si dejás `WOW_CLIENTE_EXE` vacío, el servidor arranca igual pero el juego lo
abrís vos.

### 3. Montaje sin contraseña (solo para pendrive)

`JUGAR.bat` no puede escribir una contraseña de `sudo`. Se resuelve con un
permiso **acotado a un solo comando**, no con `sudo` libre:

```bash
sudo tee /usr/local/bin/montar-pen >/dev/null <<'SH'
#!/bin/sh
mountpoint -q /mnt/e || mount -t drvfs E: /mnt/e
SH
sudo chmod +x /usr/local/bin/montar-pen

echo "$USER ALL=(root) NOPASSWD: /usr/local/bin/montar-pen" \
  | sudo tee /etc/sudoers.d/montar-pen
sudo chmod 440 /etc/sudoers.d/montar-pen
```

> Cambiá `E:` y `/mnt/e` por la letra de tu pendrive.
>
> La regla autoriza **ese script y nada más**. No es `sudo` sin contraseña
> para todo: si alguien reemplazara el script necesitaría ser root primero,
> que es justamente lo que estaría intentando conseguir.

Probalo:

```bash
sudo /usr/local/bin/montar-pen && echo "montó sin pedir contraseña"
```

### 4. Probar

Doble clic en **JUGAR.bat**. Tenés que ver la cuenta de contenedores, después
`Cargando el mundo...`, y al terminar se abre el WoW solo.

## Darles mejor aspecto

Los `.bat` se ven feos. Para dejarlos prolijos:

1. Clic derecho en el escritorio → **Nuevo** → **Acceso directo**
2. Ubicación: la ruta al `.bat` (ej. `C:\Users\jmaur\Desktop\JUGAR.bat`)
3. Nombre: `Jugar WoW`
4. Clic derecho en el acceso directo → **Propiedades**
5. **Cambiar icono** → podés apuntar al `Wow.exe` y usar el ícono del juego
6. En **Ejecutar**, elegí **Minimizada** para que la ventana negra no moleste

## Qué hace cada uno por dentro

Los `.bat` no tienen lógica propia: solo llaman a los scripts de Linux.

```bat
wsl.exe -d Ubuntu -- bash -lc "cd ~/wow-server && ./scripts/sesion-cargar.sh"
```

Toda la inteligencia (el candado, la verificación del dump, la espera del
mundo) vive en los scripts. Si algo hay que arreglar, se arregla ahí y los
accesos directos lo toman solos.

## Si algo falla

`JUGAR.bat` se queda abierto cuando hay error, con el motivo en pantalla.

| Mensaje | Qué pasa |
|---|---|
| `La sesión la tiene tomada: <otra PC>` | El candado. Andá a esa PC y corré TERMINAR, o usá `--forzar` |
| `No encuentro el destino en /mnt/e/...` | El pendrive no está enchufado, o falta el paso 3 |
| `El mundo tardó más de 10 minutos` | Mirá `ESTADO.bat`. Con poca RAM puede pasar si hay mucho abierto |
| Se cierra al instante sin decir nada | Abrilo desde una consola (`cmd`) para ver el error |

## El orden correcto al terminar

1. **Cerrá el WoW primero.** Así el servidor alcanza a guardar tu personaje.
2. Recién después, **TERMINAR.bat**.

Si apagás el servidor con el juego abierto, `sesion-guardar.sh` igual le da
120 segundos al worldserver para guardar — pero no lo hagas costumbre.
