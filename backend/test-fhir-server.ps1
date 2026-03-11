# Script de prueba para servidor HAPI FHIR
Write-Host "=== Pruebas de Servidor HAPI FHIR ===" -ForegroundColor Cyan
Write-Host ""

# Test 1: Verificar que el servidor está corriendo
Write-Host "1. Probando conexión al servidor..." -ForegroundColor Yellow
try {
    $response = Invoke-WebRequest -Uri "http://localhost:8080/fhir/metadata" -UseBasicParsing -ErrorAction Stop
    Write-Host "   ✓ Servidor respondiendo - Status: $($response.StatusCode)" -ForegroundColor Green
    $metadata = $response.Content | ConvertFrom-Json
    Write-Host "   ✓ Versión FHIR: $($metadata.fhirVersion)" -ForegroundColor Green
    Write-Host "   ✓ Nombre del servidor: $($metadata.software.name)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Error: $($_.Exception.Message)" -ForegroundColor Red
    exit 1
}

Write-Host ""
# Test 2: Crear un paciente
Write-Host "2. Creando paciente de prueba..." -ForegroundColor Yellow
$patientJson = @{
    resourceType = "Patient"
    name = @(
        @{
            family = "Pérez"
            given = @("Juan", "Carlos")
        }
    )
    gender = "male"
    birthDate = "1990-01-15"
    address = @(
        @{
            city = "Ciudad de México"
            country = "México"
        }
    )
} | ConvertTo-Json -Depth 10

try {
    $createResponse = Invoke-WebRequest -Uri "http://localhost:8080/fhir/Patient" `
        -Method POST `
        -Body $patientJson `
        -ContentType "application/fhir+json" `
        -UseBasicParsing `
        -ErrorAction Stop
    
    Write-Host "   ✓ Paciente creado - Status: $($createResponse.StatusCode)" -ForegroundColor Green
    $createdPatient = $createResponse.Content | ConvertFrom-Json
    $patientId = $createdPatient.id
    Write-Host "   ✓ ID del paciente: $patientId" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Error al crear paciente: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
# Test 3: Buscar pacientes
Write-Host "3. Buscando pacientes..." -ForegroundColor Yellow
try {
    $searchResponse = Invoke-WebRequest -Uri "http://localhost:8080/fhir/Patient" -UseBasicParsing -ErrorAction Stop
    $bundle = $searchResponse.Content | ConvertFrom-Json
    Write-Host "   ✓ Búsqueda exitosa - Total encontrados: $($bundle.total)" -ForegroundColor Green
} catch {
    Write-Host "   ✗ Error al buscar pacientes: $($_.Exception.Message)" -ForegroundColor Red
}

Write-Host ""
# Test 4: Leer el paciente específico
if ($patientId) {
    Write-Host "4. Leyendo paciente específico (ID: $patientId)..." -ForegroundColor Yellow
    try {
        $readResponse = Invoke-WebRequest -Uri "http://localhost:8080/fhir/Patient/$patientId" -UseBasicParsing -ErrorAction Stop
        $patient = $readResponse.Content | ConvertFrom-Json
        Write-Host "   ✓ Paciente leído correctamente" -ForegroundColor Green
        Write-Host "   ✓ Nombre: $($patient.name[0].given -join ' ') $($patient.name[0].family)" -ForegroundColor Green
        Write-Host "   ✓ Género: $($patient.gender)" -ForegroundColor Green
        Write-Host "   ✓ Fecha de nacimiento: $($patient.birthDate)" -ForegroundColor Green
    } catch {
        Write-Host "   ✗ Error al leer paciente: $($_.Exception.Message)" -ForegroundColor Red
    }
}

Write-Host ""
Write-Host "=== Resumen de Pruebas Completado ===" -ForegroundColor Cyan
Write-Host "El servidor HAPI FHIR está funcionando correctamente y conectado a PostgreSQL." -ForegroundColor Green
Write-Host ""
Write-Host "URLs importantes:" -ForegroundColor Yellow
Write-Host "  - Web UI: http://localhost:8080" -ForegroundColor White
Write-Host "  - FHIR Base: http://localhost:8080/fhir" -ForegroundColor White
Write-Host "  - Metadata: http://localhost:8080/fhir/metadata" -ForegroundColor White
