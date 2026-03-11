# Backend - Sistema Hospitalario FHIR

Backend basado en **HAPI FHIR 8.6.1** con sistema de autenticación JWT personalizado.

## Stack Tecnológico

- **Framework**: Spring Boot 3.5.9
- **FHIR Server**: HAPI FHIR 8.6.1
- **Java**: 21.0.10 (mínimo 17)
- **Build Tool**: Maven Wrapper 3.3.2 (incluido, NO requiere instalación global)
- **Base de Datos**: PostgreSQL 16 (Docker)
- **Autenticación**: JWT (JJWT 0.12.6) + BCrypt
- **Testing**: JUnit 5 + Mockito

## Arquitectura (3 Capas)

```
┌─────────────┐
│  Controller │ ← Endpoints HTTP REST (/api/auth, /api/users, /fhir)
└──────┬──────┘
       │
┌──────▼──────┐
│   Service   │ ← Lógica de negocio, validaciones, BCrypt, JWT
└──────┬──────┘
       │
┌──────▼──────┐
│ Repository  │ ← Spring Data JPA (acceso a PostgreSQL)
└──────┬──────┘
       │
┌──────▼──────┐
│  PostgreSQL │ ← Base de datos (Docker)
└─────────────┘
```

## Estructura del Código

```
backend/
├── src/main/java/ca/uhn/fhir/jpa/starter/
│   ├── Application.java                    # Entry point
│   └── auth/                                # Sistema de autenticación custom
│       ├── controller/
│       │   ├── AuthController.java         # POST /api/auth/login, /signup, /validate
│       │   └── UserController.java         # GET/PUT/DELETE /api/users/*
│       ├── service/
│       │   ├── AuthService.java            # Lógica JWT, BCrypt, validaciones
│       │   └── UserService.java            # CRUD usuarios, toggle status
│       ├── repository/
│       │   └── UserRepository.java         # Spring Data JPA
│       ├── model/
│       │   ├── User.java                   # Entidad JPA
│       │   └── Role.java                   # Enum: USER, ADMIN, DOCTOR, NURSE
│       ├── dto/
│       │   ├── LoginRequest.java
│       │   ├── SignupRequest.java
│       │   ├── JwtResponse.java
│       │   └── UserResponse.java
│       ├── config/
│       │   └── SecurityConfig.java         # CORS y configuración
│       └── util/
│           └── JwtUtil.java                # Generación y validación JWT
│
├── src/test/java/.../auth/
│   ├── AuthControllerTest.java            # 12 tests ✅
│   └── UserController Test.java            # 11 tests ✅
│
├── src/main/resources/
│   ├── application.yaml                    # Configuración principal
│   └── init-admin.sql                      # Usuario admin inicial
│
├── docker-compose.yml                      # PostgreSQL 16
├── pom.xml                                 # Dependencias Maven
├── mvnw.cmd                                # Maven Wrapper (Windows)
└── .mvn/wrapper/
    └── maven-wrapper.jar                   # JAR del wrapper (incluido)
```

## Inicio Rápido

### 1. Iniciar Base de Datos

```powershell
cd backend
docker-compose up -d
```

Esto inicia PostgreSQL 16 en el puerto **5432**:
- Database: `fhirdb`
- Usuario: `admin`
- Contraseña: `admin`

### 2. Iniciar Backend

```powershell
cd backend
.\mvnw.cmd spring-boot:run -Pboot
```

El servidor estará disponible en: **http://localhost:8080**

### 3. Verificar que Funciona

```powershell
# Probar endpoint FHIR
curl http://localhost:8080/fhir/metadata

# Probar autenticación (debe dar error sin token)
curl http://localhost:8080/api/auth/validate
```

## API Endpoints

### Autenticación (`/api/auth`)

#### POST `/api/auth/login` - Iniciar sesión
```json
{
  "username": "admin",
  "password": "admin123"
}
```
**Respuesta:**
```json
{
  "token": "eyJhbGciOiJIUzUxMiJ9...",
  "type": "Bearer",
  "username": "admin",
  "email": "admin@hospital.com",
  "roles": ["ADMIN", "USER"]
}
```

#### POST `/api/auth/signup` - Registrar usuario
```json
{
  "username": "doctor1",
  "email": "doctor1@hospital.com",
  "password": "password123",
  "firstName": "Juan",
  "lastName": "Pérez",
  "isAdmin": false
}
```

#### GET `/api/auth/validate` - Validar token
**Headers:** `Authorization: Bearer <token>`

#### POST `/api/auth/create-admin` - Crear administrador
Crea usuario con rol ADMIN.

### Gestión de Usuarios (`/api/users`) - Solo ADMIN

#### GET `/api/users` - Listar todos los usuarios
**Headers:** `Authorization: Bearer <admin-token>`

