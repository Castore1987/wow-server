---
name: operacion-servidor
description: Operar el servidor en producción - backups, despliegues, actualizaciones de upstream, monitoreo, seguridad y recuperación. Usar antes y durante cualquier deploy, cuando haya que actualizar AzerothCore, restaurar datos, o cuando digan /deploy.
---

# Operación del servidor

## Backups

`acore_characters` es la única base irremplazable. Todo lo demás se reconstruye.

```bash
#!/usr/bin/env bash
# scripts/backup.sh
set -euo pipefail
DEST="${1:-./backups}"
STAMP=$(date +%F_%H%M)
mkdir -p "$DEST"

for DB in acore_characters acore_auth acore_world; do
  mysqldump -u acore -p"$MYSQL_PWD" --single-transaction --routines --triggers \
    "$DB" | gzip > "$DEST/${DB}_${STAMP}.sql.gz"
done

find "$DEST" -name 'acore_world_*.sql.gz' -mtime +7  -delete
find "$DEST" -name 'acore_auth_*.sql.gz'  -mtime +30 -delete
# characters NO se borra automáticamente
```

Reglas:

- `acore_characters`: diario + antes de cada deploy. Retención mínima 30 días.
- **Un backup que nunca restauraste no es un backup.** Probá la restauración
  completa en el entorno local una vez por mes y anotá la fecha en
  `docs/operacion/backups.md`.
- Al menos una copia **fuera del VPS**.

## Deploy

```
 1. Anunciar:  .server shutdown 300 "Mantenimiento programado"
 2. Backup de acore_characters (y world si la migración la toca)
 3. git pull del core + de cada módulo
 4. Re-correr cmake (obligatorio si cambió un módulo) + make -j + make install
 5. Re-aplicar los overrides de sql/custom/overrides/  ← se pisan con el pull
 6. Aplicar migraciones pendientes de sql/updates/ en orden
 7. Levantar authserver, después worldserver
 8. Leer el log de arranque completo, de arriba a abajo
 9. Plan de prueba in-game (ver agente qa-tester)
10. Anotar el resultado en docs/operacion/incidentes.md
```

**Si el paso 8 o 9 falla: rollback.** Restaurar el dump y volver al binario
anterior. Tenés que poder hacerlo en menos de 10 minutos. Si no podés, el
procedimiento está mal y se arregla antes del próximo deploy — no después.

Guardá siempre el binario anterior (`worldserver.bak`) antes de `make install`.

## Actualizar AzerothCore desde upstream

Lo que se rompe siempre, en este orden:

1. **Los parches al core desaparecen.** Por eso están documentados en
   `docs/arquitectura/parches-core.md`. Re-aplicalos y verificá que sigan
   siendo necesarios: a veces upstream ya lo arregló.
2. **Los overrides de `acore_world` se pisan.** Re-aplicá `sql/custom/overrides/`.
3. **Los módulos se desincronizan.** Un módulo viejo contra un core nuevo no
   compila, o peor: compila y falla en runtime. Actualizalos antes.
4. **Firmas de hooks cambian.** Si un módulo propio no compila tras el pull,
   comparar la firma contra el `ScriptMgr.h` nuevo es lo primero.

Nunca actualices upstream y hagas cambios propios en el mismo deploy. Son dos
deploys.

## Monitoreo

Lo mínimo que hay que mirar todos los días:

| Qué | Cómo |
|---|---|
| Worldserver vivo | Chequeo del puerto 8085 desde afuera |
| Diff del update | `server info` — alerta si > 100 ms sostenido |
| Espacio en disco | Los logs y los backups llenan el VPS sin avisar |
| Crashes | Contar archivos nuevos en `Crashes/` |
| Errores de DB | Líneas nuevas en `DBErrors.log` |
| Intentos de login fallidos | Log del authserver — brute force |

## Seguridad

- Puertos abiertos al mundo: **solo 3724 y 8085**.
- MySQL en `127.0.0.1`, nunca expuesto. SOAP (7878) cerrado hacia afuera.
- Contraseña de `acore` cambiada antes de ver internet.
- `fail2ban` sobre el log del authserver.
- Auditar cuentas GM periódicamente:
  ```sql
  SELECT a.id, a.username, aa.gmlevel, aa.RealmID
  FROM account a JOIN account_access aa ON a.id = aa.AccountID;
  ```
- Nunca loguear ni guardar contraseñas en claro. AzerothCore usa SRP6
  (salt + verifier); el servidor no conoce la contraseña y no debería.
- Los datos de jugadores (emails, IPs) no salen del VPS ni entran al repo.
