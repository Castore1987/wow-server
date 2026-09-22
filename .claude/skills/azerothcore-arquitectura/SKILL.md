---
name: azerothcore-arquitectura
description: Cómo está armado AzerothCore por dentro — procesos, bases de datos, assets del cliente, sistema de módulos y dónde vive cada cosa. Usar antes de decidir en qué capa resolver un cambio, cuando algo no anda y no se sabe por dónde empezar, o cuando pregunten cómo funciona el servidor.
---

# Arquitectura de AzerothCore

## Los dos procesos

| Proceso | Puerto | Qué hace |
|---|---|---|
| `authserver` | 3724 | Login, SRP6, devuelve la lista de realms. Habla solo con `acore_auth`. |
| `worldserver` | 8085 | **Todo el juego**. Habla con las tres bases. Es el que consume CPU y RAM. |

Si los jugadores entran pero no ven realms → `authserver` o tabla `realmlist`.
Si ven el realm pero no conectan → `worldserver` caído, o `realmlist.address`
mal (típico: `127.0.0.1` cuando el jugador es remoto).

## Las tres bases

| Base | Qué guarda | ¿Se pisa al actualizar? |
|---|---|---|
| `acore_auth` | Cuentas, realms, bans, accesos GM | Sí, con migraciones |
| `acore_characters` | **Personajes, items, mail, guilds, AH** | Nunca. Es la irremplazable |
| `acore_world` | El mundo: NPCs, quests, loot, spawns, scripts | Sí, upstream la actualiza seguido |

El worldserver aplica las migraciones pendientes solo al arrancar, si
`Updates.EnableDatabases` está activo (`7` = las tres). Por eso tu SQL custom
tiene que ser **idempotente**: se reaplica.

## Assets del cliente

El servidor no tiene el arte ni la geometría: los lee de archivos extraídos del
cliente 3.3.5a, que van en `DataDir`.

| Carpeta | Qué es | Si falta... |
|---|---|---|
| `dbc/` | Tablas estáticas de Blizzard (spells, items, mapas, talentos) | El worldserver no arranca |
| `maps/` | Altura del terreno | Los jugadores caen al vacío |
| `vmaps/` | Colisiones (paredes, edificios) | Se dispara a través de paredes, LoS roto |
| `mmaps/` | Navegación de NPCs | Los mobs caminan en línea recta y atraviesan todo |
| `Cameras/` | Cinemáticas | Cinemáticas rotas |

Los `mmaps` tardan horas en generarse. No los borres sin necesidad.

## Las cuatro capas de un cambio

Elegí siempre la más alta posible:

1. **Config** (`worldserver.conf`) — rates, límites, features on/off. Reversible,
   sin compilar.
2. **SQL** (`acore_world`) — contenido, NPCs, quests, loot, SmartAI. El 90% del
   trabajo real vive acá. Recargable con `.reload`.
3. **Módulo** (`modules/mod-*`) — lógica nueva en C++ sin tocar upstream.
   Requiere re-correr cmake y compilar.
4. **Core** (`src/server/`) — última opción. Se pierde en cada `git pull`.

Cuando alguien te pide algo, tu primera respuesta es **en qué capa va**.

## Sistema de módulos

- Viven en `modules/`, cada uno es un repo git independiente.
- Se instalan clonando ahí adentro (o con `./acore.sh module install`).
- **Después de agregar, quitar o renombrar un módulo hay que volver a correr
  `cmake`**. `make` solo no lo detecta. Es el error más común.
- Cada módulo trae su `conf/*.conf.dist` que hay que copiar a `.conf` en el
  `etc/` del servidor instalado.
- Su SQL va en `data/sql/db-world/base/` del módulo y se importa solo.

## Scripting: cuándo C++ y cuándo SmartAI

- **SmartAI** (tabla `smart_scripts`): IA de NPC, eventos, diálogos, spawns
  condicionados, la mayoría de las mecánicas de mundo abierto. Declarativo,
  recargable en caliente, sin compilar.
- **C++**: jefes de raid complejos, sistemas nuevos, cualquier cosa con estado
  que SmartAI no puede expresar.

Si dudás, empezá por SmartAI. Migrar de SmartAI a C++ es fácil; al revés no.

## Logs

`worldserver.log`, `DBErrors.log`, `Server.log` en el `logs/` del servidor
instalado. **`DBErrors.log` es el primero que hay que leer siempre**: junta
todos los datos inconsistentes de `acore_world` y explica la mitad de los
comportamientos raros in-game.
