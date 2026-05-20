@echo off
echo ============================================
echo   Iniciando Backend FHIR
echo ============================================
echo.

cd /d "%~dp0backend"

echo [1/3] Verificando servicios de base de datos
docker ps | findstr hapi-fhir-postgres > nul 2>&1
if not errorlevel 1 (
    echo PostgreSQL FHIR ya esta corriendo
) else (
    echo Iniciando PostgreSQL FHIR
    docker compose up -d hapi-fhir-postgres
    if errorlevel 1 (
        echo Error al iniciar PostgreSQL FHIR
        pause
        exit /b 1
    )
)

docker ps | findstr ehrbase-server > nul 2>&1
if not errorlevel 1 (
    echo EHRbase ya esta corriendo
) else (
    echo Iniciando EHRbase
    docker compose up -d ehrbase-postgres ehrbase-server
    if errorlevel 1 (
        echo Error al iniciar EHRbase
        pause
        exit /b 1
    )
)

echo.
echo [2/3] Esperando servicios 12 segundos
timeout /t 12 /nobreak > nul

echo.
echo [3/3] Iniciando Backend Spring Boot  
echo.
echo IMPORTANTE: Esta ventana debe permanecer ABIERTA
echo Para detener: Presiona Ctrl+C
echo.
echo ============================================
echo.

mvnw.cmd clean spring-boot:run -Pboot
---