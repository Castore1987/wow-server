# Instalación en Windows con WSL2 + Docker

Procedimiento real, ejecutado y verificado el 2026-09-25. De cero a jugando en
una tarde, **sin compilar nada**.

Este es el camino recomendado en Windows. Evita Visual Studio y la compilación
del core, que es donde se cae la mayoría de la gente.

## Lo que necesitás antes de empezar

- Windows 10 (2004+) u 11
- Un cliente de WoW **3.3.5a build 12340** propio
- ~15 GB libres de disco
- Virtualización habilitada en la BIOS (casi siempre viene así)

---

## Paso 1 — Verificar la build del cliente

AzerothCore funciona **solo** con la build `12340`. Verificar esto primero
ahorra descubrir el problema tres horas después.

Clic derecho en `Wow.exe` → **Propiedades** → pestaña **Detalles** → campo
**Versión del archivo**. Tiene que terminar en `12340`.

Alternativa: abrir el juego y mirar abajo a la izquierda en la pantalla de login.

## Paso 2 — Instalar WSL2

PowerShell **como administrador**:

```powershell
wsl --install
```

Reiniciar. Al volver, se abre una consola que pide crear usuario:

- El usuario debe empezar con **minúscula** (`Javier` es rechazado, `javier` no).
- La contraseña **no se ve mientras se tipea**. Es normal.

Queda un prompt tipo `usuario@MAQUINA:~$`.

## Paso 3 — Instalar Docker Desktop

Descargar de https://www.docker.com/products/docker-desktop/ (AMD64).

En el instalador:

- **Per-user installation** (recomendada, no pide permisos de admin)
- **Use WSL 2 instead of Hyper-V** tildado (con la per-user es obligatorio)
- **Allow Windows Containers** destildado

Al abrirlo por primera vez pide crear cuenta: **no hace falta**, hay un `Skip`
arriba a la derecha.

Después: **Settings → Resources → WSL Integration** → tildar `Ubuntu` →
**Apply & Restart**.

Verificación, desde la terminal de Ubuntu:

```bash
docker run hello-world
```

Tiene que decir `Hello from Docker!`.

## Paso 4 — Bajar y levantar AzerothCore

Todo desde la terminal de **Ubuntu**, no desde PowerShell.

```bash
sudo apt update && sudo apt install -y git

cd ~
git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch
cd azerothcore-wotlk
```

> Cloná en `~`, **no** en `/mnt/c/...`. El sistema de archivos de Linux es
> mucho más rápido que el de Windows montado, y la diferencia se nota.

Si ya hay un MySQL en la máquina ocupando el 3306, moverlo:

```bash
echo "DOCKER_DB_EXTERNAL_PORT=64306" > .env
```

Levantar:

```bash
docker compose up -d
```

> **Sin `--build`.** Con `--build` compila el core desde cero (40+ minutos).
> Sin él, se baja las imágenes ya construidas de Docker Hub.

Descarga ~5-6 GB. En una conexión doméstica, unos 10 minutos en total incluyendo
el import de las bases.

Estado esperado con `docker compose ps`:

| Contenedor | Estado |
|---|---|
| `ac-database` | `Up (healthy)` |
| `ac-db-import` | `Exited (0)` ← correcto, terminó su trabajo |
| `ac-client-data-init` | `Exited (0)` ← correcto |
| `ac-authserver` | `Up` |
| `ac-worldserver` | `Up` |

Los datos del cliente (dbc, maps, vmaps, mmaps) los trae el contenedor
`ac-client-data-init` ya extraídos. **No hace falta correr los extractores**,
que es el paso que normalmente lleva horas.

Para ver el arranque:

```bash
docker compose logs -f ac-worldserver
```

Listo cuando aparece `World initialized in X minutes Y seconds`.

## Paso 5 — Crear la cuenta

```bash
docker attach ac-worldserver
```

En el prompt `AC>`:

```
account create <usuario> <contraseña>
account set gmlevel <usuario> 3 -1
```

Límites del cliente 3.3.5a: usuario y contraseña de **máximo 16 caracteres**,
sin acentos, sin ñ, sin espacios. No distingue mayúsculas.

> 🛑 **Para salir de `docker attach`: Ctrl+P y después Ctrl+Q.**
> **Ctrl+C apaga el worldserver.** Ver la sección de trampas.

Verificar desde fuera:

```bash
docker compose exec ac-database mysql -uroot -ppassword -e \
  "SELECT a.id, a.username, aa.gmlevel, aa.RealmID
   FROM acore_auth.account a
   LEFT JOIN acore_auth.account_access aa ON a.id = aa.id;"
```

(La columna de `account_access` se llama `id`, **no** `AccountID`.)

## Paso 6 — Apuntar el cliente

Editar `<carpeta WoW>\Data\<locale>\realmlist.wtf` — con `<locale>` = `esMX`,
`esES`, `enUS`, según el cliente. Dejar una sola línea:

```
set realmlist 127.0.0.1
```

Si no deja guardar: clic derecho → Propiedades → destildar **Solo lectura**.

Ejecutar **`Wow.exe` directamente**. Los launchers de los repacks suelen
reescribir el `realmlist.wtf` y devolverte a su servidor.

Login con la cuenta creada. Verificar GM in-game con `.gps`.

---

## Operación diaria

```bash
cd ~/azerothcore-wotlk
docker compose up -d      # prender
docker compose stop       # apagar
docker compose ps         # estado
docker compose logs -f ac-worldserver
```

El compose trae `restart: unless-stopped`, así que los contenedores vuelven
solos cuando arranca Docker Desktop, y también si el worldserver se cae.

---

## Trampas con las que nos topamos

| Trampa | Qué pasa | Solución |
|---|---|---|
| **Ctrl+C dentro de `docker attach`** | Apaga el worldserver. Se ve `Halting process...` y las líneas de `Closing down DatabasePool` | Salir con **Ctrl+P, Ctrl+Q**. Si igual pasa, el `restart: unless-stopped` lo levanta solo, o `docker compose up -d` |
| **MySQL de Windows en el 3306** | El contenedor no puede tomar el puerto | `echo "DOCKER_DB_EXTERNAL_PORT=64306" > .env` antes del primer `up` |
| **Usuario de WSL con mayúscula** | `Invalid username` | Solo minúsculas, empezando por letra o guion bajo |
| **`account set gmlevel` con el nombre equivocado** | Responde como si hubiera funcionado | Verificar siempre con la consulta SQL de arriba, no confiar en el mensaje |
| **`docker compose up -d --build`** | Se pone a compilar el core, 40+ minutos al pedo | Sin `--build` |
| **Clonar en `/mnt/c/...`** | Todo lento | Clonar en `~` |
| **Usar el launcher del repack** | Te devuelve al servidor original | Ejecutar `Wow.exe` directo |
| **`.learn all` in-game** | Enseña también los hechizos internos de prueba del emulador (`daño3`, `Automation Root Spell`…) y podés enraizarte solo | Usar `.learn all my class`. Para limpiar: `.die` + `.revive` saca las auras; `.reset spells` borra todo y se rehace con `.learn all my class` |

Ver la lista verificada de comandos GM en
[`recursos/comandos-gm.md`](../../recursos/comandos-gm.md).
