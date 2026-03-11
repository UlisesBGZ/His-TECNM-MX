# Hospital FHIR System

Sistema de gestión hospitalaria basado en HAPI FHIR con autenticación JWT y aplicación Flutter multiplataforma.

## 📁 Estructura del Proyecto

```
Hospital-FHIR-System/
│
├── backend/                      # Backend Spring Boot + HAPI FHIR
│   ├── src/
│   │   └── main/
│   │       ├── java/
│   │       │   └── ca/uhn/fhir/jpa/starter/
│   │       │       ├── Application.java       # Punto de entrada
│   │       │       └── auth/                  # Sistema de autenticación
│   │       │           ├── controller/        # 📥 Endpoints HTTP
│   │       │           │   ├── AuthController.java
│   │       │           │   └── UserController.java
│   │       │           ├── service/           # 💼 Lógica de negocio
│   │       │           │   ├── AuthService.java
│   │       │           │   └── UserService.java
│   │       │           ├── repository/        # 🗄️  Acceso a datos
│   │       │           │   └── UserRepository.java
│   │       │           ├── model/             # 📊 Entidades JPA
│   │       │           │   ├── User.java
│   │       │           │   └── Role.java
│   │       │           ├── dto/               # 📦 Data Transfer Objects
│   │       │           │   ├── LoginRequest.java
│   │       │           │   ├── SignupRequest.java
│   │       │           │   ├── JwtResponse.java
│   │       │           │   └── UserResponse.java
│   │       │           ├── config/            # ⚙️  Configuración
│   │       │           │   └── SecurityConfig.java
│   │       │           └── util/              # 🛠️  Utilidades
│   │       │               └── JwtUtil.java
│   │       └── resources/
│   │           ├── application.yaml           # Configuración principal
│   │           └── init-admin.sql             # Script inicial
│   ├── pom.xml                                # Dependencias Maven
│   ├── docker-compose.yml                     # PostgreSQL container
│   └── README.md                              # Documentación backend
│
├── frontend/                     # Frontend Flutter
│   ├── lib/
│   │   ├── main.dart                          # Punto de entrada
│   │   ├── screens/                           # 📱 Pantallas UI
│   │   │   ├── login_screen.dart
│   │   │   ├── home_screen.dart
│   │   │   ├── patients_screen.dart
│   │   │   └── ...
│   │   ├── services/                          # 🌐 Servicios HTTP
│   │   │   ├── auth_service.dart
│   │   │   └── fhir_service.dart
│   │   ├── models/                            # 📊 Modelos de datos
│   │   │   ├── auth_models.dart
│   │   │   ├── fhir_patient.dart
│   │   │   └── ...
│   │   ├── providers/                         # 🔄 Gestión de estado
│   │   │   └── auth_provider.dart
│   │   └── config/                            # ⚙️  Configuración
│   │       └── api_config.dart
│   ├── pubspec.yaml                           # Dependencias Flutter
│   ├── update-ip.ps1                          # Script actualizar IP
│   └── README.md                              # Documentación frontend
│
└── README.md                     # 📖 Este archivo

```

## 🏗️ Arquitectura del Backend

El backend sigue el patrón **MVC con capa de Servicio**:

```
┌─────────────┐
│  Controller │ ← Maneja peticiones HTTP (validación de entrada, responses)
└──────┬──────┘
       │ usa
┌──────▼──────┐
│   Service   │ ← Contiene lógica de negocio (validaciones, BCrypt, JWT)
└──────┬──────┘
       │ usa
┌──────▼──────┐
│ Repository  │ ← Acceso a base de datos (Spring Data JPA)
└──────┬──────┘
       │
┌──────▼──────┐
│  Database   │ ← PostgreSQL
└─────────────┘
```

### Beneficios de esta arquitectura:

✅ **Separación de responsabilidades**: Cada capa tiene una función clara  
✅ **Testeable**: Fácil crear mocks de Services para tests  
✅ **Mantenible**: Lógica de negocio centralizada en Services  
✅ **Reutilizable**: Services pueden ser usados por múltiples Controllers  
✅ **Limpio**: Controllers solo manejan HTTP, no lógica de negocio

## 🚀 Inicio Rápido

### Prerrequisitos

- **Java 21**+ (verificado: 21.0.10)
- **Maven Wrapper 3.3.2** (incluido, NO requiere instalación global)
- **Flutter 3.27.3**+
- **Docker Desktop** (para PostgreSQL)

### 1. Iniciar Backend

