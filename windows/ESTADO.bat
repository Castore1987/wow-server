@echo off
chcp 65001 >nul
title Servidor WoW - Estado

wsl.exe -d Ubuntu -- bash -lc "cd ~/azerothcore-wotlk && docker compose ps && echo && echo '--- ultimas lineas del worldserver ---' && docker compose logs --tail=15 ac-worldserver"

echo.
pause
