@echo off
echo ============================================
echo   Deteniendo Sistema FHIR
echo ============================================
echo.

echo [1/3] Deteniendo procesos Java (Backend)
taskkill /F /FI "IMAGENAME eq java.exe" 2>nul
if errorlevel 1 (
    echo No hay backend corriendo
) else (
    echo Backend detenido
)

echo.
echo [2/3] Deteniendo procesos Flutter (Frontend)
taskkill /F /FI "IMAGENAME eq dart.exe" 2>nul
taskkill /F /FI "IMAGENAME eq flutter.exe" 2>nul
if errorlevel 1 (
    echo No hay frontend corriendo
) else (
    echo Frontend detenido
)

echo.
echo [3/3] Deteniendo PostgreSQL
cd /d "%~dp0backend"
docker-compose down
if errorlevel 1 (
    echo Error al detener PostgreSQL
) else (
    echo PostgreSQL detenido
)

echo.
echo ============================================
echo   Sistema detenido completamente
echo ============================================
echo.
pause
