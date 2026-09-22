---
name: sql-migraciones
description: Escribir, ordenar y aplicar migraciones SQL sobre las bases de AzerothCore sin romper datos de jugadores. Usar cuando haya que cambiar el schema, aplicar un lote de cambios, versionar SQL, o cuando digan /sql.
---

# Migraciones SQL

## Dónde va cada cosa

| Carpeta | Contenido | Se reaplica |
|---|---|---|
| `sql/custom/<dominio>/` | Contenido propio del servidor, agrupado por tema | Sí, en cada import completo |
| `sql/updates/` | Cambios puntuales y de schema, en orden cronológico | Una vez, registrado |

Nombre de archivo en `sql/updates/`:

```
2026_09_22_00_world_agregar_vendor_argenta.sql
AAAA_MM_DD_NN_<base>_<descripcion>.sql
```

`<base>` es `auth`, `characters` o `world`. El `NN` permite varios el mismo día
y define el orden.

## Plantilla obligatoria

```sql
-- =========================================================
-- 2026_09_22_00_world_agregar_vendor_argenta.sql
-- Base:     acore_world
-- Qué hace: agrega el vendor de reputación del Torneo Argenta (fase 3)
-- Revertir: ver bloque ROLLBACK al final
-- Autor:    <quien>
-- =========================================================

START TRANSACTION;

DELETE FROM `creature_template` WHERE `entry` = 900050;
INSERT INTO `creature_template` (...) VALUES (...);

COMMIT;

-- ROLLBACK manual:
-- DELETE FROM `creature_template` WHERE `entry` = 900050;
```

Toda migración trae su bloque de rollback escrito. Si no sabés cómo revertirla,
todavía no está lista.

## Reglas

1. **Idempotente siempre**: `DELETE` antes de `INSERT`, `WHERE` exacto.
   `INSERT IGNORE` y `ON DUPLICATE KEY UPDATE` sirven, pero esconden errores:
   preferí el `DELETE` explícito.
2. **Transacción por archivo.** MySQL no hace DDL transaccional (`ALTER`,
   `CREATE TABLE` hacen commit implícito), así que **separá DDL de DML en
   archivos distintos**.
3. **Sobre `acore_characters`, backup primero. Sin excepción.**
   Una migración mal hecha ahí borra progreso real de gente real.
4. **Nunca `UPDATE`/`DELETE` sin `WHERE`.** Si de verdad querés tocar toda la
   tabla, escribí `WHERE 1=1` explícito para que se vea que fue a propósito.
5. **Probá el `SELECT` antes que el `UPDATE`.** Corré el mismo `WHERE` como
   `SELECT COUNT(*)` y verificá que el número de filas sea el que esperabas.
6. **Nada de datos de jugadores en el repo.** Ni dumps de `acore_characters`,
   ni emails, ni hashes de contraseña.

## Aplicar

```bash
# Un archivo
mysql -u acore -p acore_world < sql/updates/2026_09_22_00_world_....sql

# Todos los pendientes, en orden
for f in sql/updates/*.sql; do
  echo ">>> $f"
  mysql -u acore -p"$MYSQL_PWD" < "$f" || { echo "FALLÓ en $f"; break; }
done
```

Después de aplicar sobre `acore_world`, en la consola del worldserver:
`.reload <tabla>` por cada tabla tocada, o reiniciar si tocaste algo que no es
recargable.

## Verificación post-migración

1. `SELECT` que confirme el estado esperado (no "corrió sin error": el dato).
2. `DBErrors.log` limpio de entradas nuevas.
3. Prueba in-game del comportamiento concreto.

## Colisión con upstream

`acore_world` la actualiza AzerothCore seguido. Si tocaste una fila original de
Blizzard, un `git pull` puede pisarla. Por eso:

- Los cambios sobre filas originales van **todos juntos** en
  `sql/custom/overrides/` y se re-aplican después de cada actualización de
  upstream.
- Eso está en el checklist de deploy de `docs/operacion/runbook.md`.
