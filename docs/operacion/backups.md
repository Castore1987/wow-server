# Backups

## Qué se respalda y cada cuánto

| Base | Frecuencia | Retención | Por qué |
|---|---|---|---|
| `acore_characters` | Diario + antes de cada deploy | **Mínimo 30 días** | Irremplazable. Es el progreso de la gente |
| `acore_auth` | Diario | 30 días | Cuentas y accesos |
| `acore_world` | Antes de cada deploy | 7 días | Se reconstruye desde upstream + `sql/` |

## Cómo

```bash
./scripts/backup.sh ./backups
```

Ver `scripts/backup.sh`. Programalo con cron:

```
0 5 * * * /ruta/al/repo/scripts/backup.sh /ruta/backups >> /var/log/acore-backup.log 2>&1
```

## Reglas

1. **Un backup que nunca restauraste no es un backup.** Probá la restauración
   completa en el entorno local **una vez por mes** y anotá la fecha abajo.
2. **Al menos una copia fuera del VPS.** Si el disco del VPS muere, un backup
   que vivía en ese disco no existió nunca.
3. `acore_characters` **no se borra automáticamente** por antigüedad.
4. Los dumps **no entran al repo**. El `.gitignore` los bloquea.
5. Antes de cualquier `DROP`, `TRUNCATE`, `ALTER` o import masivo sobre
   `acore_characters`: dump inmediato, en el momento, no "el de anoche".

## Restaurar

```bash
# 1. Apagar el worldserver. Restaurar con el server arriba corrompe datos.
#    .server shutdown 30 "Mantenimiento de emergencia"

# 2. Restaurar
gunzip < backups/acore_characters_AAAA-MM-DD_HHMM.sql.gz \
  | mysql -u acore -p acore_characters

# 3. Verificar ANTES de levantar
mysql -u acore -p -e "SELECT COUNT(*) FROM acore_characters.characters;"

# 4. Levantar y probar login con una cuenta real
```

## Registro de restauraciones de prueba

| Fecha | Base probada | Resultado | Cuánto tardó |
|---|---|---|---|
| | | | |

Si esta tabla está vacía hace más de un mes, no tenés backups: tenés archivos.
