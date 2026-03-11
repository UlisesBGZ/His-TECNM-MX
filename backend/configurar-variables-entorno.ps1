# 🔧 Script para Configurar Variables de Entorno Permanentemente
# Ejecutar como Administrador: .\configurar-variables-entorno.ps1

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "⚙️  CONFIGURACIÓN DE VARIABLES DE ENTORNO" -ForegroundColor Cyan
Write-Host "========================================`n" -ForegroundColor Cyan

# 1. Configurar JAVA_HOME
$javaHome = "C:\Program Files\Java\jdk-21.0.10"
if (Test-Path $javaHome) {
    Write-Host "📍 Configurando JAVA_HOME..." -ForegroundColor Yellow
    [Environment]::SetEnvironmentVariable("JAVA_HOME", $javaHome, "Machine")
    Write-Host "   ✅ JAVA_HOME = $javaHome" -ForegroundColor Green
} else {
    Write-Host "   ❌ No se encontró Java en $javaHome" -ForegroundColor Red
}

# 2. Configurar Flutter en PATH
$flutterPath = "C:\src\flutter\bin"
if (Test-Path $flutterPath) {
    Write-Host "`n📍 Agregando Flutter al PATH..." -ForegroundColor Yellow
    
    $currentPath = [Environment]::GetEnvironmentVariable("Path", "Machine")
    
    if ($currentPath -notlike "*$flutterPath*") {
        $newPath = "$currentPath;$flutterPath"
        [Environment]::SetEnvironmentVariable("Path", $newPath, "Machine")
        Write-Host "   ✅ Flutter agregado al PATH" -ForegroundColor Green
    } else {
        Write-Host "   ℹ️  Flutter ya está en el PATH" -ForegroundColor Yellow
    }
} else {
    Write-Host "   ❌ No se encontró Flutter en $flutterPath" -ForegroundColor Red
}

Write-Host "`n========================================" -ForegroundColor Cyan
Write-Host "✅ CONFIGURACIÓN COMPLETADA" -ForegroundColor Green
Write-Host "========================================`n" -ForegroundColor Cyan

Write-Host "⚠️  IMPORTANTE: Debes REINICIAR PowerShell (o VS Code)" -ForegroundColor Yellow
Write-Host "   para que los cambios surtan efecto.`n" -ForegroundColor Yellow

Write-Host "Para verificar después de reiniciar:" -ForegroundColor Cyan
Write-Host "   java -version" -ForegroundColor White
Write-Host "   flutter --version" -ForegroundColor White
Write-Host ""
