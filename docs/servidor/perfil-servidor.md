# Perfil del servidor

> Completá los `<<COMPLETAR>>`. Los que quedan vacíos se asumen con el valor
> por defecto que dice cada línea, y el asistente lo va a declarar en voz alta.

## Identidad

- **Nombre del realm**: `<<COMPLETAR>>`
- **Expansión**: WotLK 3.3.5a (build 12340)
- **Core**: AzerothCore, rama `master`
- **Tipo**: `<<COMPLETAR>>` (PvE / PvP / RP-PvE) — por defecto: PvE
- **Idioma de la comunidad**: español rioplatense
- **Jugadores esperados en pico**: `<<COMPLETAR>>` — por defecto se asume < 200

## Filosofía

Blizzlike con progresión por fases. Los desvíos deliberados están en
`docs/progresion/desvios-blizzlike.md` y son la excepción, no la regla.

## Rates

| Config | Valor | Nota |
|---|---|---|
| `Rate.XP.Kill` | `<<COMPLETAR>>` | por defecto 1 |
| `Rate.XP.Quest` | `<<COMPLETAR>>` | por defecto 1 |
| `Rate.Drop.Money` | `<<COMPLETAR>>` | por defecto 1 |
| `Rate.Drop.Item.*` | `<<COMPLETAR>>` | por defecto 1 |
| `Rate.Reputation.Gain` | `<<COMPLETAR>>` | por defecto 1 |
| `Rate.Honor` | `<<COMPLETAR>>` | por defecto 1 |

## Infraestructura

- **Entorno de desarrollo**: `<<COMPLETAR>>` (Docker / build desde fuente)
- **Producción**: `<<COMPLETAR>>` (VPS, proveedor, RAM, vCPU)
- **Sistema operativo**: `<<COMPLETAR>>` — por defecto Ubuntu 24.04 LTS
- **Dominio / IP pública**: `<<COMPLETAR>>`
- **Dónde viven los backups**: `<<COMPLETAR>>`

## Módulos instalados

| Módulo | Versión / commit | Para qué |
|---|---|---|
| `<<COMPLETAR>>` | | |

## Fase de contenido actual

- **Fase activa**: `<<COMPLETAR>>` — por defecto: Fase 1 (Naxx / EoE / OS)
- **Próxima apertura prevista**: `<<COMPLETAR>>`

## Rangos de IDs propios

| Qué | Rango |
|---|---|
| `creature_template` | 900000 – 909999 |
| `gameobject_template` | 900000 – 909999 |
| `quest_template` | 900000 – 909999 |
| `item_template` | 900000 – 909999 |

Todo lo custom vive acá. Nunca se pisa un ID de Blizzard.

## Quién hace qué

- **Dueño / decisiones finales**: `<<COMPLETAR>>`
- **Acceso a producción**: `<<COMPLETAR>>`
- **GMs**: `<<COMPLETAR>>`
