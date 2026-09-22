# Reporte de bug

> Un bug sin pasos de reproducción es un rumor. Completá todo antes de escalarlo.

## Título

Una línea: qué hace mal, dónde.

## Pasos para reproducirlo

Desde el login. Exactos.

1.
2.
3.

## Qué pasa

## Qué debería pasar

Y **de dónde sale ese "debería"**: wowhead de 3.3.5a, un video de la época, el
comportamiento de otro NPC equivalente. Si no lo podés fundamentar, marcalo
`[VERIFICAR]`.

## Alcance

- ¿Todas las clases? ¿Solo una?
- ¿Todos los niveles?
- ¿Todos los mapas, o uno?
- ¿Pasa también **sin** `.gm on`? ← si no probaste esto, probalo antes de seguir
- ¿Desde cuándo? ¿Coincide con algún deploy?

## Datos

- **Entry del creature / gameobject / quest / item**:
- **Mapa y coordenadas** (`.gps`):
- **Versión del server / commit**:
- **Personaje afectado** (nombre, nivel, clase):

## Evidencia

- Captura o video:
- Líneas relevantes de `worldserver.log`:
- Líneas relevantes de `DBErrors.log`:

---

## Diagnóstico

_(lo completa quien investiga)_

- **Causa raíz**:
- **Capa**: config / SQL / módulo / core
- **Fix propuesto**:
- **Riesgo del fix**:

## Verificación

- [ ] Reproduje el bug **antes** del fix
- [ ] El caso que fallaba ahora pasa
- [ ] Un caso vecino que no debía cambiar sigue igual
- [ ] Sin errores nuevos en el log
- [ ] Anotado en `docs/operacion/incidentes.md` con su línea de prevención
