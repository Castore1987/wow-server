---
name: debug-crashes
description: Diagnosticar crashes, cuelgues, lag y comportamientos raros del worldserver. Usar cuando el server se cae, el diff se dispara, hay desync, un NPC hace cualquier cosa, o cuando digan /bug.
---

# Debug de crashes y problemas de runtime

## Lo primero, siempre: `DBErrors.log`

Antes de mirar código, gdb o cualquier otra cosa, abrí `DBErrors.log`. Junta
todas las inconsistencias de `acore_world` que el server detectó al cargar y
explica la mitad de los comportamientos raros in-game. Una referencia a un
`entry` que no existe aparece ahí, no en el log principal.

## Árbol de diagnóstico

### El worldserver crashea

1. ¿Hay `Crashes/Crash_*.txt` o un core dump? Sin eso, solo podés correlacionar
   por el log.
2. El binario tiene que estar compilado con `-DCMAKE_BUILD_TYPE=RelWithDebInfo`.
   Sin símbolos el backtrace no sirve para nada.
3. ```bash
   gdb ./worldserver core.12345
   (gdb) bt full
   (gdb) thread apply all bt
   ```
4. Buscá el frame más alto que sea **tuyo** (un módulo, un script custom). Si
   todo el stack es del core, el sospechoso número uno es un **dato malo en la
   base**, no un bug del core: un entry inexistente, un `smart_script` con
   parámetros fuera de rango, un spell ID inválido.
5. ¿Es reproducible? Anotá exactamente qué estaba pasando: jefe, spell, zona,
   cantidad de jugadores.

### El server se congela (no crashea, deja de responder)

- Casi siempre es un **loop en SmartAI**: un `UPDATE_IC` con los cuatro tiempos
  en 0, o un `actionlist` que se llama a sí mismo.
  ```sql
  SELECT * FROM smart_scripts
  WHERE event_type IN (0,1)
    AND event_param1 = 0 AND event_param2 = 0
    AND event_param3 = 0 AND event_param4 = 0;
  ```
- O una query síncrona en un hook de un módulo.
- O un deadlock entre hilos de mapa: `thread apply all bt` y buscá dos hilos
  esperándose.

### Lag / diff alto

`server info` da el diff. Por encima de ~100 ms sostenido hay problema.

| Sospechoso | Cómo lo confirmás |
|---|---|
| SmartAI en loop | La query de arriba |
| `mmaps` faltantes | Los mobs caminan raro; revisá `DataDir` |
| Query síncrona en un módulo | `grep -rn "Database.Query(" modules/` |
| MySQL mal configurado | `SHOW PROCESSLIST;` con queries colgadas |
| Logs en debug | Revisá los `Appender.*` del `worldserver.conf` |
| Demasiados spawns en un mapa | `SELECT map, COUNT(*) FROM creature GROUP BY map ORDER BY 2 DESC;` |

### Desync (el cliente ve algo distinto al server)

- `Rate.MoveSpeed` distinto de 1 → revertilo.
- `vmaps` faltantes → LoS calculado mal.
- Un aura de velocidad aplicada solo del lado server.

### "A un jugador le pasa X y a mí no"

Probá **sin** `.gm on`. El modo GM saltea chequeos de facción, de distancia, de
requisitos de quest y de cooldown. Un bug que desaparece con GM activo no
desapareció.

## Registrar el hallazgo

Todo incidente va a `docs/operacion/incidentes.md`, aunque el fix sea de una
línea:

```
## 2026-09-22 — Crash al entrar a Ulduar
Síntoma:    worldserver crashea cuando un jugador cruza el portal de Ulduar
Causa:      instance_template sin script asignado tras el pull de upstream
Fix:        UPDATE instance_template SET script = 'instance_ulduar' WHERE map = 603;
Prevención: agregado al checklist de post-pull en runbook.md
```

La columna **Prevención** es la que hace que el archivo valga la pena.

## Nunca

- Nunca "reiniciá y vemos" como diagnóstico. Reiniciar es mitigación; el
  diagnóstico viene después, pero viene.
- Nunca un fix que no puedas explicar. Si no sabés por qué anda, no anda.
- Nunca cerrar un bug sin haberlo reproducido antes del fix.