#### GET `/api/users/{id}` - Obtener usuario por ID

#### DELETE `/api/users/{id}` - Eliminar usuario

#### PUT `/api/users/{id}/toggle-status` - Habilitar/Deshabilitar usuario

### FHIR Resources (`/fhir`)

- `GET /fhir/Patient` - Listar pacientes
- `GET /fhir/Patient/{id}` - Obtener paciente
- `POST /fhir/Patient` - Crear paciente
- `PUT /fhir/Patient/{id}` - Actualizar paciente
- `DELETE /fhir/Patient/{id}` - Eliminar paciente

*(Igual para Practitioner, Observation, Appointment, etc.)*

## Testing

### Ejecutar Todos los Tests

```powershell
.\mvnw.cmd test
```

**Tests disponibles:**
- **AuthControllerTest**: 12 tests (login, signup, validación, etc.)
- **UserControllerTest**: 11 tests (CRUD, permisos, toggle status)
- **Total**: 23 tests pasando ✅

### Ejecutar Tests Específicos

```powershell
# Solo tests de autenticación
.\mvnw.cmd test -Dtest=AuthControllerTest

# Solo tests de usuarios
.\mvnw.cmd test -Dtest=UserControllerTest
```

## Configuración

### Variables de Entorno

Editar `src/main/resources/application.yaml`:

```yaml
spring:
  datasource:
    url: jdbc:postgresql://localhost:5432/fhirdb
    username: admin
    password: admin   # ⚠️ Cambiar en producción
  
  jpa:
    hibernate:
      ddl-auto: update   # Crea/actualiza tablas automáticamente

jwt:
  secret: tu-secreto-jwt-super-seguro   # ⚠️ Cambiar en producción
  expiration: 86400000  # 24 horas

server:
  port: 8080
```

### Usuario Admin Inicial

Al iniciar por primera vez, se crea automáticamente:
- **Username**: `admin`
- **Password**: `admin123`
- **Roles**: ADMIN, USER

**Script**: `src/main/resources/init-admin.sql`

## Características de Seguridad

### JWT (JSON Web Tokens)
- Generación de tokens con JJWT 0.12.6
- Expiración configurable (por defecto 24 horas)
- Firma con HS512

### Hash de Contraseñas
- BCrypt con salt automático
- Nunca se almacenan contraseñas en texto plano

### CORS
- Configurado para permitir `http://localhost:*` (desarrollo)
- Ajustar en producción en `SecurityConfig.java`

### Autorización
- Endpoints de usuario requieren token JWT válido
- Endpoints de administración requieren rol `ADMIN`
- Validación automática en cada request

## Troubleshooting

### Error: "Puerto 8080 ya en uso"
```powershell
# Ver qué proceso usa el puerto
netstat -ano | Select-String ":8080"

# Detener proceso (reemplazar PID)
Stop-Process -Id <PID> -Force

# O usar el script de iniciación que lo hace automáticamente
cd ..
.\iniciar-backend.bat
```

### Error: "Connection refused to PostgreSQL"
```powershell
# Verificar si PostgreSQL está corriendo
docker ps | Select-String "postgres"

# Si no está corriendo, iniciarlo
cd backend
docker-compose up -d

# Ver logs si hay problemas
docker logs hapi-fhir-postgres
```

### Error: Tests fallan
```powershell
# Limpiar y recompilar
.\mvnw.cmd clean test

# Ver logs detallados
.\mvnw.cmd test -X
```

### Error: "Maven Wrapper not found"
Los archivos `mvnw.cmd` y `.mvn/wrapper/maven-wrapper.jar` están incluidos en el repositorio. Si faltan:
```powershell
git restore mvnw.cmd .mvn/
```

## Build para Producción

### Crear WAR

```powershell
.\mvnw.cmd clean package
```

El archivo se genera en: `target/ROOT.war`

### Crear Imagen Docker

```powershell
docker build -t hospital-fhir-backend .
docker run -p 8080:8080 hospital-fhir-backend
```

## Tecnologías y Librerías

- **HAPI FHIR**: Framework FHIR para Java
- **Spring Boot**: Framework web y DI
- **Spring Data JPA**: ORM y acceso a datos
- **PostgreSQL**: Base de datos relacional
- **JJWT**: Librería JWT para Java
- **BCrypt**: Hash de contraseñas
- **Lombok**: Reducción de boilerplate
- **JUnit 5**: Testing
- **Mockito**: Mocking para tests

## Documentación Adicional

- [HAPI FHIR Docs](https://hapifhir.io/hapi-fhir/docs/)
- [FHIR Spec](https://www.hl7.org/fhir/)
- [Spring Boot Docs](https://docs.spring.io/spring-boot/docs/current/reference/html/)

## Licencia

Ver archivo LICENSE en la raíz del proyecto.
