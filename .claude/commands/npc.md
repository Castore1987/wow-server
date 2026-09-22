---
description: Crea o corrige un creature/gameobject con su SmartAI y loot
argument-hint: [NPC o descripción]
---
NPC / gameobject: **$ARGUMENTS**

Seguí la skill `world-database`. Entregá `creature_template`,
`creature_template_model`, el spawn, el loot y el SmartAI con el campo
`comment` completo en cada línea. Si es una corrección sobre un NPC original de
Blizzard, usá `UPDATE` sobre su fila — no crees un entry nuevo — y dejá el
cambio en `sql/custom/overrides/`.
