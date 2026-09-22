# Parches al core

> Cada fila de acá es deuda técnica. Se pierde en cada `git pull` de upstream y
> hay que re-aplicarla a mano. El objetivo es que esta tabla esté **vacía**.

Antes de agregar uno, contestá por escrito: ¿esto no se puede hacer con un
módulo, con SmartAI o con config? Si se puede, no va acá.

## Parches activos

| # | Archivo del core | Función | Qué hace | Por qué no es un módulo | Fecha |
|---|---|---|---|---|---|
| — | _(ninguno)_ | | | | |

## Plantilla de entrada

```
### P-001 — Título corto

- **Archivo**: `src/server/game/Entities/Player/Player.cpp`
- **Función**: `Player::UpdateArea()`
- **Qué hace**: <una frase>
- **Por qué no es un módulo**: <el hook que falta / por qué no alcanza>
- **Diff**: `patches/P-001.patch`
- **Cómo re-aplicar**: `git apply patches/P-001.patch`
- **Cómo verificar**: <prueba in-game concreta>
- **Fecha**: AAAA-MM-DD
- **¿Sigue siendo necesario?**: revisar en cada pull — upstream puede haberlo resuelto
```

## Procedimiento tras un `git pull` de upstream

1. Re-aplicar cada parche de esta lista, en orden.
2. Por cada uno, preguntarse si todavía hace falta. Si upstream lo resolvió,
   **borralo de acá** y de `patches/`.
3. Si un parche ya no aplica limpio, re-hacerlo contra el código nuevo antes de
   compilar. No lo fuerces.
4. Compilar y correr el plan de prueba completo.

Un parche que nadie puede explicar se borra. Si rompe algo al borrarlo, ahí se
documenta bien y vuelve.
