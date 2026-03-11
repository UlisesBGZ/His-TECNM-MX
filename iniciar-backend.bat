@echo off
echo ============================================
echo   Iniciando Backend FHIR
echo ============================================
echo.

cd /d "%~dp0backend"

echo [1/3] Verificando PostgreSQL y puerto 8080
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
    echo.
    echo [2/3] Esperando PostgreSQL 10 segundos
    timeout /t 10 /nobreak > nul
)

echo.
echo [3/3] Iniciando Backend Spring Boot  
echo.
echo IMPORTANTE: Esta ventana debe permanecer ABIERTA
echo Para detener: Presiona Ctrl+C
echo.
echo ============================================
echo.

mvnw.cmd spring-boot:run -Pboot
