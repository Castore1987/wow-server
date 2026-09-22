# Incidentes

Todo lo que se rompió, por qué, y qué se hizo para que no vuelva a pasar.

Se anota **aunque el fix sea de una línea**. La columna que hace que este
archivo valga la pena es **Prevención**.

## Plantilla

```
## AAAA-MM-DD — Título corto

- **Síntoma**:    qué vieron los jugadores / qué mostró el monitoreo
- **Impacto**:    cuánta gente, cuánto tiempo, se perdió progreso sí/no
- **Detección**:  cómo nos enteramos (monitoreo, un jugador, por casualidad)
- **Causa raíz**: la causa real, no la primera que apareció
- **Fix**:        qué se hizo, con el comando o SQL exacto
- **Rollback**:   si hubo, qué se restauró y desde cuándo
- **Prevención**: qué cambió para que no vuelva a pasar (checklist, alerta, test)
```

Reglas:

- **"Reiniciamos y anduvo" no es causa raíz.** Reiniciar es mitigación. El
  diagnóstico viene después, pero viene.
- Un incidente sin línea de **Prevención** está abierto, no cerrado.
- Si el mismo incidente aparece dos veces, la prevención de la primera vez
  estuvo mal. Arreglá esa.

---

## Historial

_(vacío — que siga así el mayor tiempo posible)_
