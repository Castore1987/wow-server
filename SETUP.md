# SETUP — Entorno de desarrollo

Dos caminos. Elegí uno y anotá cuál usás en `docs/servidor/perfil-servidor.md`.

> **¿Estás en Windows?** Andá directo a
> [`docs/operacion/instalacion-windows-docker.md`](docs/operacion/instalacion-windows-docker.md).
> Es el procedimiento que usa este servidor: WSL2 + Docker, sin compilar,
> probado de punta a punta y con las trampas documentadas.

---

## Camino A — Docker (recomendado para empezar)

Necesitás Docker y Docker Compose v2.

```bash
git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch
cd azerothcore-wotlk
cp conf/dist/config.sh conf/config.sh    # ajustes opcionales
./acore.sh docker build                  # compila dentro del contenedor
./acore.sh docker start:app              # levanta auth + world + mysql
```

El `docker-compose.yml` del repo expone por defecto:

| Servicio | Puerto |
|---|---|
| authserver | 3724 |
| worldserver | 8085 |
| worldserver (soap) | 7878 |
| mysql | 64306 (host) → 3306 (contenedor) |

Los datos extraídos del cliente (`dbc/`, `maps/`, `vmaps/`, `mmaps/`, `Cameras/`)
van en el volumen que indica el compose — normalmente `env/dist/data/`.

---

## Camino B — Build desde fuente en Linux

Probado en Ubuntu 22.04 / 24.04. `[VERIFICAR]` las versiones de paquetes contra
la documentación upstream antes de correr esto en una máquina nueva.

```bash
sudo apt update && sudo apt install -y \
  git cmake make gcc g++ clang libmysqlclient-dev libssl-dev \
  libbz2-dev libreadline-dev libncurses-dev libboost-all-dev \
  mysql-server p7zip-full

git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch
cd azerothcore-wotlk
mkdir build && cd build

cmake ../ \
  -DCMAKE_INSTALL_PREFIX=$HOME/azeroth-server/ \
  -DCMAKE_C_COMPILER=/usr/bin/clang \
  -DCMAKE_CXX_COMPILER=/usr/bin/clang++ \
  -DWITH_WARNINGS=1 \
  -DTOOLS_BUILD=all \
  -DSCRIPTS=static \
  -DMODULES=static

make -j $(nproc)
make install
```

`-j $(nproc)` con menos de 8 GB de RAM puede matar el compilador por OOM. Si
pasa, bajá a `-j 2`.

### Bases de datos

Tres bases, usuario `acore` por defecto:

```sql
CREATE USER 'acore'@'localhost' IDENTIFIED BY 'acore';
GRANT ALL PRIVILEGES ON *.* TO 'acore'@'localhost' WITH GRANT OPTION;
```

El worldserver crea e importa `acore_auth`, `acore_characters` y `acore_world`
solo en el primer arranque (o con `./acore.sh db-assembler import-all`).

### Configuración

```bash
cd $HOME/azeroth-server/etc
cp authserver.conf.dist authserver.conf
cp worldserver.conf.dist worldserver.conf
```

Lo mínimo a tocar en `worldserver.conf`:

- `DataDir` → carpeta con `dbc/ maps/ vmaps/ mmaps/`
- `LoginDatabaseInfo` / `WorldDatabaseInfo` / `CharacterDatabaseInfo`
- `Updates.EnableDatabases = 7` (auto-update de las tres DBs)

Y en la tabla `acore_auth.realmlist`:

```sql
UPDATE realmlist SET address = '<IP pública o LAN>', localAddress = '127.0.0.1'
WHERE id = 1;
```

---

## Datos del cliente

Necesitás un cliente WoW 3.3.5a (build 12340) **propio**. Desde la carpeta del
cliente, con los binarios que dejó `TOOLS_BUILD=all`:

```bash
./mapextractor        # dbc/ y maps/
./vmap4extractor && ./vmap4assembler Buildings vmaps
./mmaps_generator     # tarda horas; usá -j para paralelizar
```

Copiá `dbc/ maps/ vmaps/ mmaps/ Cameras/` al `DataDir` configurado.

## Cliente: apuntar al server

En `WoW/Data/esES/realmlist.wtf` (o `enUS`):

```
set realmlist 127.0.0.1
```

## Cuenta GM

En la consola del worldserver:

```
account create admin unaPasswordLarga
account set gmlevel admin 3 -1
```

Nivel 3 = administrador, `-1` = todos los realms.

## Verificación rápida

- `server info` en consola devuelve uptime y diff.
- `.gps` in-game responde → SmartAI y comandos GM funcionan.
- `.go xyz 1629 -4373 18 1` te mueve → maps/vmaps cargados bien.
