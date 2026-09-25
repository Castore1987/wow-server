# Perfil del servidor

> Última actualización: 2026-09-25 — primera instalación funcionando.

## Identidad

- **Nombre del realm**: AzerothCore (el que viene por defecto) — `<<COMPLETAR>>` si se renombra
- **Expansión**: WotLK 3.3.5a (build 12340)
- **Core**: AzerothCore, rama `master`, imágenes oficiales de Docker Hub
- **Tipo**: PvE
- **Idioma de la comunidad**: español rioplatense
- **Jugadores esperados en pico**: menos de 10 (uso personal y con amigos)

## Filosofía

Blizzlike con progresión por fases. Los desvíos deliberados van en
`docs/progresion/desvios-blizzlike.md`. Al día de hoy no hay ninguno: todos los
rates están en el valor original.

## Cliente

- **Origen**: cliente 3.3.5a en español latino (`esMX`), del repack de WoW Patagonia
- **Build verificada**: `3.3.5.12340` (propiedades de `Wow.exe` → Detalles)
- **Locale**: `esMX` — el `realmlist.wtf` está en `Data\esMX\`, **no** en `enUS`
- **Ruta del cliente**: `<<COMPLETAR>>`
- **Nota**: al ser un repack puede traer parches propios (`patch-4.MPQ` y
  similares). No dieron problemas hasta ahora; si aparecen modelos o textos
  raros, es el primer lugar donde mirar.

## Rates

Todos en el valor blizzlike (`1`). No se tocó `worldserver.conf`.

| Config | Valor |
|---|---|
| Todos los `Rate.*` | 1 (por defecto) |

## Infraestructura

- **Dónde corre**: PC de escritorio con Windows 11
- **Cómo corre**: WSL2 (Ubuntu) + Docker Desktop, con las imágenes oficiales
  `acore/ac-wotlk-*`. Sin compilar nada.
- **Usuario de Linux**: `chester` · **host**: `Estudio`
- **Ruta del repo de AzerothCore**: `~/azerothcore-wotlk` (dentro del sistema de
  archivos de Linux, no en `/mnt/c` — importante para el rendimiento)
- **Producción separada**: no hay. Es local.
- **Dominio / IP pública**: no aplica todavía. El realm apunta a `127.0.0.1`.
- **Dónde viven los backups**: `<<COMPLETAR>>` — todavía no hay backups configurados

Ver el procedimiento completo en
[`docs/operacion/instalacion-windows-docker.md`](../operacion/instalacion-windows-docker.md).

### Puertos

| Servicio | Puerto en el host |
|---|---|
| authserver | 3724 |
| worldserver | 8085 |
| SOAP | 7878 |
| MySQL | 64306 → 3306 del contenedor |

MySQL se movió del 3306 por defecto al 64306 con un archivo `.env` en el repo de
AzerothCore, porque en esta máquina ya había un MySQL de Windows ocupando el 3306.

## Módulos instalados

Ninguno todavía.

| Módulo | Versión / commit | Para qué |
|---|---|---|
| — | — | — |

## Fase de contenido actual

- **Fase activa**: sin definir. La instalación viene con **todo el contenido
  abierto** — no se aplicó ningún gating.
- **Próxima decisión**: definir si se cierra contenido según
  `docs/progresion/plan-de-fases.md`, o se deja todo abierto por ser un servidor
  chico entre conocidos.

## Rangos de IDs propios

| Qué | Rango |
|---|---|
| `creature_template` | 900000 – 909999 |
| `gameobject_template` | 900000 – 909999 |
| `quest_template` | 900000 – 909999 |
| `item_template` | 900000 – 909999 |

Todavía no se creó nada custom.

## Cuentas

| Cuenta | gmlevel | RealmID | Nota |
|---|---|---|---|
| `chester` | 3 | -1 | Cuenta de administración |

Las contraseñas **no se guardan en este repo**. Para cambiar una:
`.account set password <cuenta> <nueva> <nueva>` desde el juego, o
`account set password` en la consola del worldserver.

## Quién hace qué

- **Dueño / decisiones finales**: Javier
- **Acceso a producción**: Javier
- **GMs**: `chester` (nivel 3)

## Pendientes conocidos

| # | Qué | Prioridad |
|---|---|---|
| 1 | **Contraseña de MySQL en el valor por defecto** (`password`) y el puerto 64306 escuchando en `0.0.0.0`, es decir accesible desde la red local. En una LAN doméstica el riesgo es bajo, pero conviene cambiar la contraseña o atar el puerto a `127.0.0.1`. | Media |
| 2 | No hay backups configurados. `scripts/backup.sh` está en el repo pero no programado. | Media |
| 3 | Falta decidir el plan de fases (hoy está todo abierto). | Baja |
| 4 | Falta la ruta del cliente de WoW en este documento. | Baja |
