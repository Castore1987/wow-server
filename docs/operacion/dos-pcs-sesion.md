# Jugar en dos PCs con la sesión sincronizada

Cada PC tiene su propia instalación completa del servidor. Lo único que viaja
entre ellas son **tus personajes**: unos pocos MB.

El destino puede ser una carpeta de nube (Drive, Dropbox, OneDrive) **o un
pendrive**. A los scripts les da igual: `WOW_SYNC_DIR` es una carpeta y punto.

> Sobre el pendrive: antes descartamos usarlo para **correr** el servidor, por
> el desgaste que le provoca la escritura constante de MySQL. Copiar un archivo
> de pocos MB al terminar de jugar es otra cosa completamente distinta, y para
> eso está perfecto.

```
   PC de casa                 Nube                    PC portátil
  ┌───────────┐         ┌──────────────┐            ┌───────────┐
  │ servidor  │ guardar │ sesion_*.gz  │  cargar    │ servidor  │
  │ completo  │────────▶│ ultimo.txt   │───────────▶│ completo  │
  │           │         │ sesion.lock  │            │           │
  └───────────┘         └──────────────┘            └───────────┘
```

## El peligro y cómo se evita

Si jugás en la PC-B sin cargar lo último de la PC-A, quedan dos historias
paralelas y **no hay forma de fusionarlas**: una se pierde.

Por eso existe `sesion.lock`, un archivo en la carpeta de la nube que dice qué
PC tiene la sesión tomada. Si la otra intenta arrancar, se niega.

No depende de que te acuerdes. Depende del candado.

## Preparar cada PC (una vez)

1. Instalación normal del servidor (ver `instalacion-windows-docker.md`).
2. Elegir el destino:
   - **Nube**: instalar el cliente (Drive, Dropbox, OneDrive) y dejar que sincronice.
     Ojo con Google Drive en modo *stream*: monta una unidad virtual (`G:`) que
     **WSL no puede ver**. Hay que pasarlo a "Duplicar archivos" o usar otra cosa.
   - **Pendrive**: enchufarlo y montarlo (ver abajo).
3. En el repo:

```bash
cp scripts/sesion-config.sh scripts/sesion-config.local.sh
nano scripts/sesion-config.local.sh
```

Ajustar `WOW_SYNC_DIR` a la carpeta de la nube, en ruta de WSL:

```bash
WOW_SYNC_DIR="/mnt/c/Users/TuUsuario/Google Drive/wow-server"
```

> `sesion-config.local.sh` está en `.gitignore`. Cada PC tiene el suyo.

4. Crear la cuenta de juego **en las dos PCs con el mismo nombre**. Como
   `acore_auth` viaja en el dump, después queda unificada igual.

## Uso diario

**Antes de jugar:**

```bash
cd ~/wow-server && ./scripts/sesion-cargar.sh
```

**Al terminar:**

```bash
cd ~/wow-server && ./scripts/sesion-guardar.sh
```

Con nube: esperá a que termine de subir antes de arrancar en la otra PC.
Con pendrive: expulsalo desde Windows antes de desenchufarlo.

## Si el destino es un pendrive

WSL no monta las unidades removibles solas cuando las enchufás después de
arrancar. Cada vez que lo conectes:

```bash
sudo mount -t drvfs E: /mnt/e 2>/dev/null
```

Para no tipearlo siempre:

```bash
echo "alias pen='sudo mount -t drvfs E: /mnt/e 2>/dev/null; ls /mnt/e/wow-server'" >> ~/.bashrc
source ~/.bashrc
```

Después alcanza con escribir `pen`.

No hace falta formatearlo en NTFS: eso aplicaba a guardar el disco virtual de
Linux, no a copiar un archivo de pocos MB.

## Qué hace cada script

### `sesion-cargar.sh`

1. Verifica el candado. Si lo tiene otra PC, **se niega y te dice cuál**.
2. Levanta solo MySQL y espera a que responda.
3. Guarda una copia del estado local en `~/backups/antes-de-restaurar_*.sql.gz`.
4. Restaura los personajes desde la nube.
5. Levanta el resto del servidor.
6. Toma el candado a nombre de esta PC.

### `sesion-guardar.sh`

1. Apaga el worldserver con `-t 120`, para que alcance a guardar a los jugadores.
2. Exporta `acore_characters` y `acore_auth`.
3. **Verifica que el dump no salga vacío.** Si sale vacío, aborta sin tocar la
   nube ni el candado: preferís no guardar antes que guardar basura encima.
4. Lo copia a la nube y actualiza `ultimo.txt`.
5. Suelta el candado y apaga el servidor.
6. Deja las últimas 10 sesiones en la nube y borra las más viejas.

## Si el candado quedó trabado

Pasa si una PC se apagó sin guardar. Desde la PC donde querés jugar:

```bash
./scripts/sesion-cargar.sh --forzar
```

> ⚠️ Forzar descarta lo que haya quedado sin guardar en la otra PC.
> Antes de forzar, si podés, andá a esa PC y corré `sesion-guardar.sh`.

## Qué NO viaja

| Qué | Dónde vive |
|---|---|
| Personajes, items, oro, correo, banco | ✅ Viaja (`acore_characters`) |
| Cuenta y permisos de GM | ✅ Viaja (`acore_auth`) |
| El mundo (NPCs, quests, loot) | Se reconstruye solo en cada PC |
| Tus cambios propios al mundo | Van versionados en `sql/`, no en el dump |
| **Macros, atajos, addons, interfaz** | ❌ **No viajan.** Son del cliente |

Para llevar las macros de una PC a otra, copiá a mano esta carpeta del cliente:

```
<carpeta WoW>\WTF\Account\<TU_CUENTA>\
```

Con el WoW cerrado, o al salir te pisa el archivo.

## Por qué `acore_world` no viaja

Pesa GB y se reconstruye sola desde las imágenes de Docker. Y tus
modificaciones propias del mundo tienen que vivir en `sql/custom/` versionadas
en git, que es donde se pueden revisar y revertir — no escondidas dentro de un
dump binario que va y viene.

Si alguna vez el mundo queda distinto entre las dos PCs, la respuesta correcta
es aplicar los `sql/` en la que falta, no sincronizar el dump.
