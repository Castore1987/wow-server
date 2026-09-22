# Legal y límites

Leelo una vez antes de empezar. Es corto y evita problemas reales.

## El emulador es libre, el juego no

**AzerothCore es software open source** (GNU AGPL v3). Desarrollarlo,
modificarlo y distribuirlo es legítimo, y así funciona el proyecto.

**Los assets del juego son propiedad de Blizzard Entertainment.** El arte, los
modelos, los mapas, la música, los DBC y el cliente 3.3.5a completo. Nada de eso
es libre y nada de eso entra a este repo.

## Reglas de este repo

- **Ningún archivo del cliente se commitea.** Ni `dbc/`, ni `maps/`, ni `vmaps/`,
  ni `mmaps/`, ni `.MPQ`. El `.gitignore` los bloquea; el criterio va primero.
- **Cada persona usa su propio cliente 3.3.5a.** No se distribuye el cliente
  desde acá, ni con link, ni en un Drive, ni "solo para el equipo".
- **Ningún dato de jugadores sale del servidor.** Ni emails, ni IPs, ni hashes,
  ni dumps de `acore_characters`.
- Los textos y nombres de quests, NPCs e items originales que aparecen en SQL
  son parte de los datos del juego: no se publican masivamente fuera del
  servidor.

## Términos de servicio de Blizzard

Correr un servidor privado de WoW **va contra los Términos de Servicio de
Blizzard**. Eso es un hecho, no una opinión, y vale la pena tenerlo claro
desde el día uno.

En la práctica, el criterio que mantiene esto en terreno razonable:

- **Sin fines de lucro.** Nada de vender oro, items, niveles, accesos ni
  ventajas de juego. Es lo que históricamente transforma un servidor privado en
  un problema legal serio, no el servidor en sí.
- **Donaciones**: si existen, que cubran costos de infraestructura y no den
  ventaja competitiva. Es una zona gris; mantenela del lado prudente.
- **Sin marca de Blizzard.** No uses logos, ni "World of Warcraft" como nombre
  del proyecto, ni imitación de la identidad oficial.
- **Privado y chico.** Uso personal, entre conocidos, educativo.

Esto no es asesoramiento legal. Si el proyecto crece o aparece dinero de por
medio, consultá con alguien que sepa.

## Qué sí es completamente legítimo

- Estudiar y escribir código para AzerothCore.
- Publicar módulos open source.
- Aportar fixes al proyecto upstream.
- Usar todo esto para aprender C++, MySQL, Linux y arquitectura de servidores
  de juego en tiempo real. Que es, probablemente, la mejor parte.
