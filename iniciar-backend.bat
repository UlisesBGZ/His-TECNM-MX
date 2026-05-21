@echo off
echo ============================================
echo   Iniciando Backend - La Clemencia FHIR
echo ============================================
echo.

REM --- Paso 0: Liberar puerto 8080 si esta ocupado ---
echo [0/3] Verificando puerto 8080...
set PORT_LIBRE=1
for /f "tokens=5" %%a in ('netstat -aon 2^>nul ^| findstr ":8080 " ^| findstr "LISTENING"') do (
    set PORT_LIBRE=0
    echo Puerto 8080 ocupado por PID %%a, cerrando proceso...
    taskkill /F /PID %%a >nul 2>&1
    if not errorlevel 1 (
        echo Proceso %%a cerrado correctamente
    ) else (
        echo No se pudo cerrar el proceso %%a, puede requerir permisos de administrador
    )
)
if %PORT_LIBRE%==1 (
    echo Puerto 8080 disponible
)
echo.

cd /d "%~dp0backend"

REM --- Paso 1: Servicios Docker ---
echo [1/3] Verificando servicios de base de datos...

docker ps | findstr hapi-fhir-postgres > nul 2>&1
if not errorlevel 1 (
    echo PostgreSQL FHIR ya esta corriendo
) else (
    echo Iniciando PostgreSQL FHIR...
    docker compose up -d hapi-fhir-postgres
    if errorlevel 1 (
        echo ERROR: No se pudo iniciar PostgreSQL FHIR
        echo Verifica que Docker Desktop este abierto
        pause
        exit /b 1
    )
    echo PostgreSQL FHIR iniciado
)

docker ps | findstr ehrbase-postgres > nul 2>&1
if not errorlevel 1 (
    echo PostgreSQL EHRbase ya esta corriendo
) else (
    echo Iniciando PostgreSQL EHRbase...
    docker compose up -d ehrbase-postgres
    if errorlevel 1 (
        echo ERROR: No se pudo iniciar PostgreSQL EHRbase
        pause
        exit /b 1
    )
    echo PostgreSQL EHRbase iniciado
)

docker ps | findstr ehrbase-server > nul 2>&1
if not errorlevel 1 (
    echo EHRbase ya esta corriendo
) else (
    echo Iniciando EHRbase...
    docker compose up -d ehrbase-server
    if errorlevel 1 (
        echo ERROR: No se pudo iniciar EHRbase
        pause
        exit /b 1
    )
    echo EHRbase iniciado
)

REM --- Paso 2: Esperar servicios ---
echo.
echo [2/3] Esperando que los servicios esten listos (12 segundos)...
timeout /t 12 /nobreak > nul

REM --- Paso 3: Iniciar Spring Boot ---
echo.
echo [3/3] Iniciando Backend Spring Boot...
echo.
echo ============================================
echo   Backend: http://localhost:8080
echo   EHRbase: http://localhost:8081/ehrbase
echo ============================================
echo.
echo  Esta ventana debe permanecer ABIERTA
echo  Para detener: Ctrl+C y luego detener-sistema.bat
echo.

mvnw.cmd spring-boot:run -Pboot
