---
description: Escribe una migración SQL idempotente
argument-hint: [qué cambio hay que hacer en la base]
---
Migración SQL: **$ARGUMENTS**

Seguí la skill `sql-migraciones`. Entregá el archivo con el nombre
`AAAA_MM_DD_NN_<base>_<descripcion>.sql`, con cabecera, transacción, bloque de
rollback escrito, y el `SELECT` de verificación. Decime qué `.reload` hay que
correr después. Si toca `acore_characters`, empezá recordando el backup.
