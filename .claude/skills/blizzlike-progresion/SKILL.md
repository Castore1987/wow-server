---
name: blizzlike-progresion
description: Rates, economía, gating de contenido y apertura de fases de WotLK. Usar cuando pregunten por rates de XP o drop, por qué contenido abrir, cómo cerrar una raid, requisitos de instancia, balance, o cuando digan /fase o /balance.
---

# Blizzlike y progresión

La referencia es **WotLK 3.3.5a original**. Todo desvío se documenta en
`docs/progresion/desvios-blizzlike.md` con motivo, valor y cómo revertirlo.

## Las fases de WotLK

| Fase | Contenido que abre |
|---|---|
| 1 | Naxxramas, El Ojo de la Eternidad (Malygos), Cámara de Obsidiana (Sartharion) |
| 2 | Ulduar |
| 3 | Prueba del Cruzado (ToC) + Torneo Argenta + Coliseo |
| 4 | Ciudadela de la Corona de Hielo (ICC) + Cámara Rubí (Halion) en 3.3.2 |
| 5 | Ruby Sanctum como contenido final `[VERIFICAR]` el orden exacto contra el changelog de parches de la época |

El plan concreto de este servidor, con fechas y requisitos, está en
`docs/progresion/plan-de-fases.md`. **Ese archivo manda sobre esta tabla.**

## Cómo se cierra contenido

Tres herramientas, en orden de preferencia:

### 1. `disables` — la más limpia

```sql
-- Cerrar Ulduar (mapa 603) hasta la fase 2
DELETE FROM `disables` WHERE `sourceType` = 2 AND `entry` = 603;
INSERT INTO `disables` (`sourceType`, `entry`, `flags`, `comment`)
VALUES (2, 603, 0, 'Fase 2 - cerrado hasta apertura');
```

`sourceType`: `0` spell, `1` quest, `2` map, `3` battleground `[VERIFICAR]`
contra el enum `DisableType` del core de tu versión antes de usarlo.

Abrir la fase = borrar la fila + `.reload disables`.

### 2. `access_requirement` — para subir el piso de entrada

```sql
UPDATE `access_requirement`
SET `item_level` = 219
WHERE `mapId` = 631 AND `difficulty` = 0;
```

Sirve para simular el gear check de la época sin cerrar el mapa entero.

### 3. `game_event` — para lo que abre y cierra por calendario

Eventos estacionales y el Torneo Argenta. Se controla con
`.event start <id>` / `.event stop <id>` y las fechas de la tabla `game_event`.

## Checklist para abrir una fase

No alcanza con destrabar el mapa. Antes de anunciar la apertura:

- [ ] Mapa habilitado en `disables` (normal **y** heroico).
- [ ] `access_requirement` con el item level / attunement correcto.
- [ ] Vendors de emblemas de la fase: items nuevos agregados, anteriores
      bajados de precio o movidos según corresponda.
- [ ] Quests de atunement / cadena de entrada activas.
- [ ] Loot de los jefes verificado contra la lista de la época.
- [ ] Buff de raid del parche correspondiente (si aplica) configurado.
- [ ] Prueba in-game: entrar, pullear el primer jefe, verificar el loot.
- [ ] Anuncio a jugadores con fecha y hora.

Cerrar la fase anterior **no** es parte del checklist: en blizzlike, el
contenido viejo sigue abierto.

## Rates

Blizzlike es `1` en todo. Si el servidor se aparta, se mueven **en conjunto**:

| Config | Qué toca |
|---|---|
| `Rate.XP.Kill`, `Rate.XP.Quest`, `Rate.XP.Explore` | Velocidad de leveo |
| `Rate.Drop.Money` | Oro |
| `Rate.Drop.Item.Poor/Normal/Uncommon/Rare/Epic/Legendary/Artifact` | Loot |
| `Rate.Reputation.Gain` | Reputación |
| `Rate.Honor` | PvP |
| `Rate.Rest.InGame`, `Rate.Rest.Offline.InTavernOrCity` | Descanso |

`[VERIFICAR]` cada nombre contra el `worldserver.conf.dist` de tu versión.

Subir XP sin subir reputación y oro produce nivel 80 sin gear, sin dinero y sin
acceso a nada. Es el error clásico de los servidores x5.

**`Rate.MoveSpeed` no se toca.** Rompe pathfinding y produce desync con el
cliente.

## Cómo se entrega una propuesta de balance

Nunca "subilo a 3". Siempre:

1. Valor actual → valor propuesto, config por config.
2. Efecto esperado, en términos concretos (horas de 1 a 80, oro por hora).
3. Qué medir a 7 y 14 días para saber si funcionó.
4. Cómo se revierte.

Si no tenés el dato de partida (oro promedio, tiempo real de leveo actual),
pedilo. Sin dato, es adivinar, y lo decís así.
