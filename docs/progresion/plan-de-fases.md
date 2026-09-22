# Plan de fases

> Este archivo manda. Si algo acá contradice a la skill `blizzlike-progresion`,
> vale lo que dice acá.

## Estado actual

- **Fase activa**: `<<COMPLETAR>>` — por defecto: Fase 1
- **Fecha de apertura de la fase actual**: `<<COMPLETAR>>`
- **Próxima apertura prevista**: `<<COMPLETAR>>`

## Calendario

| Fase | Contenido | Estado | Fecha prevista | Fecha real |
|---|---|---|---|---|
| 1 | Naxxramas, Ojo de la Eternidad, Cámara de Obsidiana | `<<COMPLETAR>>` | | |
| 2 | Ulduar | Cerrada | `<<COMPLETAR>>` | |
| 3 | Prueba del Cruzado + Torneo Argenta | Cerrada | `<<COMPLETAR>>` | |
| 4 | Ciudadela de la Corona de Hielo | Cerrada | `<<COMPLETAR>>` | |
| 5 | Cámara Rubí (Halion) | Cerrada | `<<COMPLETAR>>` | |

`[VERIFICAR]` el orden y el contenido exacto de cada fase contra el historial de
parches de 3.3.x antes de anunciar fechas públicamente.

## IDs de mapa de referencia

| Mapa | ID |
|---|---|
| Naxxramas | 533 |
| Ojo de la Eternidad | 616 |
| Cámara de Obsidiana | 615 |
| Ulduar | 603 |
| Prueba del Cruzado | 649 |
| Ciudadela de la Corona de Hielo | 631 |
| Cámara Rubí | 724 |

`[VERIFICAR]` cada ID contra `SELECT map, name FROM instance_template JOIN ...`
de tu base antes de usarlo en un `disables`.

## Cómo se cierra cada fase

Ver la skill `blizzlike-progresion`. Resumen: `disables` para cerrar el mapa,
`access_requirement` para el gear check, `game_event` para lo estacional.

Los SQL de cada fase viven en `sql/custom/progresion/fase-N-abrir.sql` y
`fase-N-cerrar.sql`, ambos idempotentes.

## Checklist de apertura

Se recorre entero antes de anunciar. Sin excepciones.

- [ ] Mapa habilitado en `disables` — **normal y heroico**
- [ ] `access_requirement` con el item level / attunement correcto
- [ ] Vendors de emblemas actualizados (items nuevos + ajuste de los viejos)
- [ ] Cadena de quests de entrada / atunement activa
- [ ] Loot de cada jefe verificado contra la lista de la época
- [ ] Buff de raid del parche correspondiente, si aplica
- [ ] Prueba in-game: entrar, pullear el primer jefe, verificar el loot
- [ ] Backup previo hecho
- [ ] Anuncio a jugadores con fecha y hora

Cerrar la fase anterior **no** es parte del checklist: en blizzlike el contenido
viejo queda abierto.

## Registro de aperturas

| Fecha | Fase | Quién | Incidencias |
|---|---|---|---|
| | | | |
