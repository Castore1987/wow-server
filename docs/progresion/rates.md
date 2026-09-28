# Rates

Valores vigentes. Se aplican como **variables de entorno** en
`docker-compose.override.yml`, no editando `worldserver.conf`.

## Por qué variables de entorno y no el archivo

El worldserver acepta cualquier opción de configuración como variable
`AC_<NOMBRE>`. Se ve en el log de arranque:

```
Config: Found config value 'Rate.Drop.Item.Epic' from environment variable 'AC_RATE_DROP_ITEM_EPIC'
```

Ventajas sobre editar el `.conf`:

- Queda en un archivo **versionado en git**, no escondido dentro de un volumen
- Sobrevive a que se recree el contenedor
- Se revierte borrando una línea

La conversión del nombre es mecánica: puntos por guiones bajos, todo en
mayúsculas. Ojo con las opciones que llevan mayúscula interna
(`ReferencedAmount`), donde la conversión separa las palabras
(`AC_RATE_DROP_ITEM_REFERENCED_AMOUNT`) — esas conviene verificarlas en el log
antes de darlas por buenas.

## Vigentes

| Config | Blizzlike | Acá | Variable de entorno |
|---|---|---|---|
| `Rate.XP.Kill` | 1 | **10** | `AC_RATE_XP_KILL` |
| `Rate.XP.Quest` | 1 | **10** | `AC_RATE_XP_QUEST` |
| `Rate.XP.Explore` | 1 | **10** | `AC_RATE_XP_EXPLORE` |
| `Rate.XP.Pet` | 1 | **10** | `AC_RATE_XP_PET` |
| `Rate.Drop.Money` | 1 | **5** | `AC_RATE_DROP_MONEY` |
| `Rate.Reputation.Gain` | 1 | **5** | `AC_RATE_REPUTATION_GAIN` |
| `Rate.Drop.Item.Uncommon` | 1 | **3** | `AC_RATE_DROP_ITEM_UNCOMMON` |
| `Rate.Drop.Item.Rare` | 1 | **5** | `AC_RATE_DROP_ITEM_RARE` |
| `Rate.Drop.Item.Epic` | 1 | **10** | `AC_RATE_DROP_ITEM_EPIC` |
| `Rate.Drop.Item.Legendary` | 1 | **10** | `AC_RATE_DROP_ITEM_LEGENDARY` |
| `Rate.Drop.Item.Referenced` | 1 | **5** | `AC_RATE_DROP_ITEM_REFERENCED` |
| `Rate.MoveSpeed` | 1 | **1 — no se toca** | — |

Sin tocar: `Poor`, `Normal` (basura de vender), las siete
`Rate.XP.Battleground*` y las `Rate.Reputation.Gain.{AB,AV,WSG}` (no aplican
jugando solo), y las `Rate.Reputation.LowLevel.*` (regulan cuánta reputación
dan los mobs de nivel bajo, es otra cosa).

## Las dos decisiones que importan

**`Rate.Drop.Item.Referenced` no es opcional.** Buena parte del loot de jefes e
instancias no está en la tabla del NPC sino en *tablas de referencia*
compartidas. Subir `Epic` y dejar `Referenced` en 1 es el error clásico: el
equipamiento que se busca casi no se mueve.

**Las tasas se mueven en conjunto.** Subir solo la XP produce un nivel 80 sin
oro, sin reputación y sin profesiones — llegás al contenido final sin nada de
lo que hace falta para entrar. Por eso van oro y reputación junto con la XP.

Lo mismo con `Rate.XP.Explore` y `Rate.XP.Pet`: si solo subís muertes y
misiones, descubrir zonas queda irrelevante y la mascota del cazador se queda
atrás y deja de pegar.

## Cómo verificar que tomaron

```bash
docker compose logs ac-worldserver | grep -c "Found config value 'Rate"
```

Tiene que dar el número de variables definidas (hoy: **11**). Si da menos,
alguna no matcheó y hay que buscar cuál:

```bash
docker compose logs ac-worldserver | grep "Found config value 'Rate"
```

## Cómo se revierte

Borrar la línea del `docker-compose.override.yml` y `docker compose up -d`.
No toca la base ni los personajes.

## Historial

| Fecha | Cambio | Motivo |
|---|---|---|
| 2026-09-28 | Drops: Uncommon x3, Rare x5, Epic x10, Legendary x10, Referenced x5 | Servidor de una persona; el equipamiento de baja tasa era inalcanzable jugando solo |
| 2026-09-28 | XP x10 (Kill, Quest, Explore, Pet) | Llegar al contenido de nivel 80 sin la progresión completa de un servidor poblado |
| 2026-09-28 | Oro x5, Reputación x5 | Acompañar la XP: evitar el nivel 80 sin oro ni reputación |
