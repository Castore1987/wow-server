# Brief de feature

> Copiá este archivo antes de empezar cualquier cosa que lleve más de una hora.

## Qué

Una frase. Qué va a poder hacer un jugador que hoy no puede, o qué deja de
pasar que hoy pasa.

## Por qué

El problema concreto. Si el motivo es "estaría bueno", el brief no está listo.

## En qué capa va

- [ ] Config (`worldserver.conf`) — sin compilar, reversible al instante
- [ ] SQL (`acore_world`) — `.reload`, con rollback
- [ ] Módulo (`modules/mod-*`) — compila, se desactiva con `Enable = 0`
- [ ] Core (`src/server/`) — **justificá por qué no entra en ninguna de las de arriba**

## Alcance

**Entra:**
-

**No entra:**
-

## Impacto

- ¿Toca datos de jugadores? → backup obligatorio, sí/no:
- ¿Es un desvío del blizzlike? → entrada en `desvios-blizzlike.md`, sí/no:
- ¿Necesita downtime? → cuánto:
- ¿Afecta el balance o la economía?

## Cómo se prueba

Pasos concretos in-game, con los comandos GM exactos:

1.
2.

## Cómo se revierte

Comando o SQL exacto. Si no lo podés escribir, la feature no está lista.

## Listo cuando

- [ ] Funciona en el entorno local
- [ ] SQL idempotente y versionado en `sql/`
- [ ] Rollback escrito y probado
- [ ] Sin entradas nuevas en `DBErrors.log`
- [ ] Documentado donde corresponda
