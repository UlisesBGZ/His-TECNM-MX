@echo off
echo ============================================
echo   Deteniendo Sistema - La Clemencia FHIR
echo ============================================
echo.

REM --- Paso 1: Detener procesos Java (Backend) ---
echo [1/3] Deteniendo procesos Java (Backend)...
taskkill /F /FI "IMAGENAME eq java.exe" >nul 2>&1
if errorlevel 1 (
    echo No habia procesos Java corriendo
) else (
    echo Procesos Java detenidos
)

REM Esperar un momento para que los puertos queden libres
timeout /t 3 /nobreak > nul

REM Verificar que el puerto 8080 quedo libre
set PORT_OK=0
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":8080 " ^| findstr "LISTENING"') do (
    echo Advertencia: Puerto 8080 aun ocupado por PID %%a, forzando cierre...
    taskkill /F /PID %%a >nul 2>&1
    set PORT_OK=1
)
if %PORT_OK%==0 (
    echo Puerto 8080 libre
)

REM --- Paso 2: Detener procesos Flutter / Dart (Frontend) ---
echo.
echo [2/3] Deteniendo procesos Flutter (Frontend)...
set FLUTTER_RUNNING=0
taskkill /F /FI "IMAGENAME eq dart.exe" >nul 2>&1
if not errorlevel 1 set FLUTTER_RUNNING=1
taskkill /F /FI "IMAGENAME eq flutter.exe" >nul 2>&1
if not errorlevel 1 set FLUTTER_RUNNING=1

if %FLUTTER_RUNNING%==1 (
    echo Frontend detenido
) else (
    echo No habia frontend corriendo
)

REM --- Paso 3: Detener servicios Docker ---
echo.
echo [3/3] Deteniendo servicios Docker (PostgreSQL y EHRbase)...
cd /d "%~dp0backend"

docker ps | findstr "hapi-fhir\|ehrbase" > nul 2>&1
if not errorlevel 1 (
    docker compose down
    if errorlevel 1 (
        echo Error al detener servicios Docker
    ) else (
        echo Servicios Docker detenidos correctamente
    )
) else (
    echo No habia contenedores Docker corriendo
)

echo.
echo ============================================
echo   Sistema detenido completamente
echo ============================================
echo.
pause
