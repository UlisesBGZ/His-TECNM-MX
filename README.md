# Hospital FHIR System

Sistema completo de gestión hospitalaria basado en **HAPI FHIR 8.6.1** con autenticación**JWT** y aplicación **Flutter** multiplataforma.

[![GitHub](https://img.shields.io/badge/GitHub-UlisesBGZ%2FHis--TECNM--MX-blue)](https://github.com/UlisesBGZ/His--TECNM--MX)
[![License](https://img.shields.io/badge/License-Apache%202.0-green.svg)](LICENSE)

## 🎯 Descripción del Proyecto

Sistema hospitalario completo que combina:
- **Backend**: Servidor FHIR estándar HL7 (HAPI FHIR) con sistema de autenticación JWT personalizado
- **Frontend**: Aplicación Flutter multiplataforma (Web + Android) con UI moderna
- **Base de Datos**: PostgreSQL 16 en Docker

### ¿Qué hace este sistema?

✅ Gestión de **pacientes** (crear, editar, eliminar, buscar)  
✅ Gestión de **médicos** y profesionales de salud  
✅ Gestión de **citas médicas**  
✅ Sistema de **autenticación** con roles (Admin, Usuario)  
✅ API REST estándar **FHIR** (interoperable con otros sistemas de salud)  
✅ Actualización **instantánea** de datos en la interfaz  

## 🚀 Inicio Rápido (Scripts Automáticos)

### Método 1: Iniciar Todo el Sistema

```powershell
.\iniciar-sistema.bat
```

Esto iniciará automáticamente:
1. PostgreSQL en Docker (puerto 5432)
2. Backend Spring Boot (puerto 8080)
3. Frontend Flutter en Chrome

### Método 2: Iniciar Solo Backend (Recomendado para Desarrollo)

```powershell
# Terminal 1: Iniciar backend (mantener abierto)
.\iniciar-backend.bat

# Terminal 2: Cuando quieras abrir el frontend
.\iniciar-frontend.bat
```

**Ventaja**: Puedes cerrar y reabrir el frontend cuantas veces quieras sin afectar el backend.

### Método 3: Detener Todo

```powershell
.\detener-sistema.bat
```

📖 **Guía Completa de Scripts**: Ver [COMO_USAR_SCRIPTS.md](COMO_USAR_SCRIPTS.md)

## 📋 Stack Tecnológico

### Backend
- **Framework**: Spring Boot 3.5.9
- **FHIR Server**: HAPI FHIR 8.6.1
- **Lenguaje**: Java 21.0.10
- **Build**: Maven Wrapper 3.3.2 (incluido, no requiere instalación global)
- **Base de Datos**: PostgreSQL 16 (Docker)
- **Autenticación**: JWT (JJWT 0.12.6) + BCrypt
- **Testing**: JUnit 5 + Mockito (23 tests ✅)

### Frontend
- **Framework**: Flutter 3.27.3 / Dart 3.6.1
- **Diseño**: Material Design 3
- **Estado**: Provider 6.1.2
- **HTTP**: http 1.2.2
- **Testing**: flutter_test + Mockito (25 tests ✅)
- **Plataformas**: Web (Chrome) + Android

### Infraestructura
- **Contenedores**: Docker + Docker Compose
- **Base de Datos**: PostgreSQL 16
- **Control de Versiones**: Git + GitHub

## 📁 Estructura del Proyecto

```
Hospital-FHIR-System/
│
├── iniciar-sistema.bat         # 🚀 Script para iniciar todo
├── iniciar-backend.bat         # 🔨 Script solo backend
├── iniciar-frontend.bat        # 📱 Script solo frontend
├── detener-sistema.bat         # 🛑 Script para detener todo
├── COMO_USAR_SCRIPTS.md        # 📖 Guía de scripts
│
├── backend/                    # ☕ Backend Spring Boot + HAPI FHIR
│   ├── src/
│   │   ├── main/java/ca/uhn/fhir/jpa/starter/
│   │   │   ├── Application.java
│   │   │   └── auth/           # Sistema de autenticación custom
│   │   │       ├── controller/ # API REST endpoints
│   │   │       ├── service/    # Lógica de negocio
│   │   │       ├── repository/ # Acceso a datos (JPA)
│   │   │       ├── model/      # Entidades (User, Role)
│   │   │       └── dto/        # Data Transfer Objects
│   │   └── test/java/          # Tests unitarios (23 tests ✅)
│   ├── docker-compose.yml      # PostgreSQL 16
│   ├── pom.xml                 # Dependencias Maven
│   ├── mvnw.cmd                # Maven Wrapper
│   └── README.md               # 📖 Documentación backend
│
├── frontend/                   # 📱 Frontend Flutter
│   ├── lib/
│   │   ├── main.dart
│   │   ├── config/             # Configuración (URLs dinámicas)
│   │   ├── providers/          # Estado global (Provider)
│   │   ├── services/           # Servicios HTTP (auth, FHIR)
│   │   ├── models/             # Modelos de datos
│   │   └── screens/            # Pantallas UI
│   ├── test/                   # Tests (25 tests ✅)
│   ├── update-ip.ps1           # Script para actualizar IP
│   ├── pubspec.yaml            # Dependencias Flutter
│   └── README.md               # 📖 Documentación frontend
│
└── README.md                   # 📖 Este archivo
```

## 🔐 Credenciales de Desarrollo

### Usuario Admin
- **Usuario**: `admin`
- **Contraseña**: `admin123`

### Base de Datos PostgreSQL
- **Host**: `localhost:5432`
- **Database**: `fhirdb`
- **Usuario**: `admin`
- **Contraseña**: `admin`

⚠️ **Importante**: Cambiar credenciales en producción

## 📡 Endpoints Principales

### Autenticación (`/api/auth`)
- `POST /api/auth/login` - Iniciar sesión
- `POST /api/auth/signup` - Registrar usuario
- `GET /api/auth/validate` - Validar token JWT
- `POST /api/auth/create-admin` - Crear administrador

### Usuarios (`/api/users`) - Solo Admin
- `GET /api/users` - Listar usuarios
- `GET /api/users/{id}` - Obtener usuario
- `DELETE /api/users/{id}` - Eliminar usuario
- `PUT /api/users/{id}/toggle-status` - Habilitar/Deshabilitar

### FHIR (`/fhir`) - Estándar HL7 FHIR R4
- `GET/POST /fhir/Patient` - Gestión de pacientes
- `GET/POST /fhir/Practitioner` - Gestión de médicos
- `GET/POST /fhir/Appointment` - Gestión de citas
- `GET/POST /fhir/Observation` - Gestión de observaciones

## 🧪 Testing

### Backend (Spring Boot)
```powershell
cd backend
.\mvnw.cmd test
```
- **AuthControllerTest**: 12 tests ✅
- **UserControllerTest**: 11 tests ✅
- **Total**: 23 tests pasando

### Frontend (Flutter)
```bash
cd frontend
flutter test
```
- **auth_service_test**: 12 tests ✅
- **fhir_service_test**: 11 tests ✅
- **widget_test**: 2 tests ✅
- **Total**: 25 tests pasando

### Cobertura Total
**48 tests pasando** (100% de tests funcionales) ✅

## ⚙️ Requisitos del Sistema

### Software Necesario

1. **Java 21** o superior
   - Descargar: https://adoptium.net/
   - Verificar: `java -version`

2. **Flutter 3.27.3** o superior
   - Descargar: https://docs.flutter.dev/get-started/install
   - Verificar: `flutter --version`

3. **Docker Desktop**
   - Descargar: https://www.docker.com/products/docker-desktop/
   - Verificar: `docker --version`

4. **Git** (para clonar el repositorio)
   - Descargar: https://git-scm.com/
   - Verificar: `git --version`

**Nota**: Maven NO es necesario (Maven Wrapper está incluido)

### Clonar el Repositorio

```powershell
cd C:\Users\<TU_USUARIO>\Desktop
git clone https://github.com/UlisesBGZ/His-TECNM-MX.git Hospital-FHIR-System
cd Hospital-FHIR-System
```

## 🎨 Características de la Aplicación

### Backend
- ✅ API REST estándar FHIR (interoperable)
- ✅ Autenticación JWT con tokens de 24 horas
- ✅ Hash de contraseñas con BCrypt
- ✅ Roles y permisos (USER, ADMIN, DOCTOR, NURSE)
- ✅ CORS configurado para desarrollo
- ✅ Arquitectura de 3 capas (Controller → Service → Repository)
- ✅ Tests unitarios con mocks

### Frontend
- ✅ Material Design 3 (UI moderna)
- ✅ Configuración dinámica de red (localhost para web, IP para móvil)
- ✅ Actualización instantánea de listas al crear/editar
- ✅ Gestión de estado con Provider
- ✅ Almacenamiento persistente del token (SharedPreferences)
- ✅ Animaciones suaves (FadeIn, SlideTransition)
- ✅ Manejo de errores con SnackBars
- ✅ Búsqueda y filtrado de pacientes/médicos

## 🔧 Configuración Avanzada

### Cambiar Puerto del Backend

Editar `backend/src/main/resources/application.yaml`:
```yaml
server:
  port: 8080  # Cambiar a otro puerto
```

### Configurar IP para Móvil

```powershell
cd frontend
.\update-ip.ps1
```

El script detecta automáticamente tu IP local y actualiza los archivos necesarios.

### Cambiar Secreto JWT

Editar `backend/src/main/resources/application.yaml`:
```yaml
jwt:
  secret: tu-nuevo-secreto-super-seguro  # Cambiar esto
  expiration: 86400000  # 24 horas en ms
```

## 📚 Documentación Adicional

- **[backend/README.md](backend/README.md)** - Documentación completa del backend
- **[frontend/README.md](frontend/README.md)** - Documentación completa del frontend
- **[COMO_USAR_SCRIPTS.md](COMO_USAR_SCRIPTS.md)** - Guía de scripts de inicialización

## 🐛 Troubleshooting

### Error: "Puerto 8080 ya en uso"
```powershell
.\detener-sistema.bat
# O manualmente:
docker stop ehrbase-server
```

### Error: "Backend no responde" en móvil
```powershell
cd frontend
.\update-ip.ps1
flutter clean
flutter run
```

### Error: Docker no inicia
1. Abrir Docker Desktop
2. Esperar a que inicie completamente
3. Ejecutar `docker ps` para verificar

### Los tests fallan
```powershell
# Backend
cd backend
.\mvnw.cmd clean test

# Frontend
cd frontend
flutter clean
flutter test
```

## 🚀 Deploy a Producción

### Backend

```powershell
cd backend
.\mvnw.cmd clean package
# WAR generado en: target/ROOT.war
```

O con Docker:
```powershell
docker build -t hospital-fhir-backend .
docker run -p 8080:8080 hospital-fhir-backend
```

### Frontend

#### Web
```bash
cd frontend
flutter build web --release
# Archivos en: build/web/
```

#### Android
```bash
flutter build apk --release
# APK en: build/app/outputs/flutter-apk/app-release.apk
```

## 🤝 Contribuir

Este es un proyecto académico del TECNM. Para contribuir:

1. Fork el proyecto
2. Crea una rama (`git checkout -b feature/nueva-funcionalidad`)
3. Commit tus cambios (`git commit -m 'Agregar nueva funcionalidad'`)
4. Push a la rama (`git push origin feature/nueva-funcionalidad`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia Apache 2.0. Ver archivo [LICENSE](LICENSE) para más detalles.

## 👨‍💻 Autor

**Ulises BGZ**  
GitHub: [@UlisesBGZ](https://github.com/UlisesBGZ)  
Repositorio: [His-TECNM-MX](https://github.com/UlisesBGZ/His-TECNM-MX)

## 🙏 Agradecimientos

- [HAPI FHIR](https://hapifhir.io/) - Framework FHIR
- [Flutter](https://flutter.dev/) - Framework multiplataforma
- [Spring Boot](https://spring.io/projects/spring-boot) - Framework Java
- [HL7 FHIR](https://www.hl7.org/fhir/) - Estándar de interoperabilidad

---

**Fecha de última actualización**: 11 de Marzo, 2026  
**Versión**: 1.0.0  
**Estado**: ✅ Completamente funcional
