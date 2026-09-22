# Runbook

Lo que hay que hacer, en orden, cuando toca. No es documentación: es un
procedimiento para seguir con el dedo.

## Arranque normal

```bash
# Docker
./acore.sh docker start:app

# Desde fuente
cd ~/azeroth-server/bin
./authserver &
./worldserver
```

Leé el log de arranque **completo**. El primer error rojo es el que importa.

## Deploy

```
 1. Anunciar:  .server shutdown 300 "Mantenimiento programado"
 2. Backup de acore_characters (y de world si la migración la toca)
 3. git pull del core + de cada módulo
 4. cmake (OBLIGATORIO si cambió un módulo) + make -j + make install
    → guardar el binario anterior como worldserver.bak antes de instalar
 5. Re-aplicar sql/custom/overrides/         ← el pull los pisa
 6. Aplicar sql/updates/ pendientes, en orden
 7. Levantar authserver, después worldserver
 8. Leer el log de arranque completo
 9. Plan de prueba in-game (ver abajo)
10. Anotar el resultado en incidentes.md
```

**Si falla el 8 o el 9 → rollback.** Restaurar el dump, volver a
`worldserver.bak`. Tiene que tomar menos de 10 minutos. Si no puede, el
procedimiento está mal y se arregla **antes** del próximo deploy.

## Plan de prueba antes de abrir al público

Entero, cada vez, aunque el cambio sea chico.

- [ ] Login con cuenta normal (sin GM) y con cuenta GM
- [ ] Crear personaje nuevo de cada facción
- [ ] Movimiento, salto, montura, vuelo en Northrend
- [ ] Un vendor: comprar y vender
- [ ] Una quest completa: aceptar → objetivo → entregar → recompensa
- [ ] Entrar a una instancia por el portal y salir
- [ ] Un spell de daño, uno de curación, un pet/totem
- [ ] Mail con item y oro adjunto, recibido por otro personaje
- [ ] Auction House: listar y comprar
- [ ] Logout y re-login: posición, bolsa y equipo intactos
- [ ] `server info`: diff estable, sin errores rojos en el log

## Actualizar AzerothCore desde upstream

Nunca junto con cambios propios. Son dos deploys distintos.

1. Actualizar los módulos **antes** que el core.
2. `git pull` del core.
3. Re-aplicar los parches de `docs/arquitectura/parches-core.md`, y preguntarse
   por cada uno si todavía hace falta.
4. Re-aplicar `sql/custom/overrides/`.
5. Compilar. Si un módulo propio no compila, comparar la firma del hook contra
   el `ScriptMgr.h` nuevo — es la causa habitual.
6. Plan de prueba completo.

## Chequeo diario

| Qué | Cómo | Umbral |
|---|---|---|
| Worldserver vivo | puerto 8085 desde afuera | — |
| Diff del update | `server info` | alerta > 100 ms sostenido |
| Espacio en disco | `df -h` | alerta < 15% libre |
| Crashes nuevos | archivos nuevos en `Crashes/` | cualquiera |
| Errores de DB | líneas nuevas en `DBErrors.log` | cualquiera nueva |
| Logins fallidos | log del authserver | pico = brute force |

## Emergencias

### El worldserver no levanta

1. `DBErrors.log` y el log de arranque completo.
2. ¿Fue después de un deploy? → rollback al binario y dump anteriores.
3. ¿`DataDir` accesible? ¿MySQL arriba?

### Se congeló (no crashea, no responde)

Casi siempre SmartAI en loop:

```sql
SELECT * FROM smart_scripts
WHERE event_type IN (0,1)
  AND event_param1 = 0 AND event_param2 = 0
  AND event_param3 = 0 AND event_param4 = 0;
```

### Hay que restaurar personajes

```bash
gunzip < backups/acore_characters_AAAA-MM-DD_HHMM.sql.gz | mysql -u acore -p acore_characters
```

Con el worldserver **apagado**. Restaurar con el server arriba corrompe datos.

### Comandos de consola

```
server info
server shutdown 60 "motivo"
server exit
account create <user> <pass>
account set gmlevel <user> 3 -1
reload <tabla>
```
