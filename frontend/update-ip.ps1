# 🔧 Script para actualizar la IP en la configuración de Flutter
# Ejecuta este script cuando cambie la IP de tu laptop

Write-Host "🔍 Detectando IP actual de tu laptop..." -ForegroundColor Cyan

# Obtener la IP de la red local (excluyendo Docker, VirtualBox, etc.)
$ipInfo = Get-NetIPAddress -AddressFamily IPv4 | 
    Where-Object {
        $_.IPAddress -notlike "127.*" -and 
        $_.IPAddress -notlike "169.254.*" -and
        $_.IPAddress -notlike "172.*" -and
        $_.IPAddress -notlike "10.0.2.*" -and
        $_.InterfaceAlias -notlike "*Loopback*" -and
        $_.InterfaceAlias -notlike "*VirtualBox*" -and
        $_.InterfaceAlias -notlike "*WSL*" -and
        $_.InterfaceAlias -notlike "*Docker*"
    } | Select-Object -First 1

if ($ipInfo) {
    $currentIP = $ipInfo.IPAddress
    Write-Host "✅ IP encontrada: $currentIP" -ForegroundColor Green
    Write-Host ""
    
    # Actualizar api_config.dart
    $apiConfigPath = "lib\config\api_config.dart"
    $apiConfigContent = Get-Content $apiConfigPath -Raw
    
    if ($apiConfigContent -match "static const String _mobileBaseUrl = 'http://([0-9.]+):8080'") {
        $oldIP = $matches[1]
        
        if ($oldIP -eq $currentIP) {
            Write-Host "ℹ️  La IP ya está actualizada ($currentIP)" -ForegroundColor Yellow
        } else {
            Write-Host "📝 Actualizando de $oldIP a $currentIP..." -ForegroundColor Cyan
            
            # Actualizar api_config.dart
            $apiConfigContent = $apiConfigContent -replace "http://$oldIP:8080", "http://$currentIP:8080"
            Set-Content -Path $apiConfigPath -Value $apiConfigContent
            
            # Actualizar fhir_service.dart
            $fhirServicePath = "lib\services\fhir_service.dart"
            $fhirServiceContent = Get-Content $fhirServicePath -Raw
            $fhirServiceContent = $fhirServiceContent -replace "http://$oldIP:8080", "http://$currentIP:8080"
            Set-Content -Path $fhirServicePath -Value $fhirServiceContent
            
            Write-Host "✅ Configuración actualizada correctamente" -ForegroundColor Green
            Write-Host ""
            Write-Host "📱 Para aplicar cambios en dispositivo móvil:" -ForegroundColor Cyan
            Write-Host "   flutter run -d <DEVICE_ID>" -ForegroundColor White
        }
    }
} else {
    Write-Host "❌ No se pudo detectar la IP de red local" -ForegroundColor Red
    Write-Host "💡 Ejecuta manualmente: ipconfig | Select-String 'IPv4'" -ForegroundColor Yellow
}

Write-Host ""
Write-Host "🌐 Configuración actual:" -ForegroundColor Cyan
Write-Host "   Web (Chrome/Edge):     http://localhost:8080" -ForegroundColor White
Write-Host "   Móvil (Android/iOS):   http://$currentIP:8080" -ForegroundColor White
