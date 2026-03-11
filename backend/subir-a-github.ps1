# Script para subir proyecto a GitHub
# Ejecutar: .\subir-a-github.ps1

Write-Host "🚀 Script de Subida a GitHub - HAPI FHIR Hospital System" -ForegroundColor Cyan
Write-Host "========================================================" -ForegroundColor Cyan
Write-Host ""

# Verificar que estamos en el directorio correcto
if (-not (Test-Path ".\pom.xml")) {
    Write-Host "❌ Error: No estás en el directorio raíz del proyecto" -ForegroundColor Red
    Write-Host "Ejecuta este script desde: C:\Users\ulise\Desktop\hapi-fhir-jpaserver-starter\" -ForegroundColor Yellow
    exit 1
}

# Verificar que Git está instalado
try {
    $gitVersion = git --version
    Write-Host "✅ Git instalado: $gitVersion" -ForegroundColor Green
} catch {
    Write-Host "❌ Git no está instalado" -ForegroundColor Red
    Write-Host "Instala Git con: winget install Git.Git" -ForegroundColor Yellow
    exit 1
}

Write-Host ""
Write-Host "📋 PASO 1: Verificar archivos críticos" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Verificar maven-wrapper.jar
if (Test-Path ".\.mvn\wrapper\maven-wrapper.jar") {
    $jarSize = (Get-Item ".\.mvn\wrapper\maven-wrapper.jar").Length / 1KB
    Write-Host "✅ maven-wrapper.jar presente ($([math]::Round($jarSize, 2)) KB)" -ForegroundColor Green
} else {
    Write-Host "⚠️  maven-wrapper.jar NO encontrado - ¡ESTO ES CRÍTICO!" -ForegroundColor Red
    Write-Host "   Revisa GUIA_GITHUB.md para repararlo" -ForegroundColor Yellow
}

# Verificar mvnw.cmd
if (Test-Path ".\mvnw.cmd") {
    Write-Host "✅ mvnw.cmd presente" -ForegroundColor Green
} else {
    Write-Host "❌ mvnw.cmd NO encontrado" -ForegroundColor Red
}

# Verificar update-ip.ps1
if (Test-Path ".\flutter_frontend\update-ip.ps1") {
    Write-Host "✅ update-ip.ps1 presente" -ForegroundColor Green
} else {
    Write-Host "⚠️  update-ip.ps1 NO encontrado" -ForegroundColor Yellow
}

# Verificar documentación
$docs = @(
    "CONTEXTO_PARA_NUEVA_SESION.md",
    "DESARROLLO_COMPLETO.md",
    "CHECKLIST_TRANSFERENCIA.md",
    "GUIA_GITHUB.md",
    "PROMPT_PARA_NUEVA_IA.md"
)
$docsCount = 0
foreach ($doc in $docs) {
    if (Test-Path ".\$doc") { $docsCount++ }
}
Write-Host "✅ Documentación: $docsCount/$($docs.Count) archivos encontrados" -ForegroundColor Green

