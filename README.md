# Asistente Programador · Servidor privado WoW (AzerothCore 3.3.5a)

Repo-cerebro para desarrollar y operar un servidor privado de **WoW: Wrath of
the Lich King (3.3.5a, build 12340)** sobre [AzerothCore](https://www.azerothcore.org/),
con enfoque **blizzlike y progresión por fases**.

No es el código del servidor. Es el **contexto, las reglas y las habilidades**
que usa Claude Code para trabajar sobre ese código sin romper nada.

## Cómo se usa

1. Cloná este repo.
2. Cloná AzerothCore al lado (o adentro, está en `.gitignore`):
   ```bash
   git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch
   ```
3. Completá `docs/servidor/perfil-servidor.md` (los `<<COMPLETAR>>`).
4. Abrí Claude Code en la raíz de este repo y pedile lo que necesites.

## Comandos rápidos

| Comando | Qué hace |
|---|---|
| `/entorno` | Levanta o diagnostica el entorno de desarrollo |
| `/modulo` | Crea o modifica un módulo de AzerothCore |
| `/sql` | Escribe una migración SQL idempotente |
| `/quest` | Arma, arregla o audita una quest del world DB |
| `/npc` | Crea o corrige un creature/gameobject con su SmartAI y loot |
| `/bug` | Investiga un bug reportado y propone el fix |
| `/fase` | Abre o cierra contenido según el plan de progresión |
| `/balance` | Revisa rates y configuración de economía/XP |
| `/deploy` | Prepara y ejecuta un despliegue con backup previo |

## Documentos que conviene leer primero

| Archivo | Para qué |
|---|---|
| [`docs/operacion/instalacion-windows-docker.md`](docs/operacion/instalacion-windows-docker.md) | Instalar de cero en Windows, sin compilar. Probado |
| [`docs/servidor/perfil-servidor.md`](docs/servidor/perfil-servidor.md) | Cómo está configurado este servidor y qué falta |
| [`recursos/comandos-gm.md`](recursos/comandos-gm.md) | Comandos GM verificados contra la tabla `command` |
| [`docs/operacion/runbook.md`](docs/operacion/runbook.md) | Deploys, backups, emergencias |

## Estructura

Ver la tabla en [`CLAUDE.md`](CLAUDE.md).

## Antes de empezar

Leé [`recursos/legal.md`](recursos/legal.md). Resumen: el software del emulador
es open source, pero **los assets del juego no**. Cada persona necesita su
propio cliente 3.3.5a, nada de datos de Blizzard entra a este repo, y un
servidor privado va contra los Términos de Servicio de Blizzard. Uso personal,
educativo y sin fines de lucro.
