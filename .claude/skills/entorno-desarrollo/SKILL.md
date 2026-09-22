---
name: entorno-desarrollo
description: Levantar, compilar y diagnosticar el entorno de desarrollo de AzerothCore con Docker o desde fuente. Usar cuando no compila, no arranca, no se puede loguear, faltan datos del cliente, o cuando digan /entorno.
---

# Entorno de desarrollo

Antes de responder nada, preguntá (o deducí del repo) **qué camino usa el
usuario: Docker o build desde fuente**. Los diagnósticos son distintos.

## Árbol de diagnóstico

### No compila

| Síntoma | Causa típica |
|---|---|
| El compilador muere sin mensaje | OOM. Bajá a `make -j2`. WotLK necesita ~2 GB de RAM por job |
| `boost` no encontrado | Falta `libboost-all-dev` o la versión es vieja. AzerothCore pide Boost 1.74+ `[VERIFICAR]` |
| Un módulo no aparece en la build | No re-corriste `cmake`. Borrá `build/` y rehacelo |
| Errores raros tras un `git pull` | Build cache viejo. `rm -rf build && mkdir build` y cmake de nuevo |

### Compila pero el worldserver no arranca

1. Leé el log del arranque **completo**, de arriba a abajo. El primer error rojo
   es el que importa, no el último.
2. `Could not find DBC` / `Map file not found` → `DataDir` mal apuntado o
   assets no extraídos.
3. `Error connecting to MySQL` → credenciales, o MySQL no levantó todavía.
4. `Table 'acore_world.x' doesn't exist` → falta importar las bases:
   `./acore.sh db-assembler import-all`.
5. Se cuelga en "Loading..." → normal la primera vez, está aplicando migraciones.
   Dale 10 minutos antes de asumir que colgó.

### Arranca pero no puedo entrar

| Dónde falla | Mirá |
|---|---|
| "No se puede conectar" en la pantalla de login | `authserver` caído, o `realmlist.wtf` del cliente mal |
| Login OK pero la lista de realms vacía | Tabla `acore_auth.realmlist`, columna `address` |
| Elijo el realm y me vuelve al login | `worldserver` caído, o `realmlist.port` ≠ puerto real del world |
| "Versión incorrecta" | El cliente no es 3.3.5a build 12340 |
| Cuenta no existe | La creaste en la consola del world, no del auth — está bien, pero verificá `SELECT * FROM acore_auth.account;` |

### El mundo se ve raro

- Caigo al vacío → faltan `maps/`
- Disparo a través de paredes → faltan `vmaps/`
- Los mobs atraviesan el terreno → faltan `mmaps/`
- NPCs invisibles → `creature_template_model` sin modelo, o `dbc/` incompleto

## Comandos que conviene tener a mano

```bash
./acore.sh compiler all           # clean + cmake + build
./acore.sh compiler build         # solo build
./acore.sh db-assembler import-all
./acore.sh module install
./acore.sh docker build
./acore.sh docker start:app
./acore.sh docker attach          # consola del worldserver en Docker
```

## Consola del worldserver

```
server info          uptime, jugadores, diff
account create <user> <pass>
account set gmlevel <user> 3 -1
server shutdown 60 "motivo"
reload <tabla>
```

## Entregable

Cuando te piden ayuda con el entorno, entregá **comandos exactos para copiar y
pegar**, en orden, con qué esperar de cada uno. No describas procedimientos:
escribilos.
