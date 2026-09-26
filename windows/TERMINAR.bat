@echo off
chcp 65001 >nul
title Servidor WoW - Guardando
color 0E

echo.
echo   ============================================
echo     GUARDANDO Y CERRANDO EL SERVIDOR
echo   ============================================
echo.
echo   Cerra el WoW antes de seguir, asi el servidor
echo   alcanza a guardar tu personaje.
echo.
pause

wsl.exe -d Ubuntu -- bash -lc "cd ~/wow-server && ./scripts/sesion-guardar.sh"

echo.
pause
exit
