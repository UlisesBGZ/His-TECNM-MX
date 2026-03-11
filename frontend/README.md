# Sistema Hospitalario con HAPI FHIR

Sistema completo de gestión hospitalaria con autenticación JWT, gestión de usuarios y recursos FHIR.

## 🚀 Inicio Rápido

### Levantar el Backend

**Prerequisitos:**
- Java 21.0.10 o superior
- Docker Desktop ejecutándose
- Maven Wrapper 3.3.2 (incluido en el proyecto)

```powershell
# En el directorio raíz del proyecto
cd ../

# Iniciar PostgreSQL
docker-compose up -d

# Iniciar el servidor backend
.\mvnw.cmd spring-boot:run -Pboot
```

El backend estará disponible en `http://localhost:8080`

### Levantar el Frontend

**Prerequisitos:**
- Flutter 3.27.3 o superior

```bash
# Instalar dependencias
flutter pub get

# Ejecutar en web (Chrome)
flutter run -d chrome

# O ejecutar en Android/iOS (actualizar IP primero)
# Ver sección "Configuración de Red" más abajo
```

## 🔑 Credenciales por Defecto

- **Usuario Admin**: `admin`
- **Contraseña**: `admin123`

## 📡 API Endpoints

### Autenticación:
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/signup` - Registrar usuario
- `GET /api/auth/validate` - Validar token JWT
- `POST /api/auth/create-admin` - Crear administrador

### Usuarios (Solo Admin):
- `GET /api/users` - Listar todos los usuarios
- `GET /api/users/{id}` - Obtener usuario por ID
- `PUT /api/users/{id}` - Actualizar usuario
- `DELETE /api/users/{id}` - Eliminar usuario
- `PATCH /api/users/{id}/toggle-status` - Habilitar/Deshabilitar usuario

### FHIR (Estándar HL7 FHIR R4):
- `GET/POST /fhir/Patient` - Gestión de pacientes
- `GET/POST /fhir/Practitioner` - Gestión de profesionales
- `GET/POST /fhir/Appointment` - Gestión de citas
- `GET/POST /fhir/Observation` - Gestión de observaciones
- Más endpoints según estándar HL7 FHIR R4

## 🌐 Configuración de Red

### Para Web (Localhost):
La aplicación usa automáticamente `http://localhost:8080` cuando se ejecuta en navegador.

### Para Móvil (Android/iOS):
Necesitas actualizar la IP de red local antes de compilar para móvil:

```powershell
# Ejecutar el script de actualización automática
.\update-ip.ps1

# El script obtendrá tu IP local y actualizará:
# - lib/config/api_config.dart
# - lib/services/fhir_service.dart
```

**Detección Automática**: El código usa `kIsWeb` de Flutter para detectar la plataforma y usar la URL correcta automáticamente.

## 🏗️ Arquitectura

- **Backend**: Spring Boot 3.5.9 + HAPI FHIR 8.6.1 + JWT Auth
- **Frontend**: Flutter 3.27.3 (Web, Android, iOS)
- **Base de Datos**: PostgreSQL 16
  - Puerto: 5432
  - Usuario: `admin`
  - Contraseña: `admin`
  - Base de datos: `fhirdb`

## 🧪 Tests

```bash
# Correr todos los tests del frontend
flutter test

# Tests disponibles:
# - auth_service_test.dart: 12 tests ✅
# - fhir_service_test.dart: 11 tests ✅
# Total: 25 tests pasando
```

## 📦 Dependencias Principales

```yaml
dependencies:
  flutter: ^3.27.3
  http: ^1.2.2          # Cliente HTTP
  provider: ^6.1.2      # Gestión de estado
  intl: ^0.19.0        # Internacionalización (compatible con flutter_localizations)
  shared_preferences: ^2.3.5  # Almacenamiento local
```

## 📚 Documentación Adicional

Ver documentación completa en el directorio raíz:
- **AGENTS.md** - Guía completa de desarrollo
- **CONTEXTO_PARA_NUEVA_SESION.md** - Setup completo del proyecto
- **AUTHENTICATION.md** - Detalles del sistema de autenticación JWT
- **CHECKLIST_TRANSFERENCIA.md** - Guía para nueva laptop

## 🔧 Variables de Configuración

### `lib/config/api_config.dart`
```dart
class ApiConfig {
  static const String _webBaseUrl = 'http://localhost:8080';
  static const String _mobileBaseUrl = 'http://192.168.0.181:8080';  // Tu IP local
  
  // Detección automática de plataforma
  static String get baseUrl => kIsWeb ? _webBaseUrl : _mobileBaseUrl;
}
```

## 🐛 Troubleshooting

### Error de conexión en móvil
```bash
# 1. Verificar que backend está corriendo
curl http://localhost:8080/fhir/metadata

# 2. Actualizar IP con el script
.\update-ip.ps1

# 3. Verificar que la IP es correcta
ipconfig  # Windows
ifconfig  # Linux/Mac
```

### Error de dependencias
```bash
# Limpiar caché y reinstalar
flutter clean
flutter pub get
```

### Error de compilación
```bash
# Actualizar Flutter
flutter upgrade

# Verificar configuración
flutter doctor
```
