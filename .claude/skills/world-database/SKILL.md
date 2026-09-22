---
name: world-database
description: Crear y corregir contenido del mundo en acore_world - creatures, gameobjects, quests, loot, vendors, spawns y SmartAI. Usar cuando pidan un NPC, una quest, un drop, un vendor, arreglar algo que está mal en el mundo, o cuando digan /quest o /npc.
---

# Construir el mundo en la base de datos

Leé `docs/arquitectura/bases-de-datos.md` antes de escribir el primer `INSERT`:
ahí está el rango de IDs reservado para contenido propio.

## Reglas duras

1. **Idempotencia**: `DELETE` con `WHERE` exacto antes de cada `INSERT`.
2. **Rango propio**: entries custom desde 900000. Nunca pises un ID de Blizzard.
3. **Corregir ≠ duplicar**: si un NPC original está mal, `UPDATE` sobre su fila.
4. **Un archivo por cambio**, en `sql/custom/<dominio>/` o `sql/updates/`.
5. **Siempre decir cómo se prueba in-game.**

## Crear un NPC — orden de las tablas

```sql
-- 1. El template
DELETE FROM `creature_template` WHERE `entry` = 900001;
INSERT INTO `creature_template`
  (`entry`, `name`, `subname`, `minlevel`, `maxlevel`, `faction`, `npcflag`,
   `unit_class`, `rank`, `AIName`, `ScriptName`)
VALUES
  (900001, 'Nombre del NPC', 'Título', 80, 80, 35, 0, 1, 0, '', '');

-- 2. El modelo (AzerothCore lo separó del template)
DELETE FROM `creature_template_model` WHERE `CreatureID` = 900001;
INSERT INTO `creature_template_model`
  (`CreatureID`, `Idx`, `CreatureDisplayID`, `DisplayScale`, `Probability`)
VALUES (900001, 0, 19646, 1, 1);

-- 3. El spawn
DELETE FROM `creature` WHERE `id1` = 900001;
INSERT INTO `creature`
  (`guid`, `id1`, `map`, `position_x`, `position_y`, `position_z`, `orientation`,
   `spawntimesecs`, `MovementType`)
VALUES (900001, 900001, 0, -8913.0, 554.6, 93.8, 0.6, 300, 0);
```

`[VERIFICAR]` los nombres de columnas contra el schema de tu versión antes de
correr: `DESCRIBE creature_template;`. AzerothCore cambia columnas entre
releases (`id1..id3` en `creature`, el split de `creature_template_model`).

Valores de `faction` que se usan seguido: `35` amistoso a todos, `14` hostil a
todos, `1801` Alianza genérica, `1802` Horda genérica `[VERIFICAR]`.

`npcflag`: `1` gossip, `2` questgiver, `128` vendor, `16` trainer, `4096` banquero,
`65536` auctioneer. Se suman: un vendor con gossip es `129`.

## Quest

```sql
DELETE FROM `quest_template` WHERE `ID` = 900010;
INSERT INTO `quest_template`
  (`ID`, `QuestType`, `QuestLevel`, `MinLevel`, `QuestSortID`,
   `RewardXPDifficulty`, `LogTitle`, `LogDescription`, `QuestDescription`,
   `RequiredNpcOrGo1`, `RequiredNpcOrGoCount1`)
VALUES (900010, 2, 80, 78, 0, 5, 'Título', 'Objetivo', 'Texto largo', 900001, 10);

DELETE FROM `quest_template_addon` WHERE `ID` = 900010;
INSERT INTO `quest_template_addon` (`ID`, `PrevQuestID`, `NextQuestID`)
VALUES (900010, 0, 0);

DELETE FROM `creature_queststarter` WHERE `quest` = 900010;
INSERT INTO `creature_queststarter` (`id`, `quest`) VALUES (900001, 900010);

DELETE FROM `creature_questender` WHERE `quest` = 900010;
INSERT INTO `creature_questender` (`id`, `quest`) VALUES (900001, 900010);
```

Una quest sin `queststarter`/`questender` existe pero es invisible. Es el olvido
número uno.

## Loot

```sql
DELETE FROM `creature_loot_template` WHERE `Entry` = 900001;
INSERT INTO `creature_loot_template`
  (`Entry`, `Item`, `Reference`, `Chance`, `QuestRequired`, `LootMode`,
   `GroupId`, `MinCount`, `MaxCount`)
VALUES
  (900001, 40000, 0, 15, 0, 1, 0, 1, 1),
  (900001, 40001, 0, 100, 1, 1, 0, 1, 1);
```

- `Chance` positivo = porcentaje independiente. Negativo = referencia a grupo.
- `GroupId` > 0 = de ese grupo sale exactamente un item (las chances compiten).
- `QuestRequired = 1` = solo dropea si tenés la quest activa.

## SmartAI

```sql
UPDATE `creature_template` SET `AIName` = 'SmartAI' WHERE `entry` = 900001;

DELETE FROM `smart_scripts` WHERE `entryorguid` = 900001 AND `source_type` = 0;
INSERT INTO `smart_scripts`
  (`entryorguid`, `source_type`, `id`, `event_type`, `event_chance`,
   `event_flags`, `event_param1`, `event_param2`, `event_param3`, `event_param4`,
   `action_type`, `action_param1`, `target_type`, `comment`)
VALUES
  (900001, 0, 0, 4, 100, 0, 0, 0, 0, 0, 1, 0, 1, 'NPC - Al agro - Decir línea 0'),
  (900001, 0, 1, 0, 100, 0, 3000, 5000, 8000, 12000, 11, 12555, 2, 'NPC - En combate - Lanzar hechizo');
```

`event_type` frecuentes: `0` UPDATE_IC (en combate), `1` UPDATE_OOC (fuera de
combate), `2` HEALTH_PCT, `4` AGGRO, `6` DEATH, `25` RESPAWN, `19` ACCEPTED_QUEST,
`20` REWARD_QUEST, `62` GOSSIP_SELECT `[VERIFICAR]` contra el enum
`SMART_EVENT_*` del core.

`action_type` frecuentes: `1` TALK, `11` CAST, `12` SUMMON_CREATURE, `28` REMOVE_AURA,
`33` CALL_KILLEDMONSTER, `41` FORCE_DESPAWN, `53` WP_START.

`target_type`: `1` SELF, `2` VICTIM, `7` ACTION_INVOKER, `19` CLOSEST_CREATURE.

Un `UPDATE_IC` con los cuatro tiempos en 0 es un loop infinito que cuelga el
mapa. Nunca dejes repeat en 0 salvo que sepas exactamente por qué.

El campo `comment` **no es opcional** en este repo: es lo único que va a leer
quien toque esto dentro de seis meses.

## Antes de entregar

Cada archivo SQL se entrega con:

```
-- Probar con:
--   .reload creature_template
--   .reload smart_scripts
--   .npc add 900001
--   .go creature 900001
```

Y mirá `DBErrors.log` después de aplicar: si tu contenido tiene un dato
inconsistente, aparece ahí.
