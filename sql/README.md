# SQL

## Estructura

| Carpeta | Qué va | Se reaplica |
|---|---|---|
| `custom/<dominio>/` | Contenido propio, agrupado por tema | Sí, en cada import completo |
| `custom/overrides/` | Correcciones sobre filas **originales** de Blizzard | Sí, **después de cada pull de upstream** |
| `updates/` | Cambios puntuales y de schema, en orden cronológico | Una vez |

`custom/overrides/` es especial: `acore_world` la actualiza upstream seguido y
pisa cualquier cambio sobre filas originales. Re-aplicar esa carpeta es el
paso 5 del checklist de deploy.

## Nombres

```
updates/2026_09_22_00_world_agregar_vendor_argenta.sql
        AAAA_MM_DD_NN_<base>_<descripcion>.sql
```

`<base>` = `auth` | `characters` | `world`. El `NN` ordena dentro del día.

## Reglas

1. **Idempotente siempre.** `DELETE` con `WHERE` exacto antes de cada `INSERT`.
2. **Bloque de rollback escrito** al final de cada archivo. Sin eso no está listo.
3. **Nunca `UPDATE`/`DELETE` sin `WHERE`.** Si de verdad querés toda la tabla,
   escribí `WHERE 1=1` para que se vea que fue a propósito.
4. **`SELECT COUNT(*)` antes del `UPDATE`**, con el mismo `WHERE`. Verificá que
   el número de filas sea el que esperabas.
5. **DDL y DML en archivos separados.** MySQL hace commit implícito en `ALTER`
   y `CREATE`, así que no son transaccionales.
6. **`acore_characters` → backup primero.** Sin excepción.
7. **IDs propios desde 900000.** Nunca pises un ID de Blizzard creando uno nuevo.

Plantilla en `plantillas/migracion-sql.md`.
