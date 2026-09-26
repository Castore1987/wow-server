# Instalación de bajo consumo (Docker dentro de Ubuntu)

Variante de `instalacion-windows-docker.md` para máquinas con poca RAM.
Ejecutada y verificada el 2026-09-26 en una laptop de **8 GB**.

La diferencia está en un solo punto: **no se instala Docker Desktop**. En su
lugar, Docker Engine va adentro de la misma distro de Ubuntu.

## Por qué ahorra memoria

Docker Desktop no es solo el motor. Arrastra además:

| Componente | Qué es |
|---|---|
| `Docker Desktop.exe` | Interfaz gráfica en Electron (un navegador entero) |
| `com.docker.backend.exe` | Servicio puente con WSL |
| Distro `docker-desktop` | Una distro de Linux extra, solo para el motor |
| Distro `docker-desktop-data` | Otra más, solo para las imágenes |

Con Docker Engine adentro de Ubuntu queda solo `dockerd` + `containerd`.
**El ahorro ronda los 500 MB a 1 GB**, casi todo del lado de Windows.

Lo que no cambia es el grueso: los contenedores (MySQL + worldserver) consumen
lo mismo en los dos casos.

**Lo que se pierde:** el arranque automático con Windows y el panel gráfico. Con
esta variante hay que levantar el servidor a mano (o con los scripts de sesión).

## Instalación

### 1. WSL2

```powershell
wsl --install
```

Reiniciar. Usuario en minúsculas.

### 2. Docker Engine dentro de Ubuntu

```bash
cd ~
sudo apt update && sudo apt install -y curl ca-certificates
curl -fsSL https://get.docker.com -o get-docker.sh
sudo sh get-docker.sh
sudo usermod -aG docker $USER
```

> El instalador detecta WSL y **recomienda Docker Desktop**, con una cuenta
> regresiva de 20 segundos para abortar. **No abortes**: esa recomendación es
> justo lo que estamos evitando. Sigue solo.

```bash
ps -p 1 -o comm=          # tiene que decir: systemd
sudo systemctl enable --now docker
```

Si `ps -p 1` no dice `systemd`:

```bash
printf '[boot]\nsystemd=true\n' | sudo tee -a /etc/wsl.conf
```

Después `wsl --shutdown` desde PowerShell, reabrir, y recién ahí el
`systemctl enable --now docker`.

### 3. Techo de RAM para WSL

Sin esto, WSL2 se toma hasta la mitad de la RAM total.

Crear `C:\Users\<usuario>\.wslconfig`. Desde Ubuntu, sin cambiar de terminal:

```bash
WINUSER=$(powershell.exe -NoProfile -Command '$env:USERNAME' 2>/dev/null | tr -d '\r\n')
printf '[wsl2]\nmemory=4GB\nswap=4GB\n' > "/mnt/c/Users/$WINUSER/.wslconfig"
cat "/mnt/c/Users/$WINUSER/.wslconfig"
```

Cuánto poner:

| RAM total | `memory=` | Razonamiento |
|---|---|---|
| 8 GB | `4GB` | Windows ~2,5 + cliente WoW ~1,5 + WSL 4 |
| 12 GB | `6GB` | |
| 16 GB o más | `8GB` | |

El `swap` es la red de contención: si el worldserver pega un pico al cargar el
mundo, tira a disco en vez de que lo mate el sistema.

Aplicar con `wsl --shutdown`. Eso además hace que tome el grupo `docker`.

### 4. Verificar

```bash
which docker && docker compose version && free -h && docker run hello-world
```

`which docker` **tiene que decir `/usr/bin/docker`**. Si dice algo con
`docker-desktop`, la integración de Docker Desktop sigue activa y le está
ganando al Docker nativo.

### 5. AzerothCore con MySQL afinado

```bash
cd ~
git clone https://github.com/azerothcore/azerothcore-wotlk.git --branch master --single-branch
cd azerothcore-wotlk
echo "DOCKER_DB_EXTERNAL_PORT=64306" > .env

cat > docker-compose.override.yml <<'YML'
services:
  ac-database:
    command:
      - mysqld
      - --performance-schema=OFF
      - --innodb-buffer-pool-size=256M
YML

docker compose up -d
```

| Opción | Para qué |
|---|---|
| `--performance-schema=OFF` | MySQL 8 reserva ~400 MB para métricas internas. **Este es el ahorro grande** |
| `--innodb-buffer-pool-size=256M` | Techo a la caché de la base. De sobra para un servidor de una persona |

Va en `docker-compose.override.yml` porque el `docker-compose.yml` de
AzerothCore dice explícitamente que no hay que editarlo: así los ajustes
sobreviven a las actualizaciones de upstream.

## Resultado medido

En la laptop de 8 GB, con WSL limitado a 4 GB:

```
WORLD: World Initialized In 0 Minutes 20 Seconds

Last 500 diffs summary:
 |- Mean: 3ms
 |- Median: 1ms
 |- Percentiles (95, 99, max): 11ms, 21ms, 182ms
```

**Media de 3 ms.** El umbral de preocupación son ~100 ms sostenidos; el 182 ms
es el máximo de una sola muestra durante el arranque, no un problema.

> Al arrancar por primera vez conviene cerrar navegador y ofimática: importar
> las bases y cargar el mundo es el pico de consumo de todo el proceso.

## Avisos cosméticos

`Config: Missing property ALE.BytecodeCache` en el log de arranque es una
propiedad de configuración nueva que el `.conf.dist` todavía no trae. El
servidor usa un valor por defecto y funciona igual.
