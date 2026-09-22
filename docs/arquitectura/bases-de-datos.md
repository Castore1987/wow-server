# Bases de datos

## Las tres

| Base | Qué guarda | Upstream la actualiza | Irremplazable |
|---|---|---|---|
| `acore_auth` | Cuentas, realms, bans, `account_access` | Sí | No |
| `acore_characters` | Personajes, items, mail, guilds, AH, logros | Rara vez | **Sí** |
| `acore_world` | NPCs, quests, loot, spawns, SmartAI, vendors | Seguido | No |

`acore_characters` es la única que no se puede reconstruir. Todo procedimiento
que la toque empieza con un backup.

## Auto-update

El worldserver aplica las migraciones pendientes al arrancar si en
`worldserver.conf`:

```
Updates.EnableDatabases = 7   # 1=auth, 2=characters, 4=world (bitmask)
```

Por eso todo SQL propio tiene que ser **idempotente**: puede reaplicarse.

## Rangos de IDs propios

| Tabla | Rango reservado |
|---|---|
| `creature_template` | 900000 – 909999 |
| `gameobject_template` | 900000 – 909999 |
| `quest_template` | 900000 – 909999 |
| `item_template` | 900000 – 909999 |
| `creature` (guid de spawns) | 900000 en adelante |

Regla: **nunca se pisa un ID de Blizzard creando uno nuevo**. Si un NPC
original está mal, se corrige con `UPDATE` sobre su fila y el cambio va a
`sql/custom/overrides/`, que se re-aplica después de cada pull de upstream.

## Colisión con upstream

`acore_world` la actualiza AzerothCore con frecuencia. Los cambios propios
sobre filas originales **se pisan**. Por eso viven todos juntos en
`sql/custom/overrides/` y re-aplicarlos es un paso fijo del checklist de deploy
(`docs/operacion/runbook.md`, paso 5).

## Tablas que se tocan seguido

### Mundo

`creature_template`, `creature_template_model`, `creature`, `creature_addon`,
`gameobject_template`, `gameobject`, `quest_template`, `quest_template_addon`,
`creature_queststarter`, `creature_questender`, `creature_loot_template`,
`reference_loot_template`, `npc_vendor`, `npc_trainer`, `smart_scripts`,
`waypoints`, `conditions`, `game_event`, `disables`, `access_requirement`,
`instance_template`, `spell_dbc`.

### Personajes — leer sí, escribir con mucho cuidado

`characters`, `character_inventory`, `item_instance`, `mail`, `guild`,
`auctionhouse`, `character_achievement`.

Nunca un `UPDATE` masivo acá sin backup, sin `SELECT COUNT(*)` previo con el
mismo `WHERE`, y sin plan de rollback escrito.

### Auth

`account`, `account_access`, `realmlist`, `ip_banned`, `account_banned`.

Las contraseñas son SRP6 (`salt` + `verifier`). El servidor no conoce la
contraseña en claro y no debe conocerla nunca.

## Nunca en el repo

- Dumps de `acore_characters`.
- Emails, IPs o hashes de jugadores.
- Contraseñas, ni de prueba.

El `.gitignore` los bloquea, pero el criterio va primero.