Write-Host ""
Write-Host "📋 PASO 2: Inicializar Git" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Verificar si ya está inicializado
if (Test-Path ".\.git") {
    Write-Host "ℹ️  Git ya está inicializado" -ForegroundColor Cyan
    
    # Verificar si hay remote configurado
    $remote = git remote -v 2>$null
    if ($remote) {
        Write-Host "ℹ️  Remote ya configurado:" -ForegroundColor Cyan
        Write-Host $remote
        
        $continue = Read-Host "`n¿Deseas continuar y hacer push? (s/n)"
        if ($continue -ne "s") {
            Write-Host "❌ Operación cancelada" -ForegroundColor Yellow
            exit 0
        }
    }
} else {
    Write-Host "Inicializando repositorio Git..." -ForegroundColor Cyan
    git init
    Write-Host "✅ Git inicializado" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 PASO 3: Ver archivos que se subirán" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Ver estadísticas
$allFiles = Get-ChildItem -Recurse -File | Measure-Object
$ignoredFiles = git status --ignored --short | Where-Object { $_ -match "^!!" } | Measure-Object

Write-Host "Total de archivos en proyecto: $($allFiles.Count)" -ForegroundColor White
Write-Host "Archivos ignorados (.gitignore): $($ignoredFiles.Count)" -ForegroundColor White
Write-Host "Archivos que se subirán: $($allFiles.Count - $ignoredFiles.Count)" -ForegroundColor Green

Write-Host ""
Write-Host "Archivos principales que SE SUBIRÁN:" -ForegroundColor Green
Write-Host "  ✅ .mvn/wrapper/maven-wrapper.jar" -ForegroundColor White
Write-Host "  ✅ mvnw.cmd" -ForegroundColor White
Write-Host "  ✅ src/main/java/** (código Java)" -ForegroundColor White
Write-Host "  ✅ src/test/java/** (tests)" -ForegroundColor White
Write-Host "  ✅ flutter_frontend/lib/** (código Flutter)" -ForegroundColor White
Write-Host "  ✅ flutter_frontend/test/** (tests Flutter)" -ForegroundColor White
Write-Host "  ✅ flutter_frontend/update-ip.ps1" -ForegroundColor White
Write-Host "  ✅ Documentación (.md)" -ForegroundColor White
Write-Host "  ✅ docker-compose.yml" -ForegroundColor White
Write-Host "  ✅ pom.xml" -ForegroundColor White

Write-Host ""
Write-Host "Archivos que NO se subirán (ignorados):" -ForegroundColor Yellow
Write-Host "  ❌ target/ (compilados Java)" -ForegroundColor DarkGray
Write-Host "  ❌ flutter_frontend/build/ (compilados Flutter)" -ForegroundColor DarkGray
Write-Host "  ❌ .dart_tool/ (cache Dart)" -ForegroundColor DarkGray
Write-Host "  ❌ mvnw.cmd.backup (backup)" -ForegroundColor DarkGray
Write-Host "  ❌ .idea/ (configuración IDE)" -ForegroundColor DarkGray

Write-Host ""
$continue = Read-Host "¿Continuar con el commit? (s/n)"
if ($continue -ne "s") {
    Write-Host "❌ Operación cancelada" -ForegroundColor Yellow
    exit 0
}

Write-Host ""
Write-Host "📋 PASO 4: Agregar archivos a Git" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

Write-Host "Agregando archivos..." -ForegroundColor Cyan
git add .

$stagedFiles = git diff --cached --numstat | Measure-Object
Write-Host "✅ $($stagedFiles.Count) archivos agregados al staging area" -ForegroundColor Green

Write-Host ""
Write-Host "📋 PASO 5: Crear commit" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Crear commit
$commit = git commit -m "Initial commit: HAPI FHIR + Custom Auth + Flutter + Full Documentation

- Sistema de autenticación JWT personalizado
- Controllers: AuthController (login, signup, validate) y UserController (CRUD)
- Frontend Flutter con animaciones y Material Design 3
- Configuración dinámica de red (kIsWeb para web/móvil)
- 23 tests backend + 25 tests frontend (100% pasando)
- Documentación completa (5 archivos .md)
- Maven Wrapper reparado (maven-wrapper.jar + mvnw.cmd)
- Script update-ip.ps1 para actualizar IP automáticamente
- Docker Compose con PostgreSQL 16

Stack: Spring Boot 3.5.9, HAPI FHIR 8.6.1, Flutter 3.38.7, PostgreSQL 16"

if ($LASTEXITCODE -eq 0) {
    Write-Host "✅ Commit creado exitosamente" -ForegroundColor Green
} else {
    Write-Host "⚠️  Commit no necesario o ya existe" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "📋 PASO 6: Configurar repositorio remoto" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

# Verificar si ya hay remote
$existingRemote = git remote get-url origin 2>$null
if ($existingRemote) {
    Write-Host "ℹ️  Remote ya configurado: $existingRemote" -ForegroundColor Cyan
    $changeRemote = Read-Host "¿Deseas cambiar la URL del remote? (s/n)"
    
    if ($changeRemote -eq "s") {
        Write-Host ""
        Write-Host "Ingresa la URL de tu repositorio GitHub:" -ForegroundColor Cyan
        Write-Host "Ejemplo: https://github.com/tu-usuario/hapi-fhir-hospital-system.git" -ForegroundColor Gray
        $repoUrl = Read-Host "URL"
        
        if ($repoUrl) {
            git remote set-url origin $repoUrl
            Write-Host "✅ Remote actualizado" -ForegroundColor Green
        }
    }
} else {
    Write-Host ""
    Write-Host "⚠️  NO tienes un remote configurado. Necesitas crear un repositorio en GitHub primero." -ForegroundColor Yellow
    Write-Host ""
    Write-Host "Pasos:" -ForegroundColor Cyan
    Write-Host "1. Ve a: https://github.com/new" -ForegroundColor White
    Write-Host "2. Repository name: hapi-fhir-hospital-system" -ForegroundColor White
    Write-Host "3. ❌ NO marcar 'Initialize with README'" -ForegroundColor Red
    Write-Host "4. ❌ NO agregar .gitignore" -ForegroundColor Red
    Write-Host "5. Privado o Público (recomiendo Privado)" -ForegroundColor White
    Write-Host "6. Click 'Create repository'" -ForegroundColor White
    Write-Host ""
    
    $createRepo = Read-Host "¿Ya creaste el repositorio en GitHub? (s/n)"
    if ($createRepo -ne "s") {
        Write-Host ""
        Write-Host "❌ Crea el repositorio primero, luego ejecuta este script de nuevo" -ForegroundColor Yellow
        exit 0
    }
    
    Write-Host ""
    Write-Host "Ingresa la URL de tu repositorio GitHub:" -ForegroundColor Cyan
    Write-Host "Ejemplo: https://github.com/tu-usuario/hapi-fhir-hospital-system.git" -ForegroundColor Gray
    $repoUrl = Read-Host "URL"
    
    if (-not $repoUrl) {
        Write-Host "❌ URL no proporcionada. Operación cancelada." -ForegroundColor Red
        exit 1
    }
    
    git remote add origin $repoUrl
    Write-Host "✅ Remote configurado: $repoUrl" -ForegroundColor Green
}

Write-Host ""
Write-Host "📋 PASO 7: Subir a GitHub" -ForegroundColor Yellow
Write-Host "----------------------------------------" -ForegroundColor Yellow

Write-Host "Cambiando rama a 'main'..." -ForegroundColor Cyan
git branch -M main

Write-Host "Subiendo a GitHub..." -ForegroundColor Cyan
Write-Host ""
Write-Host "⚠️  Si pide autenticación:" -ForegroundColor Yellow
Write-Host "   Username: tu-usuario-github" -ForegroundColor White
Write-Host "   Password: [USA PERSONAL ACCESS TOKEN, NO TU PASSWORD]" -ForegroundColor White
Write-Host ""
Write-Host "   Crear token en: https://github.com/settings/tokens" -ForegroundColor Gray
Write-Host "   Scope necesario: 'repo' (full control of private repositories)" -ForegroundColor Gray
Write-Host ""

$pushResult = git push -u origin main 2>&1

if ($LASTEXITCODE -eq 0) {
    Write-Host ""
    Write-Host "🎉 ¡ÉXITO! Proyecto subido a GitHub" -ForegroundColor Green
    Write-Host "========================================================" -ForegroundColor Green
    Write-Host ""
    Write-Host "✅ Todo el código está en GitHub" -ForegroundColor Green
    Write-Host "✅ maven-wrapper.jar incluido" -ForegroundColor Green
    Write-Host "✅ Documentación incluida" -ForegroundColor Green
    Write-Host "✅ Configuración incluida" -ForegroundColor Green
    Write-Host ""
    
    $repoUrl = git remote get-url origin
    Write-Host "🔗 URL del repositorio: $repoUrl" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "📋 Próximos pasos en la NUEVA laptop:" -ForegroundColor Yellow
    Write-Host "   1. git clone $repoUrl" -ForegroundColor White
    Write-Host "   2. cd hapi-fhir-hospital-system" -ForegroundColor White
    Write-Host "   3. cd flutter_frontend; .\update-ip.ps1" -ForegroundColor White
    Write-Host "   4. docker-compose up -d" -ForegroundColor White
    Write-Host "   5. .\mvnw.cmd spring-boot:run -Pboot" -ForegroundColor White
    Write-Host ""
    Write-Host "📚 Consulta GUIA_GITHUB.md para más detalles" -ForegroundColor Cyan
} else {
    Write-Host ""
    Write-Host "⚠️  Error al subir a GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles causas:" -ForegroundColor Yellow
    Write-Host "  1. Autenticación fallida (usa Personal Access Token, no password)" -ForegroundColor White
    Write-Host "  2. URL del repositorio incorrecta" -ForegroundColor White
    Write-Host "  3. No tienes permisos en el repositorio" -ForegroundColor White
    Write-Host "  4. Ya existe código en el repositorio (hacer pull primero)" -ForegroundColor White
    Write-Host ""
    Write-Host "Consulta GUIA_GITHUB.md para soluciones detalladas" -ForegroundColor Cyan
}

Write-Host ""
Write-Host "Fin del script" -ForegroundColor Gray
