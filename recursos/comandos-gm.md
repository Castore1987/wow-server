# Comandos GM — lista verificada

> Todos los de esta página fueron verificados contra la tabla `command` del
> world DB de AzerothCore (`data/sql/base/db_world/command.sql`, rama `master`,
> consultada el 2026-09-25). **No es una lista de memoria.**
>
> La columna "nivel" es el `gmlevel` mínimo que necesita la cuenta.
> Ver el gmlevel propio: `SELECT gmlevel FROM acore_auth.account_access;`

Se escriben **dentro del juego**, empezando con un punto, después de apretar Enter.

## Ubicación y movimiento

| Comando | Nivel | Qué hace |
|---|---|---|
| `.gps` | 1 | Dónde estoy: mapa, zona, área, coordenadas |
| `.go xyz <x> <y> <z> <mapa>` | 1 | Ir a coordenadas. Ej: `.go xyz -8913 554 93 0` (Ventormenta) |
| `.go creature <entry>` | 1 | Ir al spawn de un NPC |
| `.go grid <x> <y> <mapa>` | 1 | Ir a una celda del mapa |
| `.teleport <lugar>` | 2 | Teletransporte por nombre. Ej: `.teleport orgrimmar` |

> ⚠️ **`.tele` no existe** en AzerothCore. El comando es `.teleport`.

## Modo GM

| Comando | Nivel | Qué hace |
|---|---|---|
| `.gm on` / `.gm off` | 1 | Activa/desactiva el modo GM |
| `.gm fly` | 2 | Volar en cualquier mapa |
| `.cheat god` | 2 | Invulnerable |
| `.cheat status` | 2 | Ver qué cheats están activos |

> Un bug que solo aparece **sin** `.gm on` es distinto de uno que aparece con GM
> activo: el modo GM saltea chequeos de facción, distancia, cooldown y requisitos
> de quest. Probá siempre con un personaje normal antes de dar un veredicto.

## Personaje

| Comando | Nivel | Qué hace |
|---|---|---|
| `.character level <nivel>` | 2 | Poner **en** ese nivel |
| `.levelup <n>` | 2 | **Sumar** n niveles |
| `.revive` | 2 | Revivir |
| `.die` | 2 | Morir. Útil: **limpia todas las auras** |
| `.modify money <cobre>` | 2 | Dar oro (en monedas de cobre) |
| `.modify speed <n>` | 2 | Velocidad. Solo para pruebas, genera desync |

> ⚠️ **`.modify level` no existe.** Para el nivel es `.character level`.

## Hechizos

| Comando | Nivel | Qué hace |
|---|---|---|
| `.learn all my class` | 2 | Los hechizos de tu clase y nivel |
| `.learn all my talents` | 2 | Los talentos |
| `.learn all my trainer` | 2 | Lo que te enseñaría un entrenador |
| `.learn all lang` | 2 | Todos los idiomas (hablar con la otra facción) |
| `.unlearn <spellId>` | 2 | Olvidar un hechizo |
| `.unaura <spellId>` | 2 | Quitar un efecto activo |
| `.reset spells` | 3 | Borrar todos los hechizos y volver a los iniciales |
| `.reset talents` | 3 | Resetear talentos |

> 🚨 **No uses `.learn all`.** Enseña *literalmente* todos los hechizos de la
> base, incluidos los internos de prueba del emulador (`daño3`, `daño7`,
> `Automation Root Spell`). Ese último te enraiza hasta que lo saques, y el
> libro de hechizos queda ilegible. Usá `.learn all my class`.
>
> Si ya pasó: `.die` + `.revive` saca las auras, y `.reset spells` seguido de
> `.learn all my class` deja el libro limpio.

## Items y NPCs

| Comando | Nivel | Qué hace |
|---|---|---|
| `.additem <entry> [cantidad]` | 2 | Darte un item |
| `.additem set <setId>` | 2 | Darte un set completo |
| `.npc info` | 2 | Todo sobre el NPC seleccionado (entry, facción, flags, script) |
| `.npc add <entry>` | 3 | Spawnear un NPC donde estás |

## Quests

| Comando | Nivel | Qué hace |
|---|---|---|
| `.quest add <id>` | 2 | Agregarte una quest |
| `.quest complete <id>` | 2 | Completarla |
| `.quest remove <id>` | 2 | Sacarla del log |

## Buscar IDs

| Comando | Nivel | Qué hace |
|---|---|---|
| `.lookup creature <texto>` | 1 | Buscar NPC por nombre |
| `.lookup item <texto>` | 1 | Buscar item |
| `.lookup quest <texto>` | 1 | Buscar quest |
| `.lookup spell <texto>` | 1 | Buscar hechizo |

Es la forma correcta de conseguir un ID: preguntárselo al servidor, no buscarlo
en internet ni adivinarlo.

## Servidor

| Comando | Nivel | Qué hace |
|---|---|---|
| `.server info` | 0 | Uptime, jugadores conectados, **diff** |
| `.server shutdown <seg> "<motivo>"` | 3 | Apagar avisando a los jugadores |
| `.reload <tabla>` | 3 | Recargar una tabla del world DB sin reiniciar |
| `.account create <user> <pass>` | 4 | Crear cuenta (nivel 4 = solo por consola) |
| `.account set gmlevel <user> <n> <realm>` | 3 | Dar permisos de GM |
| `.account set password <user> <nueva> <nueva>` | 3 | Cambiar contraseña |

El **diff** de `.server info` es la métrica de salud del servidor: por encima de
~100 ms sostenido hay un problema de performance. Ver `docs/operacion/runbook.md`.

## La lista completa

```
.commands
```

Nivel 0, la puede correr cualquiera. Muestra todos los comandos disponibles
según el gmlevel de tu cuenta.

## Niveles de GM

| Nivel | Quién |
|---|---|
| 0 | Jugador normal |
| 1 | Moderador — ver, no tocar |
| 2 | Game Master — la mayoría de los comandos útiles |
| 3 | Administrador — recargas, spawns, cuentas |
| 4 | Consola — solo desde el worldserver, no desde el juego |
