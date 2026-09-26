@echo off
chcp 65001 >nul
title Servidor WoW - Iniciando
color 0A

echo.
echo   ============================================
echo     INICIANDO EL SERVIDOR DE WOW
echo   ============================================
echo.
echo   Esto tarda entre 1 y 3 minutos.
echo   No cierres esta ventana.
echo.

wsl.exe -d Ubuntu -- bash -lc "cd ~/wow-server && ./scripts/sesion-cargar.sh"

if errorlevel 1 (
    echo.
    echo   ============================================
    echo     ALGO FALLO. El motivo esta arriba.
    echo   ============================================
    echo.
    pause
    exit /b 1
)

echo.
echo   Servidor listo. Que lo disfrutes.
echo.
timeout /t 5 >nul
exit
