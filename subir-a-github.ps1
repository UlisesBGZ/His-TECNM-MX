# ========================================================================
# Script para Subir a GitHub: His-TECNM-MX
# Sistema Hospitalario - TECNM México
# ========================================================================

Write-Host "`n╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
Write-Host "║                                                                    ║" -ForegroundColor Cyan
Write-Host "║     SUBIR PROYECTO A GITHUB: His-TECNM-MX                         ║" -ForegroundColor Cyan -BackgroundColor DarkCyan
Write-Host "║                                                                    ║" -ForegroundColor Cyan
Write-Host "╚════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Cyan

# Verificar que estamos en el directorio correcto
$currentDir = Get-Location
if ($currentDir.Path -notlike "*Hospital-FHIR-System*") {
    Write-Host "❌ ERROR: Debes ejecutar este script desde la carpeta Hospital-FHIR-System" -ForegroundColor Red
    Write-Host "Directorio actual: $($currentDir.Path)" -ForegroundColor Yellow
    exit 1
}

Write-Host "📍 Directorio actual: $($currentDir.Path)" -ForegroundColor Yellow
Write-Host ""

# ========================================================================
# PASO 1: Verificar configuración de Git
# ========================================================================

Write-Host "🔍 PASO 1: Verificando configuración de Git..." -ForegroundColor Cyan

$gitUser = git config user.name
$gitEmail = git config user.email

if ([string]::IsNullOrEmpty($gitUser) -or [string]::IsNullOrEmpty($gitEmail)) {
    Write-Host "⚠️ Configuración de Git no encontrada. Configurando..." -ForegroundColor Yellow
    
    $username = Read-Host "Ingresa tu nombre de usuario de GitHub"
    $email = Read-Host "Ingresa tu email de GitHub"
    
    git config --global user.name $username
    git config --global user.email $email
    
    Write-Host "✅ Configuración de Git actualizada" -ForegroundColor Green
} else {
    Write-Host "✅ Usuario Git: $gitUser" -ForegroundColor Green
    Write-Host "✅ Email Git: $gitEmail" -ForegroundColor Green
}

Write-Host ""

# ========================================================================
# PASO 2: Verificar estado del repositorio local
# ========================================================================

Write-Host "🔍 PASO 2: Verificando repositorio local..." -ForegroundColor Cyan

# Verificar si hay commits
$commitCount = git rev-list --count HEAD 2>$null
if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($commitCount)) {
    Write-Host "⚠️ No hay commits en el repositorio. Creando commit inicial..." -ForegroundColor Yellow
    
    git add .
    git commit -m "feat: Initial commit - Sistema Hospitalario TECNM México"
    
    Write-Host "✅ Commit inicial creado" -ForegroundColor Green
} else {
    Write-Host "✅ Repositorio tiene $commitCount commit(s)" -ForegroundColor Green
}

# Verificar archivos sin commit
$uncommittedFiles = git status --short
if (![string]::IsNullOrEmpty($uncommittedFiles)) {
    Write-Host "⚠️ Hay archivos sin commitear:" -ForegroundColor Yellow
    git status --short
    
    $commitNow = Read-Host "`n¿Deseas hacer commit de estos archivos ahora? (s/n)"
    if ($commitNow -eq "s" -or $commitNow -eq "S") {
        git add .
        $commitMessage = Read-Host "Ingresa el mensaje del commit"
        git commit -m $commitMessage
        Write-Host "✅ Commit realizado" -ForegroundColor Green
    }
}

Write-Host ""

# ========================================================================
# PASO 3: Instrucciones para crear repositorio en GitHub
# ========================================================================

Write-Host "📝 PASO 3: CREAR REPOSITORIO EN GITHUB" -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "Por favor, sigue estos pasos en GitHub:" -ForegroundColor Yellow
Write-Host ""
Write-Host "1. Ve a: https://github.com/new" -ForegroundColor White
Write-Host ""
Write-Host "2. Configura el repositorio:" -ForegroundColor White
Write-Host "   • Repository name: " -NoNewline -ForegroundColor White
Write-Host "His-TECNM-MX" -ForegroundColor Green
Write-Host "   • Description: " -NoNewline -ForegroundColor White
Write-Host "Sistema Hospitalario - TECNM México con HAPI FHIR" -ForegroundColor Gray
Write-Host "   • Visibility: " -NoNewline -ForegroundColor White
Write-Host "Public ó Private (tu elección)" -ForegroundColor Gray
Write-Host "   • ❌ NO inicializar con README (ya lo tenemos)" -ForegroundColor Red
Write-Host "   • ❌ NO agregar .gitignore (ya lo tenemos)" -ForegroundColor Red
Write-Host "   • ❌ NO agregar licencia (opcional, puedes agregar después)" -ForegroundColor Red
Write-Host ""
Write-Host "3. Click en " -NoNewline -ForegroundColor White
Write-Host "Create repository" -ForegroundColor Green
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray

$continue = Read-Host "`n¿Ya creaste el repositorio en GitHub? (s/n)"
if ($continue -ne "s" -and $continue -ne "S") {
    Write-Host "`n⏸️ Script pausado. Ejecuta nuevamente cuando hayas creado el repositorio." -ForegroundColor Yellow
    exit 0
}

