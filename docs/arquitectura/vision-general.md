# Visión general de la arquitectura

```
   Cliente WoW 3.3.5a
      │
      │ realmlist.wtf → IP del authserver
      ▼
  ┌─────────────┐        ┌──────────────┐
  │ authserver  │───────▶│  acore_auth  │  cuentas, realms, bans, GM
  │   :3724     │        └──────────────┘
  └──────┬──────┘
         │ devuelve lista de realms (tabla realmlist)
         ▼
  ┌─────────────┐        ┌────────────────────┐
  │ worldserver │───────▶│ acore_characters   │  personajes, items, mail, AH
  │   :8085     │───────▶│ acore_world        │  NPCs, quests, loot, scripts
  │   :7878 soap│        └────────────────────┘
  └──────┬──────┘
         │ lee del disco
         ▼
   DataDir/  dbc/  maps/  vmaps/  mmaps/  Cameras/
```

## Qué proceso hace qué

- **authserver**: solo login (SRP6) y lista de realms. Liviano. Si se cae,
  nadie entra nuevo, pero los que están adentro siguen jugando.
- **worldserver**: todo el juego. Corre los mapas en hilos paralelos. Si se
  cae, se cae el servidor.

## Las cuatro capas de un cambio

Elegí siempre la más alta posible:

| Capa | Dónde | Requiere compilar | Reversible |
|---|---|---|---|
| 1. Config | `worldserver.conf` | No | Trivial |
| 2. SQL | `acore_world` | No (`.reload`) | Sí, con rollback |
| 3. Módulo | `modules/mod-*` | Sí (+ cmake) | Sí, desactivando |
| 4. Core | `src/server/` | Sí | Difícil, se pierde en cada pull |

La respuesta a "¿cómo hago X?" empieza siempre por **en qué capa va**.

## Assets del cliente

No están en el repo y nunca van a estarlo. Se extraen del cliente propio con
las herramientas que deja `TOOLS_BUILD=all`. Ver `SETUP.md` y `recursos/legal.md`.

| Carpeta | Si falta |
|---|---|
| `dbc/` | El worldserver no arranca |
| `maps/` | Los jugadores caen al vacío |
| `vmaps/` | Línea de visión rota, se dispara a través de paredes |
| `mmaps/` | Los NPCs no calculan rutas |

## Dónde mirar cuando algo falla

1. `DBErrors.log` — siempre primero.
2. `worldserver.log` — el arranque completo, de arriba a abajo.
3. `Crashes/` — dumps.
4. `server info` en consola — uptime, jugadores, diff.
