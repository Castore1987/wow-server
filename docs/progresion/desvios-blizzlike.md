# Desvíos del blizzlike

Todo lo que este servidor hace distinto de WotLK 3.3.5a original. Si no está
acá, es porque es blizzlike.

Este servidor es de **una sola persona, jugando sola**, con comandos de GM
disponibles. Ese es el contexto que justifica los desvíos: mecánicas pensadas
para una economía con miles de jugadores y grupos de 25 personas no funcionan
igual en solitario.

## Activos

### D-001 — Tasas de XP, oro, reputación y drop aumentadas

- **Qué cambia**: se llega a nivel 80 unas diez veces más rápido, con oro,
  reputación y equipamiento acompañando. El equipamiento de baja probabilidad
  (azules, morados, loot de jefes) pasa a ser alcanzable jugando solo.
- **Original 3.3.5a**: todas las tasas en 1.
- **Acá**: ver la tabla completa en [`rates.md`](rates.md).
- **Por qué**: el contenido de WotLK asume una población con grupos, economía
  activa y meses de progresión. Jugando solo, la progresión blizzlike vuelve
  inalcanzable la mayor parte del contenido — que es justamente lo que se
  quiere jugar.
- **Dónde está**: `docker-compose.override.yml` del repo de AzerothCore, como
  variables de entorno `AC_RATE_*`.
- **Cómo se revierte**: borrar las líneas y `docker compose up -d`. No toca la
  base ni los personajes.
- **Qué medimos**: si el nivel 80 llega con el equipamiento y el oro acordes, o
  si algo quedó desbalanceado (demasiada basura verde, morados aún inalcanzables).
- **Fecha**: 2026-09-28

## Plantilla

```
### D-00X — Título corto

- **Qué cambia**: <una frase, en términos de lo que siente el jugador>
- **Original 3.3.5a**: <valor / comportamiento>
- **Acá**: <valor / comportamiento>
- **Por qué**: <el problema concreto que resuelve — "sería más divertido" no alcanza>
- **Dónde está**: <config / tabla / módulo>
- **Cómo se revierte**: <comando o SQL exacto>
- **Qué medimos**: <qué mirar para saber si estuvo bien>
- **Fecha**: AAAA-MM-DD
```

## Revisados y descartados

| Propuesta | Fecha | Por qué no |
|---|---|---|
| `Rate.MoveSpeed` > 1 | 2026-09-28 | Rompe el pathfinding y genera desync con el cliente. Para moverse rápido se usa `.modify speed`, que es por sesión y no afecta a los NPCs |
| `Rate.Drop.Item.Poor` / `Normal` | 2026-09-28 | Son basura de vender y ropa básica. Multiplicarlas solo llena las bolsas |
| Hechizos custom en el libro de hechizos | 2026-09-28 | Requiere parche `.MPQ` del lado del cliente. Se resolvió con macros sobre `.modify speed` |