Write-Host ""

# ========================================================================
# PASO 4: Conectar con GitHub y subir
# ========================================================================

Write-Host "🚀 PASO 4: Conectando con GitHub..." -ForegroundColor Cyan

# Pedir el nombre de usuario de GitHub
$githubUsername = Read-Host "Ingresa tu nombre de usuario de GitHub"

# Crear la URL del repositorio
$repoUrl = "https://github.com/$githubUsername/His-TECNM-MX.git"

Write-Host "`n📡 URL del repositorio: $repoUrl" -ForegroundColor Yellow

# Verificar si ya hay un remote configurado
$existingRemote = git remote get-url origin 2>$null

if (![string]::IsNullOrEmpty($existingRemote)) {
    Write-Host "⚠️ Ya existe un remote configurado: $existingRemote" -ForegroundColor Yellow
    $changeRemote = Read-Host "¿Deseas cambiarlo? (s/n)"
    
    if ($changeRemote -eq "s" -or $changeRemote -eq "S") {
        git remote remove origin
        git remote add origin $repoUrl
        Write-Host "✅ Remote actualizado" -ForegroundColor Green
    }
} else {
    git remote add origin $repoUrl
    Write-Host "✅ Remote agregado: origin -> $repoUrl" -ForegroundColor Green
}

Write-Host ""

# Configurar rama principal como 'main'
$currentBranch = git branch --show-current
if ($currentBranch -ne "main") {
    Write-Host "🔄 Renombrando rama a 'main'..." -ForegroundColor Cyan
    git branch -M main
    Write-Host "✅ Rama renombrada a 'main'" -ForegroundColor Green
}

Write-Host ""

# ========================================================================
# PASO 5: Push al repositorio
# ========================================================================

Write-Host "🚀 PASO 5: Subiendo código a GitHub..." -ForegroundColor Cyan
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""

Write-Host "Ejecutando: git push -u origin main" -ForegroundColor Yellow
Write-Host ""

try {
    git push -u origin main
    
    if ($LASTEXITCODE -eq 0) {
        Write-Host "`n╔════════════════════════════════════════════════════════════════════╗" -ForegroundColor Green
        Write-Host "║                                                                    ║" -ForegroundColor Green
        Write-Host "║     ✅ PROYECTO SUBIDO EXITOSAMENTE A GITHUB                      ║" -ForegroundColor Green -BackgroundColor DarkGreen
        Write-Host "║                                                                    ║" -ForegroundColor Green
        Write-Host "╚════════════════════════════════════════════════════════════════════╝`n" -ForegroundColor Green
        
        Write-Host "📦 Repositorio: " -NoNewline -ForegroundColor Cyan
        Write-Host "His-TECNM-MX" -ForegroundColor Green
        Write-Host "👤 Usuario: " -NoNewline -ForegroundColor Cyan
        Write-Host "$githubUsername" -ForegroundColor Green
        Write-Host "🌐 URL: " -NoNewline -ForegroundColor Cyan
        Write-Host "https://github.com/$githubUsername/His-TECNM-MX" -ForegroundColor Blue
        Write-Host ""
        Write-Host "🎉 Puedes ver tu repositorio en:" -ForegroundColor Yellow
        Write-Host "   https://github.com/$githubUsername/His-TECNM-MX" -ForegroundColor Blue
        Write-Host ""
    } else {
        throw "Error al hacer push"
    }
} catch {
    Write-Host "`n❌ ERROR al subir el código a GitHub" -ForegroundColor Red
    Write-Host ""
    Write-Host "Posibles causas:" -ForegroundColor Yellow
    Write-Host "1. El repositorio 'His-TECNM-MX' no existe en GitHub" -ForegroundColor White
    Write-Host "2. No tienes permisos para subir a ese repositorio" -ForegroundColor White
    Write-Host "3. Necesitas autenticación con token personal (si es privado)" -ForegroundColor White
    Write-Host ""
    Write-Host "Para autenticación con token:" -ForegroundColor Cyan
    Write-Host "1. Ve a: https://github.com/settings/tokens" -ForegroundColor White
    Write-Host "2. Genera un nuevo token (classic)" -ForegroundColor White
    Write-Host "3. Copia el token y úsalo como contraseña cuando Git lo pida" -ForegroundColor White
    Write-Host ""
    Write-Host "Comando manual:" -ForegroundColor Cyan
    Write-Host "git push -u origin main" -ForegroundColor Yellow
    Write-Host ""
    exit 1
}

# ========================================================================
# FINALIZACIÓN
# ========================================================================

Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "📚 Próximos pasos sugeridos:" -ForegroundColor Cyan
Write-Host ""
Write-Host "1. Configurar GitHub Actions (CI/CD)" -ForegroundColor White
Write-Host "2. Agregar badges al README (build status, tests, etc.)" -ForegroundColor White
Write-Host "3. Configurar branch protection rules" -ForegroundColor White
Write-Host "4. Invitar colaboradores si es necesario" -ForegroundColor White
Write-Host ""
Write-Host "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━" -ForegroundColor DarkGray
Write-Host ""
Write-Host "✅ Script completado con éxito" -ForegroundColor Green
Write-Host ""
