# Frontend - Sistema Hospitalario FHIR

Aplicación Flutter multiplataforma (Web + Android) para el sistema hospitalario FHIR.

## Stack Tecnológico

- **Framework**: Flutter 3.27.3 / Dart 3.6.1
- **Diseño**: Material Design 3
- **Estado**: Provider 6.1.2
- **HTTP Client**: http 1.2.2
- **Almacenamiento**: shared_preferences 2.3.5
- **Testing**: flutter_test, http + Mockito

## Estructura del Código

```
frontend/
├── lib/
│   ├── main.dart                           # Entry point
│   ├── config/
│   │   └── api_config.dart                 # URLs dinámicas (web/móvil)
│   ├── providers/
│   │   └── auth_provider.dart              # Estado de autenticación
│   ├── services/
│   │   ├── auth_service.dart               # API de autenticación
│   │   └── fhir_service.dart               # API FHIR
│   ├── models/
│   │   ├── auth_models.dart                # User, LoginRequest, etc.
│   │   ├── fhir_patient.dart               # Modelo Patient
│   │   ├── fhir_practitioner.dart          # Modelo Practitioner
│   │   └── fhir_appointment.dart           # Modelo Appointment
│   └── screens/
│       ├── login_screen.dart               # Pantalla de login
│       ├── home_screen.dart                # Pantalla principal
│       ├── patient_list_screen.dart        # Lista de pacientes
│       ├── patient_form_screen.dart        # Crear/editar paciente
│       ├── practitioner_list_screen.dart   # Lista de médicos
│       └── appointment_list_screen.dart    # Lista de citas
│
├── test/
│   ├── services/
│   │   ├── auth_service_test.dart         # 12 tests ✅
│   │   └── fhir_service_test.dart         # 11 tests ✅
│   └── widget_test.dart                    # 2 tests ✅
│
├── pubspec.yaml                            # Dependencias
├── update-ip.ps1                           # Script para actualizar IP de red
└── android/                                # Configuración Android
```

## Inicio Rápido

### 1. Instalar Dependencias

```bash
flutter pub get
```

### 2. Ejecutar en Web (Chrome)

```bash
flutter run -d chrome
```

La aplicación se abrirá automáticamente en Chrome en `http://localhost:*`

### 3. Ejecutar en Android

**Importante**: Primero actualiza tu IP de red:

```powershell
# Windows
.\update-ip.ps1

# Luego ejecuta
flutter run
```

## Configuración Dinámica de Red

La aplicación detecta automáticamente la plataforma y usa la URL correcta:

### `lib/config/api_config.dart`

```dart
import 'package:flutter/foundation.dart';

class ApiConfig {
  static String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';  // Web usa localhost
    } else {
      return 'http://192.168.X.X:8080';  // Móvil usa IP de red
    }
  }
}
```

### Script de Actualización Automática

El script `update-ip.ps1` obtiene automáticamente tu IP local y actualiza:
- `lib/config/api_config.dart`
- `lib/services/fhir_service.dart`

```powershell
.\update-ip.ps1
```

## Funcionalidades

### Autenticación
- ✅ Login con usuario y contraseña
- ✅ Almacenamiento seguro del token JWT
- ✅ Validación automática del token
- ✅ Cierre de sesión
- ✅ Estado de autenticación global (Provider)

### Gestión de Pacientes
- ✅ Lista de pacientes con búsqueda
- ✅ Ver detalles de paciente
- ✅ Crear nuevo paciente
- ✅ Editar paciente existente
- ✅ Eliminar paciente (con confirmación)
- ✅ **Actualización instantánea** al crear/editar

### Gestión de Médicos
- ✅ Lista de profesionales de salud
- ✅ Ver detalles de médico
- ✅ Filtros por especialidad

### Gestión de Citas
- ✅ Lista de citas programadas
- ✅ Detalles de cita (paciente, médico, fecha)
- ✅ Estado de la cita (pendiente, confirmada, cancelada)

### UI/UX
- ✅ Material Design 3
- ✅ Tema personalizado (azul/morado)
- ✅ Animaciones suaves
- ✅ Indicadores de carga
- ✅ Manejo de errores con SnackBars
- ✅ Responsive design

## Credenciales por Defecto

- **Usuario**: `admin`
- **Contraseña**: `admin123`

## Testing

### Ejecutar Todos los Tests

```bash
flutter test
```

**Cobertura de Tests:**
- **auth_service_test.dart**: 12 tests
  - Login exitoso/fallido
  - Signup con validaciones
  - Validación de token
  - Manejo de errores
- **fhir_service_test.dart**: 11 tests
  - CRUD de pacientes
  - Lista de recursos FHIR
  - Manejo de errores HTTP
