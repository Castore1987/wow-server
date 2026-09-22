---
description: Investiga un bug reportado y propone el fix
argument-hint: [descripción del bug]
---
Bug reportado: **$ARGUMENTS**

Seguí la skill `debug-crashes` y el criterio del agente `qa-tester`.

1. Empezá por `DBErrors.log`.
2. Si el reporte no tiene pasos de reproducción, alcance y datos (entry, mapa,
   coords, versión), pedilos antes de proponer nada.
3. Entregá: causa raíz, fix, cómo reproducir el problema **antes** y comprobar
   que se fue **después**, y la entrada para `docs/operacion/incidentes.md` con
   su línea de prevención.
