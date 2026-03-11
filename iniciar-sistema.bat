@echo off
echo ============================================
echo   Hospital FHIR System - Iniciando
echo ============================================
echo.

cd /d "%~dp0backend"

echo [1/4] Verificando PostgreSQL y puerto 8080
docker ps | findstr ehrbase-server > nul 2>&1
if not errorlevel 1 docker stop ehrbase-server > nul 2>&1

docker ps | findstr hapi-fhir-postgres > nul 2>&1
if not errorlevel 1 (
    echo PostgreSQL ya esta corriendo
) else (
    echo Iniciando PostgreSQL
    docker-compose up -d
    if errorlevel 1 (
        echo Error al iniciar PostgreSQL
        pause
        exit /b 1
    )
    echo PostgreSQL iniciado
    timeout /t 10 /nobreak > nul
)

echo.
echo [2/4] Iniciando Backend en nueva ventana
cd /d "%~dp0"
start "Backend - MANTENER ABIERTO" cmd /k iniciar-backend.bat

echo.
echo [3/4] Esperando backend (20 segundos)
timeout /t 20 /nobreak > nul

echo.
echo [4/4] Iniciando Frontend en nueva ventana
start "Frontend - Puedes cerrar cuando quieras" cmd /k iniciar-frontend.bat

echo.
echo ============================================
echo   Sistema iniciado
echo ============================================
echo.
echo Informacion:
echo   - PostgreSQL: http://localhost:5432
echo   - Backend:    http://localhost:8080
echo   - Frontend:   Se abrira Chrome
echo.
echo Credenciales:
echo   Usuario:  admin
echo   Password: admin123
echo.
pause