- **widget_test.dart**: 2 tests
  - Renderizado de widgets
  
**Total**: 25 tests pasando ✅

### Ejecutar Tests Específicos

```bash
# Solo tests de autenticación
flutter test test/services/auth_service_test.dart

# Solo tests FHIR
flutter test test/services/fhir_service_test.dart
```

## Dependencias Principales

```yaml
dependencies:
  # Framework
  flutter: ^3.27.3
  
  # Gestión de Estado
  provider: ^6.1.2
  
  # HTTP y Networking
  http: ^1.2.2
  
  # Almacenamiento Local
  shared_preferences: ^2.3.5
  
  # Internacionalización
  intl: ^0.19.0
  
dev_dependencies:
  # Testing
  flutter_test:
  mockito: ^5.4.0
  build_runner: ^2.4.0
```

## Arquitectura de la Aplicación

### Estado Global (Provider)

```dart
MultiProvider(
  providers: [
    ChangeNotifierProvider(create: (_) => AuthProvider()),
  ],
  child: MaterialApp(...),
)
```

### Flujo de Autenticación

```
1. Usuario ingresa credenciales
2. auth_service.dart hace POST /api/auth/login
3. Recibe token JWT
4. auth_provider guarda token en memoria y SharedPreferences
5. Navegación automática a HomeScreen
6. Cada request HTTP incluye: Authorization: Bearer <token>
```

### Actualización Instantánea de Listas

Cuando creas/editas un paciente:

```dart
// PatientFormScreen retorna el paciente guardado
Navigator.of(context).pop(savedPatient);

// PatientListScreen lo recibe y actualiza la lista
if (result != null) {
  _patients.add(result);  // Agregar a la lista
  _filterPatients();      // Actualizar vista
}
```

## Configuración Android

### `android/app/build.gradle`

```gradle
android {
    compileSdk = 34
    
    defaultConfig {
        minSdk = 21
        targetSdk = 34
    }
}
```

### Permisos de Internet

Ya configurado en `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
```

## Troubleshooting

### Error: "Failed to fetch" en móvil

**Causa**: La IP del backend es incorrecta o el backend no está corriendo.

**Solución**:
```powershell
# 1. Verificar que backend está corriendo
curl http://localhost:8080/fhir/metadata

# 2. Actualizar IP
.\update-ip.ps1

# 3. Reconstruir la app
flutter clean
flutter run
```

### Error: "PlatformException: SharedPreferences"

**Causa**: Error al inicializar SharedPreferences.

**Solución**:
```bash
flutter clean
flutter pub get
```

### Error: Dependencias no resuelven

**Solución**:
```bash
# Actualizar Flutter
flutter upgrade

# Limpiar caché
flutter pub cache repair
flutter pub get
```

### Error: "Token expired"

**Causa**: El token JWT expiró (24 horas por defecto).

**Solución**: Vuelve a hacer login. El token se renovará automáticamente.

## Comandos Útiles

```bash
# Ejecutar en modo release (más rápido)
flutter run --release

# Construir APK para Android
flutter build apk --release

# Construir para web
flutter build web

# Analizar el código
flutter analyze

# Formatear código
dart format lib/

# Ver dispositivos disponibles
flutter devices
```

## Características de UI

### Tema Personalizado

```dart
ThemeData(
  primarySwatch: Colors.blue,
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    brightness: Brightness.light,
  ),
  useMaterial3: true,
)
```

### Animaciones

- **Login**: FadeIn + SlideTransition (1200ms)
- **Home**: ScaleTransition escalonada (1500ms)
- **Listas**: Hero transitions
- **Botones**: Ripple effect automático

## Build para Producción

### Android

```bash
# Generar APK
flutter build apk --release

# Generar App Bundle (para Play Store)
flutter build appbundle --release
```

El APK estará en: `build/app/outputs/flutter-apk/app-release.apk`

### Web

```bash
# Build optimizado para web
flutter build web --release

# Los archivos estarán en: build/web/
```

Luego puedes servir con:
```bash
cd build/web
python -m http.server 8000
```

## Próximas Mejoras Sugeridas

- [ ] Soporte para iOS
- [ ] Modo offline con caché local
- [ ] Notificaciones push
- [ ] Biométricos (huella/Face ID)
- [ ] Modo oscuro
- [ ] Internacionalización (i18n) español/inglés
- [ ] Tests de integración (integration_test)
- [ ] CI/CD con GitHub Actions

## Recursos Adicionales

- [Flutter Docs](https://docs.flutter.dev/)
- [Material Design 3](https://m3.material.io/)
- [Provider Docs](https://pub.dev/packages/provider)
- [FHIR Resources](https://www.hl7.org/fhir/resourcelist.html)
