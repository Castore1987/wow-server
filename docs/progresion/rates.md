# Rates

Valores vigentes, en `worldserver.conf`. Blizzlike es `1` en todo.

| Config | Blizzlike | Acá | Última revisión |
|---|---|---|---|
| `Rate.XP.Kill` | 1 | `<<COMPLETAR>>` | |
| `Rate.XP.Quest` | 1 | `<<COMPLETAR>>` | |
| `Rate.XP.Explore` | 1 | `<<COMPLETAR>>` | |
| `Rate.Drop.Money` | 1 | `<<COMPLETAR>>` | |
| `Rate.Drop.Item.Poor` | 1 | `<<COMPLETAR>>` | |
| `Rate.Drop.Item.Normal` | 1 | `<<COMPLETAR>>` | |
| `Rate.Drop.Item.Uncommon` | 1 | `<<COMPLETAR>>` | |
| `Rate.Drop.Item.Rare` | 1 | `<<COMPLETAR>>` | |
| `Rate.Drop.Item.Epic` | 1 | `<<COMPLETAR>>` | |
| `Rate.Reputation.Gain` | 1 | `<<COMPLETAR>>` | |
| `Rate.Honor` | 1 | `<<COMPLETAR>>` | |
| `Rate.Rest.InGame` | 1 | `<<COMPLETAR>>` | |
| `Rate.Creature.Normal.Damage` | 1 | `<<COMPLETAR>>` | |
| `Rate.MoveSpeed` | 1 | **1 — no se toca** | |

`[VERIFICAR]` cada nombre contra el `worldserver.conf.dist` de tu versión: los
nombres cambian entre releases.

## Reglas

- Los rates se mueven **en conjunto**. XP alta con reputación y oro en 1 produce
  personajes de nivel 80 sin gear, sin dinero y sin acceso a nada.
- `Rate.MoveSpeed` distinto de 1 rompe el pathfinding y genera desync. No se toca.
- Todo cambio se anota en `desvios-blizzlike.md` con qué se va a medir.

## Historial de cambios

| Fecha | Config | De | A | Motivo | Resultado a 14 días |
|---|---|---|---|---|---|
| | | | | | |