```powershell
cd backend

# Iniciar PostgreSQL
docker-compose up -d

# Iniciar Spring Boot (Maven Wrapper incluido)
.\mvnw.cmd spring-boot:run -Pboot
```

Backend estará en: http://localhost:8080

### 2. Iniciar Frontend

```powershell
cd frontend

# Web (Chrome)
flutter run -d chrome

# Android (emulador o dispositivo)
# Primero actualizar IP de red:
.\update-ip.ps1
flutter run
```

## 📡 Endpoints Principales

### Autenticación (`/api/auth`)

- `POST /api/auth/login` - Login de usuario
- `POST /api/auth/signup` - Registro de nuevo usuario
- `POST /api/auth/create-admin` - Crear admin
- `GET /api/auth/validate` - Validar token JWT

### Usuarios (`/api/users`) - Requiere rol ADMIN

- `GET /api/users` - Listar usuarios
- `GET /api/users/{id}` - Obtener usuario
- `DELETE /api/users/{id}` - Eliminar usuario
- `PUT /api/users/{id}/toggle-status` - Habilitar/deshabilitar

### FHIR (`/fhir`)

- `GET /fhir/Patient` - Listar pacientes
- `GET /fhir/Practitioner` - Listar médicos
- `GET /fhir/Appointment` - Listar citas
- `GET /fhir/Observation` - Listar observaciones

## 🔐 Credenciales de Desarrollo

**Usuario Admin**:
- Username: `admin`
- Password: `admin123`

**Base de Datos**:
- Host: `localhost:5432`
- Database: `fhirdb`
- Usuario: `admin`
- Password: `admin`

⚠️ **Cambiar en producción**

## 🧪 Ejecutar Tests

### Backend
```powershell
cd backend
.\mvnw.cmd test
# 23 tests: AuthControllerTest (12) + UserControllerTest (11)
```

### Frontend
```powershell
cd frontend
flutter test
# 25 tests: auth_service (12) + fhir_service (11) + widgets (2)
```

## 📚 Documentación Adicional

- [Backend README](backend/README.md) - Detalles del backend
- [Frontend README](frontend/README.md) - Detalles del frontend
- [CONTEXTO_PARA_NUEVA_SESION.md](backend/CONTEXTO_PARA_NUEVA_SESION.md) - Contexto técnico completo
- [DESARROLLO_COMPLETO.md](backend/DESARROLLO_COMPLETO.md) - Historia del desarrollo

## 🛠️ Stack Tecnológico

### Backend
- **Framework**: Spring Boot 3.5.9
- **FHIR**: HAPI FHIR 8.6.1
- **Java**: 21.0.10
- **Build**: Maven Wrapper 3.3.2
- **Base de Datos**: PostgreSQL 16
- **Autenticación**: JWT (JJWT 0.12.6) + BCrypt
- **Testing**: JUnit 5 + Mockito

### Frontend
- **Framework**: Flutter 3.27.3
- **Lenguaje**: Dart 3.6.1
- **UI**: Material Design 3
- **HTTP**: http 1.1.0
- **Estado**: Provider 6.1.1
- **Testing**: flutter_test + Mockito

## 🌐 Configuración de Red

El frontend usa configuración dinámica:

- **Web**: `http://localhost:8080` (automático)
- **Móvil**: `http://[TU_IP]:8080` (ejecutar `update-ip.ps1`)

Archivo: `frontend/lib/config/api_config.dart`

## 🔄 Migraciones desde Proyecto Anterior

Si vienes del proyecto `HapiFhir-Springboot`, estos son los cambios principales:

### ✅ Completado:

1. **Separación de carpetas**:
   - Backend: Ahora en `Hospital-FHIR-System/backend/`
   - Frontend: Ahora en `Hospital-FHIR-System/frontend/`

2. **Capa de Service agregada**:
   - `AuthService.java` - Lógica de autenticación
   - `UserService.java` - Lógica de gestión de usuarios

3. **Controllers refactorizados**:
   - `AuthController` - Solo maneja HTTP, usa AuthService
   - `UserController` - Solo maneja HTTP, usa UserService

### 📍 Sin cambios:

- **Los endpoints siguen iguales** - No necesitas modificar el frontend
- **Base de datos igual** - Misma configuración PostgreSQL
- **Credenciales iguales** - Para facilitar desarrollo

## 📞 Soporte y Contribución

Para preguntas o problemas, consultar la documentación en `backend/` o `frontend/`.

---

**Última actualización**: Marzo 11, 2026  
**Versión**: 2.0.0 (Arquitectura reorganizada)
