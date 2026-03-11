@echo off
echo ============================================
echo   Iniciando Frontend Flutter
echo ============================================
echo.

cd /d "%~dp0frontend"

echo Verificando conexion con backend
curl -s http://localhost:8080/fhir/metadata > nul 2>&1
if errorlevel 1 (
    echo.
    echo ADVERTENCIA: El backend no esta respondiendo
    echo Por favor ejecuta primero: iniciar-backend.bat
    echo.
    pause
    exit /b 1
)

echo Backend detectado en http://localhost:8080
echo.
echo Iniciando Flutter en Chrome
echo.
echo Puedes cerrar esta ventana cuando termines
echo.
echo ============================================
echo.

flutter run -d chrome
