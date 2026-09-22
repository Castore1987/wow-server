---
name: modulos-y-cpp
description: Crear módulos de AzerothCore y escribir C++ contra los hooks del ScriptMgr sin tocar el core. Usar cuando haga falta lógica nueva que SQL no puede expresar, cuando pidan un módulo, un script de jefe, un sistema propio, o cuando digan /modulo.
---

# Módulos y C++

Antes de escribir C++, contestá: **¿esto no se puede hacer con SmartAI o con
config?** Si se puede, se hace así. Ver `azerothcore-arquitectura`.

## Esqueleto de un módulo

```
modules/mod-ejemplo/
├── CMakeLists.txt
├── README.md
├── conf/
│   └── mod_ejemplo.conf.dist
├── data/sql/db-world/base/mod_ejemplo.sql
└── src/
    ├── mod_ejemplo.cpp
    └── mod_ejemplo_loader.cpp
```

`CMakeLists.txt`:

```cmake
AC_ADD_SCRIPT_LOADER("mod_ejemplo" "${CMAKE_CURRENT_LIST_DIR}/src/mod_ejemplo_loader.cpp")
AC_ADD_SCRIPTS("${CMAKE_CURRENT_LIST_DIR}/src")
AC_ADD_CONFIG_FILE("${CMAKE_CURRENT_LIST_DIR}/conf/mod_ejemplo.conf.dist")
```

`[VERIFICAR]` las macros contra un módulo oficial reciente de
`azerothcore-modules`: el API de CMake cambió alguna vez.

`src/mod_ejemplo_loader.cpp`:

```cpp
void Addmod_ejemploScripts()
{
    AddMod_ejemploPlayerScripts();
}
```

## Hooks

Todos salen de `src/server/game/Scripting/ScriptMgr.h`. Antes de inventar uno:

```bash
grep -n "virtual void On" src/server/game/Scripting/ScriptMgr.h | less
```

Los que más se usan:

```cpp
class MiPlayerScript : public PlayerScript
{
public:
    MiPlayerScript() : PlayerScript("MiPlayerScript") { }

    void OnLogin(Player* player) override;
    void OnLevelChanged(Player* player, uint8 oldLevel) override;
    void OnPlayerKilledByCreature(Creature* killer, Player* killed) override;
    void OnCreatureKill(Player* killer, Creature* killed) override;
    void OnMapChanged(Player* player) override;
};
```

`[VERIFICAR]` cada firma: cambian entre versiones de AzerothCore y compilar con
una firma vieja da errores que no dicen nada útil.

Otras clases: `WorldScript` (arranque, config reload), `CreatureScript`
(IA de un NPC), `AllMapScript`, `AllCreatureScript`, `GlobalScript`,
`CommandScript` (comandos GM propios).

## Config del módulo

```cpp
#include "Config.h"

bool enabled = sConfigMgr->GetOption<bool>("Mod.Ejemplo.Enable", false);
uint32 valor = sConfigMgr->GetOption<uint32>("Mod.Ejemplo.Valor", 10);
```

Default **siempre seguro** (`Enable = false`). Un módulo que se activa solo al
instalarlo es un módulo que rompe servidores ajenos.

Releé la config en `WorldScript::OnAfterConfigLoad(bool reload)` para soportar
`.reload config`.

## Reglas de performance

El worldserver corre los mapas en hilos. Lo que escribas dentro de un hook se
ejecuta **en el update loop**:

- **Nunca** una query síncrona (`CharacterDatabase.Query`) en un hook de
  gameplay. Usá `AsyncQuery` con callback, o cacheá al arranque.
- Nada de `new`/`delete` por tick. Nada de `std::string` construido en bucles
  por jugador.
- Nada de estado global mutable sin protección: dos mapas pueden entrar a la vez.
- Los `LOG_INFO` dentro de bucles por jugador se notan en el diff.

## Compilar

```bash
cd build
cmake ../ -DCMAKE_INSTALL_PREFIX=$HOME/azeroth-server/ -DMODULES=static ...
make -j$(nproc) && make install
```

**Después de agregar o quitar un módulo hay que volver a correr `cmake`.** Solo
`make` no lo ve. Si tu módulo "no hace nada", ese es el motivo el 80% de las veces.

Copiá `mod_ejemplo.conf.dist` a `mod_ejemplo.conf` en el `etc/` del servidor
instalado y activá `Enable = 1`.

## Entregable

Un módulo no está listo sin:

- `README.md` con qué hace, qué configs tiene y cómo se prueba.
- SQL propio en `data/sql/db-world/base/`, idempotente.
- `Enable = 0` por defecto.
- Pasos exactos de prueba in-game.
